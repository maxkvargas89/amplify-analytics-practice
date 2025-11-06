# Amplify Analytics Engineering Practice

End-to-end analytics infrastructure for a K-12 adaptive learning platform, demonstrating dimensional modeling, incremental loading, and product analytics.

## 🎯 Project Overview

This project showcases analytics engineering best practices for K-12 education technology, built to answer three core business questions:

1. **User Activation & Engagement** - Track daily active users (DAU), activation rates, and engagement levels
2. **Student Progress & Performance** - Monitor learning progression through adaptive units with mastery tracking
3. **K-12 Context & Equity** - Handle student school transfers via Type 2 SCDs and enable demographic analysis
4. **Data Modeling Task** - Model of event stream data emitted from 2 different products: ELA and Science

## 🏗️ Architecture

### **Star Schema Design**
```
marts/
└── mart_student_progress (business-ready analytics)
└── mart_user_product_activity_weekly (business-ready analytics)
└── mart_event_details_monthly (business-ready analytics)
        ↑
core/facts/
├── fact_student_activity (daily engagement - incremental)
└── fact_learning_progress (unit mastery - incremental)
└── fact_produce_events (real-time events - incremental)
        ↑
core/dimensions/
├── dim_student (Type 2 SCD - handles school transfers)
├── dim_school (demographics & poverty classification)
├── dim_learning_unit (curriculum structure)
└── dim_date (K-12 school calendar aware)
└── dim_user (K-12 school calendar aware)
└── dim_object (K-12 school calendar aware)
└── dim_product (K-12 school calendar aware)
└── dim_verb (K-12 school calendar aware)

        ↑
staging/
└── 4 staging models (cleaned source data)
```

## 🛠️ Tech Stack

- **Data Warehouse:** Google BigQuery
- **Transformation:** dbt Cloud
- **Version Control:** GitHub
- **Testing:** 35+ data quality tests
- **Documentation:** Auto-generated dbt docs

## ✨ Key Features

### **Type 2 Slowly Changing Dimensions**
Tracks student attribute changes over time (school transfers, grade promotions) with effective dates and surrogate keys.

### **Incremental Fact Tables**
Efficiently processes only new data using dbt's incremental materialization, reducing query costs and runtime.

### **K-12 School Calendar**
Date dimension understands school years (Aug-July), semesters, and school vs. non-school days.

### **Product Analytics**
- User activation tracking (first lesson completion)
- Daily/Weekly active user metrics
- Engagement level classification
- 7-day activity windows

## 🧪 Data Quality

35+ automated tests covering:
- Unique constraints
- Not null validations
- Referential integrity (foreign keys)
- Accepted value ranges
- Business logic validation

### **Sample Queries**

**Track DAU:**
```sql
SELECT 
  activity_date,
  COUNT(DISTINCT student_id) as daily_active_users
FROM analytics.fact_student_activity
GROUP BY activity_date
ORDER BY activity_date;
```

**Identify At-Risk Students:**
```sql
SELECT 
  full_name,
  school_name,
  mastery_rate,
  days_active_last_7
FROM marts.mart_student_progress
WHERE progress_status = 'at_risk';
```

**Equity Analysis:**
```sql
SELECT 
  poverty_level,
  ethnicity,
  AVG(mastery_rate) as avg_mastery,
  COUNT(*) as student_count
FROM marts.mart_student_progress
GROUP BY poverty_level, ethnicity;
```

**Active (>5 events) Users:**
```sql
SELECT 
    product_name,
    COUNT(DISTINCT user_id) AS active_users
FROM mart_user_product_activity_weekly
WHERE is_active_user = TRUE
GROUP BY product_name;
```

**Events per user per product last week:**
```sql
SELECT 
    user_id,
    product_name,
    event_count
FROM mart_user_event_summary
ORDER BY event_count DESC;
```

**Selected verb events by product per month:**
```sql
SELECT 
    product_name,
    year,
    month,
    SUM(event_count) AS total_events
FROM mart_event_details_monthly
WHERE verb_id IN ('selected')
GROUP BY 1, 2, 3
ORDER BY year, month, product_name;
```

**Events by user last month, segmented by verb and object:**
```sql
SELECT 
    user_id,
    verb_id,
    object_id,
    SUM(event_count) AS total_events
FROM mart_event_details_monthly
WHERE year = 2024
  AND month = 10
GROUP BY 1, 2, 3
ORDER BY user_id, total_events DESC;
```
