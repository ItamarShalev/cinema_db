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

DROP FUNCTION IF EXISTS test_movies_not_for_adults;
CREATE FUNCTION test_movies_not_for_adults()
    RETURNS INT
    DETERMINISTIC
BEGIN
    DECLARE expected_result TEXT DEFAULT '3,4,5,6,7,11,12,16,20,23,29';
    DECLARE actual_result TEXT;
    DECLARE test_result INT;

    SELECT GROUP_CONCAT(id ORDER BY id SEPARATOR ',')
    INTO actual_result
    FROM view_movies_not_for_adults;

    SET test_result =  IF(actual_result != expected_result OR actual_result IS NULL, 0, 1);

    RETURN test_result;
END;

-- SELECT test_movies_not_for_adults();

DROP FUNCTION IF EXISTS test_employee_earn_per_month;
CREATE FUNCTION test_employee_earn_per_month()
    RETURNS INT
    DETERMINISTIC
BEGIN
    DECLARE expected_result INT DEFAULT 1;
    DECLARE actual_result TEXT;
    DECLARE test_result INT;

    SELECT IF(COUNT(*) = 19 AND SUM(sales) = 3650, 1, 0)
    INTO actual_result
    FROM view_employee_earn_per_month;

    SET test_result =  IF(actual_result != expected_result OR actual_result IS NULL, 0, 1);

    RETURN test_result;
END;

SELECT test_employee_earn_per_month();
