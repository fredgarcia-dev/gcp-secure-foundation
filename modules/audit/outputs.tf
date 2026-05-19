output "sink_name" {
  description = "The name of the audit log sink"
  value       = google_logging_project_sink.audit.name
}

output "bigquery_dataset_id" {
  description = "The BigQuery dataset ID for audit logs"
  value       = google_bigquery_dataset.audit_logs.dataset_id
}

output "audit_log_filter" {
  description = "The filter applied to the log sink (empty = all logs)"
  value       = google_logging_project_sink.audit.filter
}
