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

DROP PROCEDURE IF EXISTS get_employee_earned_most_money;
CREATE PROCEDURE get_employee_earned_most_money()
BEGIN
    DROP TEMPORARY TABLE IF EXISTS temporary_table_get_employee_earned_most_money;
    CREATE TEMPORARY TABLE IF NOT EXISTS temporary_table_get_employee_earned_most_money
    (
        id            INT,
        first_name    VARCHAR(255),
        last_name     VARCHAR(255),
        money INT
    );

    INSERT INTO temporary_table_get_employee_earned_most_money
    SELECT *
    FROM view_employee_with_sales_money
    WHERE sales = (SELECT MAX(sales) FROM view_employee_with_sales_money);

    SELECT * FROM temporary_table_get_employee_earned_most_money;
END;

DROP PROCEDURE IF EXISTS get_employees_not_sold_more_than_x_products;
CREATE PROCEDURE get_employees_not_sold_more_than_x_products(IN param_product_count INT)
BEGIN
    SELECT *
    FROM view_employee_with_amount_products
    WHERE products_amount < param_product_count;
END;

DROP PROCEDURE IF EXISTS remove_screen_if_no_tickets;
CREATE PROCEDURE remove_screen_if_no_tickets(
    IN param_room_number INT,
    IN param_screen_time DATETIME,
    OUT succeed BOOLEAN)
BEGIN
    DELETE FROM screen
    WHERE room_number = param_room_number AND screen_time = param_screen_time
    AND NOT EXISTS(SELECT ticket.id
                   FROM ticket
                   WHERE room_number = param_room_number AND screen_time = param_screen_time
                   AND ticket.id IN (SELECT ticket_id FROM sell WHERE ticket_id IS NOT NULL));

    SELECT ROW_COUNT() > 0
    INTO succeed;
END;

DROP PROCEDURE IF EXISTS update_manager_to_department;
CREATE PROCEDURE update_manager_to_department(
    IN param_manager_id INT,
    IN param_department_id INT,
    OUT succeed BOOLEAN)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            ROLLBACK;
        END;

    SET succeed = FALSE;

    START TRANSACTION;

    IF param_manager_id IN (SELECT manager_id FROM department WHERE id != param_department_id) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'The manager is already manager in different department.';
    END IF;

    START TRANSACTION;

    UPDATE employee
    SET department_id = param_department_id
    WHERE id = param_manager_id;

    UPDATE department
    SET manager_id = param_manager_id
    WHERE id = param_department_id;

    COMMIT;

    SET succeed = TRUE;

END;

DROP PROCEDURE IF EXISTS delete_useless_employees;
CREATE PROCEDURE delete_useless_employees()
BEGIN
    -- Disable foreign key checks to ignore shift_employee constraints.
    SET FOREIGN_KEY_CHECKS = 0;

    -- Delete all employees that didn't sell any item and they are not managers.
    DELETE FROM employee
    WHERE id NOT IN (SELECT employee_id FROM sell)
      AND id NOT IN (SELECT manager_id FROM department)
      AND id NOT IN (SELECT manager_id FROM branch);

    -- Re-enable foreign key checks.
    SET FOREIGN_KEY_CHECKS = 1;
END;

-- Returns all workers id, and full name from specific department.
DROP PROCEDURE IF EXISTS department_workers;
CREATE PROCEDURE department_workers(IN param_department_number INT)
BEGIN
    DROP TABLE IF EXISTS temporary_table_department_workers;
    CREATE TEMPORARY TABLE IF NOT EXISTS temporary_table_department_workers
    (
        id         INT,
        first_name VARCHAR(255),
        last_name  VARCHAR(255)
    );

    INSERT INTO temporary_table_department_workers
    SELECT id, first_name, last_name
    FROM employee
    WHERE department_id = param_department_number;

    SELECT * FROM temporary_table_department_workers ORDER BY id;
END;

-- All movies in specific date.
DROP PROCEDURE IF EXISTS movies_of_date;
CREATE PROCEDURE movies_of_date(IN param_date DATE)
BEGIN
    DROP TEMPORARY TABLE IF EXISTS temporary_table_movies_of_today;
    CREATE TEMPORARY TABLE IF NOT EXISTS temporary_table_movies_of_today
    (
        id          INT,
        screen_time DATETIME,
        movie_name  VARCHAR(255)
    );

    INSERT INTO temporary_table_movies_of_today
    SELECT id, screen_time, movie_name
    FROM movie
    INNER JOIN screen
    ON movie.id = screen.movie_id
    WHERE DATE(screen.screen_time) = param_date;

    SELECT * FROM temporary_table_movies_of_today;
END;

