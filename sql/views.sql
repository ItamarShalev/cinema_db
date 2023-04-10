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

SELECT * FROM view_employee_earn_per_month;
