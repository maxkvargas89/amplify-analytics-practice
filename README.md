# Amplify Analytics Engineering Project

Analytics infrastructure for K-12 adaptive learning platform, demonstrating:
- Type 2 Slowly Changing Dimensions for student data
- Incremental fact tables for student activity
- Product analytics (user activation, DAU)
- K-12-aware dimensional modeling (school years, student mobility)

## Tech Stack
- **Data Warehouse:** Google BigQuery
- **Transformation:** dbt Cloud
- **Version Control:** GitHub

## Project Structure
- `models/staging/` - Cleaned source data
- `models/core/dimensions/` - Dimension tables (Type 2 SCDs)
- `models/core/facts/` - Fact tables (incremental)
- `models/marts/` - Business-specific analytical marts

## Setup
1. Clone this repository
2. Install dbt dependencies: `dbt deps`
3. Configure BigQuery connection in `profiles.yml`
4. Run models: `dbt run`
5. Test data quality: `dbt test`

## Key Features
- **Type 2 SCD:** Tracks student school transfers over time
- **Incremental Loading:** Efficient processing of large event tables
- **K-12 Context:** School calendar-aware date dimension
- **Product Analytics:** User activation, engagement, and progress tracking
