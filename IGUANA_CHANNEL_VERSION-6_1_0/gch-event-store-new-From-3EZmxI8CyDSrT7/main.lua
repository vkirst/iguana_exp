local utils = require 'Utils'
local config = require 'Configuration'
local dbEventStore = require 'com.logibec.gch.db.eventStore'
local mappingEventStore = require 'com.logibec.gch.mappings.eventStore'
local MAX_RESULT = 100

local devMode = iguana.isTest()
--local devMode = false;;;

if devMode then
   iguana.setTimeout(15)
end

function main()
   local envName = config.getEnvironmentName()
   local conn, connected = config.getVipConnection(devMode)
   trace(iguana.workingDir())

   if not connected and not devMode then
      return
   end
   
   -- Don't run until the Iguana Queue is empty to prevent overload
   if utils.getIguanaQueueCount() == '0' then 

      -- Debug/testing debug logging 
      local eventCount = dbEventStore.getQueueCount(conn)
      
      if eventCount ~= "0" then 
         iguana.logDebug("QueueCount = ".. eventCount)
      end

      local events
      -- ## Query queue table in database for rest if null 
      events = dbEventStore.getQueue(conn, MAX_RESULT)
      
      -- ## Convert each record to JSON string and push to the queue
      -- loops through all records in result set
      local eventOut
      
      iguana.logDebug("Number of events to treat = ".. tostring(#events))
      
      for i=1, #events,1 do 
         -- generates JSON template 
         eventOut = mappingEventStore.recordOut()

         -- maps db record values to JSON outbound message            
         mappingEventStore.mapRecordOut(events[i],eventOut)

         if eventOut ~= nil then
            local success, result = pcall(dbEventStore.updateEventStatus, conn, eventOut.eventStoreId, 1)
            if success then
               queue.push{data=json.serialize{data=eventOut}}
            else
               iguana.logError("Error while updating status")
            end
         end

      end 
   end
   conn:close()
end
