# GitHub 上传操作指南

> 本指南基于 GitHub 官方文档 编写，适用于将本地项目上传至已创建的 GitHub 仓库。citeweb_search:5#0

## 前置条件

- [x] GitHub 账号已注册
- [x] 已在 GitHub 创建名为 `零售数据分析` 的仓库（可空仓库，也可带 README）
- [x] 本地已安装 Git（命令行输入 `git --version` 验证）

## 方式一：Git 命令行上传（推荐）

### 步骤1：进入项目目录

```bash
# Windows: 在项目文件夹地址栏输入 cmd 回车
# Mac/Linux: 打开终端，cd 到项目目录
cd /path/to/零售数据分析
```

### 步骤2：初始化 Git 仓库

```bash
git init
```

### 步骤3：添加所有文件到暂存区

```bash
git add .
```

### 步骤4：提交文件到本地仓库

```bash
git commit -m "feat: 初始化零售数据分析项目

- 添加8个核心SQL分析模块
- 添加数据库表结构DDL
- 添加数据字典和分析文档
- 添加README和.gitignore"
```

### 步骤5：关联远程仓库

```bash
# 替换为你的实际仓库地址
git remote add origin https://github.com/你的用户名/零售数据分析.git
```

### 步骤6：推送代码到 GitHub

```bash
# 如果仓库是空的（没有README/License）
git push -u origin main

# 如果仓库已有文件（如README），先拉取再推送
git pull origin main --rebase
git push -u origin main
```

### 步骤7：验证上传

打开浏览器访问 `https://github.com/你的用户名/零售数据分析`，确认文件已上传。

---

## 方式二：GitHub 网页直接上传（适合小文件/快速上传）

1. 打开你的 GitHub 仓库页面
2. 点击 **"Add file"** → **"Upload files"**
3. 将本地项目文件夹中的文件/文件夹 **拖拽** 到浏览器上传区域
4. 在 "Commit changes" 区域填写提交信息
5. 点击 **"Commit changes"** 完成上传 citeweb_search:5#6

> ⚠️ 注意：网页上传不支持 `.gitattributes` 的行尾自动转换功能，大文件或批量上传建议使用 Git 命令行。

---

## 常见问题解决

### Q1: 提示 "fatal: refusing to merge unrelated histories"

```bash
git pull origin main --allow-unrelated-histories
git push -u origin main
```

### Q2: 提示 "Permission denied" 或需要输入密码

- 使用 HTTPS 方式时，GitHub 已不支持密码验证，需使用 **Personal Access Token** 代替密码
- 或在 GitHub 设置 → Developer settings → Personal access tokens 生成 Token

### Q3: 分支名是 master 还是 main？

- GitHub 新仓库默认分支为 `main`
- 如果本地初始化后默认是 `master`，可执行：
  ```bash
  git branch -M main
  git push -u origin main
  ```

### Q4: 如何后续更新代码？

```bash
# 修改文件后，重复以下步骤
git add .
git commit -m "update: 更新分析模块X"
git push origin main
```

---

## 项目文件清单

上传后你的 GitHub 仓库应包含以下文件：

```
零售数据分析/
├── .gitignore              # Git忽略规则
├── README.md               # 项目说明文档
├── data/
│   └── .gitkeep            # 保留空目录（实际数据不上传）
├── docs/
│   ├── analysis_guide.md   # 分析执行指南
│   └── data_dictionary.md  # 数据字典
└── sql/
    ├── 00_ddl_schema.sql   # 数据库表结构
    ├── 01_rfm_base.sql     # RFM基础指标
    ├── 02_rfm_segmentation.sql  # RFM客户分层
    ├── 03_high_rebuy_city_month.sql  # 高复购城市分布
    ├── 04_city_return_analysis.sql   # 城市退货分析
    ├── 05_category_sales_return.sql  # 品类销售退货
    ├── 06_price_supplier_analysis.sql # 价格带供应商
    ├── 07_customer_type_ratio.sql    # 客户分层占比
    └── 08_customer_type_return.sql    # 分层与退货关联
```

---

## 安全提醒

1. **不要上传真实业务数据**：`data/` 目录已配置 `.gitignore` 忽略 `.csv`、`.xlsx` 等数据文件
2. **不要上传数据库连接配置**：避免将含密码的配置文件提交到仓库
3. **Excel 分析结果**：建议在本地保留，或在 GitHub 发布脱敏后的样本数据

---

## 参考文档

- [GitHub 官方上传指南](https://docs.github.com/zh/get-started/start-your-journey/uploading-a-project-to-github) citeweb_search:5#0
- [GitHub 添加文件到仓库](https://docs.github.com/zh/repositories/working-with-files/managing-files/adding-a-file-to-a-repository) citeweb_search:5#6
