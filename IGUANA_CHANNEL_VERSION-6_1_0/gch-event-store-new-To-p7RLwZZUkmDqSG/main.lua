local utils = require 'Utils'
local config = require 'Configuration'

local dbEmployee = require 'com.logibec.espresso.db.employee'
local dbPosition = require 'com.logibec.espresso.db.position'

local mappingsEmployee = require 'com.logibec.espresso.mappings.employee'
local mappingsPosition = require 'com.logibec.espresso.mappings.position'

--local devMode = iguana.isTest()
local devMode = false

if devMode then
   iguana.setTimeout(15)
end

function main(Data)
   local conn, connected = config.getEspressoConnection(devMode)

   if not connected and not devMode then
      iguana.logWarning("Database connection failed")
      return
   end   
   eventIn = json.parse{data=Data}

   local success = false, err
   local methodNotSupported = false
   
   if eventIn.domain == 'employee' then
      if eventIn.eventType == 'employeeAdded' then

         local employee = mappingsEmployee.mapFromDb(eventIn.data,mappingsEmployee.recordOut())
         if employee == nil then
            iguana.logError("Mapping error")
         else
            success, err = dbEmployee.merge(employee, conn)
            if not success then
               iguana.logDebug(err.code)
               iguana.logDebug(err.message)
               iguana.logInfo("employee NOT created")
            else
               iguana.logInfo("employee created")
            end
         end
      else
         methodNotSupported = true
      end
   elseif eventIn.domain == 'position' then
      if eventIn.eventType == 'positionMerged' then

         local err, position = mappingsPosition.mapFromDb(eventIn.data,mappingsPosition.recordOut())
         if err == nil then
            success, err = dbPosition.merge(position, conn)
            if not success then
               iguana.logError("position NOT created")
               iguana.logDebug(err.code .. ": " .. err.message)
            else
               iguana.logInfo("position created")
            end
         else
            iguana.logError("Mapping error:" .. err)
         end
      else
         methodNotSupported = true
      end
   end

   if success then
      message = 'Event ' .. eventIn.domain .. ' submitted successfully.'
      iguana.logInfo(message)
   elseif methodNotSupported then
      iguana.logWarning(eventIn.domain .. " event " .. eventIn.eventType .. " not supported")
   end
   conn:close()
end