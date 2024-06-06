dashboard "solace_shared_schemas_dashboard" {
  title = "[8] Shared Schemas"

  text {
    value = "Miscellaneous Central: Your Go-To Dashboard for All Things Random!"
  }

  container {
    title = "Shared Schemas"

    table {
      sql = <<-EOQ
        WITH evids AS (
          SELECT string_to_table(replace(replace(replace(sv.referenced_by_event_version_ids, '[', ''), ']', ''), ' ', ', '), ', ') as evid, 
                  sv.id as svid,
                  d.id as did,
                  d.name as dname,
                  e.id as eid
          FROM solace_schema_version sv 
          JOIN solace_schema s ON s.id = sv.schema_id
          JOIN solace_event_version ev ON sv.referenced_by_event_version_ids LIKE '%' || ev.id || '%'
          JOIN solace_event e ON e.id = ev.event_id 
          JOIN solace_application_domain d on e.application_domain_id = d.id
          WHERE sv.referenced_by_event_version_ids != '[]'
          ORDER BY sv.id
        )
        SELECT
          s.name as "Schema Name", 
          d.name as "Source Domain Name", 
          evids.dname as "Referencing Domain Name",
          e.name as "Referencing Event Name"
        FROM evids
        JOIN solace_schema_version sv ON evids.svid = sv.id
        JOIN solace_schema s ON s.id = sv.schema_id 
        JOIN solace_event_version ev ON sv.referenced_by_event_version_ids LIKE '%' || ev.id || '%'
        JOIN solace_event e ON e.id = ev.event_id and e.id <> evids.eid
        JOIN solace_event_version ev2 ON ev2.id = evids.evid
        JOIN solace_event e2 ON e2.id = ev2.event_id
        JOIN solace_application_domain d on d.id = s.application_domain_id AND d.id <> evids.did
        GROUP BY s.name, evids.dname, d.name, e.name
        ORDER BY s.name, evids.dname, d.name, e.name

      EOQ
    }
  }

}