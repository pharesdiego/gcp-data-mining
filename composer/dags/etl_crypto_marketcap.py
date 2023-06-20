from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.bash import BashOperator

default_args = {
    'email': ['test@test.com'],
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 3,
    'retry_delay': timedelta(seconds=30)
}

with DAG(
    'etl_crypto_marketcap',
    default_args=default_args,
    description='Mines data from site, converts to csv and loads into GCP',
    schedule=timedelta(minutes=5),
    start_date=datetime(2023, 6, 15),
    catchup=False
) as dag:
    setup = BashOperator(
        task_id='setup_task',
        bash_command='temp_folder=$HOME/{{var.value.get("DATA_FOLDER")}}/$(date +%N) && mkdir $temp_folder && echo $temp_folder'
    )

    extract = BashOperator(
        task_id='extract_data',
        bash_command='curl -s -L --compressed {{var.value.get("SITE_URL")}} >> {{ti.xcom_pull("setup_task")}}/temp.html'
    )

    transform = BashOperator(
        task_id='transform_data',
        bash_command='curl -d @{{ti.xcom_pull("setup_task")}}/temp.html -H "Content-Type: text/plain" {{var.value.get("TRANSFORM_FN_URL")}} >> {{ti.xcom_pull("setup_task")}}/temp.csv'
    )

    load = BashOperator(
        task_id='load_data',
        bash_command='curl --form file=@{{ti.xcom_pull("setup_task")}}/temp.csv {{var.value.get("LOAD_FN_URL")}}'
    )

    cleanup = BashOperator(
        task_id='cleanup_files',
        bash_command='rm -r {{ti.xcom_pull("setup_task")}}'
    )

    setup >> extract >> transform >> load >> cleanup
