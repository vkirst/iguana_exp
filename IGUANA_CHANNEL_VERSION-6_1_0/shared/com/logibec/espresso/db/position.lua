local position = {}

function position.merge(position, conn)  
   local Success = true
   local Err
   local mergeEmployee = [[ MERGE INTO ft.poste_tb p
   USING (
   SELECT clientcode,]]
   .. position.posteNumero .. [[ poste_numero, 'test1' description,]] .. ((position.usager == json.NULL or position.usager == nil) and 'null' or conn:quote(position.usager))
   .. [[ usager,]] .. ((position.dtDebut == json.NULL or position.dtDebut == nil) and 'null' or [[ TRUNC(TO_DATE(]] .. conn:quote(position.dtDebut) .. [[,'yyyy-mm-dd hh24:mi:ss')) dtdebut from fp.bd_parametre_tb ) s]]) ..
   [[ ON (p.clientcode = s.clientcode and p.poste_numero = ]] .. position.posteNumero 
   .. [[) WHEN MATCHED THEN UPDATE SET 
   description = s.description,
   usager = s.usager,
   dtdebut = s.dtdebut
   WHEN NOT MATCHED THEN INSERT (clientcode, poste_numero, description, dthrcreation, usager, dtdebut) 
   VALUES (s.clientcode, s.poste_numero, s.description, sysdate, s.usager, s.dtdebut)]] 
   
   
   trace(mergeEmployee)
  
   iguana.logInfo(mergeEmployee)
   
   local Success, Err = pcall(conn.execute, conn, {sql = mergeEmployee})
   return Success, Err
end
   
return position
