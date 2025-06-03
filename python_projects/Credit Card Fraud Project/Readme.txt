Credit Card Fraud Detection - Data Exploration
This project performs exploratory data analysis (EDA) on a credit card transaction dataset to investigate fraudulent activity and understand key data patterns.

📊 Dataset
The dataset used is the Credit Card Fraud Detection dataset made available by ULB. It contains transactions made by European cardholders in September 2013.

Total observations: 284,807

Features: 30 (anonymized)

Class label: 0 for legitimate, 1 for fraud

🧪 Objective
The goal of this project is to:

Understand the structure of the dataset

Perform data cleaning and formatting

Identify correlations and potential indicators of fraud

Investigate name frequencies (where applicable) tied to fraud patterns

🔍 Techniques Used
pandas for data loading and manipulation

matplotlib and seaborn for visualizations

Grouping, filtering, and aggregation

Frequency analysis of features in fraudulent cases

📌 Key Findings
Strong class imbalance: ~0.17% of transactions are fraudulent

Certain feature distributions (like V14, V10) show outliers in fraud cases

Patterns in names (when available) reveal individuals associated with multiple fraud instances

📁 Files
Data Exploration (credit card fraud).ipynb: Jupyter Notebook containing EDA steps and visualizations

Dataset assumed to be: creditcard.csv in the same folder

🚀 Future Work
Feature engineering and outlier handling

Model training with ML algorithms

Expanding to other datasets: finance, healthcare, AML, etc.

📚 Requirements
Python 3.x

Jupyter Notebook

pandas, numpy, matplotlib, seaborn

Install dependencies with:

bash
Copy
Edit
pip install pandas numpy matplotlib seaborn
📎 Credits
Dataset by ULB, available on Kaggle