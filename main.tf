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
}

import {
  to = google_cloudfunctions2_function.transform_marketcap_fn
  id = "projects/my-learning-de/locations/us-west4/functions/transform_marketcap"
}

resource "google_cloudfunctions2_function" "transform_marketcap_fn" {
  name = "transform_marketcap"
  location = "us-west4"

  build_config {
    runtime = "python311"
    entry_point = "transform_html_into_csv"
    source {
      bucket = google_storage_bucket.cloud_fns_bucket.name
    }
  }
}
