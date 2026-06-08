-- ============================================
-- 分析模块3: 高复购客户城市月度分布
-- 目的: 按城市和注册月份统计高复购客户的平均RFM指标
-- ============================================

WITH order_cust_amt AS (
    SELECT
        c.customer_id,
        c.city,
        c.signup_date,
        o.order_id,
        o.order_date,
        IFNULL(SUM(p.amount), 0) AS order_money
    FROM customers c
    INNER JOIN orders o ON c.customer_id = o.customer_id
    LEFT JOIN payments p ON o.order_id = p.order_id
    GROUP BY c.customer_id, c.city, c.signup_date, o.order_id, o.order_date
),
cust_rfm_raw AS (
    SELECT
        customer_id,
        city,
        signup_date,
        DATEDIFF('2024-02-01', MAX(order_date)) AS R,
        COUNT(DISTINCT order_id) AS F_all,
        SUM(order_money) AS M
    FROM order_cust_amt
    GROUP BY customer_id, city, signup_date
),
cust_year_f AS (
    SELECT customer_id, YEAR(order_date) AS ord_year, COUNT(DISTINCT order_id) AS F_year
    FROM orders 
    GROUP BY customer_id, YEAR(order_date)
),
high_f_cust AS (
    SELECT DISTINCT customer_id FROM cust_year_f WHERE F_year >= 3
),
rfm_base AS (
    SELECT r.*, IF(h.customer_id IS NOT NULL, 1, 0) AS is_high_rebuy
    FROM cust_rfm_raw r 
    LEFT JOIN high_f_cust h ON r.customer_id = h.customer_id
)
SELECT
    city,
    DATE_FORMAT(signup_date, '%Y-%m') AS reg_month,
    COUNT(DISTINCT customer_id) AS high_cust_num,
    ROUND(AVG(R), 2) AS avg_R,
    ROUND(AVG(F_all), 2) AS avg_F,
    ROUND(AVG(M), 2) AS avg_M
FROM rfm_base
WHERE is_high_rebuy = 1
GROUP BY city, reg_month
ORDER BY high_cust_num DESC;
