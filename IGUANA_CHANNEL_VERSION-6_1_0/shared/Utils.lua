local Utils = {}


function Utils.writeCSV(path, data)
   sep = ','
   local file = assert(io.open(path, "w"))
   for i=1,#data do
      for j=1,#data[i] do
         if j>1 then file:write(sep) end
         file:write(data[i][j])
      end
      file:write('\n')
   end
   file:close()
end


--- Rename an OS file
function Utils.renameFile(file,newFile)  
      
   local valid = io.open(file, "r")
   
   if valid ~= nil  then 
      valid:close()         
      os.rename(file,newFile)   
   end 
   
end


-- Add the suffix to the file name
-- Eg file = c:\budget.csv
--    suffix = '_old'
--    return: c:\budget_old.csv
function Utils.AddSuffixToFileName(file,suffix)  
   
   --- Find the last occurrance of a period so we can extract the extension
   local i = 0
   local extensionPos = 0
    while true do
      i = string.find(file, ".", i+1,true)   
      if i == nil then 
         break 
      else
         extensionPos = i
      end      
    end

   --- Extract the extension
   local extension = string.sub(file,extensionPos,-1)
   
   ---Extract the path and file name without the extension
   file = string.sub(file, 1, extensionPos - 1)
   
   local newFileName = (file..suffix..extension)
   
   return newFileName
   
end



function Utils.log(message, logLevel)
      
   if logLevel == "Error" then
      iguana.logError(message)
   elseif logLevel == "Warning" then
      iguana.logWarning(message)
   elseif logLevel == "Info" then
      iguana.logInfo(message)      
   elseif logLevel == "Debug" then      
      iguana.logDebug(message)          
	elseif logLevel == "Stop" and not iguana.isTest() then      
      -- This will kill the channel
      error(message)          
   else      
      iguana.logDebug(message)            
   end
      
end

function Utils.jsonDiff(dataRecord, compareRecord)
--  Returns true if the external copy differs from the incomming data
   
   -- A nil External Copy indicates the data receord is new
   if compareRecord == nil then
      differs = true      
   else  
      differs = false 

      for key,value in next,dataRecord,nil do
         if compareRecord[key] ~= value then         
            differs = true            
         end 

      end
	end
 --  differs = true  --hardcode result to true for testing   
   return differs
end


-- Put the JSON message in the Queue
function Utils.pushToQueue(Payload)    
   -- Queue event message
   queue.push{data=json.serialize{data=Payload}}   
       
end



function Utils.wsQuery(method,uri,headers,body)
   
   local attempts = 2
   local wait = 1000  --1 seconds
   for i=1,attempts do -- connections issues 
      pcallStatus, response, statusCode = pcall(Utils.wsQueryRetry,method,uri,headers,body)
      trace(uri)
      trace(pcallStatus)   
      trace(response)     
      trace(statusCode)
   
      if pcallStatus == true then       
         return response, statusCode
      else
         local waitSecs = wait/1000
         Utils.log([[Utils.wsQuery Attempt failed # ]]..i..[[. Retry in ]]..waitSecs..[[ seconds. URI=]]..uri..[[  ]]..response, 'Warning')
         util.sleep(wait)
      end
   end 
   
   -- If we get here it has failed
   message = 'Error Executing Utils.wsQuery. ' ..uri.. '. Response: '.. response         
   logLevel = 'Stop'    
   Utils.log(message,logLevel)  
   
end

-- SCDINT-1037
function Utils.wsQueryRetry(method,uri,headers,body)
    trace(headers)
   if method == 'post' then
      local response, statusCode, headers = net.http.post{url=uri,headers=headers,body=body,live=true}
      return response, statusCode
   elseif method == 'put' then
      local response, statusCode, headers = net.http.put{url=uri,headers=headers,data=body,live=true}
      return response, statusCode
   --elseif method == 'delete' then
   --   local response, statusCode, headers = net.http.delete{url=uri,headers=headers,body=body,live=true}
   --   return response, statusCode      
   elseif method == 'get' then
      trace(uri)
      local response, statusCode, headers = net.http.get{url=uri,headers=headers,live=true}
      return response, statusCode

   end
  
end

--  Returns a count of the number of records in the Iguana queue
function Utils.getIguanaQueueCount()
   
   --local StatusXml = iguana.status()
   local StatusNodeTree = xml.parse{data=iguana.status()}
   local channelNumber = 0
   
   trace(StatusNodeTree)
   if StatusNodeTree ~= nil and StatusNodeTree.IguanaStatus:childCount("Channel") > 0 then
      -- Determine which channel number this channel is in the node tree
      for i = 1, StatusNodeTree.IguanaStatus:childCount("Channel") do
         local channelName = StatusNodeTree.IguanaStatus:child("Channel", i).Name:nodeValue()
         if channelName == iguana.channelName() then
            channelNumber = i         
            break
         end 
      end
      
      trace(channelNumber)
      -- return number of records in Iguana Queue
      return StatusNodeTree.IguanaStatus:child("Channel",channelNumber).MessagesQueued:nodeValue()
   end
   return "0";   
end


-- If the string is NULL return NUll, else return the trimmed string wrapped in quotes
function Utils.formatStringFromDB(inString)
	
   if inString:isNull() then
      return 'NULL'
   else     
      return '\''..string.trimRWS(inString)..'\'' 
   end
   
end


-- Build a blank Json template
function Utils.buildJsonTemplate() 

   template = [[
   {}
   ]]

   return json.parse(template)
   
end


return Utils