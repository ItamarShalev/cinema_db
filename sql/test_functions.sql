USE db_cinema;

DROP FUNCTION IF EXISTS test_count_tables_in_database;
CREATE FUNCTION test_count_tables_in_database()
    RETURNS INT
    DETERMINISTIC
BEGIN
    DECLARE excepted_result INT DEFAULT 10;
    DECLARE actual_result INT;
    DECLARE test_result INT;

    SELECT count_tables_in_database() INTO actual_result;
    SET test_result = IF((actual_result != excepted_result OR actual_result IS NULL), 0, 1);

    RETURN test_result;
END;

-- SELECT test_count_tables_in_database();
