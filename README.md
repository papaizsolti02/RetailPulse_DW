# 📊 RetailPulse_DW

**RetailPulse_DW** is a robust and modular data warehouse pipeline built for processing and analyzing e-commerce data. It extracts data from multiple sources and processes them accordingly

### 🧺 Product Data Generation and Ingestion

#### 🔧 Synthetic Product Generation

Product records are generated using the `Faker` library and follow a controlled structure designed to reflect realistic e-commerce data:

- **Brands:** Nike, Adidas, Zara, H&M, Uniqlo, Puma, Levi's, Under Armour, Gap, Reebok
- **Categories by Gender:**
  - **Men:** T-Shirt, Jeans, Jacket, Shoe, Accessories
  - **Women:** Dress, Blouse, Skirt, Shoe, Handbag
  - **Kids:** T-Shirt, Short, Sneaker, Hoodie, Cap
- **Colors:** Black, White, Red, Blue, Green, Yellow, Pink, Gray, Beige, Navy

These product entries are inserted into the `[raw].[Products]` table and serve as the input for downstream ETL processes.

---

#### ⚙️ Staging Process: `[stage].[ProcessRawProducts]`

A stored procedure transforms and stages raw product data from `[raw].[Products]` into `[stage].[Products]`.

##### 🔁 Steps Performed:

1. **Table Initialization**
   - Checks for existence of `[stage].[Products]`.
   - Creates the table if it does not exist, including columns for metadata (e.g., `HASHDATA`, `BUSINESSKEYHASH`, `InsertedAt`).
   - If the table already exists, it is truncated to support a full refresh.

2. **Data Ingestion with Deduplication**
   - Inserts records from `[raw].[Products]` that do not already exist in the staging layer based on key attributes:
     - `Name`, `Brand`, `Category`, `Color`, `Gender`, `Price`

3. **Hashing**
   - Executes the `config.HashTableEntries` stored procedure with `@DataSourceId = 5`.
   - This adds row-level hashes (`HASHDATA`, `BUSINESSKEYHASH`) to support change tracking and SCD Type 2 logic.

4. **Transactional Safety**
   - All operations are wrapped in a `TRY...CATCH` block.
   - If an error occurs, the transaction is rolled back and the error is raised to ensure consistency.

---

##### 🏭 Production Load: SCD Type II

After staging and hashing, the records are merged into the `prod.ProductDim` table using **Slowly Changing Dimension Type II (SCD II)** logic. This ensures:

- **New products** are inserted with `IsCurrent = 1`.
- **Existing products with changes** have the old version closed (`IsCurrent = 0`, `EndDate` populated).
- **Historical tracking** of changes to price, color, brand, etc.

This design supports both point-in-time analytics and current state reporting.



### 👤 User Data Ingestion & Location Dimension Processing

#### 🌐 Data Source

