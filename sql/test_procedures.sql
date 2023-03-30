USE db_cinema;

DROP PROCEDURE IF EXISTS test_count_tables_in_database;
CREATE PROCEDURE test_count_tables_in_database()
BEGIN
    DECLARE excepted_result INT DEFAULT 10;
    DECLARE actual_result INT;
    CALL count_tables_in_database(actual_result);
    SELECT IF((actual_result != excepted_result OR actual_result IS NULL), 0, 1) AS test_result;
END;

-- CALL test_count_tables_in_database();
