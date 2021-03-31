CREATE LUA SCRIPT "DB_MIGRATION" (CONNECTION_NAME,DB2SCHEMA,DB_FILTER,SCHEMA_FILTER,TABLE_FILTER,IDENTIFIER_CASE_INSENSITIVE) RETURNS TABLE AS
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
		success,res2 = pquery(sqlstatement)
			if not success then
				output(res2.error_message)
			elseif string.sub(sqlstatement,1,6) == "create" then 
				output(success)
			else
				output(res2.rows_affected)
			end
	end
end