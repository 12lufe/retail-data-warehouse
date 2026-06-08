# 分析说明文档

## 分析执行顺序

建议按以下顺序执行SQL文件，部分分析存在依赖关系：

| 序号 | 文件名 | 依赖 | 说明 |
|------|--------|------|------|
| 0 | `00_ddl_schema.sql` | 无 | 创建表结构（首次使用） |
| 1 | `01_rfm_base.sql` | 无 | RFM基础指标计算 |
| 2 | `02_rfm_segmentation.sql` | 无 | RFM客户分层（可独立运行） |
| 3 | `03_high_rebuy_city_month.sql` | 无 | 高复购客户城市分布 |
| 4 | `04_city_return_analysis.sql` | 无 | 城市退货分析 |
| 5 | `05_category_sales_return.sql` | 无 | 品类销售与退货 |
| 6 | `06_price_supplier_analysis.sql` | 无 | 价格带与供应商分析 |
| 7 | `07_customer_type_ratio.sql` | tmp_rfm表 | 需先执行01或02生成临时表 |
| 8 | `08_customer_type_return.sql` | tmp_rfm表 | 需先执行01或02生成临时表 |

> **注意**: 模块7和8依赖`tmp_rfm`表。建议在Navicat中先执行模块1或2，将结果保存为临时表/视图后再执行7和8。

## 各模块输出字段说明

### 模块1: RFM基础指标
- `customer_id`: 客户ID
- `city`: 所在城市
- `signup_date`: 注册日期
- `R`: 最近购买距2024-02-01的天数（越小越活跃）
- `F_all`: 总购买订单数
- `M`: 总消费金额
- `is_high_rebuy`: 是否高复购客户（1=是，0=否）

### 模块2: RFM客户分层
- 在模块1基础上增加：
- `R_score`/`F_score`/`M_score`: RFM五分位评分（1-5分）
- `rfm_tag`: RFM组合标签（如"555"表示高分客户）
- `cust_type`: 客户分层类型

### 模块3: 高复购城市分布
- `city`: 城市
- `reg_month`: 注册月份（YYYY-MM格式）
- `high_cust_num`: 高复购客户数
- `avg_R`/`avg_F`/`avg_M`: 平均RFM指标

### 模块4: 城市退货分析
- `city`: 城市
- `total_order`: 总订单数
- `ret_order`: 退货订单数
- `return_rate`: 退货率
- `high_cust_count`: 高复购客户数

### 模块5: 品类分析（3个查询）
- `category_name`: 品类名称
- `all_sale_qty`: 总销量
- `ret_qty`: 退货数量
- `cat_return_rate`: 品类退货率
- `high_cust_buy_qty`: 高复购客户购买量

### 模块6: 价格带分析
- `price_level`: 价格带（低价/中端/高价）
- `supplier_id`/`country`: 供应商信息
- `total_buy_qty`: 高复购客户购买量

### 模块7: 客户分层占比
- `cust_type`: 客户类型
- `customer_count`: 客户数量
- `ratio`: 占比（基于9999总客户数）

### 模块8: 分层与退货关联
- `cust_type`: 客户类型
- `customer_count`: 客户数量
- `avg_return_times`: 平均退货次数

## 关键业务洞察方向

1. **客户价值识别**: 通过RFM找到高价值客户，制定差异化运营策略
2. **城市运营优化**: 结合退货率和高复购客户数，识别优质/问题城市
3. **品类管理**: 通过退货率识别质量问题品类，优化供应链
4. **价格策略**: 分析高复购客户价格偏好，指导定价和促销
5. **流失预警**: 通过R值识别即将流失客户，及时激活

## Excel导出建议

在Navicat中执行SQL后，右键结果集 → 导出向导 → Excel格式：
- 建议每个SQL单独导出为一个Sheet
- 文件名格式：`零售数据分析_模块X_YYYYMMDD.xlsx`
- 可在GitHub `data/` 目录中保留导出的样本数据（注意脱敏）