- **API:** [randomuser.me](https://randomuser.me)
- **Frequency:** Daily
- **Volume:** 100–500 users/day (randomized)
- **Note:** Only a subset of users will place orders.

---

#### 🧭 Pipeline Overview

```text
API → raw.Users → stage.Users + stage.Territories + stage.SubTerritories → prod.UserDim + prod.TerritoriesDim + prod.SubTerritoriesDim
```

---

#### 🐍 Step 1: Daily User Fetch (Python)

##### Script Behavior

- Pulls a random number of users via `https://randomuser.me/api/`
- Loads JSON data into `raw.Users` via `[raw].[IngestRawUsers]`
- Invokes `[stage].[ProcessRawUsers]` to:
  - Parse data into structured format
  - Normalize location data
  - Populate `stage.Users` and related dimensions

---

#### ⚙️ Step 2: Raw to Stage Transformation

##### Stored Procedure: `[stage].[ProcessRawUsers]`

This procedure:

1. Truncates `stage.Users`
2. Parses and validates fields from `raw.Users`:
   - Filters invalid/unicode data using binary collation
3. Calls two dimension processors:
   - `[stage].[ProcessTerritories]`
   - `[stage].[ProcessSubTerritories]`
4. Resolves `SubTerritoryId` via joins
5. Populates `stage.Users`
6. Calls:
   - `config.HashTableEntries @DataSourceId = 1`
   - `prod.UpsertUsersDim` (Type 2 SCD merge)

---

#### 🗺️ Step 3: Territories Processing

##### Stored Procedure: `[stage].[ProcessTerritories]`

This procedure populates the `stage.Territories` table using country and state-level deduplication from `#ParsedUsers`.

###### Behavior:

- Inserts distinct `(Country, State)` combinations not already present
- Calls:
  - `config.HashTableEntries @DataSourceId = 2` (hashing for SCD Type 2)
  - `prod.MergeTerritoriesDim` (merge into `prod.TerritoriesDim`)
- Sets success/error output flags for traceability

---

#### 🏙️ Step 4: SubTerritories Processing

##### Stored Procedure: `[stage].[ProcessSubTerritories]`

This procedure loads the `stage.SubTerritories` table with city/street-level data tied to a territory.

###### Behavior:

- Joins `#ParsedUsers` to `stage.Territories` to determine `TerritoryId`
- Inserts distinct subterritory values:
  - `City`, `StreetName`, `Latitude`, `Longitude`
- Ensures no duplicates via `NOT EXISTS` logic
- Calls:
  - `config.HashTableEntries @DataSourceId = 3`
  - `prod.MergeSubTerritoriesDim` (merge into `prod.SubTerritoriesDim`)


### 💱 Daily Exchange Rate Processing

This module automates the ingestion and update of currency exchange rates relative to EUR, ensuring the data warehouse maintains accurate and timely financial conversions for e-commerce analytics.

---

#### 🐍 Python Function: `daily_exchange_rate_processing`

##### Description

Executes the entire daily workflow to process exchange rates, including:

- Verifying the existence of the country-currency reference data table (`[config].[CountryInfo]`).
- Ingesting country and currency metadata from a CSV source if missing.
- Retrieving countries and currencies needing exchange rates via a utility view.
- Querying the Frankfurter API to fetch the latest rates (currency → EUR).
- Handling API failures by logging warnings and defaulting to zero rates.
- Upserting the collected exchange rate data into the warehouse via stored procedure calls.

---

##### Workflow Details

1. **Country Info Verification & Ingestion**
   - Checks if `[config].[CountryInfo]` exists.
   - If not, reads from `datalake/countries.csv` and loads data through `[config].[IngestCountryInfo]`.

2. **Fetch Territory Currencies**
   - Queries `[utils].[GetTerritoryCurrencies]` view to identify all (Country, Currency) pairs requiring update.

3. **Exchange Rate Retrieval**
   - For each currency:
     - If currency = `EUR`, sets rate = 1.
     - Otherwise, requests exchange rate from Frankfurter API.
     - On failure, logs a warning and uses rate = 0.

4. **Upsert Exchange Rates**
   - Calls `[prod].[UpsertExchangeRate]` stored procedure for each (Country, Currency, Rate) tuple.
   - Commits changes to the database.

##### Description

Upserts exchange rates for a given country and currency into the `ExchangeRatesDim` dimension, maintaining historical versions with SCD Type II logic:

- Marks any previous current record for the currency as inactive.
- Inserts a new record marked as current with today's rate.

##### Behavior

- Updates all existing `IsCurrent = 1` records for the given `(Country, Currency)`:
  - Sets `IsCurrent = 0`
  - Sets `ExpirationDate` to today’s date.
- Inserts a new row with the current exchange rate, marked as `IsCurrent = 1`.

### Date Dimension Generation (`[prod].[GenerateDateDim]`)

Generates date records in `prod.DateDim` for a given date range.

#### Description

For each date between `@StartDate` and `@EndDate`, inserts a row with:

- `DateKey` (int, yyyyMMdd format)
- `FullDate`, `Day`, `Month`, `MonthName`, `Year`, `Quarter`
- `DayOfWeek`, `DayName`, `WeekOfYear`, `ISOWeek`
- Flags for `IsWeekend` and `IsLeapYear`

This table supports time-based analysis and reporting.

### 🛒 Transaction Data Pipeline

#### 🐍 Python Script: `daily_transaction_processing`

##### Purpose
Generates synthetic purchase transactions and processes them through the ETL pipeline.

##### Workflow
1. Generate subsets of users and products from DB.
2. Create 10-50 fake purchases with random carts and dates.
3. Insert JSON transactions into `[raw].[Transactions]`.
4. Call `[stage].[ProcessRawTransactions]` to parse and stage data.
5. Call `[prod].[InsertTransactionsFact]` to load fact table.

---

#### 🛠️ Stored Procedure: `[stage].[ProcessRawTransactions]`

##### Purpose
Parse raw JSON transactions, validate, enrich, and insert into staging.

##### Key points
- Truncates staging table.
- Reads raw transactions with cursor.
- Validates users, currencies, and exchange rates.
- Parses cart JSON to rows, calculates totals.
- Inserts detailed rows into `[stage].[Transactions]`.
- Handles errors gracefully.

---

#### 📦 Stored Procedure: `[prod].[InsertTransactionsFact]`

##### Purpose
Load staged data into production fact table.

##### Key points
- Creates fact table if missing.
- Inserts all staging records.
- Enforces foreign keys.
- Includes error handling.

Simulates daily transactions → raw JSON → staging detail → production fact. Supports multi-currency and referential integrity.

## 🏗️ Architecture Diagram

![RetailPulse Data Warehouse Architecture](./images/architecture_diagram.png)

## ⚙️ Utility Stored Procedures & Tables Documentation

### 🔐 Procedure: `config.HashTableEntries`

**Purpose:**
Generates hash values for rows in a dataset's processing table to enable efficient change detection.

**Inputs:**
- `@DataSourceID INT`: Identifier of the dataset.

**Process:**
- Retrieves the processing table name from `config.Datasets` based on `@DataSourceID`.
- Reads the ordered list of hash column expressions from `config.HashColumns` for the dataset.
- Concatenates these column values into a single string (`HASHDATA`).
- Creates a SHA2-512 hash (`BUSINESSKEYHASH`) from this concatenated string.
- Updates the processing table with these hash values.

**Error Handling:**
Raises errors if dataset or hash columns are missing, or on any execution error.

---

### 🗂️ Table: `config.HashColumns`

| Column      | Type         | Description                                   |
|-------------|--------------|-----------------------------------------------|
| Id          | INT (PK)     | Identity primary key                          |
| DatasetId   | INT          | FK to `config.Datasets`                       |
| ColumnName  | NVARCHAR(255)| Name of the column to hash                    |
| HashString  | NVARCHAR(255)| Expression/string used for concatenation     |
| HashOrder   | INT          | Order of columns when concatenating for hash |

---

### 🌍 Procedure: `config.IngestCountryInfo`

**Purpose:**
Ingests country and currency metadata into the `config.CountryInfo` table.

**Inputs:**
- `@CountryName NVARCHAR(255)`
- `@Currency NVARCHAR(10)`
- `@CurrencySymbol NVARCHAR(100)`

**Process:**
- Creates the `config.CountryInfo` table if it does not exist.
- Inserts a new record with the country name, currency code, and currency symbol.

---

### 🏷️ Table: `config.CountryInfo`

| Column         | Type          | Description                      |
|----------------|---------------|----------------------------------|
| Id             | INT (PK)      | Identity primary key             |
| CountryName    | NVARCHAR(255) | Name of the country             |
| Currency       | NVARCHAR(10)  | Currency code (e.g., EUR, USD)  |
| CurrencySymbol | NVARCHAR(100) | Currency symbol (e.g., €, $)    |
| InsertedAt     | DATETIME      | Timestamp when inserted          |

---

### 📊 Table: `config.Datasets`

| Column          | Type          | Description                              |
|-----------------|---------------|------------------------------------------|
| Id              | INT (PK)      | Identity primary key                     |
| Dataset         | NVARCHAR(100) | Name of the dataset                      |
| DatasetSource   | NVARCHAR(255) | Source description or location          |
| SourceRefreshType | NVARCHAR(50) | Type of refresh (e.g., daily, incremental) |
| LoadTable       | NVARCHAR(255) | Raw data load table                      |
| ProcessingTable | NVARCHAR(255) | Intermediate processing table            |
| FinalTable      | NVARCHAR(255) | Final destination table                   |
| CreatedAt       | DATETIME      | Record creation timestamp                 |

This table stores metadata about each dataset used in the system. It tracks where the data originates, how often it is refreshed, and the specific tables involved at different stages of the ETL process: raw loading, processing, and final output. This enables flexible management and automation of data workflows.

![Datasets Listed](./images/datasets_listed.png)


---
The **RetailPulse_DW** data warehouse pipeline offers a comprehensive, scalable solution for e-commerce analytics. By combining synthetic data generation, robust staging and production ETL processes, and sophisticated slowly changing dimension handling, it enables accurate, historical, and real-time insights. The modular design ensures easy extensibility and maintainability across product, user, transaction, and financial data domains, empowering data-driven decision-making with reliable and up-to-date information.