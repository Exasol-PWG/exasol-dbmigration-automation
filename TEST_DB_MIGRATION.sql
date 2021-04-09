OPEN SCHEMA DATABASE_MIGRATION;

EXECUTE SCRIPT DATABASE_MIGRATION.DB_MIGRATION(
    'SQLSERVER_JDBC_CONNECTION',    -- CONNECTION_NAME: name of the database connection inside exasol -> e.g. sqlserver_db
    true,                           -- DB2SCHEMA: if true then SQL Server: database.schema.table => EXASOL: database.schema_table; if false then SQLSERVER: schema.table => EXASOL: schema.table
    'AdventureWorks2012',           -- DB_FILTER: filter for SQLSERVER db, e.g. 'master', 'ma%', 'first_db, second_db', '%'
    'Sales',                        -- SCHEMA_FILTER: filter for the schemas to generate and load e.g. 'my_schema', 'my%', 'schema1, schema2', '%'
    'Currency',                     -- TABLE_FILTER: filter for the tables to generate and load e.g. 'my_table', 'my%', 'table1, table2', '%'
    true                            -- IDENTIFIER_CASE_INSENSITIVE: set to TRUE if identifiers should be put uppercase
);

/*
The DB_MIGRATION script takes the same parameters as the Exasol migration scripts becaause part of the script is to call the underlying
migration script and pass the parameters straight through
*/