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

DROP PROCEDURE IF EXISTS test_remove_screen_if_no_tickets;
CREATE PROCEDURE test_remove_screen_if_no_tickets()
BEGIN
    DECLARE test_result INT;
    DECLARE result_failed BOOLEAN;
    DECLARE result_succeed BOOLEAN;

    -- Don't save the result of this delete command.
    START TRANSACTION;

    CALL remove_screen_if_no_tickets(1, '2023-03-03 12:00:00', result_failed);
    CALL remove_screen_if_no_tickets(4, '2023-03-11 21:00:00', result_succeed);

    ROLLBACK;

    SELECT result_failed = FALSE AND result_succeed = TRUE
    INTO test_result;

    SELECT test_result;
END;

DROP PROCEDURE IF EXISTS test_update_manager_to_department;
CREATE PROCEDURE test_update_manager_to_department()
BEGIN
    DECLARE test_result INT;
    DECLARE result_failed BOOLEAN;
    DECLARE result_succeed BOOLEAN;

    -- Don't save the result of this update command.
    START TRANSACTION;

    CALL update_manager_to_department(4, 2, result_failed);
    CALL update_manager_to_department(15, 2, result_succeed);

    ROLLBACK;

    SELECT result_failed = FALSE AND result_succeed = TRUE
    INTO test_result;

    SELECT test_result;
END;

DROP PROCEDURE IF EXISTS test_delete_useless_employees;
CREATE PROCEDURE test_delete_useless_employees()
BEGIN
    DECLARE test_result INT;
    DECLARE employees_count INT;
    DECLARE employees_current_count INT;

    SELECT COUNT(*)
    INTO employees_count
    FROM employee;

    -- Don't save the result of this delete command.
    START TRANSACTION;

    CALL delete_useless_employees();

    SELECT COUNT(*)
    INTO employees_current_count
    FROM employee;

    SELECT employees_count != employees_current_count
    INTO test_result;

    ROLLBACK;

    SELECT test_result;
END;

DROP PROCEDURE IF EXISTS test_department_workers;
CREATE PROCEDURE test_department_workers()
BEGIN
    DECLARE expected_result TEXT DEFAULT 'Alice,Grace,Karen,Amanda,Stephanie,Taylor';
    DECLARE actual_result TEXT;

    CALL department_workers(4);

    SELECT GROUP_CONCAT(first_name SEPARATOR ',')
    INTO actual_result
    FROM temporary_table_department_workers;

    DROP TEMPORARY TABLE IF EXISTS temporary_table_department_workers;

    SELECT IF(actual_result != expected_result OR actual_result IS NULL, 0, 1) AS test_result;
END;

DROP PROCEDURE IF EXISTS test_movies_of_date;
CREATE PROCEDURE test_movies_of_date()
BEGIN
    DECLARE expected_result TEXT;
    DECLARE actual_result TEXT;

    SET expected_result = 'Forrest Gump,The Dark Knight,The Godfather,The Shawshank Redemption';

    CALL movies_of_date('2023-03-06');

    SELECT GROUP_CONCAT(movie_name SEPARATOR ',')
    INTO actual_result
    FROM temporary_table_movies_of_today;

    DROP TEMPORARY TABLE IF EXISTS temporary_table_movies_of_today;
    SELECT IF(actual_result != expected_result OR actual_result IS NULL, 0, 1) AS test_result;
END;

DROP PROCEDURE IF EXISTS test_shortest_movie;
CREATE PROCEDURE test_shortest_movie()
BEGIN
    DECLARE expected_result TEXT DEFAULT '7,The Lion King';
    DECLARE actual_result TEXT;

    CALL shortest_movie();

    SELECT GROUP_CONCAT(CONCAT(id, ',', movie_name) ORDER BY id SEPARATOR '|')
    INTO actual_result
    FROM temporary_table_shortest_movie;

    DROP TEMPORARY TABLE IF EXISTS temporary_table_shortest_movie;

    SELECT IF(actual_result != expected_result OR actual_result IS NULL, 0, 1) AS test_result;
END;

DROP PROCEDURE IF EXISTS test_food_for_toddlers;
CREATE PROCEDURE test_food_for_toddlers()
BEGIN

    DECLARE expected_result TEXT DEFAULT 'Small Soda,Medium Soda,Large Soda,Ice Cream';
    DECLARE actual_result TEXT;

    CALL food_for_toddlers(2);

    SELECT GROUP_CONCAT(product_name SEPARATOR ',')
    INTO actual_result
    FROM temporary_table_food_for_toddlers;

    DROP TEMPORARY TABLE IF EXISTS temporary_table_movies_of_today;
    SELECT IF(actual_result != expected_result OR actual_result IS NULL, 0, 1) AS test_result;
END;

DROP PROCEDURE IF EXISTS test_tickets_for_screen;
CREATE PROCEDURE test_tickets_for_screen()
BEGIN
    DECLARE expected_result TEXT;
    DECLARE actual_result TEXT;

    SET expected_result = CONCAT('11,12,13,14,15,16,17,18,19,31,32,33,34,35,36,37,38,39,40,61',
                                 ',62,63,64,65,66,67,68,69,70,79,80,81,82,83,84,85,86,87,88,89,',
                                 '90,91,92,93,94,95,96,97,98,99,100');

    CALL tickets_for_screen('2023-03-06 12:00:00','The Shawshank Redemption');

    SELECT GROUP_CONCAT(id SEPARATOR ',')
    INTO actual_result
    FROM temporary_table_tickets_for_screen;

    DROP TEMPORARY TABLE IF EXISTS temporary_table_movies_of_today;
    SELECT IF(actual_result != expected_result OR actual_result IS NULL, 0, 1) AS test_result;
