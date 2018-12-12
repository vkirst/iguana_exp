local store = require 'store2'
local Configuration = {}

local config = iguana.workingDir() .. 'gch-integration-config.xml'
local f = io.open(config, 'r')
local configXML = f:read('*a')
f:close()
local configTable = xml.parse{data=configXML}

function Configuration.getEnvironmentName()
   trace(configTable.config.environment.name[1]:nodeValue())   
   return configTable.config.environment.name[1]:nodeValue()
end

function Configuration.getVipConnection(devMode) 

   --  use loadstring to create executable code from the string
   
         connectionString = loadstring(
         [[conn =  db.connect{
         api = ]].. configTable.config.environment.connectionStrings.vip.api[1]:nodeValue() ..[[,
         name = ']]..configTable.config.environment.connectionStrings.vip.dbsid[1]:nodeValue()..[[', 
         user = ']]..configTable.config.environment.connectionStrings.vip.username[1]:nodeValue()..[[', 
         password = ']]..configTable.config.environment.connectionStrings.vip.password[1]:nodeValue()..[[',
         use_unicode=true,
         live=]] .. (devMode and 'false' or 'true') ..[[}]]
         )
   trace(connectionString)
       
   -- execute the code to create the connection
   connectionString()
   
   local ConnectionValid
   if conn:check() == true then 
      ConnectionValid = true
   else
      ConnectionValid = false
   end    
   
  return conn, ConnectionValid
end

function Configuration.getEspressoConnection(devMode) 

   --  use loadstring to create executable code from the string
   connectionString = loadstring(
      [[conn =  db.connect{
      api = ]].. configTable.config.environment.connectionStrings.espresso.api[1]:nodeValue() ..[[,
      name = ']]..configTable.config.environment.connectionStrings.espresso.dbsid[1]:nodeValue()..[[', 
      user = ']]..configTable.config.environment.connectionStrings.espresso.username[1]:nodeValue()..[[', 
      password = ']]..configTable.config.environment.connectionStrings.espresso.password[1]:nodeValue()..[[',
      use_unicode=true,
      live=]] .. (devMode and 'false' or 'true') ..[[}]]
   )
   
   trace(connectionString)
       
   -- execute the code to create the connection
   connectionString()
   
   local ConnectionValid
   if conn:check() == true then 
      ConnectionValid = true
   else
      ConnectionValid = false
   end    
   
  return conn, ConnectionValid
end

function Configuration.getRecruitmentUrl() 
   trace(configTable.config.environment.recruitment.url[1]:nodeValue())
   return configTable.config.environment.recruitment.url[1]:nodeValue()
end

function Configuration.getGchWebServiceUrl() 
   trace(configTable.config.environment["vip-web-service"].url[1]:nodeValue())
   return configTable.config.environment["vip-web-service"].url[1]:nodeValue()
end


return Configuration