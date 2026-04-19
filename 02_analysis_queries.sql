------
---PART B: BUSINESS INTELLIGENCE & ANALYTICS
--Objective: Answer 15 critical business questions regarding revenue and trends.
------------------

---------------------------
-- SECTION 1: REVENUE & PROFITABILITY
----------------------------------------------

-- Q1: Top 5 Selling Products by Total Revenue
-- Logic: Revenue = Quantity * Unit Price
SELECT 
    p.product_name,
    SUM(o.quantity * p.unit_price) AS total_revenue
FROM orders o
JOIN products p ON o.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_revenue DESC
LIMIT 5;


-- Q2: High-Value Departments (> $15M Revenue) & Profit Margin
-- Logic: Profit Margin % = (Total Revenue - Total Cost) / Total Revenue * 100
WITH Dept_Financials AS (
    SELECT 
        d.department_name,
        SUM(o.quantity * p.unit_price) AS total_revenue,
        SUM(o.quantity * p.unit_cost) AS total_cost
    FROM orders o
    JOIN products p ON o.product_id = p.product_id
    JOIN departments d ON p.department_id = d.department_id
    GROUP BY d.department_name
)
SELECT 
    department_name,
    total_revenue,
    ROUND(((total_revenue - total_cost) / total_revenue) * 100, 2) AS profit_margin_percentage
FROM Dept_Financials
WHERE total_revenue > 15000000
ORDER BY total_revenue DESC;


-- Q3: Peak Profitability Year
SELECT 
    EXTRACT(YEAR FROM order_date) AS sales_year,
    SUM((p.unit_price - p.unit_cost) * o.quantity) AS total_profit
FROM orders o
JOIN products p ON o.product_id = p.product_id
GROUP BY sales_year
ORDER BY total_profit DESC
LIMIT 1;


-- Q4: Juice Contribution Hypothesis (Is it 25%?)
-- Logic: Compare Juice Revenue vs Global Revenue using a CTE.
WITH Sales_Data AS (
    SELECT 
        SUM(CASE WHEN p.product_name ILIKE '%juice%' THEN (o.quantity * p.unit_price) ELSE 0 END) AS juice_revenue,
        SUM(o.quantity * p.unit_price) AS global_revenue
    FROM orders o
    JOIN products p ON o.product_id = p.product_id
)
SELECT 
    juice_revenue,
    global_revenue,
    ROUND((juice_revenue / global_revenue) * 100, 2) AS juice_percentage_contribution,
    CASE 
        WHEN (juice_revenue / global_revenue) >= 0.25 THEN 'Hypothesis Supported'
        ELSE 'Hypothesis Rejected'
    END AS validation_result
FROM Sales_Data;


---------------------------------------------
-- SECTION 2: CUSTOMER BEHAVIOR & TRENDS
------------------------------------------------------------

-- Q5: Chocolate Cravings (Day of the Week)
-- Logic: Filter for chocolate and group by day (0=Sun, 1=Mon...).
SELECT 
    CASE 
        WHEN order_dow = 0 THEN 'Sunday'
        WHEN order_dow = 1 THEN 'Monday'
        WHEN order_dow = 2 THEN 'Tuesday'
        WHEN order_dow = 3 THEN 'Wednesday'
        WHEN order_dow = 4 THEN 'Thursday'
        WHEN order_dow = 5 THEN 'Friday'
        WHEN order_dow = 6 THEN 'Saturday'
    END AS day_of_week,
    SUM(o.quantity) AS total_units_sold
FROM orders o
JOIN products p ON o.product_id = p.product_id
WHERE p.product_name ILIKE '%chocolate%'
GROUP BY order_dow
ORDER BY total_units_sold DESC;


-- Q6: Holiday Habits (Alcohol on Christmas 2019 vs Average)
WITH Alcohol_Stats AS (
    SELECT 
        o.order_date,
        SUM(o.quantity) AS daily_alcohol_units
    FROM orders o
    JOIN products p ON o.product_id = p.product_id
    JOIN departments d ON p.department_id = d.department_id
    WHERE d.department_name = 'alcohol'
    GROUP BY o.order_date
),
Metrics AS (
    SELECT 
        (SELECT daily_alcohol_units FROM Alcohol_Stats WHERE order_date = '2019-12-25') AS christmas_sales,
        (SELECT AVG(daily_alcohol_units) FROM Alcohol_Stats) AS average_daily_sales
)
SELECT 
    christmas_sales,
    ROUND(average_daily_sales, 2) as avg_sales,
    CASE 
        WHEN christmas_sales > average_daily_sales THEN 'Higher on Christmas' 
        ELSE 'Lower/Equal on Christmas' 
    END AS sales_comparison
FROM Metrics;

select * from departments;

-- Q7: Night Owls (Top 3 Products between 8 PM - 4 AM, 2020-2022)
SELECT 
    p.product_name,
    SUM(o.quantity) AS total_quantity
FROM orders o
JOIN products p ON o.product_id = p.product_id
WHERE 
    (o.order_hour_of_day >= 20 OR o.order_hour_of_day <= 4)
    AND EXTRACT(YEAR FROM o.order_date) BETWEEN 2020 AND 2022
GROUP BY p.product_name
ORDER BY total_quantity DESC
LIMIT 3;


-- Q8: Alcohol Timing (Peak Hour)
SELECT 
    o.order_hour_of_day AS hour_of_day,
    SUM(o.quantity) AS alcohol_units_sold
FROM orders o
JOIN products p ON o.product_id = p.product_id
JOIN departments d ON p.department_id = d.department_id
WHERE d.department_name = 'alcohol'
GROUP BY o.order_hour_of_day
ORDER BY alcohol_units_sold DESC
LIMIT 1;


