-- ============================================
-- 分析模块1: RFM基础指标计算
-- 目的: 计算客户R(最近购买间隔)、F(总频次)、M(总金额)
--       并标记高复购客户(自然年下单≥3次)
-- 作者: 数据分析师
-- 日期: 2024-02
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
        DATEDIFF('2024-02-01', MAX(order_date)) AS R,  -- 距离基准日期的天数
        COUNT(DISTINCT order_id) AS F_all,             -- 总购买频次
        SUM(order_money) AS M                            -- 总消费金额
    FROM order_cust_amt
    GROUP BY customer_id, city, signup_date
),
-- 按自然年统计频次，筛选年下单≥3次的高复购客户
cust_year_f AS (
    SELECT
        customer_id,
        YEAR(order_date) AS ord_year,
        COUNT(DISTINCT order_id) AS F_year
    FROM orders
    GROUP BY customer_id, YEAR(order_date)
),
high_f_cust AS (
    SELECT DISTINCT customer_id 
    FROM cust_year_f 
    WHERE F_year >= 3
),
rfm_base AS (
    SELECT
        r.*,
        IF(h.customer_id IS NOT NULL, 1, 0) AS is_high_rebuy
    FROM cust_rfm_raw r
    LEFT JOIN high_f_cust h ON r.customer_id = h.customer_id
)
SELECT * FROM rfm_base;
