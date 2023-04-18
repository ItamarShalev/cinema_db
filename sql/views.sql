USE db_cinema;


CREATE OR REPLACE VIEW view_employee_with_sold_products_count AS
(
    SELECT
        employee.id,
        employee.first_name,
        employee.last_name,
        IF(sell.employee_id IS NULL, 0, COUNT(*)) AS product_count
    FROM employee LEFT JOIN sell
    ON employee.id = sell.employee_id
    GROUP BY employee.id
);

-- Return all the movies not for adults
CREATE OR REPLACE VIEW view_movies_not_for_adults AS
(
    SELECT id, movie_name
    FROM movie
    WHERE rating != 'R'
);

CREATE OR REPLACE VIEW view_employee_earn_per_month AS
(
    SELECT
        employee.id,
        YEAR(sell.sell_time) AS at_year,
        MONTH(sell.sell_time) AS at_month,
        SUM(product.price) AS sales
    FROM sell INNER JOIN product INNER JOIN employee
    ON sell.product_id = product.id AND sell.employee_id = employee.id
    GROUP BY YEAR(sell.sell_time), MONTH(sell.sell_time), employee.id
);

CREATE OR REPLACE VIEW view_earn_per_month AS
(
    SELECT at_year, at_month, SUM(sales) AS sales
    FROM view_employee_earn_per_month
    GROUP BY at_year, at_month
);

CREATE OR REPLACE VIEW view_employee_with_sales_money AS
(
    SELECT
        employee.id,
        employee.first_name,
        employee.last_name,
        SUM(product.price) AS sales
    FROM employee
             INNER JOIN sell ON employee.id = sell.employee_id
             INNER JOIN product ON sell.product_id = product.id
    GROUP BY employee.id
    UNION DISTINCT
    SELECT
        employee.id AS id,
        employee.first_name,
        employee.last_name,
        0 AS sales
    FROM employee
             LEFT JOIN sell ON employee.id = sell.employee_id
    WHERE sell.employee_id IS NULL
);

CREATE OR REPLACE VIEW view_employee_with_amount_products AS
(
    SELECT
        employee.id,
        employee.first_name,
        employee.last_name,
        COUNT(employee.id) AS products_amount
    FROM employee
    INNER JOIN sell
    ON employee.id = sell.employee_id
    GROUP BY employee.id

    UNION DISTINCT

    SELECT
        employee.id,
        employee.first_name,
        employee.last_name,
        0 AS products_amount
    FROM employee
    LEFT JOIN sell
    ON employee.id = sell.employee_id
    WHERE sell.employee_id IS NULL
);

CREATE OR REPLACE VIEW view_vip_movies_with_free_seats AS
(
    SELECT
        movie.id,
        movie.movie_name,
        screen.room_number,
        screen.screen_time
    FROM movie
    INNER JOIN screen INNER JOIN theater
    ON screen.room_number = theater.room_number AND movie.id = screen.movie_id
    WHERE theater.is_vip = TRUE AND EXISTS(
        SELECT id
        FROM ticket
        WHERE ticket.room_number = theater.room_number AND ticket.screen_time = screen.screen_time
          AND ticket.id NOT IN (SELECT ticket_id
                                FROM sell
                                WHERE ticket_id IS NOT NULL)
    )
    ORDER BY screen.screen_time
);

-- Return all movies screening today.
CREATE OR REPLACE VIEW view_movies_screened_today AS
(
    SELECT screen_time, movie_name
    FROM movie
    INNER JOIN screen
    ON movie.id = screen.movie_id
    WHERE DATE(screen.screen_time) = CURDATE()
);

-- Return all VIP movies.
CREATE OR REPLACE VIEW view_vip_movies AS
(
    SELECT DISTINCT screen_time, movie_name
    FROM movie
    INNER JOIN screen INNER JOIN theater
    ON movie.id = screen.movie_id AND screen.room_number = theater.room_number
    WHERE theater.is_vip = 1
);

-- Return all food that contains dairy
CREATE OR REPLACE VIEW view_food_contains_dairy AS
(
    SELECT price, product_name
    FROM food
    INNER JOIN product
    ON food.id = product.id
    WHERE food.allergy = 'milk'
);

-- Return all non dairy food.
CREATE OR REPLACE VIEW view_non_dairy_food AS
(
    SELECT price, product_name
    FROM food
    INNER JOIN product
    ON food.id = product.id
    WHERE food.allergy IS NULL
       OR food.allergy != 'milk'
);

-- Return all employees that sold anything.
CREATE OR REPLACE VIEW view_employee_that_sold AS
(
    SELECT DISTINCT employee.id, employee.first_name , employee.last_name
    FROM employee INNER JOIN sell
    ON employee.id = sell.employee_id
);
