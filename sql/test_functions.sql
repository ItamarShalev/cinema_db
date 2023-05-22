USE db_cinema;

DROP FUNCTION IF EXISTS test_count_tables_in_database;
CREATE FUNCTION test_count_tables_in_database()
    RETURNS INT
    DETERMINISTIC
BEGIN
    DECLARE excepted_result INT DEFAULT 12;
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

-- SELECT test_employee_earn_per_month();

DROP FUNCTION IF EXISTS test_earn_per_month;
CREATE FUNCTION test_earn_per_month()
    RETURNS INT
    DETERMINISTIC
BEGIN
    DECLARE expected_result INT DEFAULT 1;
    DECLARE actual_result TEXT;
    DECLARE test_result INT;

    SELECT IF(COUNT(*) = 3 AND SUM(sales) = 3650, 1, 0)
    INTO actual_result
    FROM view_earn_per_month;

    SET test_result =  IF(actual_result != expected_result OR actual_result IS NULL, 0, 1);

    RETURN test_result;
END;

DROP FUNCTION IF EXISTS test_employee_with_sales_money;
CREATE FUNCTION test_employee_with_sales_money()
    RETURNS INT
    DETERMINISTIC
BEGIN
    DECLARE expected_result TEXT DEFAULT '5,410|3,375|12,370|19,360';
    DECLARE actual_result TEXT;
    DECLARE test_result INT;
    DECLARE has_zeros_sales INT DEFAULT 0;

    SELECT GROUP_CONCAT(CONCAT(id, ',', sales) SEPARATOR '|')
    INTO actual_result
    FROM (SELECT id, sales
          FROM view_employee_with_sales_money
          ORDER BY sales DESC
          LIMIT 4) AS employees;

    SET has_zeros_sales = IF(0 IN (SELECT sales FROM view_employee_with_sales_money), 1, 0);

    SET test_result =  IF(has_zeros_sales = 0
                              OR actual_result != expected_result
                              OR actual_result IS NULL, 0, 1);

    RETURN test_result;
END;

DROP FUNCTION IF EXISTS test_employee_with_amount_products;
CREATE FUNCTION test_employee_with_amount_products()
    RETURNS INT
    DETERMINISTIC
BEGIN
    DECLARE expected_result TEXT;
    DECLARE actual_result TEXT;
    DECLARE test_result INT;

    SET expected_result = CONCAT('1,0|2,0|3,10|4,0|5,11|6,0|7,7|8,3|9,0|10,0|11,4|12,10|13,0|14,0',
                                 '|15,7|16,8|17,0|18,0|19,10|20,7|21,0|22,0|23,4|24,7|25,0|26,0',
                                 '|27,4|28,6|29,0|30,0');

    SELECT GROUP_CONCAT(CONCAT(id, ',', products_amount) ORDER BY id SEPARATOR '|')
    INTO actual_result
    FROM view_employee_with_amount_products;

    SET test_result =  IF(actual_result != expected_result OR actual_result IS NULL, 0, 1);

    RETURN test_result;
END;

DROP FUNCTION IF EXISTS test_get_money_earned_in_month;
CREATE FUNCTION test_get_money_earned_in_month()
    RETURNS INT
    DETERMINISTIC
BEGIN
    DECLARE test_result INT;
    DECLARE result_3365 INT;
    DECLARE result_0 INT;

    SELECT get_money_earned_in_month(2023, 3)
    INTO result_3365;

    SELECT get_money_earned_in_month(2043, 1)
    INTO result_0;

    SELECT result_0 = 0 AND result_3365 = 3365
    INTO test_result;

    RETURN test_result;
END;

DROP FUNCTION IF EXISTS test_get_money_earned_in_year;
CREATE FUNCTION test_get_money_earned_in_year()
    RETURNS INT
    DETERMINISTIC
BEGIN
    DECLARE test_result INT;
    DECLARE result_3650 INT;
    DECLARE result_0 INT;

    SELECT get_money_earned_in_year(2023)
    INTO result_3650;

    SELECT get_money_earned_in_year(2043)
    INTO result_0;

    SELECT result_0 = 0 AND result_3650 = 3650
    INTO test_result;

    RETURN test_result;
END;

DROP FUNCTION IF EXISTS test_vip_movies_with_free_seats;
CREATE FUNCTION test_vip_movies_with_free_seats()
    RETURNS INT
    DETERMINISTIC
