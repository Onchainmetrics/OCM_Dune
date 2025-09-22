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

## 🚀 Advanced SQL Techniques

### Statistical Analysis Methods
- **Window Functions**: LAG/LEAD operations for price sensitivity and temporal analysis
- **Percentile Aggregations**: Outlier-resistant market cap calculations using APPROX_PERCENTILE
- **Coefficient of Variation**: Advanced bot filtering using position variance analysis
- **Correlation Analysis**: Price sensitivity detection with CORR functions

### Performance Optimizations
- **Recursive CTEs**: Complex hierarchical data processing for wallet relationship mapping
- **Cross Joins**: Complete address matrices ensuring comprehensive daily snapshots
- **Materialized Views**: Pre-computed datasets for high-frequency query optimization
- **Parametrized Queries**: Dynamic analysis capabilities with user-defined inputs

### Data Quality Assurance
- **Honeypot Detection**: Multi-criteria filtering for scam token identification
- **Bot Filtering**: Statistical variance analysis to exclude automated trading patterns
- **MEV Protection**: Exclusion of MEV suspect addresses from analysis datasets
- **Volume Validation**: Spike pattern identification with 7x threshold requirements

## 📈 Alpha Trader Classification System

### Multi-Tier Performance Analysis
Our proprietary classification system uses advanced statistical methods to identify and categorize high-performance cryptocurrency traders:

**Insider Detection**
- Clear spike trading patterns with 2+ spike tokens traded
- Massive win requirements (1+ wins with 3x+ returns)
- Average spike ratio ≥10x with 65%+ win rates
- Minimum $50k total performance threshold

**Alpha Trader Identification**
- Win rates between 75-90% with realistic performance caps
- $150k-$2M total PnL range with position size validation
- Minimum 10 unique tokens traded with 40+ total trades
- Required spike activity participation for authenticity

**Volume Leader Classification**
- High-frequency trading with 60+ trades and 15+ unique tokens
- Win rates between 65-85% with $100k+ minimum performance
- Active trading patterns (3-15 trades per day average)
- Diversified portfolio requirements for risk management

## 🔍 Market Intelligence Capabilities

### Real-Time Flow Analysis
- **Multi-Timeframe Windows**: 1h/4h/24h analysis with USD-denominated calculations
- **Holder Tracking**: Current position monitoring with minimum value thresholds ($500+)
- **Entry Analysis**: Implied market cap calculations using transaction-level data
- **Outlier Protection**: Median-based aggregations for price stability

### Behavioral Pattern Detection
- **Accumulation Patterns**: Multi-timeframe position increase identification
- **Distribution Signals**: Coordinated selling pattern recognition
- **Holding Analysis**: Low-activity wallet classification with percentage thresholds
- **Mixed Behavior**: Contradictory signal detection across timeframes

### Supply Evolution Tracking
- **Historical Reconstruction**: Complete daily insider supply percentage calculations
- **Market Cap Correlation**: Price movement analysis with insider activity patterns
- **Peak/Bottom Identification**: Statistical trend analysis with moving averages
- **Volume Integration**: Trading activity correlation with supply changes

## 🛠️ Technical Implementation

### Query Optimization Strategies
- **Efficient Filtering**: Pre-filter trades to exclude low-quality tokens and MEV activity
- **Smart Indexing**: Optimized JOIN strategies for large-scale blockchain data
- **Memory Management**: Staged processing to handle terabyte-scale datasets
- **Error Handling**: Robust NULL handling and division-by-zero protection

### Data Processing Pipeline
```sql
Raw Blockchain Data → Quality Filtering → Statistical Analysis → Classification → Output
        ↓                    ↓                   ↓               ↓          ↓
   dex_solana.trades    Token Quality     Performance      Behavior    Final Results
                        Assessment        Calculation     Analysis     & Rankings
```

### Performance Metrics
- **Scale**: Processing 10M+ transactions across 30-day analysis windows
- **Efficiency**: Optimized queries handling hundreds of thousands of wallet addresses
- **Accuracy**: Multi-layered validation ensuring high-quality trader identification
- **Reliability**: Robust error handling with graceful degradation

## 📊 Query Categories & Use Cases

### Interactive Analysis Endpoints
Perfect for real-time market intelligence and user-driven analysis:
- Token-specific whale analysis with behavioral classification
- Market-wide alpha activity heatmaps with flow calculations
- Elite trader subset analysis for focused intelligence gathering

### Statistical Research Queries
Designed for deep analytical research and pattern identification:
- Insider network analysis with supply evolution tracking
- Late buyer clustering with financial performance metrics
- Historical trend analysis with market cap correlation

### Infrastructure & Monitoring
System maintenance and performance optimization queries:
- Query performance benchmarking and optimization analysis
- Data quality validation and consistency checking

## 🔗 Integration Ecosystem

### Dune Analytics Platform
- **Materialized Views**: Pre-computed datasets for optimal performance
- **Parametrized Execution**: Dynamic analysis with user-defined inputs
- **API Integration**: Programmatic access for real-time applications
- **Version Control**: Query versioning for continuous improvement

### OCM_Hub Platform Integration
- **Real-time Commands**: Live endpoint execution through Telegram interface
- **Caching Strategy**: Redis-based result caching for sub-2ms response times
- **Rate Limiting**: Intelligent query throttling for optimal resource utilization
- **Error Recovery**: Automatic fallback mechanisms for system reliability

### R Framework Data Pipeline
- **CSV Export Integration**: Seamless data transfer for statistical analysis
- **Clustering Algorithm Support**: Optimized data formats for network analysis
- **Supply Timeline Analysis**: Historical data preparation for trend analysis
- **Market Cap Correlation**: Price data integration for comprehensive analysis

## 📈 Business Applications

### Institutional Research
- **Due Diligence**: Comprehensive token holder analysis for investment decisions
- **Risk Assessment**: Insider activity monitoring for portfolio management
- **Compliance**: Market manipulation detection and reporting capabilities
- **Performance Analytics**: Alpha trader identification for strategy development

### Trading Intelligence
- **Signal Generation**: Real-time alpha detection for trading opportunities
- **Market Timing**: Pattern recognition for optimal entry/exit points
- **Competitor Analysis**: Institutional trading behavior monitoring
- **Portfolio Optimization**: Diversification analysis using network clustering

### Academic Research
- **Market Microstructure**: Trading pattern analysis and behavioral economics
- **Network Theory**: Graph analysis applications in financial markets
- **Statistical Modeling**: Advanced analytics for predictive market analysis
- **Behavioral Finance**: Trader psychology and decision-making pattern studies

## 🔐 Data Quality & Security

### Validation Mechanisms
- **Multi-Source Verification**: Cross-reference validation across data sources
- **Statistical Consistency**: Automated checks for data integrity and accuracy
- **Outlier Detection**: Advanced statistical methods for anomaly identification
- **Temporal Validation**: Time-series consistency checking and gap detection

### Privacy & Compliance
- **Anonymization**: Personal data protection while maintaining analytical value
- **Access Control**: Query-level permissions and user authentication
- **Audit Trails**: Comprehensive logging for regulatory compliance
- **Data Retention**: Automated cleanup and archival policies

## 📄 License

Proprietary - All rights reserved. This SQL infrastructure demonstrates advanced on-chain analytics capabilities and institutional-grade data processing methodologies.

---

**Built for the future of on-chain intelligence**

*OCM_Dune represents cutting-edge SQL analytics infrastructure, combining advanced statistical methods with blockchain data processing to deliver institutional-grade cryptocurrency market intelligence.*
