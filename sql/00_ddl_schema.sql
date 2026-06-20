-- ============================================
-- 零售数据分析 - 数据库表结构DDL
-- 数据库: MySQL 8.0+
-- 表数量: 12张
-- ============================================

-- 1. 商品分类表
CREATE TABLE categories (
    category_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '分类ID',
    category_name VARCHAR(100) NOT NULL COMMENT '分类名称'
) COMMENT='商品分类表';

-- 2. 客户表
CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '客户ID',
    city VARCHAR(50) NOT NULL COMMENT '所在城市',
    signup_date DATE NOT NULL COMMENT '注册日期'
) COMMENT='客户信息表';

-- 3. 员工表
CREATE TABLE employees (
    employee_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '员工ID',
    store_id INT NOT NULL COMMENT '所属门店ID',
    salary DECIMAL(10,2) NOT NULL COMMENT '薪资'
) COMMENT='员工信息表';

-- 4. 订单明细表
CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '明细ID',
    order_id INT NOT NULL COMMENT '订单ID',
    product_id INT NOT NULL COMMENT '商品ID',
    qty INT NOT NULL DEFAULT 1 COMMENT '购买数量',
    price DECIMAL(10,2) NOT NULL COMMENT '单价'
) COMMENT='订单明细表';

-- 5. 订单主表
CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '订单ID',
    customer_id INT NOT NULL COMMENT '客户ID',
    store_id INT NOT NULL COMMENT '门店ID',
    order_date DATETIME NOT NULL COMMENT '下单日期',
    promotion_id INT COMMENT '促销ID'
) COMMENT='订单主表';

-- 6. 支付表
CREATE TABLE payments (
    payment_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '支付ID',
    order_id INT NOT NULL COMMENT '订单ID',
    amount DECIMAL(10,2) NOT NULL COMMENT '支付金额'
) COMMENT='支付记录表';

-- 7. 商品表
CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '商品ID',
    category_id INT NOT NULL COMMENT '分类ID',
    supplier_id INT NOT NULL COMMENT '供应商ID',
    price DECIMAL(10,2) NOT NULL COMMENT '售价'
) COMMENT='商品信息表';

-- 8. 促销表
CREATE TABLE promotions (
    promotion_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '促销ID',
    discount DECIMAL(4,2) NOT NULL COMMENT '折扣率(0.00-1.00)'
) COMMENT='促销活动表';

-- 9. 退货表
CREATE TABLE returns (
    return_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '退货ID',
    order_item_id INT NOT NULL COMMENT '订单明细ID',
    refund DECIMAL(10,2) NOT NULL COMMENT '退款金额'
) COMMENT='退货记录表';

-- 10. 物流表
CREATE TABLE shipments (
    shipment_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '物流ID',
    order_id INT NOT NULL COMMENT '订单ID',
    status VARCHAR(20) NOT NULL COMMENT '物流状态'
) COMMENT='物流信息表';

-- 11. 门店表
CREATE TABLE stores (
    store_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '门店ID',
    city VARCHAR(50) NOT NULL COMMENT '所在城市'
) COMMENT='门店信息表';

-- 12. 供应商表
CREATE TABLE suppliers (
    supplier_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '供应商ID',
    country VARCHAR(50) NOT NULL COMMENT '国家'
) COMMENT='供应商信息表';

-- 添加外键约束
ALTER TABLE orders ADD FOREIGN KEY (customer_id) REFERENCES customers(customer_id);
ALTER TABLE orders ADD FOREIGN KEY (store_id) REFERENCES stores(store_id);
ALTER TABLE order_items ADD FOREIGN KEY (order_id) REFERENCES orders(order_id);
ALTER TABLE order_items ADD FOREIGN KEY (product_id) REFERENCES products(product_id);
ALTER TABLE products ADD FOREIGN KEY (category_id) REFERENCES categories(category_id);
ALTER TABLE products ADD FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id);
ALTER TABLE payments ADD FOREIGN KEY (order_id) REFERENCES orders(order_id);
ALTER TABLE returns ADD FOREIGN KEY (order_item_id) REFERENCES order_items(order_item_id);
ALTER TABLE employees ADD FOREIGN KEY (store_id) REFERENCES stores(store_id);
