WITH time_windows AS (
    SELECT 
        NOW() - INTERVAL '1' hour as hour_1,
        NOW() - INTERVAL '4' hour as hour_4,
        NOW() - INTERVAL '24' hour as hour_24
),

alpha_wallets AS (
    SELECT wallet 
    FROM dune.latecapdao.result_alfa_wallets_labeled
    WHERE trader_type != 'Other'
),

token_meta AS (
    SELECT token_address, symbol, total_supply
    FROM dune.latecapdao.result_metadata_matview
    WHERE token_address != 'So11111111111111111111111111111111111111112'),

-- First get all trades
alpha_trades AS (
    SELECT 
        t.block_time,
        t.token_bought_mint_address as token_address,
        t.token_bought_amount as amount,
        t.amount_usd as usd_amount,
        t.trader_id as wallet,
        'buy' as action,
        (t.amount_usd / NULLIF(t.token_bought_amount, 0)) * tm.total_supply as implied_mcap_at_entry
    FROM dex_solana.trades t
    JOIN alpha_wallets a ON t.trader_id = a.wallet
    JOIN token_meta tm ON t.token_bought_mint_address = tm.token_address
    WHERE t.block_time >= (SELECT hour_24 FROM time_windows)
    AND t.token_bought_mint_address != 'So11111111111111111111111111111111111111112'
    
    UNION ALL
    
    SELECT 
        t.block_time,
        t.token_sold_mint_address as token_address,
        -t.token_sold_amount as amount,
        -t.amount_usd as usd_amount,
        t.trader_id as wallet,
        'sell' as action,
        (t.amount_usd / NULLIF(t.token_sold_amount, 0)) * tm.total_supply as implied_mcap_at_entry
    FROM dex_solana.trades t
    JOIN alpha_wallets a ON t.trader_id = a.wallet
    JOIN token_meta tm ON t.token_sold_mint_address = tm.token_address
    WHERE t.block_time >= (SELECT hour_24 FROM time_windows)
    AND t.token_sold_mint_address != 'So11111111111111111111111111111111111111112' 
),

-- Calculate all flows first, regardless of current holdings
all_flows AS (
    SELECT 
        token_address,
        wallet,
        -- Calculate flows for all traders
        SUM(CASE 
            WHEN block_time >= (SELECT hour_1 FROM time_windows)
            THEN usd_amount ELSE 0 
        END) as flow_1h,
        SUM(CASE 
            WHEN block_time >= (SELECT hour_4 FROM time_windows)
            THEN usd_amount ELSE 0 
        END) as flow_4h,
        SUM(usd_amount) as flow_24h,
        -- Count trades
        COUNT(CASE 
            WHEN block_time >= (SELECT hour_1 FROM time_windows)
            AND action = 'buy' THEN 1 
        END) as buys_1h,
        COUNT(CASE 
            WHEN block_time >= (SELECT hour_1 FROM time_windows)
            AND action = 'sell' THEN 1 
        END) as sells_1h,
        MAX(block_time) as last_trade
    FROM alpha_trades
    GROUP BY token_address, wallet
),

-- Separately calculate current holdings
current_holdings AS (
    SELECT 
        token_address,
        wallet,
        SUM(amount) as token_amount,
        SUM(usd_amount) as net_value
    FROM alpha_trades
    GROUP BY token_address, wallet
    HAVING SUM(amount) > 0  -- Only include positive holdings
    AND SUM(usd_amount) >= 500  -- Minimum $500 value
),

-- Calculate average implied market cap at entry per token with outlier protection
token_mcap_basis AS (
    WITH trade_stats AS (
        SELECT 
            token_address,
            approx_percentile(implied_mcap_at_entry, 0.5) as median_mcap,
            avg(implied_mcap_at_entry) as mean_mcap,
            stddev(implied_mcap_at_entry) as stddev_mcap
        FROM alpha_trades
        WHERE action = 'buy'  -- Only consider buys for entry mcap
        AND implied_mcap_at_entry > 0  -- Ensure we only consider valid prices
        GROUP BY token_address
    )
    SELECT 
        token_address,
        median_mcap as avg_mcap_at_entry
    FROM trade_stats
)

-- Final aggregation
SELECT 
    tm.symbol,
    af.token_address,
    COUNT(DISTINCT ch.wallet) as active_alphas,  -- Count of wallets still holding
    
    -- Net flows by timeframe (from all traders, including those who exited)
    SUM(af.flow_1h) as flow_1h,
    SUM(af.flow_4h) as flow_4h,
    SUM(af.flow_24h) as flow_24h,
    
    -- Count of trades by timeframe
    SUM(af.buys_1h) as buys_1h,
    SUM(af.sells_1h) as sells_1h,
    -- Most recent activity
    MAX(af.last_trade) as last_trade,
    
    -- Unique wallets by action in 1h
    COUNT(DISTINCT CASE WHEN af.buys_1h > 0 THEN af.wallet END) as unique_buyers_1h,
    COUNT(DISTINCT CASE WHEN af.sells_1h > 0 THEN af.wallet END) as unique_sellers_1h,

    -- Current holders array and market cap at entry
    ARRAY_AGG(DISTINCT COALESCE(ch.wallet, af.wallet)) as involved_wallets,
    tmb.avg_mcap_at_entry,
    
    -- Total value still held
    SUM(COALESCE(ch.net_value, 0)) as total_held_value

FROM all_flows af
JOIN token_meta tm ON af.token_address = tm.token_address
LEFT JOIN current_holdings ch ON af.token_address = ch.token_address AND af.wallet = ch.wallet
LEFT JOIN token_mcap_basis tmb ON af.token_address = tmb.token_address
GROUP BY tm.symbol, af.token_address, tmb.avg_mcap_at_entry
HAVING SUM(ABS(af.flow_24h)) > 500  -- Filter for meaningful activity
ORDER BY COUNT(DISTINCT ch.wallet) DESC, ABS(SUM(af.flow_24h)) DESC 
LIMIT 200