local employee = {}

function employee.merge(employee, conn)  
   local Success = true
   local Err
   local mergeEmployee = [[ MERGE INTO fp.EMPLOYE_TB d
   USING (
   SELECT ]]
   .. employee.matri .. [[ matri, 'test1' nom from dual) s
   ON (d.matri = ]] .. employee.matri .. [[)
   WHEN MATCHED THEN UPDATE SET
   d.nom = ]] .. conn:quote(employee.nom) 
   .. [[, d.prenom =  ]] .. conn:quote(employee.prenom) 
   .. [[, d.etat_civil_code =  ]] .. employee.etat_civil_code
   .. [[, d.PHNOM1_CODE =  ]] .. conn:quote(employee.phnom1_code)
   .. [[, d.VILLE =  ]] .. conn:quote(employee.ville)
   .. [[, d.adresse =  ]] .. conn:quote(employee.adresse)
   .. [[, d.code_postal =  ]] .. conn:quote(employee.code_postal)
   .. [[, d.sexe_code =  ]] .. conn:quote(employee.sexe_code)
   .. [[, d.dtnais = TRUNC(TO_DATE(]] .. conn:quote(employee.dtnais) .. [[,'yyyy/mm/dd HH24:MI:SS'))
   WHEN NOT MATCHED THEN INSERT (clientcode, matri, nom, prenom, etat_civil_code, PHNOM1_CODE, VILLE, adresse, code_postal, sexe_code, dtnais) 
   VALUES (]].. employee.clientcode ..[[,]].. employee.matri ..[[,]].. conn:quote(employee.nom)..[[,]].. conn:quote(employee.prenom)
   ..[[,]].. employee.etat_civil_code..[[,]].. conn:quote(employee.phnom1_code)
   ..[[,]].. conn:quote(employee.ville)   ..[[,]].. conn:quote(employee.adresse)..[[,]].. conn:quote(employee.code_postal)
   ..[[,]].. conn:quote(employee.sexe_code)..[[, TRUNC(TO_DATE(]] .. conn:quote(employee.dtnais) .. [[,'yyyy/mm/dd HH24:MI:SS'))  )]]
   
   iguana.logInfo(mergeEmployee)
   local Success, Err = pcall(conn.execute, conn, {sql = mergeEmployee})
   return Success, Err
end
   
return employee
