-- ============================================
-- 分析模块5: 品类销售与退货分析
-- 目的: 分析各品类总销量、退货量、退货率及高复购客户购买占比
-- ============================================

DROP TEMPORARY TABLE IF EXISTS tmp_high_cust;
CREATE TEMPORARY TABLE tmp_high_cust
SELECT DISTINCT customer_id
FROM orders
WHERE order_date <= '2024-12-31'
GROUP BY customer_id, YEAR(order_date)
HAVING COUNT(DISTINCT order_id) >= 3;

-- 5.1 品类总销量
SELECT 
    ca.category_name,
    SUM(oi.qty) AS all_sale_qty
FROM categories ca
JOIN products p ON ca.category_id = p.category_id
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY ca.category_id, ca.category_name
ORDER BY all_sale_qty DESC;

-- 5.2 品类销量与退货量
SELECT 
    ca.category_name,
    SUM(oi.qty) AS all_sale_qty,
    SUM(IF(r.return_id IS NOT NULL, oi.qty, 0)) AS ret_qty
FROM categories ca
JOIN products p ON ca.category_id = p.category_id
JOIN order_items oi ON p.product_id = oi.product_id
LEFT JOIN returns r ON oi.order_item_id = r.order_item_id
GROUP BY ca.category_id, ca.category_name
ORDER BY all_sale_qty DESC;

-- 5.3 品类综合指标(含退货率和高复购客户购买量)
SELECT 
    ca.category_name,
    SUM(oi.qty) AS all_sale_qty,
    SUM(IF(r.return_id IS NOT NULL, oi.qty, 0)) AS ret_qty,
    ROUND(SUM(IF(r.return_id IS NOT NULL, oi.qty, 0)) / SUM(oi.qty), 4) AS cat_return_rate,
    SUM(IF(oi.order_id IN (
        SELECT order_id FROM orders 
        WHERE customer_id IN (SELECT customer_id FROM tmp_high_cust)
    ), oi.qty, 0)) AS high_cust_buy_qty
FROM categories ca
JOIN products p ON ca.category_id = p.category_id
JOIN order_items oi ON p.product_id = oi.product_id
LEFT JOIN returns r ON oi.order_item_id = r.order_item_id
GROUP BY ca.category_id, ca.category_name
ORDER BY high_cust_buy_qty DESC;
