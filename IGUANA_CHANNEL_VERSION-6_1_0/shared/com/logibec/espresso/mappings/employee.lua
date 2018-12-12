local mappingsEmployee = {}

function mappingsEmployee.recordOut() 

   out = [[
   {
     'clientcode':'',
     'matri':'',
     'dtnais':'',
     'ville':'',
     'adresse':'',
     'nom':'',
     'prenom':'',
     'phnom1_code':'',
     'code_postal':'',
     'sexe_code':'',
     'etat_civil_code':'',
     'type_ress':''
   }
   ]]

   return json.parse(out)
   
end




function mappingsEmployee.mapFromDb(record,recordOut) 
   -- Espresso = GCH-VIP
   recordOut.clientcode = '992'
   recordOut.matri = tonumber(record.indvId)
   recordOut.dtnais = tostring(record.birthDate)
   recordOut.ville = tostring(record.ville)
   recordOut.adresse = tostring(record.adresse:sub(1,25))
   recordOut.nom = tostring(record.lastName)
   recordOut.phnom1_code = tostring('A130') -- 'A130'
   recordOut.code_postal = tostring(record.code_postal:gsub(" ", ""))
   recordOut.prenom = tostring(record.firstName)
   recordOut.sexe_code = tostring(record.sexe_code)
   recordOut.etat_civil_code = tonumber(record.etat_civil_code)
   recordOut.type_ress = '' -- 0
   return recordOut
end

return mappingsEmployee