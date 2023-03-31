USE db_cinema;

-- Return how many tables there is in the database
DROP FUNCTION IF EXISTS count_tables_in_database;
CREATE FUNCTION count_tables_in_database()
    RETURNS INT
    DETERMINISTIC
BEGIN
    DECLARE count_tables INT;

    SELECT COUNT(*)
    INTO count_tables
    FROM information_schema.tables
    WHERE table_schema = DATABASE()
    AND table_type = 'BASE TABLE';

    RETURN count_tables;
END;

-- SELECT count_tables_in_database();
