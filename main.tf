terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.69.1"
    }
  }
}

provider "google" {
  project = "my-learning-de"
  region  = "us-west4"
}

import {
  to = google_storage_bucket.marketcap_bucket
  id = "crypto_marketcap"
}

resource "google_storage_bucket" "marketcap_bucket" {
  name     = "crypto_marketcap"
  location = "us-west4"
}

import {
  to = google_storage_bucket.cloud_fns_bucket
  id = "gcf-v2-sources-823447068653-us-west4"
}

resource "google_storage_bucket" "cloud_fns_bucket" {
  name     = "gcf-v2-sources-823447068653-us-west4"
  location = "us-west4"

  lifecycle {
    ignore_changes = [
      cors,
      lifecycle_rule
    ]
  }
}

resource "google_storage_bucket_object" "transform_marketcap_zip" {
  name   = "transform_marketcap/function-source.zip"
  source = "./cloud_functions/transform_marketcap/function-source.zip"
  bucket = google_storage_bucket.cloud_fns_bucket.name
}

resource "google_storage_bucket_object" "load_file_into_cloud_storage_zip" {
  name   = "load_file_into_cloud_storage/function-source.zip"
  source = "./cloud_functions/load_to_warehouse/function-source.zip"
  bucket = google_storage_bucket.cloud_fns_bucket.name
}

import {
  to = google_cloudfunctions2_function.transform_marketcap_fn
  id = "projects/my-learning-de/locations/us-west4/functions/transform_marketcap"
}

resource "google_cloudfunctions2_function" "transform_marketcap_fn" {
  name     = "transform_marketcap"
  location = "us-west4"

  build_config {
    runtime     = "python311"
    entry_point = "transform_html_into_csv"
    source {
      storage_source {
        bucket = google_storage_bucket.cloud_fns_bucket.name
        object = google_storage_bucket_object.transform_marketcap_zip.name
      }
    }
  }

  service_config {
    timeout_seconds                  = 60
    max_instance_count               = 2
    min_instance_count               = 0
    max_instance_request_concurrency = 1
    available_memory                 = "256M"
    service_account_email            = "823447068653-compute@developer.gserviceaccount.com"
    service                          = "projects/my-learning-de/locations/us-west4/services/transform-marketcap"
    ingress_settings                 = "ALLOW_ALL"
    environment_variables            = {}
    available_cpu                    = "0.1666"
    all_traffic_on_latest_revision   = true
  }

  lifecycle {
    ignore_changes = [labels, timeouts]
  }
}

import {
  to = google_cloudfunctions2_function.load_file_into_cloud_storage
  id = "projects/my-learning-de/locations/us-west4/functions/load_file_into_cloud_storage"
}

resource "google_cloudfunctions2_function" "load_file_into_cloud_storage" {
  name     = "load_file_into_cloud_storage"
  location = "us-west4"

  build_config {
    runtime     = "python311"
    entry_point = "load_file_into_cloud_storage"
    source {
      storage_source {
        bucket = google_storage_bucket.cloud_fns_bucket.name
        object = google_storage_bucket_object.load_file_into_cloud_storage_zip.name
      }
    }
  }

  service_config {
    timeout_seconds                  = 60
    max_instance_count               = 2
    min_instance_count               = 0
    max_instance_request_concurrency = 1
    available_memory                 = "256M"
    service_account_email            = "823447068653-compute@developer.gserviceaccount.com"
    service                          = "projects/my-learning-de/locations/us-west4/services/load-file-into-cloud-storage"
    ingress_settings                 = "ALLOW_ALL"
    available_cpu                    = "0.1666"
    all_traffic_on_latest_revision   = true
    environment_variables = {
      "BUCKET_NAME" = "crypto_marketcap"
    }
  }

  lifecycle {
    ignore_changes = [labels, timeouts]
  }
}
