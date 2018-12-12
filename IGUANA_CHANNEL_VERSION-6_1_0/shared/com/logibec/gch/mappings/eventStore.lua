local mappingsEventStore = {}

function mappingsEventStore.recordOut() 

   out = [[
   {'eventStoreId':'',
   'occurredOn':'',
   'domain':'',
   'eventType':'',
   'eventStatus':'',
   'keys':'',
   'data':''
   }
   ]]

   return json.parse(out)
   
end

function mappingsEventStore.mapRecordOut(record,recordOut) 
	trace(record)
   trace(recordOut)
   recordOut.eventStoreId = record.EVENT_STORE_ID:nodeValue()
   recordOut.occurredOn = record.OCCURRED_ON:nodeValue()
   recordOut.domain = record.DOMAIN:nodeValue()
   recordOut.eventType = record.EVENT_TYPE:nodeValue()
   recordOut.eventStatus = record.EVENT_STATUS:nodeValue()
   recordOut.version = record.VERSION:nodeValue()
   recordOut.keys = record.KEYS:nodeValue()
   if record.DATA ~= nil then
      local success, parsedData = pcall(json.parse, record.DATA:nodeValue())
      if success then
         recordOut.data = parsedData
      else
         return nil
      end
   end
   trace(recordOut)
   return recordOut
end


return mappingsEventStore