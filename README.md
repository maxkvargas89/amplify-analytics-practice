# Amplify Analytics Engineering Project

End-to-end analytics infrastructure for a K-12 adaptive learning platform, demonstrating dimensional modeling, incremental loading, and product analytics.

## 🎯 Project Overview

This project showcases analytics engineering best practices for K-12 education technology, built to answer three core business questions:

1. **User Activation & Engagement** - Track daily active users (DAU), activation rates, and engagement levels
2. **Student Progress & Performance** - Monitor learning progression through adaptive units with mastery tracking
3. **K-12 Context & Equity** - Handle student school transfers via Type 2 SCDs and enable demographic analysis

## 🏗️ Architecture

### **Star Schema Design**
```
marts/
└── mart_student_progress (business-ready analytics)
        ↑
core/facts/
├── fact_student_activity (daily engagement - incremental)
└── fact_learning_progress (unit mastery - incremental)
        ↑
core/dimensions/
├── dim_student (Type 2 SCD - handles school transfers)
├── dim_school (demographics & poverty classification)
├── dim_learning_unit (curriculum structure)
└── dim_date (K-12 school calendar aware)
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

### **Equity Analysis**
Built-in demographic breakdowns by poverty level, ethnicity, special education status enabling equity-focused insights.

## 📊 Data Models

### **Dimensions (4)**
- `dim_student` - 7 records (6 students + 1 transfer)
- `dim_school` - 2 schools with demographics
- `dim_learning_unit` - 5 curriculum units
- `dim_date` - 365 days (full school year)

### **Facts (2)**
- `fact_student_activity` - ~500 rows (student-day grain)
- `fact_learning_progress` - ~300 rows (student-unit-day grain)

### **Marts (1)**
- `mart_student_progress` - 6 rows (one per student) with 30+ metrics

## 🧪 Data Quality

35+ automated tests covering:
- Unique constraints
- Not null validations
- Referential integrity (foreign keys)
- Accepted value ranges
- Business logic validation

## 🚀 Getting Started

### **Prerequisites**
- Google Cloud Platform account with BigQuery enabled
- dbt Cloud account
- GitHub account

### **Setup**
```bash
# Clone repository
git clone https://github.com/YOUR_USERNAME/amplify-analytics-dbt.git

# Install dbt packages
dbt deps

# Run full pipeline
dbt build

# Generate documentation
dbt docs generate
```

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

## 🎓 Learning Outcomes

Through this project, I demonstrated:
- Kimball dimensional modeling methodology
- Type 2 SCD implementation for historical tracking
- Incremental loading strategies for large fact tables
- K-12 education data modeling complexity
- dbt best practices (testing, documentation, version control)
- SQL optimization and BigQuery-specific features

## 🔗 Links

- **Repository:** https://github.com/YOUR_USERNAME/amplify-analytics-dbt
- **dbt Documentation:** [Link to hosted docs]
- **Lineage Graph:** [Screenshot or link]

## 📧 Contact

Max Vargas  
maxkvargas@gmail.com  
[LinkedIn](https://linkedin.com/in/maxkvargas)  
[GitHub](https://github.com/maxkvargas89)