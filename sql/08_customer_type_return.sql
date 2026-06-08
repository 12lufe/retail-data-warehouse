-- ============================================
-- 分析模块8: 客户分层与退货行为关联分析
-- 目的: 分析不同客户分层的平均退货次数
-- 依赖: tmp_rfm 表(需先执行模块1/2生成)
-- ============================================

SELECT
    s.cust_type,
    COUNT(s.customer_id) AS customer_count,
    ROUND(AVG(IFNULL(cr.return_times, 0)), 2) AS avg_return_times
FROM (
    SELECT
        customer_id,
        CASE
            WHEN NTILE(5) OVER(ORDER BY R DESC) >= 4 
                 AND NTILE(5) OVER(ORDER BY F ASC) >= 4 
                 AND NTILE(5) OVER(ORDER BY M ASC) >= 4 
            THEN '重要高价值客户'
            WHEN NTILE(5) OVER(ORDER BY F ASC) >= 4 
                 AND NTILE(5) OVER(ORDER BY M ASC) <= 2 
            THEN '高频低消费客户'
            WHEN NTILE(5) OVER(ORDER BY R DESC) <= 2 
                 AND NTILE(5) OVER(ORDER BY F ASC) >= 4 
            THEN '沉睡高复购老客'
            WHEN NTILE(5) OVER(ORDER BY F ASC) <= 2 
            THEN '低频零散客户'
            ELSE '潜力待激活客户'
        END AS cust_type
    FROM tmp_rfm
) s
LEFT JOIN (
    SELECT 
        o.customer_id, 
        COUNT(DISTINCT r.return_id) AS return_times
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN returns r ON oi.order_item_id = r.order_item_id
    GROUP BY o.customer_id
) cr ON s.customer_id = cr.customer_id
GROUP BY s.cust_type;
