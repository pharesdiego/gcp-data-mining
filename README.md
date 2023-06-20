# Crypto prices miner
Automated ETL pipeline to mine data from market cap sites to analyze prices' evolution over time.

## Architecture
The whole architecture is managed with Terraform, which makes it easy to understand how the services are connected. This is an overall look into how things work:

1. Google's Composer (Airflow) is used to orchestrate task to mine the data.
2. Every 5 minutes the DAG fetches data from the site and passes that data down to multiple Cloud Functions that transform and load data.
3. Data is loaded in a Cloud Storage bucket.

![ETL architecture image](/assets/etl_diagram.png)

## Main features
* Automatic retrieval of cryptocurrency market capitalization data using Airflow.
* Data is stored in a Cloud Storage bucket.
* Stored data can be used for exploring market trends and overall BI.
* Uses Terraform to easily manage architecture.

## Stored data
CSVs are loaded into the bucket and are ready for trend analysis. Example of one of the generated CSVs:
```

|   name     | symbol |    price   |
|------------|--------|------------|
| Bitcoin    |  BTC   | $24,960.31 |
| Ethereum   |  ETH   | $1,638.19  |
| Tether     | USDT   |   $0.999   |
| BNB        |  BNB   |  $232.21   |
| USD Coin   | USDC   |   $1.00    |
```