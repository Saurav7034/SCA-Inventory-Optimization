# Inventory Forecasting & Stock Optimization Analysis

A SQL + Python analytics project focused on inventory visibility, stock risk detection, reorder-point estimation, inventory turnover, and stock-reduction recommendations across stores and products.

## Project Overview

This project analyzes an inventory dataset containing daily store-product records and operational factors such as sales, inventory, orders, demand forecast, price, discount, weather, promotions, competitor pricing, and seasonality.

The analysis is designed to answer practical supply-chain questions:

- How much inventory is held by each store and product?
- Which store-product combinations are at low stock levels?
- When should inventory be reordered based on recent demand?
- Which products are fast-selling or slow-moving?
- Where is excess stock potentially tying up working capital?
- How can inventory decisions be explored interactively by store?

## Dataset

The working dataset contains **109,500 rows and 15 columns**.

### Schema

| Column | Description |
|---|---|
| `Date` | Date of the inventory record |
| `Store_ID` / `Store ID` | Store identifier |
| `ProductID` / `Product ID` | Product identifier |
| `Category` | Product category |
| `Region` | Store/product region |
| `Inventory_Level` / `Inventory Level` | Inventory available at the record level |
| `Units_Sold` / `Units Sold` | Units sold |
| `Units_ordered` / `Units Ordered` | Units ordered |
| `Demand_Forecast` / `Demand Forecast` | Forecasted demand |
| `Price` | Product selling price |
| `Discount` | Discount percentage/value recorded in the dataset |
| `Weather_Condition` / `Weather Condition` | Weather condition |
| `Holiday_Promotion` / `Holiday/Promotion` | Promotion/holiday indicator |
| `Competitor_Pricing` / `Competitor Pricing` | Competitor price |
| `Seasonality` | Seasonal classification |

> The SQL table uses underscore-based column names, while the Python notebook uses the dataset's space-based names.

## Tools & Technologies

- **SQL / MySQL** — database creation, aggregation, joins, CTEs, filtering, conditional logic, and inventory calculations
- **Python** — analytical processing and business-rule calculations
- **Pandas & NumPy** — data manipulation and KPI calculations
- **Matplotlib & Seaborn** — visual analysis
- **ipywidgets** — interactive store-level dashboard

## Analysis Workflow

### 1. Data loading and inspection

The Python notebook loads the CSV into a Pandas DataFrame and checks the dataset structure. The notebook reports a shape of `109500 x 15`.

### 2. Stock-level analysis

For every store-product combination, the project calculates:

- Total stock
- Average stock
- Minimum stock
- Maximum stock

This provides a basic inventory profile for each product at each store.

### 3. Low-stock alerts

A simple low-stock threshold is set at **Inventory Level < 30**. The notebook identifies **137 low-stock instances** and summarizes the affected product-store combinations.

### 4. Reorder-point estimation

The project estimates a reorder point using average daily sales and an assumed **7-day lead time**:

`Reorder Point = Average Daily Sales × 7`

A product-store combination is marked **Reorder Now** when its average current inventory is below the estimated reorder point; otherwise it is marked **Stock OK**.

> This is a simplified operational rule and is not a statistically trained demand-forecasting model.

### 5. Inventory turnover analysis

Inventory turnover is calculated as:

`Turnover Ratio = Total Units Sold / Average Inventory`

Products are grouped into three movement categories using the project's thresholds:

- `SLOW-Moving`: turnover ratio ≤ 480
- `Moderate`: turnover ratio between 480 and 500
- `FAST-Selling`: turnover ratio > 500

The notebook visualizes the relationship between average inventory and total sales with turnover ratio represented through marker size/category.

### 6. Stock-reduction recommendations

The project estimates daily sales from a 30-day aggregation and calculates a one-week target stock level:

`Target Stock = Daily Sales × 7`

It then compares average inventory with target stock to derive a **suggested reduction**. The top recommendations are visualized to highlight store-product combinations where inventory is materially above the one-week target.

