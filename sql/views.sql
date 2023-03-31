USE db_cinema;

DROP VIEW IF EXISTS view_employee_with_sold_products_count;
CREATE VIEW view_employee_with_sold_products_count AS
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
DROP VIEW IF EXISTS view_movies_not_for_adults;
CREATE VIEW view_movies_not_for_adults AS
(
    SELECT id, movie_name
    FROM movie
    WHERE rating != 'R'
);

-- SELECT * FROM view_movies_not_for_adults;

