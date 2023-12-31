variable "airflow_site_url" {
  description = "Site from where data is mined"
  type = string
}

variable "airflow_data_folder" {
  description = "Folder where files generated by DAGs are stored"
  type = string
}

variable "transform_cloudfn_url" {
  type = string
}

variable "load_file_cloudfn_url" {
  type = string
}
