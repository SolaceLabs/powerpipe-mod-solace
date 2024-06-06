dashboard "solace_shared_events_dashboard" {
  title = "[6] Shared Events"

  text {
    value = "Miscellaneous Central: Your Go-To Dashboard for All Things Random!"
  }

  container {
    title = "Shared Events"

    table {
      sql = <<-EOQ
        WITH avids AS (
          SELECT string_to_table(replace(ev.declared_consuming_application_version_ids || ', ' || 
                  ev.declared_producing_application_version_ids, '''',''), ', ') as aid, 
                  ev.id as evid,
                  d.id as did,
                  d.name as dname
          FROM solace_event_version ev 
          JOIN solace_event e ON e.id = ev.event_id
          JOIN solace_application_domain d on e.application_domain_id = d.id
          WHERE ev.declared_consuming_application_version_ids != '' AND ev.declared_producing_application_version_ids != ''
          ORDER BY ev.id
        )
        SELECT
          e.name as "Event Name", 
          avids.dname as "Source Domain Name",
          d.name as "Referencing Domain Name", 
          a.name as "Referencing Application Name"
        FROM avids
        JOIN solace_event_version ev ON avids.evid = ev.id
        JOIN solace_event e ON e.id = ev.event_id 
        JOIN solace_application_version av ON 
          (ev.declared_consuming_application_version_ids || ev.declared_producing_application_version_ids) LIKE '%' || av.id || '%'
        JOIN solace_application a ON a.id = av.application_id 
        JOIN solace_application_version av2 ON av2.id = avids.aid
        JOIN solace_application a2 ON a2.id = av2.application_id
        JOIN solace_application_domain d on d.id = a.application_domain_id AND d.id <> avids.did
        GROUP BY e.name, avids.dname, d.name, a.name
        ORDER BY e.name, avids.dname, d.name, a.name
      EOQ
    }
  }

}