-- The shortest movie.
DROP PROCEDURE IF EXISTS shortest_movie;
CREATE PROCEDURE shortest_movie()
BEGIN

    DROP TEMPORARY TABLE IF EXISTS temporary_table_shortest_movie;
    CREATE TEMPORARY TABLE IF NOT EXISTS temporary_table_shortest_movie
    (
        id INT,
        movie_name VARCHAR(50)
    );

    INSERT INTO temporary_table_shortest_movie
    SELECT id, movie_name
    FROM movie
    WHERE duration_in_minutes = (SELECT MIN(duration_in_minutes) FROM movie);

    SELECT * FROM temporary_table_shortest_movie;

END;

-- Food for children under a certain age.
DROP PROCEDURE IF EXISTS food_for_toddlers;
CREATE PROCEDURE food_for_toddlers(IN param_min_age INT)
BEGIN
    DROP TEMPORARY TABLE IF EXISTS temporary_table_food_for_toddlers;
    CREATE TEMPORARY TABLE IF NOT EXISTS temporary_table_food_for_toddlers
    (
        price        INT,
        product_name VARCHAR(255)
    );

    INSERT INTO temporary_table_food_for_toddlers
    SELECT price, product_name
    FROM food
    INNER JOIN product
    ON food.id = product.id
    WHERE food.min_age <= param_min_age;

    SELECT * FROM temporary_table_food_for_toddlers;
END;

-- All tickets for specific screen, will return all available seats.
DROP PROCEDURE IF EXISTS tickets_for_screen;
CREATE PROCEDURE tickets_for_screen(IN param_screen_time DATETIME, IN param_movie_name VARCHAR(255))
BEGIN
    DROP TEMPORARY TABLE IF EXISTS temporary_table_tickets_for_screen;
    CREATE TEMPORARY TABLE IF NOT EXISTS temporary_table_tickets_for_screen
    (
        id   INT,
        seat INT
    );

    INSERT INTO temporary_table_tickets_for_screen
    SELECT ticket.id, ticket.seat_number
    FROM ticket
    INNER JOIN screen
    INNER JOIN theater
    INNER JOIN movie
    ON screen.movie_id = movie.id
        AND screen.room_number = theater.room_number
        AND ticket.room_number = screen.room_number
    WHERE ticket.screen_time = param_screen_time
      AND screen.screen_time = param_screen_time
      AND movie.movie_name = param_movie_name
      AND ticket.id NOT IN (SELECT ticket_id
                            FROM sell
                            WHERE ticket_id IS NOT NULL);

    SELECT * FROM temporary_table_tickets_for_screen;
END;

-- All customers that bought a product that is in a certain cost or more.
DROP PROCEDURE IF EXISTS customers_that_bought_in_certain_cost;
CREATE PROCEDURE customers_that_bought_in_certain_cost(IN param_cost INT)
BEGIN
    DROP TEMPORARY TABLE IF EXISTS temporary_table_customers_that_bought_in_certain_cost;
    CREATE TEMPORARY TABLE IF NOT EXISTS temporary_table_customers_that_bought_in_certain_cost
    (
        customer_name VARCHAR(255)
    );

    INSERT INTO temporary_table_customers_that_bought_in_certain_cost
    SELECT DISTINCT customer_name
    FROM customer
    INNER JOIN sell INNER JOIN product
    ON sell.product_id = product.id AND customer.id = sell.customer_id
    WHERE product.price >= param_cost;

    SELECT * FROM temporary_table_customers_that_bought_in_certain_cost;
END;

-- All screens that are NOT screened in a specific room.
DROP PROCEDURE IF EXISTS screens_not_in_theater;
CREATE PROCEDURE screens_not_in_theater(IN param_room INT)
BEGIN
    DROP TEMPORARY TABLE IF EXISTS temporary_table_screens_not_in_thetaer;
    CREATE TEMPORARY TABLE IF NOT EXISTS temporary_table_screens_not_in_thetaer
    (
        screen_time DATETIME,
        movie_name  VARCHAR(255)
    );

    INSERT INTO temporary_table_screens_not_in_thetaer
    SELECT screen_time, movie_name
    FROM screen
    INNER JOIN theater INNER JOIN movie
    ON screen.room_number = theater.room_number AND screen.movie_id = movie.id
    WHERE screen.room_number != param_room;

    SELECT * FROM temporary_table_screens_not_in_thetaer;
END;

-- Delete certain food that we stopped selling.
DROP PROCEDURE IF EXISTS delete_food;
CREATE PROCEDURE delete_food(IN id INT, OUT succeed BOOLEAN)
BEGIN
    DECLARE product_count INT;
    DECLARE food_count INT;

    SELECT COUNT(*) INTO product_count FROM product WHERE product.id = id;
    SELECT COUNT(*) INTO food_count FROM food WHERE food.id = id;

    IF product_count = 0 OR food_count = 0 THEN
        SET succeed = 0;
    ELSE
        DELETE FROM food WHERE food.id = id;
        DELETE FROM product WHERE product.id = id;
        SET succeed = 1;
    END IF;
END;

-- Add new food for sale.
DROP PROCEDURE IF EXISTS add_food;
CREATE PROCEDURE add_food(
IN param_name VARCHAR(255),
IN param_cost INT,
IN param_need_cooling TINYINT,
IN param_allegry VARCHAR(10),
IN param_min_age INT,
OUT succeed BOOLEAN)

