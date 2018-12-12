local store = require 'store2'
local utils = require 'Utils'
local config = require 'Configuration'

-- Manage database timezone
local channelStore = store.connect(iguana.channelName())

function main(Data)

   trace(Data)
   local dataOut
   --Parse queued record back to JSON
   local eventIn = json.parse{data=Data} 
   local uri
   local headers = {['Content-Type']='application/json'}
   local method = 'get'
   local domain = eventIn.domain:lower()
   
   if domain == 'jobcategory' then
      domain = 'jobcategories'
   elseif domain == 'visibleminority' then
      domain = 'visibleminorities'
   elseif domain == 'aborigenous' then
      domain = 'aborigenous'
   else
      domain = domain .. 's'
   end
   
   -- Get the endpoint parameter service name 
   local wsUri = config.getGchWebServiceUrl()
   uri = wsUri .. domain.."/" .. filter.uri.enc(eventIn.keys)

   iguana.logDebug(uri)

   local pcallResult, response, status, headers  = pcall(utils.wsQuery,method,uri,headers,nil)
   iguana.logDebug("Web Service status : ".. domain .. ": " ..eventIn.keys .. " " ..status )
   if status == 200 then
      dataOut = json.parse{data=response}
      iguana.logDebug("Web Service response: ".. domain .. ": " ..eventIn.keys .. " " ..response)
   else
      iguana.logError("Filter Error, dataOut empty " .. eventIn.domain .. ": " ..eventIn.keys)
   end
   
   if dataOut ~= nil then
      eventIn.data = dataOut
      trace(eventIn)
      -- Queue event message
      queue.push{data=json.serialize{data=eventIn}}
   else
      iguana.logError("Filter Error ".. eventIn.domain .. ": " ..eventIn.keys)
   end
end
