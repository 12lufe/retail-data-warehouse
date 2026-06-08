-- ============================================
-- 分析模块6: 高复购客户价格带与供应商分析
-- 目的: 分析高复购客户在不同价格带的购买偏好及供应商分布
-- ============================================

DROP TEMPORARY TABLE IF EXISTS tmp_high_cust;
CREATE TEMPORARY TABLE tmp_high_cust
SELECT DISTINCT customer_id
FROM orders
WHERE order_date <= '2024-12-31'
GROUP BY customer_id, YEAR(order_date)
HAVING COUNT(DISTINCT order_id) >= 3;

ALTER TABLE tmp_high_cust ADD INDEX idx_custid(customer_id);

DROP TEMPORARY TABLE IF EXISTS tmp_high_order;
CREATE TEMPORARY TABLE tmp_high_order
SELECT DISTINCT order_id, customer_id 
FROM orders
WHERE order_date <= '2024-12-31' 
  AND customer_id IN (SELECT customer_id FROM tmp_high_cust);

ALTER TABLE tmp_high_order ADD INDEX idx_oid(order_id);

SELECT
    CASE
        WHEN p.price < 50 THEN '低价<50'
        WHEN p.price BETWEEN 50 AND 200 THEN '中端50~200'
        ELSE '高价>200'
    END AS price_level,
    s.supplier_id,
    s.country,
    SUM(oi.qty) AS total_buy_qty
FROM tmp_high_order ho
JOIN order_items oi ON ho.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
JOIN suppliers s ON p.supplier_id = s.supplier_id
GROUP BY price_level, s.supplier_id, s.country
ORDER BY total_buy_qty DESC;
