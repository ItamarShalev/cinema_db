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

    DROP TEMPORARY TABLE IF EXISTS test_get_employee_birthday_in_month;

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

    DROP TEMPORARY TABLE IF EXISTS temporary_table_food_that_need_cooling;

    SELECT IF(actual_result != expected_result OR actual_result IS NULL, 0, 1) AS test_result;
END;

DROP PROCEDURE IF EXISTS test_get_movies_screen_in_theater;
CREATE PROCEDURE test_get_movies_screen_in_theater()
BEGIN
    DECLARE expected_result TEXT DEFAULT '4,Forrest Gump|14,Goodfellas|24,The Green Mile';
    DECLARE actual_result TEXT;

    CALL get_movies_screen_in_theater(4);

    SELECT GROUP_CONCAT(CONCAT(id, ',', movie_name) ORDER BY id SEPARATOR '|')
    INTO actual_result
    FROM temporary_table_movies_screen_in_theater;

    DROP TEMPORARY TABLE IF EXISTS temporary_table_movies_screen_in_theater;

    SELECT IF(actual_result != expected_result OR actual_result IS NULL, 0, 1) AS test_result;
END;

DROP PROCEDURE IF EXISTS test_get_tickets_sold_in_screen;
CREATE PROCEDURE test_get_tickets_sold_in_screen()
BEGIN
    DECLARE expected_result TEXT;
    DECLARE actual_result TEXT;

    SET expected_result = CONCAT(
            '1,2,3,4,5,6,7,8,9,10,20,21,22,23,24,25,26,27,28,29,30,',
            '41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,',
            '71,72,73,74,75,76,77,78'
        );

    CALL get_tickets_sold_in_screen('2023-03-06 12:00:00', 1);

    SELECT GROUP_CONCAT(seat_number ORDER BY seat_number SEPARATOR ',')
    INTO actual_result
    FROM temporary_table_tickets_sold_in_screen;

    DROP TEMPORARY TABLE IF EXISTS temporary_table_tickets_sold_in_screen;

    SELECT IF(actual_result != expected_result OR actual_result IS NULL, 0, 1) AS test_result;
END;

DROP PROCEDURE IF EXISTS test_get_employee_with_most_products;
CREATE PROCEDURE test_get_employee_with_most_products()
BEGIN
    DECLARE expected_result TEXT DEFAULT '5,Michael,Brown,11';
    DECLARE actual_result TEXT;

    CALL get_employee_with_most_products();

    SELECT GROUP_CONCAT(
        CONCAT(id, ',', first_name, ',', last_name, ',', product_count)
        ORDER BY id SEPARATOR '|')
    INTO actual_result
    FROM temporary_table_employee_with_most_products;

    DROP TEMPORARY TABLE IF EXISTS temporary_table_employee_with_most_products;

    SELECT IF(actual_result != expected_result OR actual_result IS NULL, 0, 1) AS test_result;
END;

DROP PROCEDURE IF EXISTS test_get_employee_earned_most_money;
CREATE PROCEDURE test_get_employee_earned_most_money()
BEGIN
    DECLARE expected_result TEXT DEFAULT '5,Michael,Brown,410';
    DECLARE actual_result TEXT;

    CALL get_employee_earned_most_money();

    SELECT GROUP_CONCAT(
        CONCAT(id, ',', first_name, ',', last_name, ',', money)
        ORDER BY id SEPARATOR '|')
    INTO actual_result
    FROM temporary_table_get_employee_earned_most_money;

    DROP TEMPORARY TABLE IF EXISTS temporary_table_get_employee_earned_most_money;

    SELECT IF(actual_result != expected_result OR actual_result IS NULL, 0, 1) AS test_result;
END;
