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
    INNER JOIN sell ON employee.id = sell.employee_id
    GROUP BY employee.id
    UNION DISTINCT
    SELECT
        employee.id,
        employee.first_name,
        employee.last_name,
        0 AS products_amount
    FROM employee
    LEFT JOIN sell ON employee.id = sell.employee_id
    WHERE sell.employee_id IS NULL
);