### 7. Interactive store dashboard

An interactive `ipywidgets` store selector provides store-specific views of:

- Inventory status split into Low vs OK
- Top 5 selling products
- Top 5 turnover ratios

This allows users to move from a network-level inventory view to store-level operational analysis.

## SQL Analysis

The SQL script creates a database and an `Inventory_Forecasting` table, loads the CSV data, and implements the core inventory analyses.

Key SQL techniques used include:

- `GROUP BY` for store/product-level aggregation
- `SUM`, `AVG`, `MIN`, and `MAX` for stock and sales metrics
- Subqueries and `JOIN` for product stock distribution across stores
- `CASE` statements for product movement classification
- Common Table Expressions (`CTE`) for stock-adjustment calculations
- Filtering and ordering for low-stock and reorder prioritization

## Example SQL Questions Addressed

```sql
-- Total inventory by product
SELECT
    ProductID,
    SUM(Inventory_Level) AS total_inventory
FROM Inventory_Forecasting
GROUP BY ProductID
ORDER BY total_inventory DESC;
```

```sql
-- Low inventory records
SELECT *
FROM Inventory_Forecasting
WHERE Inventory_Level < 30
ORDER BY Inventory_Level ASC
LIMIT 15;
```

```sql
-- Reorder point using a 7-day lead time
SELECT
    Store_ID,
    ProductID,
    ROUND(AVG(Units_Sold), 2) AS avg_daily_sales,
    ROUND(AVG(Units_Sold) * 7) AS reorder_point_estimate
FROM Inventory_Forecasting
GROUP BY Store_ID, ProductID;
```

## Key Outputs

The project produces the following business-oriented outputs:

| Output | Purpose |
|---|---|
| Store-product stock summary | Monitor total, average, minimum, and maximum inventory |
| Low-stock alert list | Flag products requiring attention |
| Reorder-point table | Prioritize replenishment using a 7-day rule |
| Turnover analysis | Identify fast-selling and slow-moving inventory |
| Stock-reduction recommendations | Identify potential inventory rationalization opportunities |
| Interactive store dashboard | Explore KPIs at individual-store level |

## Business Value

The analysis can support supply-chain decisions by helping teams prioritize replenishment, identify low-stock risk, distinguish fast-moving products from slower inventory, and locate potential excess stock.

It also demonstrates practical use of SQL and Python for moving from raw transactional-style data to operational KPIs and decision-support outputs.

## Project Structure

```text
.
├── Project sql.sql
├── Sql project.ipynb
├── inventory_forecasting.csv
└── README.md
```

## How to Run

### SQL

1. Open `Project sql.sql` in MySQL.
2. Create the database/table using the script.
3. Ensure `local_infile` is enabled if using the provided `LOAD DATA LOCAL INFILE` command.
4. Update the CSV path in the script to match your local file location.
5. Run the queries to reproduce the inventory analysis.

### Python

1. Place `inventory_forecasting.csv` in the notebook's working directory.
2. Open `Sql project.ipynb` in Jupyter Notebook/JupyterLab.
3. Install the required Python packages if needed:

```bash
pip install pandas numpy matplotlib seaborn ipywidgets
```

4. Run the notebook cells in order.

## Limitations & Assumptions

- The reorder-point calculation assumes a fixed **7-day lead time**.
- The low-stock rule uses a fixed threshold of **30 units**.
- Stock-reduction logic uses a one-week target based on average daily sales.
- Turnover categories use project-specific thresholds of 480 and 500 rather than externally benchmarked industry standards.
- Supplier performance cannot be directly evaluated because the dataset does not contain supplier-level delivery or lead-time performance fields.
- The project uses the existing `Demand_Forecast` field for analysis but does not train a machine-learning forecasting model.

## Project Outcome

This project demonstrates an end-to-end inventory analytics workflow: **data ingestion → KPI calculation → risk identification → replenishment logic → inventory optimization → visualization → interactive decision support**.
