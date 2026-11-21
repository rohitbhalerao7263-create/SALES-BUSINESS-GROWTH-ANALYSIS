/*
==========================================================
PROJECT: SALES & BUSINESS GROWTH ANALYSIS
SECTION: SQL BUSINESS ANALYSIS REPORT
DATABASE: sales_business_growth
TABLE: sales
PERIOD: January 2026 - May 2026

PURPOSE:
Analyze sales performance, profitability, products, regions,
sales representatives, monthly growth and discounts.

AUTHOR: Rohit Bhalerao
==========================================================
*/


/* ======================================================
1. DATABASE VALIDATION
====================================================== */

USE sales_business_growth;

SELECT COUNT(*) AS total_records
FROM sales;


/* Expected Result: 40 */


/* ======================================================
2. CHECK TABLE STRUCTURE / SAMPLE DATA
====================================================== */

SELECT *
FROM sales
LIMIT 10;


/* ======================================================
3. OVERALL BUSINESS KPIs
====================================================== */

SELECT
    ROUND(SUM(revenue), 2) AS total_revenue,
    ROUND(SUM(cost), 2) AS total_cost,
    ROUND(SUM(profit), 2) AS total_profit,
    COUNT(*) AS total_transactions,
    SUM(quantity) AS total_units_sold,
    ROUND(
        SUM(profit) / SUM(revenue) * 100,
        2
    ) AS profit_margin_percentage
FROM sales;


/*
EXPECTED RESULT

Total Revenue       = ₹2,395,068
Total Cost          = ₹1,801,870
Total Profit        = ₹593,198
Transactions        = 40
Units Sold          = 342
Profit Margin       = 24.77%
*/


/* ======================================================
4. PRODUCT PERFORMANCE
====================================================== */

SELECT
    product,
    ROUND(SUM(revenue), 2) AS total_revenue,
    ROUND(SUM(cost), 2) AS total_cost,
    ROUND(SUM(profit), 2) AS total_profit,
    SUM(quantity) AS units_sold,
    COUNT(*) AS transactions,
    ROUND(
        SUM(profit) / SUM(revenue) * 100,
        2
    ) AS profit_margin_percentage
FROM sales
GROUP BY product
ORDER BY total_revenue DESC;


/* ======================================================
5. TOP REVENUE-GENERATING PRODUCT
====================================================== */

SELECT
    product,
    ROUND(SUM(revenue), 2) AS total_revenue
FROM sales
GROUP BY product
ORDER BY total_revenue DESC
LIMIT 1;


/*
Expected:
Laptop
Revenue = ₹825,560
*/


/* ======================================================
6. PRODUCT PROFITABILITY
====================================================== */

SELECT
    product,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(
        SUM(profit) / SUM(revenue) * 100,
        2
    ) AS profit_margin_percentage
FROM sales
GROUP BY product
ORDER BY total_profit DESC;


/* ======================================================
7. CATEGORY PERFORMANCE
====================================================== */

SELECT
    category,
    ROUND(SUM(revenue), 2) AS total_revenue,
    ROUND(SUM(profit), 2) AS total_profit,
    SUM(quantity) AS units_sold,
    COUNT(*) AS transactions
FROM sales
GROUP BY category
ORDER BY total_revenue DESC;


/* ======================================================
8. REGIONAL PERFORMANCE
====================================================== */

SELECT
    region,
    ROUND(SUM(revenue), 2) AS total_revenue,
    ROUND(SUM(cost), 2) AS total_cost,
    ROUND(SUM(profit), 2) AS total_profit,
    SUM(quantity) AS units_sold,
    COUNT(*) AS transactions,
    ROUND(
        SUM(profit) / SUM(revenue) * 100,
        2
    ) AS profit_margin_percentage
FROM sales
GROUP BY region
ORDER BY total_revenue DESC;


/*
Expected ranking by revenue:

1. West
2. South
3. North
4. East
*/


/* ======================================================
9. SALES REPRESENTATIVE PERFORMANCE
====================================================== */

SELECT
    sales_rep,
    ROUND(SUM(revenue), 2) AS total_revenue,
    ROUND(SUM(profit), 2) AS total_profit,
    SUM(quantity) AS units_sold,
    COUNT(*) AS transactions,
    ROUND(
        SUM(profit) / SUM(revenue) * 100,
        2
    ) AS profit_margin_percentage
FROM sales
GROUP BY sales_rep
ORDER BY total_revenue DESC;


