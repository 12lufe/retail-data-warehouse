# 数据字典

## 表关系图

```
categories (1) ───< products (N) ───< order_items (N) ───> orders (1) ───< payments (N)
                          │                              │
                    suppliers (1)                    customers (1)
                          │                              │
                                                       stores (1)
                                                          │
                                                    employees (N)

orders (1) ───< shipments (N)
order_items (1) ───< returns (N)
orders (N) ───> promotions (1)
```

## 字段详细说明

### categories 商品分类表
| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| category_id | INT | PK, AI | 分类唯一标识 |
| category_name | VARCHAR(100) | NOT NULL | 分类名称，如：电子产品、服装、食品等 |

### customers 客户表
| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| customer_id | INT | PK, AI | 客户唯一标识 |
| city | VARCHAR(50) | NOT NULL | 客户所在城市，如：北京、上海、广州 |
| signup_date | DATE | NOT NULL | 客户注册日期，格式：YYYY-MM-DD |

### employees 员工表
| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| employee_id | INT | PK, AI | 员工唯一标识 |
| store_id | INT | NOT NULL | 所属门店ID，关联stores表 |
| salary | DECIMAL(10,2) | NOT NULL | 员工月薪 |

### order_items 订单明细表
| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| order_item_id | INT | PK, AI | 明细唯一标识 |
| order_id | INT | NOT NULL | 所属订单ID，关联orders表 |
| product_id | INT | NOT NULL | 商品ID，关联products表 |
| qty | INT | NOT NULL, DEFAULT 1 | 购买数量 |
| price | DECIMAL(10,2) | NOT NULL | 商品单价（下单时价格） |

### orders 订单主表
| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| order_id | INT | PK, AI | 订单唯一标识 |
| customer_id | INT | NOT NULL | 下单客户ID，关联customers表 |
| store_id | INT | NOT NULL | 订单所属门店ID，关联stores表 |
| order_date | DATETIME | NOT NULL | 下单时间 |
| promotion_id | INT | NULL | 使用的促销ID，关联promotions表 |

### payments 支付表
| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| payment_id | INT | PK, AI | 支付唯一标识 |
| order_id | INT | NOT NULL | 对应订单ID |
| amount | DECIMAL(10,2) | NOT NULL | 实际支付金额 |

### products 商品表
| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| product_id | INT | PK, AI | 商品唯一标识 |
| category_id | INT | NOT NULL | 所属分类ID |
| supplier_id | INT | NOT NULL | 供应商ID |
| price | DECIMAL(10,2) | NOT NULL | 商品售价 |

### promotions 促销表
| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| promotion_id | INT | PK, AI | 促销唯一标识 |
| discount | DECIMAL(4,2) | NOT NULL | 折扣率，范围0.00-1.00 |

### returns 退货表
| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| return_id | INT | PK, AI | 退货唯一标识 |
| order_item_id | INT | NOT NULL | 退货的订单明细ID |
| refund | DECIMAL(10,2) | NOT NULL | 退款金额 |

### shipments 物流表
| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| shipment_id | INT | PK, AI | 物流唯一标识 |
| order_id | INT | NOT NULL | 对应订单ID |
| status | VARCHAR(20) | NOT NULL | 物流状态：待发货/运输中/已签收/已退回 |

### stores 门店表
| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| store_id | INT | PK, AI | 门店唯一标识 |
| city | VARCHAR(50) | NOT NULL | 门店所在城市 |

### suppliers 供应商表
| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| supplier_id | INT | PK, AI | 供应商唯一标识 |
| country | VARCHAR(50) | NOT NULL | 供应商所在国家 |

## 核心指标定义

| 指标 | 计算方式 | 业务含义 |
|------|----------|----------|
| R (Recency) | DATEDIFF('2024-02-01', MAX(order_date)) | 客户最近一次购买距基准日的天数 |
| F (Frequency) | COUNT(DISTINCT order_id) | 客户总购买订单数 |
| M (Monetary) | SUM(payment_amount) | 客户总消费金额 |
| 高复购客户 | 自然年内下单≥3次 | 年活跃度高、忠诚度强的客户 |
| 退货率 | 退货订单数 / 总订单数 | 衡量商品质量或客户满意度 |
| 价格带 | 低价<50 / 中端50~200 / 高价>200 | 商品价格分层 |
