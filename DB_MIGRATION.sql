OPEN SCHEMA DATABASE_MIGRATION;
--/
CREATE OR REPLACE LUA SCRIPT "DB_MIGRATION" (CONNECTION_NAME,DB2SCHEMA,DB_FILTER,SCHEMA_FILTER,TABLE_FILTER,IDENTIFIER_CASE_INSENSITIVE) RETURNS TABLE AS
res = query([[EXECUTE SCRIPT SQLSERVER_TO_EXASOL(:CONNECTION_NAME,:DB2SCHEMA,:DB_FILTER,:SCHEMA_FILTER,:TABLE_FILTER,:IDENTIFIER_CASE_INSENSITIVE);]],
			{
			CONNECTION_NAME = CONNECTION_NAME,
			DB2SCHEMA = DB2SCHEMA,
			DB_FILTER = DB_FILTER,
			SCHEMA_FILTER = SCHEMA_FILTER,
			TABLE_FILTER = TABLE_FILTER,
			IDENTIFIER_CASE_INSENSITIVE = IDENTIFIER_CASE_INSENSITIVE
			})
for i=1, #res do
	if string.sub(res[i][1],1,2) ~= "--" then
		sqlstatement = res[i][1]
        if string.sub(sqlstatement,1,27) == "create schema if not exists" then
            s = string.gsub(string.gsub(sqlstatement,'%W',''),'createschemaifnotexists','')
            success3,res3 = pquery([[SELECT COUNT(*) AS SCH FROM EXA_ALL_SCHEMAS WHERE SCHEMA_NAME = :sch;]],{sch = s})
            if res3[1].SCH == 1 then
                outMessage = "Schema "..s.." already exists"
            else 
                outMessage = "Schema "..s.." created"
            end
        elseif string.sub(sqlstatement,1,23) == "create or replace table" then
            --t = string.gsub(string.gsub(string.sub(sqlstatement,string.find(sqlstatement,'%.')+1,string.find(sqlstatement,'%(')-2),'"',''),' ','')
            longTabName = string.gsub(string.gsub(string.sub(sqlstatement, string.find(sqlstatement,'"'), string.find(sqlstatement,'%(')-1),'"',''),' ','')
            shortTabName = string.sub(longTabName,string.find(longTabName,'%.')+1,string.len(longTabName))
            success4,res4 = pquery([[SELECT COUNT(*) AS TAB FROM EXA_ALL_TABLES WHERE TABLE_NAME = :tab;]],{tab = shortTabName})
            if res4[1].TAB == 1 then
                outMessage = "Table "..longTabName.." replaced"
            else
                outMessage = "Table "..longTabName.." created"
            end
        end
		success,res2 = pquery(sqlstatement)
			if not success then
				output(res2.error_message.." - "..sqlstatement)
            elseif string.sub(sqlstatement,1,27) == "create schema if not exists" then
                output(outMessage)
			elseif string.sub(sqlstatement,1,23) == "create or replace table" then
                output(outMessage)
			elseif string.sub(sqlstatement,1,6) == "import" then 
			 	output(res2.rows_affected.." rows loaded into "..string.gsub(string.sub(sqlstatement,13,string.find(sqlstatement,'%(')-2),'"',''))
            else
                output(sqlstatement)
			end
	end
end
/