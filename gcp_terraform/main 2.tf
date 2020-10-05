locals {
  billing_data_project    = "billing-data"
  billing_data_project_id = "${local.billing_data_project}-${var.salt}"
}

resource "google_folder" "gcp_org_billing_folder" {
  display_name = "Billing"
  parent       = "organizations/${var.organization_id}"
}

resource "google_project" "gcp_org_billing_project_data" {
  name       = local.billing_data_project
  project_id = local.billing_data_project_id

  folder_id       = google_folder.gcp_org_billing_folder.id
  billing_account = var.billing_account_id

  labels = {
    "cost-code" = var.cost_code
  }
}

resource "google_project_service" "billing_data_project_services" {
  project                    = google_project.gcp_org_billing_project_data.project_id
  count                      = length(var.billing_services)
  service                    = element(var.billing_services, count.index)
  disable_on_destroy         = true
  disable_dependent_services = true
}

resource "google_storage_bucket" "billing_data_bucket" {
  project       = google_project.gcp_org_billing_project_data.project_id
  name          = "billing_data-${var.salt}"
  location      = "EU"
  force_destroy = false
  storage_class = "MULTI_REGIONAL"

  versioning {
    enabled = "true"
  }

  logging {
    log_bucket = "audit_log-${var.salt}"
  }
}

/* Below is a section dedicated to create billing exports from BQ including
 * creating bundling source code for Google Cloud Function, deploying this func,
 * setting up execution, etc.
 */
resource "google_storage_bucket" "bq-export-func" {
  project       = google_project.gcp_org_billing_project_data.project_id
  name          = "billing-bq-export-${var.salt}"
  location      = "London"
  force_destroy = false
  storage_class = "REGIONAL"

  logging {
    log_bucket = "audit_log-${var.salt}"
  }
}

resource "null_resource" "bundle-bq-exp-func" {
  provisioner "local-exec" {
    command = "git archive --format=tar HEAD:billing/export --prefix bq-export/ -o bq-export.zip"
  }
}

resource "google_storage_bucket_object" "func-archive" {
  depends_on = [null_resource.bundle-bq-exp-func]
  name       = "bq-export.zip"
  bucket     = google_storage_bucket.bq-export-func.name
  source     = "./bq-export.zip"
}

resource "google_cloudfunctions_function" "bq-billing-exp-func" {
  name        = "bq-billing-exp-func"
  description = "Fucntion for exporting billing data from BQ into GCS for Recharger processing"
  runtime     = "python37"

  available_memory_mb   = 128
  source_archive_bucket = google_storage_bucket.bq-export-func.name
  source_archive_object = google_storage_bucket_object.func-archive.name
  trigger_http          = true
  timeout               = 60
  entry_point           = "main"
  max_instances         = 1
  labels = {
    "cost-code" = var.cost_code
  }

  environment_variables = {
    GCS_BUCKET = google_storage_bucket.billing_data_bucket.name
  }
}

resource "google_cloud_scheduler_job" "bq-billing-exp-func-scheduler" {
  name             = "bq-billing-exp-func-cron"
  description      = "Scheduler for running billing BQ exports to GCS for Recharger"
  schedule         = "07 12 * * *"
  time_zone        = "Europe/London"
  attempt_deadline = "60s"

  http_target {
    http_method = "GET"
    uri         = google_cloudfunctions_function.bq-billing-exp-func.https_trigger_url
  }
}

/*
# IAM entry for a single user to invoke the function
resource "google_cloudfunctions_function_iam_member" "invoker" {
  project        = google_cloudfunctions_function.bq-billing-exp-func.project
  region         = google_cloudfunctions_function.bq-billing-exp-func.region
  cloud_function = google_cloudfunctions_function.bq-billing-exp-func.name

  role   = "roles/cloudfunctions.invoker"
  member = "user:stephanie.gooch@kpmg.co.uk"
}
*/
