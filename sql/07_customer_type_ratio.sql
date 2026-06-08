-- ============================================
-- 分析模块7: 客户分层占比统计
-- 目的: 统计各客户分层的客户数量及占比
-- 依赖: tmp_rfm 表(需先执行模块1/2生成)
-- ============================================

SELECT
    cust_type,
    COUNT(customer_id) AS customer_count,
    ROUND(COUNT(customer_id) / 9999, 4) AS ratio
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
) AS a
GROUP BY cust_type
ORDER BY customer_count DESC;
