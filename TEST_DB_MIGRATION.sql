OPEN SCHEMA DATABASE_MIGRATION;
EXECUTE SCRIPT DATABASE_MIGRATION.DB_MIGRATION('SQLSERVER_JDBC_CONNECTION',true,'AdventureWorks2012','Purchasing','%',true) WITH OUTPUT;