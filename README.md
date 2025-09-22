Comprehensive Dune Analytics SQL infrastructure
This repository contains the complete SQL infrastructure for on-chain analysis:

📊 OCM_Hub Tool Endpoints:
• Alpha_wallets_labeled.sql - Proprietary alpha trader identification with multi-layered filtering
• heatmap_endpoint_all.sql - 24h pattern detection across all alpha traders
• heatmap_endpoint_elite.sql - Elite trader subset analysis excluding 'Other' category
• whales_query.sql - Comprehensive whale analysis with behavioral classification

🔬 R Framework Dataset Generation:
• insider_flows_query.sql - Trading flow analysis for insider wallets
• insider_supply_timeline.sql - Historical insider supply tracking
• late_buyer_financial_metrics.sql - Late buyer clustering analysis
• token_price_history.sql - Market cap calculations with supply data

⚙️ Materialized Views & Infrastructure:
• benchmark.sql - Performance benchmarking queries
• early_holders_with_transfers.sql - Legacy whale analysis

Features advanced SQL techniques:
- Window functions with LAG/LEAD operations
- Recursive CTEs and percentile aggregations
- Coefficient of variation analysis for bot filtering
- Temporal grouping for spike pattern identification
- Honeypot detection algorithms
