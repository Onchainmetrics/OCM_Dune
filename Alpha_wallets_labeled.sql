 WITH
  -- STEP 1: Pre-filter trades (exclude meteora)
  base_filtered_trades AS (
      SELECT
          trader_id as wallet,
          block_time,
          CASE
              WHEN token_sold_mint_address IN ('So11111111111111111111111111111111111111112', 'EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v', 'Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB')
              THEN token_bought_mint_address ELSE token_sold_mint_address
          END as token_address,
          CASE
              WHEN token_sold_mint_address IN ('So11111111111111111111111111111111111111112', 'EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v', 'Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB')
              THEN 'buy' ELSE 'sell'
          END as trade_type,
          amount_usd,
          ABS(amount_usd) as abs_amount,
          project
      FROM dex_solana.trades
      WHERE
          block_time >= NOW() - INTERVAL '30' DAY
          AND project IN ('raydium', 'raydium_launchlab', 'pumpdotfun', 'pumpswap')  -- Excluded meteora
          AND trader_id NOT IN (SELECT address FROM dune.latecapdao.result_mev_suspects_matview WHERE address IS NOT NULL)
          AND amount_usd != 0
          AND ABS(amount_usd) BETWEEN 1 AND 50000
  ),

  -- STEP 2: Much stricter token quality filtering
  token_quality AS (
      SELECT
          token_address,
          COUNT(DISTINCT wallet) as unique_traders,
          SUM(abs_amount) as total_volume,
          COUNT(*) as total_trades,
          MAX(CASE WHEN project IN ('pumpdotfun', 'pumpswap') THEN 1 ELSE 0 END) as is_pump_token,
          -- Seller ratio - honeypots have very few sellers
          COUNT(DISTINCT CASE WHEN trade_type = 'sell' THEN wallet END) * 1.0 /
              NULLIF(COUNT(DISTINCT CASE WHEN trade_type = 'buy' THEN wallet END), 0) as seller_ratio,
          -- Additional scam detection: check for concentrated trading
          MAX(daily_traders) * 1.0 / AVG(daily_traders) as trader_concentration_ratio
      FROM (
          SELECT
              token_address, wallet, abs_amount, project, trade_type,
              COUNT(DISTINCT wallet) OVER (PARTITION BY token_address, DATE(block_time)) as daily_traders
          FROM base_filtered_trades
      ) t
      GROUP BY token_address
      HAVING
          -- MUCH stricter quality requirements
          COUNT(DISTINCT wallet) >= 500 AND  -- 500 unique traders minimum
          SUM(abs_amount) >= 5000000 AND     -- $5M total volume minimum
          COUNT(*) >= 4000 AND               -- 4000 trades minimum
          -- Honeypot detection - healthy tokens should have many sellers
          COUNT(DISTINCT CASE WHEN trade_type = 'sell' THEN wallet END) * 1.0 /
              NULLIF(COUNT(DISTINCT CASE WHEN trade_type = 'buy' THEN wallet END), 0) >= 0.4 AND -- At least 50% of buyers also sell
          -- Volume per trader sanity check (much stricter)
          SUM(abs_amount) / COUNT(DISTINCT wallet) <= 15000 AND  -- Max $15k average per trader
          -- Trader concentration check - avoid tokens with suspicious trading patterns
          MAX(daily_traders) * 1.0 / NULLIF(AVG(daily_traders), 0) <= 5  -- Max 5x daily trader concentration
  ),

  -- STEP 3: Fixed spike detection with proper grouping
  daily_volumes AS (
      SELECT
          bft.token_address,
          DATE(bft.block_time) as trade_date,
          SUM(bft.abs_amount) as daily_volume,
          COUNT(DISTINCT bft.wallet) as daily_traders
      FROM base_filtered_trades bft
      INNER JOIN token_quality tq ON bft.token_address = tq.token_address
      GROUP BY bft.token_address, DATE(bft.block_time)
  ),

  token_spikes AS (
      SELECT
          token_address,
          AVG(daily_volume) as avg_daily_volume,
          MAX(daily_volume) as max_daily_volume,
          MAX(daily_volume) / NULLIF(AVG(daily_volume), 0) as spike_ratio,
          COUNT(*) as active_days
      FROM daily_volumes
      GROUP BY token_address
      HAVING
          COUNT(*) >= 5  -- At least 5 days of activity
          AND MAX(daily_volume) / NULLIF(AVG(daily_volume), 0) > 7  -- At least 7x spike
          AND AVG(daily_volume) >= 100000  -- Meaningful base volume
  ),

  -- STEP 4: Much stricter wallet filtering
  wallet_basics AS (
      SELECT
          bft.wallet,
          COUNT(*) as total_trades,
          COUNT(DISTINCT bft.token_address) as unique_tokens,
          COUNT(DISTINCT DATE(bft.block_time)) as active_days,
          MAX(bft.block_time) as last_trade,
          -- Enhanced bot detection
          STDDEV(bft.abs_amount) / NULLIF(AVG(bft.abs_amount), 0) as amount_cv,
          COUNT(DISTINCT ROUND(bft.abs_amount, 0)) * 1.0 / COUNT(*) as position_variance,
          -- Profit per token ratio (high ratios suggest fake tokens)
          SUM(CASE WHEN bft.trade_type = 'sell' THEN bft.amount_usd ELSE -bft.amount_usd END) /
              NULLIF(COUNT(DISTINCT bft.token_address), 0) as profit_per_token,
          -- Time spread check - avoid wallets with concentrated trading periods
          DATE_DIFF('day', MIN(DATE(bft.block_time)), MAX(DATE(bft.block_time))) as trading_span_days
      FROM base_filtered_trades bft
      INNER JOIN token_quality tq ON bft.token_address = tq.token_address
      GROUP BY bft.wallet
      HAVING
          COUNT(*) BETWEEN 15 AND 500  -- Reasonable range
          AND COUNT(DISTINCT bft.token_address) >= 5  -- More diversification
          AND COUNT(DISTINCT DATE(bft.block_time)) >= 5  -- Active multiple days
          -- Bot filters (stricter)
          AND STDDEV(bft.abs_amount) / NULLIF(AVG(bft.abs_amount), 0) > 0.6
          AND COUNT(DISTINCT ROUND(bft.abs_amount, 0)) * 1.0 / COUNT(*) > 0.3
          -- Sanity checks
          AND ABS(SUM(CASE WHEN bft.trade_type = 'sell' THEN bft.amount_usd ELSE -bft.amount_usd END) /
              NULLIF(COUNT(DISTINCT bft.token_address), 0)) <= 1000000  -- Max $1M profit per token
          AND DATE_DIFF('day', MIN(DATE(bft.block_time)), MAX(DATE(bft.block_time))) >= 3  -- At least 3 days trading span
  ),

  -- STEP 5: Token performance with correct insider detection
  token_performance AS (
      SELECT
          bft.wallet,
          bft.token_address,
          MIN(CASE WHEN bft.trade_type = 'buy' THEN bft.block_time END) as first_buy,
          MAX(CASE WHEN bft.trade_type = 'sell' THEN bft.block_time END) as last_sell,
          SUM(CASE WHEN bft.trade_type = 'buy' THEN bft.amount_usd ELSE 0 END) as total_bought,
          SUM(CASE WHEN bft.trade_type = 'sell' THEN bft.amount_usd ELSE 0 END) as total_sold,
          -- Fixed insider indicators
          CASE WHEN ts.spike_ratio > 7 THEN 1 ELSE 0 END as had_volume_spike,
          COALESCE(ts.spike_ratio, 0) as spike_ratio
      FROM base_filtered_trades bft
      INNER JOIN wallet_basics wb ON bft.wallet = wb.wallet
      INNER JOIN token_quality tq ON bft.token_address = tq.token_address
      LEFT JOIN token_spikes ts ON bft.token_address = ts.token_address
      GROUP BY bft.wallet, bft.token_address, ts.spike_ratio
  ),

  -- STEP 6: Much more conservative performance metrics
  wallet_performance AS (
      SELECT
          wallet,
          COUNT(*) as token_count,
          -- Win rate with $500 minimum profit to count as win, but cap win rate at 95% (perfect win rates are suspicious)
          LEAST(
              COUNT(CASE WHEN total_sold - total_bought > 500 THEN 1 END) * 100.0 /
                  NULLIF(COUNT(CASE WHEN total_sold > 0 AND ABS(total_sold - total_bought) > 100 THEN 1 END), 0),
              95.0
          ) as win_rate,

          -- Much more conservative profit capping
          LEAST(SUM(total_sold - total_bought), 3000000) as total_pnl,
          AVG(total_bought) as avg_position_size,

          -- Insider detection
          COUNT(CASE WHEN had_volume_spike = 1 THEN 1 END) as spike_tokens_traded,
          COUNT(CASE WHEN had_volume_spike = 1 AND total_sold - total_bought > total_bought * 3 THEN 1 END) as massive_wins,
          AVG(CASE WHEN had_volume_spike = 1 THEN spike_ratio ELSE NULL END) as avg_spike_ratio
      FROM token_performance
      GROUP BY wallet
      HAVING
          -- Much higher minimum total profits
          LEAST(SUM(total_sold - total_bought), 3000000) > 75000  -- $75k minimum
          AND COUNT(CASE WHEN total_sold > 0 THEN 1 END) >= 5  -- At least 5 closed positions
          AND AVG(total_bought) <= 25000  -- Realistic position sizes
  ),

  -- STEP 7: More conservative classification
  final_classification AS (
      SELECT
          wb.wallet,
          wb.total_trades,
          wb.unique_tokens,
          wb.last_trade,
          wp.win_rate,
          wp.total_pnl,
          wp.avg_position_size,
          wb.total_trades / 30.0 as trades_per_day,
          wp.spike_tokens_traded,
          wp.massive_wins,
          wp.avg_spike_ratio,

          -- Much more conservative classification
          CASE
              -- INSIDERS: Clear spike trading pattern (lower threshold as it's harder to detect)
              WHEN wp.spike_tokens_traded >= 2
                  AND wp.massive_wins >= 1
                  AND wp.avg_spike_ratio >= 10
                  AND wp.win_rate >= 65
                  AND wp.total_pnl >= 50000
              THEN 'Insider'

              -- ALPHA TRADERS: Great performance + must have traded spike tokens
              WHEN wp.win_rate BETWEEN 75 AND 90
              AND wp.total_pnl BETWEEN 150000 AND 2000000
              AND wb.unique_tokens >= 10
              AND wb.total_trades >= 40
              AND wp.avg_position_size <= 20000
              AND wb.total_trades / 30.0 <= 10
              AND (wp.spike_tokens_traded > 0 OR wp.avg_spike_ratio > 0)  -- Must have spike activity
              THEN 'Alpha Trader'

              -- VOLUME LEADERS: Active but not suspicious
              WHEN wp.win_rate BETWEEN 65 AND 85
                  AND wb.total_trades >= 60
                  AND wb.unique_tokens >= 15
                  AND wp.total_pnl >= 100000
                  AND wb.total_trades / 30.0 BETWEEN 3 AND 15
                  AND (wp.spike_tokens_traded > 0 OR wp.avg_spike_ratio > 0)  -- Must have spike activity
              THEN 'Volume Leader'

              -- CONSISTENT PERFORMERS: Reliable and realistic
              WHEN wp.win_rate BETWEEN 70 AND 88
                  AND wp.total_pnl BETWEEN 75000 AND 800000
                  AND wb.unique_tokens >= 8
                  AND wb.total_trades / 30.0 <= 8
                  AND (wp.spike_tokens_traded > 0 OR wp.avg_spike_ratio > 0)  -- Must have spike activity
              THEN 'Consistent Performer'

              ELSE 'Other'
          END as trader_type
      FROM wallet_basics wb
      INNER JOIN wallet_performance wp ON wb.wallet = wp.wallet
  )

  SELECT
      wallet,
      trader_type,
      ROUND(total_pnl, 2) as total_profits,
      ROUND(win_rate, 1) as win_rate,
      ROUND(trades_per_day, 2) as trades_per_day,
      unique_tokens,
      total_trades,
      spike_tokens_traded,
      massive_wins,
      ROUND(COALESCE(avg_spike_ratio, 0), 1) as avg_spike_ratio,
      last_trade
  FROM final_classification
  WHERE trader_type != 'Other'
  ORDER BY
      CASE trader_type WHEN 'Insider' THEN 1 WHEN 'Alpha Trader' THEN 2 WHEN 'Volume Leader' THEN 3 ELSE 4 END,
      total_profits DESC
  LIMIT 400;