local eventStore = {}

function eventStore.getQueue(conn, maxResults) 
   
   local sql = [[SELECT *
   FROM
   (
   select raw_to_guid(event_store_id) event_store_id, domain, event_type, version, event_seq, keys, to_char(occurred_on, 'yyyy-MM-dd"T"HH24:mm:ss.ff6') occurred_on, event_status, data
   from event_store_t
   where event_status = 0
   ORDER BY OCCURRED_ON, EVENT_SEQ, EVENT_STORE_ID
)
   WHERE ROWNUM < ]] .. maxResults
   
   local success, result = pcall(conn.query, conn,sql)
   if success then
      return result
   else
      return nil
   end
end

function eventStore.getQueueCount(conn) 
   local sql = [[select count(*) NUMBER_OF_EVENTS from EVENT_STORE_T where event_status = 0]]
   local success, result = pcall(conn.query, conn, sql)
   local count = "0"
   if success and result ~= nil and #result > 0 then 
        count = result[1].NUMBER_OF_EVENTS:nodeValue()
   end
   return count
end

function eventStore.updateEventStatus(conn, id,status) 
   local sql = [[update EVENT_STORE_T set event_status = ]]..status..[[ where EVENT_STORE_ID = guid_to_raw(']] .. id .. [[')]]
   return pcall(conn.execute, conn, sql)
end

return eventStore