# 💸 Data Exploration (Synthetic Fraud Dataset) — SQL Project

This project analyzes 1 million simulated financial transactions using SQL to detect patterns of fraud and anomalies. It focuses on identifying suspicious behavior in TRANSFER and CASH_OUT transactions through data cleaning, feature engineering, and outlier detection — all without the use of external tools or programming languages.

## 📂 Project Structure

```
aml-fraud-detection/
├── sfd_fraud_1m.csv                          # The raw transaction dataset (1 million rows)
├── Data Exploration (synthetic fraud dataset).sql  # Complete SQL script with detailed comments
├── README.md                                 # Project documentation
```

## 🔧 Requirements

- **MySQL 8.0+**
- File import permissions (`local_infile = ON`)
- Ability to execute global settings like `SET GLOBAL local_infile`

## ⚙️ How to Run the Project

1. **Start MySQL Workbench or your preferred client.**
2. **Open and execute `Data Exploration (synthetic fraud dataset).sql`.**  
   This script:
   - Creates the schema and main table
   - Imports the dataset
   - Cleans and standardizes column names
   - Filters only relevant transaction types
   - Detects balance errors
   - Flags outliers based on receiver-specific averages
   - Labels transactions into `Normal`, `Suspicious`, `Extreme`, or `Small Sample`

3. **Preview the final results** using:
   ```sql
   SELECT * FROM tc_table;
   ```

## 📊 Key Features

- ✅ Pure SQL — no need for Python, R, or external libraries
- ✅ Outlier detection based on dynamic receiver-based averages
- ✅ Balance validation to detect impossible or suspicious transactions
- ✅ Categorized transaction behaviors (`Normal`, `Suspicious`, `Extreme`)
- ✅ Well-commented and logically ordered script for educational use

## 📌 Dataset Fields

| Column            | Description                                       |
|-------------------|---------------------------------------------------|
| step              | Hour of the simulation                            |
| type              | Transaction type (e.g., TRANSFER, CASH_OUT)       |
| amount            | Transaction amount                                |
| name_orig         | Sender's unique ID                                |
| oldbalance_orig   | Sender's balance before the transaction           |
| newbalance_orig   | Sender's balance after the transaction            |
| name_dest         | Receiver's unique ID                              |
| oldbalance_dest   | Receiver's balance before the transaction         |
| newbalance_dest   | Receiver's balance after the transaction          |
| is_fraud          | 1 if the transaction was fraudulent               |
| is_flagged_fraud  | 1 if flagged as fraud (even if unconfirmed)       |

## 🧠 Learning Goals

- Practice large-scale data handling in SQL
- Apply basic fraud detection logic using raw SQL
- Explore schema design and data standardization
- Learn to categorize outliers and anomalies within financial data

## 📁 License

This project is for **educational purposes only**. The dataset is simulated and does not contain real financial records.
