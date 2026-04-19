# Instacart SQL Analytics

**PostgreSQL business intelligence analysis on a grocery e-commerce dataset.**  
Answers 15 strategic business questions across revenue, customer behaviour, product performance, and growth trends.

---

## Schema

```
departments ──┐
              ├──► products ──► orders
aisles ────────┘
```

| Table | Key Columns |
|-------|-------------|
| `departments` | department_id, department_name |
| `aisles` | aisle_id, aisle |
| `products` | product_id, product_name, unit_cost, unit_price, aisle_id, department_id |
| `orders` | order_id, user_id, product_id, quantity, order_date, order_dow, order_hour_of_day, days_since_prior_order, order_status |

---

## Analysis Overview

### Section 1 — Revenue & Profitability
| # | Question |
|---|----------|
| Q1 | Top 5 products by total revenue |
| Q2 | High-value departments (>$15M revenue) with profit margin % |
| Q3 | Peak profitability year |

### Section 2 — Customer Behaviour & Trends
| # | Question |
|---|----------|
| Q4 | Most popular order day of the week |
| Q5 | Chocolate sales by day of week |
| Q6 | Holiday habits — alcohol sales on Christmas 2019 vs daily average |
| Q7 | Night owl products (orders between 8 PM–4 AM, 2020–2022) |
| Q8 | Peak hour for alcohol sales |

### Section 3 — Specific Product Analysis
| # | Question |
|---|----------|
| Q9 | Bread revenue in Q2 & Q3 2016 |
| Q10 | Days since the last cheese order (data freshness) |

### Section 4 — Advanced Strategic Insights
| # | Question | Technique |
|---|----------|-----------|
| Q11 | Pareto Principle — does top 20% of customers drive 80% of revenue? | `NTILE(5)` window function |
| Q12 | Month-over-Month revenue growth rate | `LAG()` window function |
| Q13 | Product "stickiness" — fastest reorder velocity | `AVG(days_since_prior_order)` |
| Q14 | Weekend Rush vs Weekday Lull — Average Order Value comparison | `CASE` + `COUNT(DISTINCT order_id)` |
| Q15 | High-value customer segmentation (VIP / Loyal / Occasional) | CTE + spend thresholds |

---

## Setup

1. Create a PostgreSQL database named `instacart`
2. Run `01_database_setup.sql` to create tables and load `aisles.csv` / `departments.csv`  
   *(update the `COPY` paths to match your local file location)*
3. Load `products.csv` and `orders.csv` (source: [Instacart Market Basket dataset](https://www.kaggle.com/c/instacart-market-basket-analysis))
4. Run `02_analysis_queries.sql` to execute all 15 business queries

---

## Key Techniques

- **Window functions**: `LAG()` for MoM growth, `NTILE()` for customer quintiles
- **CTEs**: multi-step aggregations kept readable
- **ILIKE**: case-insensitive product name filtering
- **Date functions**: `EXTRACT()`, `TO_CHAR()` for temporal breakdowns
- **Financial precision**: `NUMERIC(10,2)` for cost/price columns

---

## Tools

- PostgreSQL 15+
- pgAdmin / psql
