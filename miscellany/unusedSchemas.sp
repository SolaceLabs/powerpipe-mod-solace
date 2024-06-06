dashboard "solace_unused_schemas_dashboard" {
  title = "[7] Unused Schemas"

  text {
    value = "Miscellaneous Central: Your Go-To Dashboard for All Things Random!"
  }

  container {
    title = "Unused Schemas"

    table {
      sql = <<-EOQ
        SELECT 
          d.name as "Domain Name", 
          s.name as "Schema Name", 
          string_agg('v' || sv.version || 
            CASE WHEN sv.state_id = '1' THEN ' (Draft)'
              WHEN sv.state_id = '2' THEN ' (Released)'
              WHEN sv.state_id = '3' THEN ' (Deprecated)'
              WHEN sv.state_id = '4' THEN ' (Retired)'
            END, ', ') as "Schema Versions"
          FROM solace_schema_version sv
          JOIN solace_schema s ON s.id = sv.schema_id
          JOIN solace_application_domain d on s.application_domain_id = d.id
          WHERE sv.referenced_by_event_version_ids = '[]' AND sv.referenced_by_schema_version_ids = '[]'
          GROUP BY s.id, s.name, d.name
          ORDER BY s.id, s.name, d.name
      EOQ
    }
  }

}