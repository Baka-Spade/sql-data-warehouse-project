/*
WARNING
This script permanently deletes any existing BakaDBW database.
==============================================================================

This script initializes the database by creating the BakaDBW database and the
Bronze, Silver, and Gold schemas based on the Medallion Architecture.
*/

-- Drop the database if it already exists
IF EXISTS (
    SELECT 1
    FROM sys.databases
    WHERE name = 'BakaDBW'
)
BEGIN
    ALTER DATABASE BakaDBW
    SET SINGLE_USER
    WITH ROLLBACK IMMEDIATE;

    DROP DATABASE BakaDBW;
END;
GO

--Creating Database
CREATE DATABASE BakaDBW;
GO

USE BakaDBW;
GO

--Creating Schema Based on Medallion Architecture  
CREATE SCHEMA Bronze;
GO

CREATE SCHEMA Silver;
GO

CREATE SCHEMA Gold;
GO