BEGIN
    DECLARE expected_result TEXT;
    DECLARE actual_result TEXT;
    DECLARE test_result INT;

    SET expected_result = CONCAT('3,The Dark Knight,3,2023-03-06 18:00:00',
                                 '|5,Inception,5,2023-03-07 12:00:00',
                                 '|7,The Lion King,7,2023-03-07 18:00:00',
                                 '|10,Fight Club,10,2023-03-08 15:00:00',
                                 '|13,The Silence of the Lambs,3,2023-03-09 12:00:00',
                                 '|15,The Godfather: Part II,5,2023-03-09 18:00:00',
                                 '|17,Schindler''s List,7,2023-03-10 12:00:00',
                                 '|20,The Prestige,10,2023-03-10 21:00:00',
                                 '|23,Interstellar,3,2023-03-11 18:00:00',
                                 '|25,Se7en,5,2023-03-12 12:00:00',
                                 '|27,The Departed,7,2023-03-12 18:00:00',
                                 '|30,Eternal Sunshine of the Spotless Mind,10,',
                                 '2023-03-13 15:00:00');

    SELECT GROUP_CONCAT(CONCAT(id, ',', movie_name, ',', room_number, ',', screen_time)
                        ORDER BY id SEPARATOR '|')
    INTO actual_result
    FROM view_vip_movies_with_free_seats;

    SET test_result =  IF(actual_result != expected_result OR actual_result IS NULL, 0, 1);

    RETURN test_result;
END;

DROP FUNCTION IF EXISTS test_view_vip_movies;
CREATE FUNCTION test_view_vip_movies()
    RETURNS INT
    DETERMINISTIC
BEGIN
    DECLARE expected_result TEXT;
    DECLARE actual_result TEXT;
    DECLARE test_result INT;

    SET expected_result = CONCAT('The Dark Knight,The Silence of the Lambs,Interstellar',
                                 ',Inception,The Godfather: Part II,Se7en,The Lion King',
                                 ',Schindler''s List,The Departed,Fight Club,The Prestige',
                                 ',Eternal Sunshine of the Spotless Mind');

    SELECT GROUP_CONCAT(movie_name SEPARATOR ',')
    INTO actual_result
    FROM view_vip_movies;

    SET test_result = IF(actual_result != expected_result OR actual_result IS NULL, 0, 1);

    RETURN test_result;
END;

DROP FUNCTION IF EXISTS test_view_food_contains_dairy;
CREATE FUNCTION test_view_food_contains_dairy()
    RETURNS INT
    DETERMINISTIC
BEGIN
    DECLARE expected_result TEXT DEFAULT 'Ice Cream';
    DECLARE actual_result TEXT;
    DECLARE test_result INT;

    SELECT GROUP_CONCAT(product_name  SEPARATOR ',')
    INTO actual_result
    FROM view_food_contains_dairy;

    SET test_result = IF(actual_result != expected_result OR actual_result IS NULL, 0, 1);

    RETURN test_result;
END;

DROP FUNCTION IF EXISTS test_view_non_dairy_food;
CREATE FUNCTION test_view_non_dairy_food()
    RETURNS INT
    DETERMINISTIC
BEGIN
    DECLARE expected_result TEXT;
    DECLARE actual_result TEXT;
    DECLARE test_result INT;

    SET expected_result = CONCAT('Small Soda,Medium Soda,Large Soda,Pretzel,Pizza Slice',
                                 ',Chicken Tenders,Fries,Onion Rings,Nachos,Small Popcorn',
                                 ',Medium Popcorn,Large Popcorn,Hot Dog,Candy');

    SELECT GROUP_CONCAT(product_name  SEPARATOR ',')
    INTO actual_result
    FROM view_non_dairy_food;

    SET test_result = IF(actual_result != expected_result OR actual_result IS NULL, 0, 1);

    RETURN test_result;
END;

DROP FUNCTION IF EXISTS test_view_employee_that_sold;
CREATE FUNCTION test_view_employee_that_sold()
    RETURNS INT
    DETERMINISTIC
BEGIN
    DECLARE expected_result TEXT DEFAULT '20,3,15,19,7,11,12,16,5,27,8,24,28,23';
    DECLARE actual_result TEXT;
    DECLARE test_result INT;

    SELECT GROUP_CONCAT(id  SEPARATOR ',')
    INTO actual_result
    FROM view_employee_that_sold;

    SET test_result = IF(actual_result != expected_result OR actual_result IS NULL, 0, 1);

    RETURN test_result;
END;
