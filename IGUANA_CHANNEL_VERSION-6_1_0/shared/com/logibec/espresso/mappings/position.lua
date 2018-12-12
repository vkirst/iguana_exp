local mappingsPosition = {}

function mappingsPosition.recordOut() 

   out = [[
   {
     'clientcode':'',
     'posteNumero':'',
     'description':'',
     'dtDebut':'',
     'dtFin':'',
     'dthrCreation':'',
     'usager':''
   }
   ]]

   return json.parse(out)
   
end




function mappingsPosition.mapFromDb(record,recordOut) 
   -- Espresso = GCH-VIP
   local tmpPositionId = ((record.oldPositionId == json.NULL or record.oldPositionId == nil) and record.positionId or record.oldPositionId)
   recordOut.posteNumero = tonumber(tmpPositionId)
   if not recordOut.posteNumero then
      return "posteNumero must be an integer: " .. tmpPositionId, nil
   elseif recordOut.posteNumero > 99999999999 then
      return "posteNumero can not be greater than 99999999999: " .. tmpPositionId, nil
   end
   recordOut.description = 'test1'
   recordOut.dtDebut = record.startDate
   if record.endDate == 'NULL' then
      recordOut.dtFin = record.endDate
   end
   
   recordOut.dthrCreation = record.creationDate
   recordOut.usager = record.creationUser
   return nil, recordOut
end

return mappingsPosition