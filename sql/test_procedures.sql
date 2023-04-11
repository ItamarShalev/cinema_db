USE db_cinema;

DROP PROCEDURE IF EXISTS test_get_products_under_price;
CREATE PROCEDURE test_get_products_under_price()
BEGIN
    DECLARE expected_result TEXT DEFAULT '9,Candy,25|4,Small Soda,20';
    DECLARE actual_result TEXT;

    CALL get_products_under_price(30);

    SELECT GROUP_CONCAT(CONCAT(id, ',', product_name, ',', price) SEPARATOR '|')
    INTO actual_result
    FROM temporary_table_products_under_price;

    DROP TEMPORARY TABLE IF EXISTS temporary_table_products_under_price;

    SELECT IF(actual_result != expected_result OR actual_result IS NULL, 0, 1) AS test_result;
END;

DROP PROCEDURE IF EXISTS test_get_employee_birthday_in_month;
CREATE PROCEDURE test_get_employee_birthday_in_month()
BEGIN
    DECLARE expected_result TEXT DEFAULT '10,Melissa Garcia,1987-04-29|27,Nicholas Kim,1990-04-27';
    DECLARE actual_result TEXT;

    CALL get_employee_birthday_in_month(4);

    SELECT GROUP_CONCAT(CONCAT(id, ',', employee_name, ',', date_of_birth) SEPARATOR '|')
    INTO actual_result
    FROM (SELECT * FROM temporary_table_employee_birthday_in_month ORDER BY id) AS employees;

    DROP TEMPORARY TABLE IF EXISTS table_example_multi_procedure;

    SELECT IF(actual_result != expected_result OR actual_result IS NULL, 0, 1) AS test_result;
END;

DROP PROCEDURE IF EXISTS test_get_food_that_need_cooling;
CREATE PROCEDURE test_get_food_that_need_cooling()
BEGIN
    DECLARE expected_result TEXT DEFAULT '10,Ice Cream';
    DECLARE actual_result TEXT;

    CALL get_food_that_need_cooling();

    SELECT GROUP_CONCAT(CONCAT(id, ',', food_name) ORDER BY id SEPARATOR '|')
    INTO actual_result
    FROM temporary_table_food_that_need_cooling;

    DROP TEMPORARY TABLE IF EXISTS table_example_multi_procedure;

    SELECT IF(actual_result != expected_result OR actual_result IS NULL, 0, 1) AS test_result;
END;
