dashboard "solace_unused_events_dashboard" {
  title = "[5] Unused Events"

  text {
    value = "Miscellaneous Central: Your Go-To Dashboard for All Things Random!"
  }

  container {
    title = "Unused Events"

    table {
      sql = <<-EOQ
        SELECT 
          d.name as "Domain Name", 
          e.name as "Event Name", 
          string_agg('v' || ev.version || 
            CASE WHEN ev.state_id = '1' THEN ' (Draft)'
              WHEN ev.state_id = '2' THEN ' (Released)'
              WHEN ev.state_id = '3' THEN ' (Deprecated)'
              WHEN ev.state_id = '4' THEN ' (Retired)'
            END, ', ') as "Event Versions"
          FROM solace_event_version ev
          JOIN solace_event e ON e.id = ev.event_id
          JOIN solace_application_domain d on e.application_domain_id = d.id
          WHERE ev.declared_consuming_application_version_ids = '' AND ev.declared_producing_application_version_ids = ''
          GROUP BY e.id, e.name, d.name
          ORDER BY e.id, e.name, d.name
      EOQ
    }
  }

}