/* ======================================================
10. TOP SALES REPRESENTATIVE
====================================================== */

SELECT
    sales_rep,
    ROUND(SUM(revenue), 2) AS total_revenue
FROM sales
GROUP BY sales_rep
ORDER BY total_revenue DESC
LIMIT 1;


/*
Expected:
Neha
Revenue = ₹632,650
*/


/* ======================================================
11. MONTHLY SALES PERFORMANCE
====================================================== */

SELECT
    DATE_FORMAT(sale_date, '%Y-%m') AS sales_month,
    ROUND(SUM(revenue), 2) AS total_revenue,
    ROUND(SUM(profit), 2) AS total_profit,
    COUNT(*) AS transactions,
    SUM(quantity) AS units_sold
FROM sales
GROUP BY DATE_FORMAT(sale_date, '%Y-%m')
ORDER BY sales_month;


/* ======================================================
12. MONTH-OVER-MONTH REVENUE GROWTH
====================================================== */

WITH monthly_sales AS
(
    SELECT
        DATE_FORMAT(sale_date, '%Y-%m') AS sales_month,
        SUM(revenue) AS revenue
    FROM sales
    GROUP BY DATE_FORMAT(sale_date, '%Y-%m')
),

monthly_growth AS
(
    SELECT
        sales_month,
        revenue,
        LAG(revenue) OVER (
            ORDER BY sales_month
        ) AS previous_month_revenue
    FROM monthly_sales
)

SELECT
    sales_month,
    ROUND(revenue, 2) AS revenue,
    ROUND(previous_month_revenue, 2) AS previous_month_revenue,
    CASE
        WHEN previous_month_revenue IS NULL
            THEN NULL
        ELSE ROUND(
            (revenue - previous_month_revenue)
            / previous_month_revenue * 100,
            2
        )
    END AS mom_growth_percentage
FROM monthly_growth
ORDER BY sales_month;


/*
EXPECTED MONTHLY REVENUE

January = ₹287,375
February = ₹237,890
March = ₹446,858
April = ₹508,495
May = ₹914,450

Highest growth:
May = approximately +79.83%
*/


/* ======================================================
13. HIGHEST REVENUE MONTH
====================================================== */

SELECT
    DATE_FORMAT(sale_date, '%Y-%m') AS sales_month,
    ROUND(SUM(revenue), 2) AS total_revenue
FROM sales
GROUP BY DATE_FORMAT(sale_date, '%Y-%m')
ORDER BY total_revenue DESC
LIMIT 1;


/*
Expected:
May 2026
Revenue = ₹914,450
*/


/* ======================================================
14. DISCOUNT ANALYSIS
====================================================== */

SELECT
    product,
    ROUND(AVG(discount_percent), 2) AS average_discount,
    ROUND(SUM(revenue), 2) AS total_revenue,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(
        SUM(profit) / SUM(revenue) * 100,
        2
    ) AS profit_margin_percentage
FROM sales
GROUP BY product
ORDER BY average_discount DESC;


/* ======================================================
15. TOP 5 TRANSACTIONS BY REVENUE
====================================================== */

SELECT
    sales_id,
    sale_date,
    product,
    region,
    sales_rep,
    quantity,
    discount_percent,
    ROUND(revenue, 2) AS revenue,
    ROUND(profit, 2) AS profit
FROM sales
ORDER BY revenue DESC
LIMIT 5;


/* ======================================================
16. TOP 5 MOST PROFITABLE TRANSACTIONS
====================================================== */

SELECT
    sales_id,
    sale_date,
    product,
    region,
    sales_rep,
    ROUND(revenue, 2) AS revenue,
    ROUND(profit, 2) AS profit
FROM sales
ORDER BY profit DESC
LIMIT 5;


/* ======================================================
17. PRODUCT + REGION ANALYSIS
====================================================== */

SELECT
    product,
    region,
    ROUND(SUM(revenue), 2) AS total_revenue,
    ROUND(SUM(profit), 2) AS total_profit,
    SUM(quantity) AS units_sold
FROM sales
GROUP BY product, region
ORDER BY total_revenue DESC;


/* ======================================================
18. PRODUCTS WITH ABOVE-AVERAGE REVENUE
====================================================== */

SELECT
    product,
    ROUND(SUM(revenue), 2) AS total_revenue