-------------------------------
-- SECTION 3: SPECIFIC PRODUCT ANALYSIS
---------------------------------------

-- Q9: Bread Sales in Q2 & Q3 2016
-- Logic: Filter Year 2016, Months 4-9 (April to Sept).
SELECT 
    SUM(o.quantity * p.unit_price) AS bread_revenue
FROM orders o
JOIN products p ON o.product_id = p.product_id
WHERE 
    p.product_name ILIKE '%bread%'
    AND EXTRACT(YEAR FROM o.order_date) = 2016
    AND EXTRACT(MONTH FROM o.order_date) BETWEEN 4 AND 9;


-- Q10: Cheese Dormancy (Days since last order).
SELECT 
    MAX(o.order_date) AS last_cheese_order_date,
    CURRENT_DATE AS today,
    (CURRENT_DATE - MAX(o.order_date)) AS days_since_last_order
FROM orders o
JOIN products p ON o.product_id = p.product_id
WHERE p.product_name ILIKE '%cheese%';

-- --------------------------------------------------------------------------
-- SECTION 4: ADVANCED STRATEGIC INSIGHTS
-- --------------------------------------------------------------------------

-- Q11: The Pareto Principle (80/20 Rule) Validation
-- Scenario: Management believes the top 20% of customers contribute to 80% of revenue.
-- Logic: We categorize customers into quintiles (5 groups) based on spend and calculate the revenue share of the top group.
WITH Customer_Spend AS (
    SELECT 
        user_id,
        SUM(o.quantity * p.unit_price) AS total_spend
    FROM orders o
    JOIN products p ON o.product_id = p.product_id
    GROUP BY user_id
),
Ranked_Customers AS (
    SELECT 
        user_id,
        total_spend,
        NTILE(5) OVER (ORDER BY total_spend DESC) AS income_bracket
    FROM Customer_Spend
)
SELECT 
    income_bracket,
    SUM(total_spend) AS bracket_revenue,
    ROUND((SUM(total_spend) / (SELECT SUM(total_spend) FROM Customer_Spend) * 100), 2) AS revenue_percentage
FROM Ranked_Customers
GROUP BY income_bracket
ORDER BY income_bracket; 
-- If Bracket 1 (Top 20%) is 52.91%, the rule didn't holds.


-- Q12: Month-over-Month (MoM) Revenue Growth Rate
-- Scenario: The finance team needs to see the percentage growth or decline in sales compared to the previous month.
-- Logic: Use LAG() to get the previous month's revenue in the same row, then calculate percentage change.
WITH Monthly_Revenue AS (
    SELECT 
        TO_CHAR(order_date, 'YYYY-MM') AS sale_month,
        SUM(o.quantity * p.unit_price) AS current_revenue
    FROM orders o
    JOIN products p ON o.product_id = p.product_id
    GROUP BY sale_month
)
SELECT 
    sale_month,
    current_revenue,
    LAG(current_revenue) OVER (ORDER BY sale_month) AS previous_month_revenue,
    ROUND(
        ((current_revenue - LAG(current_revenue) OVER (ORDER BY sale_month)) / 
        LAG(current_revenue) OVER (ORDER BY sale_month)) * 100
    , 2) AS growth_rate_percentage
FROM Monthly_Revenue;


-- Q13: Product "Stickiness" (Reorder Velocity)
-- Scenario: Which products driving the fastest reorders?
-- Logic: Calculate average 'days_since_prior_order' for each product. Lower days = higher stickiness.
SELECT 
    p.product_name,
    ROUND(AVG(o.days_since_prior_order), 1) AS avg_days_to_reorder,
    COUNT(*) AS total_orders
FROM orders o
JOIN products p ON o.product_id = p.product_id
WHERE o.days_since_prior_order IS NOT NULL
GROUP BY p.product_name
ORDER BY avg_days_to_reorder ASC
LIMIT 5;


-- Q14: The "Weekend Rush" vs. "Weekday Lull" (AOV Analysis)
-- Scenario: Do people spend more money per transaction on weekends compared to weekdays?
-- Logic: Group days into Weekend (0=Sun, 6=Sat) vs Weekday, calculate Average Order Value (AOV).
SELECT 
    CASE 
        WHEN order_dow IN (0, 6) THEN 'Weekend'
        ELSE 'Weekday'
    END AS day_type,
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(quantity * unit_price) AS total_revenue,
    ROUND(SUM(quantity * unit_price) / COUNT(DISTINCT order_id), 2) AS average_order_value
FROM orders o
JOIN products p ON o.product_id = p.product_id
GROUP BY 
    CASE 
        WHEN order_dow IN (0, 6) THEN 'Weekend'
        ELSE 'Weekday'
    END;


-- Q15: High-Value Customer Segmentation
-- Scenario: Marketing wants to target users based on their spending habits (VIP vs. Regular vs. Occasional).
WITH User_Totals AS (
    SELECT 
        user_id,
        SUM(o.quantity * p.unit_price) AS lifetime_value
    FROM orders o
    JOIN products p ON o.product_id = p.product_id
    GROUP BY user_id
)
SELECT 
    CASE 
        WHEN lifetime_value >= 1000 THEN 'VIP'
        WHEN lifetime_value BETWEEN 500 AND 999 THEN 'Loyal Customer'
        ELSE 'Occasional Shopper'
    END AS customer_segment,
    COUNT(user_id) AS customer_count,
    SUM(lifetime_value) AS segment_total_revenue
FROM User_Totals
GROUP BY 
    CASE 
        WHEN lifetime_value >= 1000 THEN 'VIP'
        WHEN lifetime_value BETWEEN 500 AND 999 THEN 'Loyal Customer'
        ELSE 'Occasional Shopper'
    END
ORDER BY segment_total_revenue DESC;