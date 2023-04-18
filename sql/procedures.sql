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
    -- Delete all employees that didn't sell any item and they are not managers
    DELETE FROM employee
    WHERE id NOT IN (SELECT employee_id FROM sell)
      AND id NOT IN (SELECT manager_id FROM department);
END;

-- Returns all workers id, and full name from specific department.
DROP PROCEDURE IF EXISTS department_workers;
CREATE PROCEDURE department_workers(IN dep_num INT)
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
    WHERE department_id = dep_num;

    SELECT * FROM temporary_table_department_workers ORDER BY id;
END;

-- All movies in specific date.
DROP PROCEDURE IF EXISTS movies_of_date;
CREATE PROCEDURE movies_of_date(IN param_date DATE)
BEGIN
    DROP TEMPORARY TABLE IF EXISTS temporary_table_movies_of_today;
    CREATE TEMPORARY TABLE IF NOT EXISTS temporary_table_movies_of_today
    (
        screen_time DATETIME,
        movie_name  VARCHAR(255)
    );

    INSERT INTO temporary_table_movies_of_today
    SELECT screen_time, movie_name
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
CREATE PROCEDURE delete_food(IN id INT)
BEGIN
    DELETE FROM product WHERE product.id = id;
    DELETE FROM food WHERE food.id = id;
END;

-- Add new food for sale.
DROP PROCEDURE IF EXISTS add_food;
CREATE PROCEDURE add_food(IN param_name VARCHAR(255), IN param_cost INT)
BEGIN
    IF NOT EXISTS(SELECT * FROM product WHERE product_name = param_name) THEN
        INSERT INTO product(product_name, price)
        VALUES (param_name, param_cost);
        SELECT 'New product was added to Products' AS message;
    ELSE
        SELECT 'This name already exists!' AS message;
    END IF;
END;

-- Add new employee.
DROP PROCEDURE IF EXISTS add_employee;
CREATE PROCEDURE add_employee(IN param_first_name VARCHAR(255), IN param_last_name VARCHAR(255),
                              IN param_date_of_birth DATE, IN param_department INT)
BEGIN
    IF NOT EXISTS(SELECT * FROM department WHERE id = param_department) THEN
        SELECT 'Department number does not exists!' AS message;
    END IF;
    IF EXISTS(SELECT *
              FROM employee
              WHERE first_name = param_first_name
                AND last_name = param_last_name
                AND date_of_birth = param_date_of_birth) THEN

        INSERT INTO employee(first_name, last_name, date_of_birth, department_id)
        VALUES (param_first_name, param_last_name, param_date_of_birth, param_department);
        SELECT 'New Employee was added! notice there is an employee with same info.' AS message;
    ELSE
        INSERT INTO employee(first_name, last_name, date_of_birth, department_id)
        VALUES (param_first_name, param_last_name, param_date_of_birth, param_department);
        SELECT 'New Employee was added!' AS message;
    END IF;
END;