FROM sales
GROUP BY product
HAVING SUM(revenue) >
(
    SELECT AVG(product_revenue)
    FROM
    (
        SELECT SUM(revenue) AS product_revenue
        FROM sales
        GROUP BY product
    ) AS product_summary
)
ORDER BY total_revenue DESC;


/* ======================================================
19. REGIONS WITH PROFIT ABOVE ₹130,000
====================================================== */

SELECT
    region,
    ROUND(SUM(profit), 2) AS total_profit
FROM sales
GROUP BY region
HAVING SUM(profit) > 130000
ORDER BY total_profit DESC;


/* ======================================================
20. HIGH-VALUE TRANSACTIONS
====================================================== */

SELECT
    sales_id,
    product,
    region,
    sales_rep,
    revenue,
    profit
FROM sales
WHERE revenue > 100000
ORDER BY revenue DESC;


/* ======================================================
21. PROFIT MARGIN BY PRODUCT
====================================================== */

SELECT
    product,
    ROUND(
        SUM(profit) / SUM(revenue) * 100,
        2
    ) AS profit_margin_percentage
FROM sales
GROUP BY product
ORDER BY profit_margin_percentage DESC;


/*
Expected ranking:

1. Mouse      ≈ 30.00%
2. Keyboard   ≈ 26.32%
3. Laptop     ≈ 25.64%
4. Printer    ≈ 23.73%
5. Monitor    ≈ 22.49%
*/


/* ======================================================
22. LOW-MARGIN PRODUCTS
====================================================== */

SELECT
    product,
    ROUND(
        SUM(profit) / SUM(revenue) * 100,
        2
    ) AS profit_margin_percentage
FROM sales
GROUP BY product
HAVING SUM(profit) / SUM(revenue) < 0.25
ORDER BY profit_margin_percentage;


/* ======================================================
23. MONTHLY PROFITABILITY
====================================================== */

SELECT
    DATE_FORMAT(sale_date, '%Y-%m') AS sales_month,
    ROUND(SUM(revenue), 2) AS revenue,
    ROUND(SUM(profit), 2) AS profit,
    ROUND(
        SUM(profit) / SUM(revenue) * 100,
        2
    ) AS profit_margin_percentage
FROM sales
GROUP BY DATE_FORMAT(sale_date, '%Y-%m')
ORDER BY sales_month;


/* ======================================================
24. REGION + PRODUCT PERFORMANCE
====================================================== */

SELECT
    region,
    product,
    ROUND(SUM(revenue), 2) AS revenue,
    ROUND(SUM(profit), 2) AS profit
FROM sales
GROUP BY region, product
ORDER BY region, revenue DESC;


/* ======================================================
25. FINAL BUSINESS KPI VALIDATION
====================================================== */

SELECT
    COUNT(*) AS transactions,
    SUM(quantity) AS units_sold,
    ROUND(SUM(revenue), 2) AS revenue,
    ROUND(SUM(cost), 2) AS cost,
    ROUND(SUM(profit), 2) AS profit,
    ROUND(
        SUM(profit) / SUM(revenue) * 100,
        2
    ) AS profit_margin
FROM sales;


/*
==========================================================
FINAL VALIDATED RESULTS

Transactions       : 40
Units Sold         : 342
Revenue            : ₹2,395,068
Cost               : ₹1,801,870
Profit             : ₹593,198
Profit Margin      : 24.77%

TOP PRODUCT        : Laptop
TOP REGION         : West
TOP SALES REP      : Neha
TOP REVENUE MONTH  : May 2026

KEY BUSINESS FINDINGS:

1. Laptop generated the highest revenue.
2. West generated the highest regional revenue.
3. Neha generated the highest sales representative revenue.
4. May was the strongest month.
5. May revenue increased approximately 79.83% versus April.
6. Mouse had the highest product-level profit margin.
7. Monitor had the lowest product-level profit margin.
8. Discount levels should be monitored for lower-margin products.

==========================================================
PROJECT CONCLUSION

SQL analysis successfully transformed raw sales data into
business KPIs and actionable insights covering:

- Revenue
- Cost
- Profit
- Profit Margin
- Product Performance
- Category Performance
- Regional Performance
- Sales Representative Performance
- Monthly Growth
- Discount Analysis
- Transaction Analysis

These results were reconciled against the Excel analysis
and form the SQL analytical layer of the Sales & Business
Growth Analysis portfolio project.

==========================================================
END OF SQL BUSINESS ANALYSIS REPORT
==========================================================
*/