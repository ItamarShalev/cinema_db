USE db_cinema;

-- Return how many tables there is in the database
DROP PROCEDURE IF EXISTS count_tables_in_database;
CREATE PROCEDURE count_tables_in_database(OUT count_tables INT)
BEGIN
    SELECT COUNT(*)
    INTO count_tables
    FROM information_schema.tables
    WHERE table_schema = DATABASE();
END;

-- CALL count_tables_in_database(@count_tables);
-- SELECT @count_tables;