END;

DROP PROCEDURE IF EXISTS test_customers_that_bought_in_certain_cost;
CREATE PROCEDURE test_customers_that_bought_in_certain_cost()
BEGIN
    DECLARE expected_result TEXT;
    DECLARE actual_result TEXT;

    SET expected_result = CONCAT('Alexander Turner,Sophia Rodriguez,Avery Ward,Sarah Johnson',
                                 ',Mia Wilson,David Brown,John Smith,Abigail Reyes,Lucas Evans',
                                 ',Owen Richardson,Aurora Adams,Lila Ramirez,Caroline Nelson',
                                 ',Carter Scott,Dylan Cooper,Avery Green,Ethan Chavez,Henry Morris',
                                 ',Matthew Jones,Anthony Scott,Michael Davis,Victoria Phillips',
                                 ',Christopher Baker,Olivia Martin,Isabella Nguyen',
                                 ',William Hernandez,Wyatt Coleman,Jessica Lee,Emily Wilson',
                                 ',Elijah Wright,Audrey Collins,Madison Mitchell,Sofia Parker',
                                 ',Amelia Collins,Leah Cook,Aiden Garcia,Mila Hall,Jackson Rivera');

    CALL customers_that_bought_in_certain_cost(7);

    SELECT GROUP_CONCAT(customer_name SEPARATOR ',')
    INTO actual_result
    FROM temporary_table_customers_that_bought_in_certain_cost;

    DROP TEMPORARY TABLE IF EXISTS temporary_table_movies_of_today;
    SELECT IF(actual_result != expected_result OR actual_result IS NULL, 0, 1) AS test_result;
END;

DROP PROCEDURE IF EXISTS test_screens_not_in_theater;
CREATE PROCEDURE test_screens_not_in_theater()
BEGIN
    DECLARE expected_result TEXT;
    DECLARE actual_result TEXT;

    SET expected_result = CONCAT('The Shawshank Redemption',
                                 ',The Lord of the Rings: The Return of the King',
                                 ',American History X,The Godfather',
                                 ',Star Wars: Episode IV - A New Hope,Saving Private Ryan',
                                 ',The Dark Knight,The Silence of the Lambs,Interstellar',
                                 ',Inception,The Godfather: Part II,Se7en',
                                 ',The Lord of the Rings: The Fellowship of the Ring',
                                 ',The Lord of the Rings: The Two Towers,Gladiator',
                                 ',The Lion King,Schindler''s List,The Departed,The Matrix',
                                 ',For a Few Dollars More,The Terminator,Pulp Fiction',
                                 ',The Usual Suspects,The Sixth Sense,Fight Club,The Prestige',
                                 ',Eternal Sunshine of the Spotless Mind');

    CALL screens_not_in_theater(4);

    SELECT GROUP_CONCAT(movie_name SEPARATOR ',')
    INTO actual_result
    FROM temporary_table_screens_not_in_thetaer;

    DROP TEMPORARY TABLE IF EXISTS temporary_table_movies_of_today;
    SELECT IF(actual_result != expected_result OR actual_result IS NULL, 0, 1) AS test_result;
END;

DROP PROCEDURE IF EXISTS test_delete_food;
CREATE PROCEDURE test_delete_food()
BEGIN
    DECLARE test_result INT;
    DECLARE result_failed BOOLEAN;
    DECLARE result_succeed BOOLEAN;

    START TRANSACTION;

    CALL delete_food(4, result_succeed);
    CALL delete_food(100, result_failed);

    ROLLBACK;

    SELECT result_failed = FALSE AND result_succeed = TRUE
    INTO test_result;

    SELECT test_result;
END;

DROP PROCEDURE IF EXISTS test_add_food;
CREATE PROCEDURE test_add_food()
BEGIN
    DECLARE test_result INT;
    DECLARE result_failed BOOLEAN;
    DECLARE result_succeed BOOLEAN;

    START TRANSACTION;

    CALL add_food('tempo', 9, 0, NULL, 3, result_succeed);
    CALL add_food('some some', 9, 0, NULL, 0, result_failed);

    ROLLBACK;

    SELECT result_failed = FALSE AND result_succeed = TRUE
    INTO test_result;

    SELECT test_result;
END;

DROP PROCEDURE IF EXISTS test_add_employee;
CREATE PROCEDURE test_add_employee()
BEGIN
    DECLARE test_result INT;
    DECLARE result_failed BOOLEAN;
    DECLARE result_succeed BOOLEAN;

    START TRANSACTION;

    CALL add_employee('ron','shaull', '1993-03-11', 2, '1998-03-11', 90.3, 80, result_succeed);
    CALL add_employee('ron','shaull', '1993-03-11', 45, '1998-03-11', 90.3, 80, result_failed);

    ROLLBACK;

    SELECT result_failed = FALSE AND result_succeed = TRUE
    INTO test_result;

    SELECT test_result;
END;