BEGIN
    IF NOT EXISTS(SELECT * FROM product WHERE product_name = param_name)
        AND param_cost > 0 AND param_min_age > 0
    THEN
        INSERT INTO product(product_name, price)
        VALUES (param_name, param_cost);
        INSERT INTO food(id, need_cooling, allergy, min_age)
        VALUES ((SELECT LAST_INSERT_ID()), param_need_cooling, param_allegry, param_min_age);
        SET succeed = 1;
    ELSE
        SET succeed = 0;
    END IF;
END;

-- Add new employee.
DROP PROCEDURE IF EXISTS add_employee;
CREATE PROCEDURE add_employee(IN param_first_name VARCHAR(255),
                              IN param_last_name VARCHAR(255),
                              IN param_date_of_birth DATE,
                              IN param_department INT,
                              IN param_date_of_hiring DATE,
                              IN param_salary FLOAT,
                              IN param_rating INT,
                              OUT succeed BOOLEAN)
BEGIN
    IF NOT EXISTS(SELECT * FROM department WHERE id = param_department)
        OR param_first_name != '' OR param_last_name != ''
        OR EXISTS(SELECT *
                  FROM employee
                  WHERE first_name = param_first_name
                    AND last_name = param_last_name
                    AND date_of_birth = param_date_of_birth)
    THEN
        SET succeed = 0;
        SELECT 'Error';
    END IF;
    IF EXISTS(SELECT *
              FROM employee
              WHERE first_name = param_first_name
                AND last_name = param_last_name
                AND date_of_birth = param_date_of_birth) THEN
        SET succeed = 0;
    ELSE
        INSERT INTO employee(first_name, last_name, date_of_birth, department_id, date_of_hiring,
                             salary, rating)
        VALUES (param_first_name, param_last_name, param_date_of_birth, param_department,
                param_date_of_hiring, param_salary, param_rating);
        SET succeed = 1;
    END IF;
END;

-- Add sell to sell list, used for both ticket and food.
DROP PROCEDURE IF EXISTS add_sell;
CREATE PROCEDURE add_sell(IN param_customer_id INT,
                          IN param_customer_name VARCHAR(255),
                          IN param_date_of_birth DATE,
                          IN param_employee_id INT,
                          IN param_product_id INT,
                          IN param_ticket_id INT,
                          OUT succeed BOOLEAN)
BEGIN
    IF NOT EXISTS(SELECT *
                  FROM customer
                  WHERE param_customer_name = customer.customer_name
                    AND param_date_of_birth = customer.date_of_birth
                    AND param_employee_id = customer.id)
        OR NOT EXISTS(SELECT *
                      FROM employee
                      WHERE param_employee_id = employee.id)
        OR NOT EXISTS(SELECT *
                      FROM product
                      WHERE param_product_id = product.id)
    THEN
        SET succeed = 0;
        SELECT 'Error';
    END IF;
    IF param_ticket_id < 0
    THEN
        IF param_product_id = 16 OR param_product_id = 17
            OR NOT EXISTS(SELECT *
                          FROM employee
                          WHERE employee.id = param_employee_id
                            AND employee.department_id = 4)
        THEN
            SET succeed = 0;
            SELECT 'Error';
        ELSE
            INSERT INTO sell(employee_id, customer_id, product_id, ticket_id, sell_time)
            VALUES (param_employee_id, param_customer_id, param_product_id, NULL, NOW());
            SET succeed = 1;
        END IF;
    ELSE
        IF NOT EXISTS(SELECT *
                      FROM employee
                      WHERE employee.id = param_employee_id
                        AND employee.department_id = 1)
        THEN
            SET succeed = 0;
            SELECT 'Error';
        ELSE
            INSERT INTO sell(employee_id, customer_id, product_id, ticket_id, sell_time)
            VALUES (param_employee_id, param_customer_id, param_product_id, param_ticket_id,
                    NOW());
            SET succeed = 1;
        END IF;
    END IF;
END;

-- Return one row of specific movie.
DROP PROCEDURE IF EXISTS get_movie_by_id;
CREATE PROCEDURE get_movie_by_id(IN param_id INT)
BEGIN
    DROP TEMPORARY TABLE IF EXISTS temporary_table_movie;
    CREATE TEMPORARY TABLE IF NOT EXISTS temporary_table_movie
    (
        id                  INT,
        movie_name          VARCHAR(255),
        rating              VARCHAR(255),
        duration_in_minutes INT,
        screen_time         DATE,
        room_number         INT
    );

    INSERT INTO temporary_table_movie
    SELECT id, movie_name, rating, duration_in_minutes, screen_time, room_number
    FROM movie
             INNER JOIN screen
    WHERE movie.id = screen.movie_id
      AND movie.id = param_id;

    SELECT * FROM temporary_table_movie;
END;
