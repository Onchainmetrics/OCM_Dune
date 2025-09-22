# OCM_Dune - Advanced On-Chain SQL Analytics Infrastructure

This Repo was made public temporarily

[![SQL](https://img.shields.io/badge/SQL-Advanced-blue.svg)](https://www.postgresql.org/)
[![Dune Analytics](https://img.shields.io/badge/Dune-Analytics-orange.svg)](https://dune.com)


Comprehensive SQL infrastructure powering advanced cryptocurrency market analysis. This repository contains the complete data layer for on-chain intelligence, featuring proprietary alpha trader identification, real-time market analysis endpoints, and sophisticated statistical modeling queries.

## 🏗️ Repository Structure

### 📊 OCM_Hub Platform Endpoints
Interactive command endpoints for real-time cryptocurrency intelligence platform:

- **`Alpha_wallets_labeled.sql`** - Proprietary alpha trader identification with multi-layered filtering
- **`heatmap_endpoint_all.sql`** - 24h pattern detection across all alpha traders with flow analysis
- **`heatmap_endpoint_elite.sql`** - Elite trader subset analysis excluding 'Other' category
- **`whales_query.sql`** - Comprehensive whale analysis with behavioral classification and PnL metrics

### 🔬 R Framework Dataset Generation
Parametrized queries for statistical analysis and clustering algorithms:

- **`insider_flows_query.sql`** - Trading flow analysis for insider wallet networks
- **`insider_supply_timeline.sql`** - Historical insider supply tracking with market cap correlation
- **`late_buyer_financial_metrics.sql`** - Late buyer clustering analysis with financial classification
- **`token_price_history.sql`** - Market cap calculations with supply metadata integration

### ⚙️ Infrastructure & Analytics
System infrastructure and benchmarking queries:

- **`benchmark.sql`** - Performance benchmarking and query optimization analysis
- **`early_holders_with_transfers.sql`** - Legacy whale analysis with transfer pattern detection

