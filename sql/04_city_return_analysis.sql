-- ============================================
-- 分析模块4: 城市退货与高复购分析
-- 目的: 分析各城市订单退货率与高复购客户数量关系
-- ============================================

-- 城市退货指标
WITH city_return AS (
    SELECT
        c.city,
        COUNT(DISTINCT o.order_id) AS total_order,
        COUNT(DISTINCT IF(r.return_id IS NOT NULL, o.order_id, NULL)) AS ret_order,
        ROUND(COUNT(DISTINCT IF(r.return_id IS NOT NULL, o.order_id, NULL)) / COUNT(DISTINCT o.order_id), 4) AS return_rate
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    LEFT JOIN order_items oi ON o.order_id = oi.order_id
    LEFT JOIN returns r ON oi.order_item_id = r.order_item_id
    GROUP BY c.city
),
-- 各城市高复购人数
high_cust_city AS (
    SELECT
        c.city,
        COUNT(DISTINCT c.customer_id) AS high_cust_count
    FROM customers c
    WHERE c.customer_id IN (
        SELECT DISTINCT customer_id 
        FROM (
            SELECT customer_id, COUNT(DISTINCT order_id) AS F_year
            FROM orders 
            GROUP BY customer_id, YEAR(order_date)
        ) t 
        WHERE F_year >= 3
    )
    GROUP BY c.city
)
SELECT cr.*, IFNULL(h.high_cust_count, 0) AS high_cust_count
FROM city_return cr
LEFT JOIN high_cust_city h ON cr.city = h.city
ORDER BY high_cust_count DESC, return_rate DESC;
