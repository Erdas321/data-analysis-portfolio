Credit Card Fraud Detection - Exploratory Data Analysis
This project focuses on analyzing a credit card transaction dataset to identify patterns and insights related to fraudulent transactions. It performs basic data preparation, exploratory data analysis (EDA), and visualizations.

📁 Dataset
The dataset used (ccf_sampple.csv) contains records of credit card transactions with information such as transaction time, amount, merchant, location, and a fraud label.

📚 Libraries Used
pandas – for data manipulation

numpy – for numerical operations

matplotlib.pyplot – for visualizations

sklearn.model_selection – for splitting the dataset

🧪 Workflow Summary
Data Loading

The dataset is loaded into a pandas DataFrame from a CSV file.

Train/Test Split

70% of the dataset is used for training, and 30% is used for testing (all further analysis is performed on the test set).

Preprocessing

Display settings are adjusted for easier data exploration.

The gender column is standardized (F → Female, M → Male).

Exploratory Analysis

Fraud counts per state and per city.

Density of fraud across the U.S. using a scatter plot.

Fraud transactions per category with a horizontal bar chart.

Attempt to calculate percentage of population involved in fraud (incomplete).

📊 Visualizations
Scatter Plot: Fraud density by geographic location using latitude/longitude.

Bar Plot: Frequency of fraudulent transactions per purchase category.

📝 Notes
The test set contains 105,000 records across 24 columns.

Fraud analysis includes city and state-level breakdowns.

Additional data cleaning and analysis (e.g., population-based fraud percentage) are a work in progress.

🔧 Future Work
Clean and transform datetime columns for time-based analysis.

Add geospatial mapping with libraries like folium or geopandas.

Use machine learning models for predictive fraud detection.

📌 Disclaimer
This project is for learning and educational purposes. The dataset may be synthetic or anonymized.