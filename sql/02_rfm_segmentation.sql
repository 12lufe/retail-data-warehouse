-- ============================================
-- 分析模块2: RFM客户分层
-- 目的: 基于RFM五分位评分，将客户划分为5个价值层级
-- 分层规则:
--   重要高价值客户: R≥4, F≥4, M≥4
--   高频低消费客户: F≥4, M≤2
--   沉睡高复购老客: R≤2, F≥4
--   低频零散客户: F≤2
--   潜力待激活客户: 其他
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
    SELECT
        customer_id,
        YEAR(order_date) AS ord_year,
        COUNT(DISTINCT order_id) AS F_year
    FROM orders
    GROUP BY customer_id, YEAR(order_date)
),
high_f_cust AS (
    SELECT DISTINCT customer_id FROM cust_year_f WHERE F_year >= 3
),
rfm_base AS (
    SELECT
        r.*,
        IF(h.customer_id IS NOT NULL, 1, 0) AS is_high_rebuy
    FROM cust_rfm_raw r
    LEFT JOIN high_f_cust h ON r.customer_id = h.customer_id
),
rfm_score AS (
    SELECT
        *,
        -- R越大=越久没买，分数越低(NTILE按降序分5档)
        NTILE(5) OVER(ORDER BY R DESC) AS R_score,
        -- F/M越大越好，升序分档
        NTILE(5) OVER(ORDER BY F_all ASC) AS F_score,
        NTILE(5) OVER(ORDER BY M ASC) AS M_score,
        CONCAT(
            NTILE(5) OVER(ORDER BY R DESC),
            NTILE(5) OVER(ORDER BY F_all ASC),
            NTILE(5) OVER(ORDER BY M ASC)
        ) AS rfm_tag
    FROM rfm_base
)
SELECT
    *,
    CASE
        WHEN F_score >= 4 AND M_score >= 4 AND R_score >= 4 THEN '重要高价值客户'
        WHEN F_score >= 4 AND M_score <= 2 THEN '高频低消费客户'
        WHEN R_score <= 2 AND F_score >= 4 THEN '沉睡高复购老客'
        WHEN F_score <= 2 THEN '低频零散客户'
        ELSE '潜力待激活客户'
    END AS cust_type
FROM rfm_score;
