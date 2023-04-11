USE db_cinema;

DROP PROCEDURE IF EXISTS get_products_under_price;
CREATE PROCEDURE get_products_under_price(IN param_price INT)
BEGIN
    DROP TEMPORARY TABLE IF EXISTS temporary_table_products_under_price;
    CREATE TEMPORARY TABLE IF NOT EXISTS temporary_table_products_under_price
    (
        id           INT,
        product_name VARCHAR(255),
        price        INT
    );

    INSERT INTO temporary_table_products_under_price
    SELECT id, product_name, price
    FROM product
    WHERE price < param_price;

    SELECT * FROM temporary_table_products_under_price;
END;

DROP PROCEDURE IF EXISTS get_employee_birthday_in_month;
CREATE PROCEDURE get_employee_birthday_in_month(IN param_month INT)
BEGIN
    DROP TEMPORARY TABLE IF EXISTS temporary_table_employee_birthday_in_month;
    CREATE TEMPORARY TABLE IF NOT EXISTS temporary_table_employee_birthday_in_month
    (
        id            INT,
        employee_name VARCHAR(255),
        date_of_birth DATE
    );

    INSERT INTO temporary_table_employee_birthday_in_month
    SELECT id, CONCAT(first_name, ' ', last_name) AS full_name, date_of_birth
    FROM employee
    WHERE MONTH(date_of_birth) = param_month;

    SELECT * FROM temporary_table_employee_birthday_in_month;
END;

DROP PROCEDURE IF EXISTS get_food_that_need_cooling;
CREATE PROCEDURE get_food_that_need_cooling()
BEGIN
    DROP TEMPORARY TABLE IF EXISTS temporary_table_food_that_need_cooling;
    CREATE TEMPORARY TABLE IF NOT EXISTS temporary_table_food_that_need_cooling
    (
        id        INT,
        food_name VARCHAR(255)
    );

    INSERT INTO temporary_table_food_that_need_cooling
    SELECT product.id, product.product_name AS food_name
    FROM product
    NATURAL JOIN food
    WHERE food.need_cooling = TRUE;

    SELECT * FROM temporary_table_food_that_need_cooling;
END;

DROP PROCEDURE IF EXISTS get_movies_screen_in_theater;
CREATE PROCEDURE get_movies_screen_in_theater(IN param_room_number INT)
BEGIN
    DROP TEMPORARY TABLE IF EXISTS temporary_table_movies_screen_in_theater;
    CREATE TEMPORARY TABLE IF NOT EXISTS temporary_table_movies_screen_in_theater
    (
        id         INT,
        movie_name VARCHAR(255)
    );

    INSERT INTO temporary_table_movies_screen_in_theater
    SELECT movie.id, movie.movie_name
    FROM movie
    INNER JOIN screen
    ON movie.id = screen.movie_id
    WHERE screen.room_number = param_room_number;

    SELECT * FROM temporary_table_movies_screen_in_theater;
END;

DROP PROCEDURE IF EXISTS get_tickets_sold_in_screen;
CREATE PROCEDURE get_tickets_sold_in_screen(IN param_screen_time DATETIME, IN param_room_number INT)
BEGIN
    DROP TEMPORARY TABLE IF EXISTS temporary_table_tickets_sold_in_screen;
    CREATE TEMPORARY TABLE IF NOT EXISTS temporary_table_tickets_sold_in_screen
    (
        seat_number INT
    );

    INSERT INTO temporary_table_tickets_sold_in_screen
    SELECT ticket.seat_number
    FROM ticket INNER JOIN sell
    ON ticket.id = sell.ticket_id
    WHERE ticket.screen_time = param_screen_time
    AND ticket.room_number = param_room_number;

    SELECT * FROM temporary_table_tickets_sold_in_screen;
END;

DROP PROCEDURE IF EXISTS get_employee_with_most_products;
CREATE PROCEDURE get_employee_with_most_products()
BEGIN
    DROP TEMPORARY TABLE IF EXISTS temporary_table_employee_with_most_products;
    CREATE TEMPORARY TABLE IF NOT EXISTS temporary_table_employee_with_most_products
    (
        id            INT,
        first_name    VARCHAR(255),
        last_name     VARCHAR(255),
        product_count INT
    );

    INSERT INTO temporary_table_employee_with_most_products
    SELECT *
    FROM view_employee_with_sold_products_count
    WHERE product_count = (SELECT MAX(product_count) FROM view_employee_with_sold_products_count);

    SELECT * FROM temporary_table_employee_with_most_products;
END;
