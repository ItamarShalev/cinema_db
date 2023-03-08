-- L039: Ignore one space before identifier to make it easier to read
-- L003: Ignore consist of only spaces to make it easier to read the on delete and update
-- noqa: disable=L039,L003

CREATE DATABASE IF NOT EXISTS db_cinema;

USE db_cinema;

CREATE TABLE IF NOT EXISTS employee
(
    id            INT         NOT NULL AUTO_INCREMENT,
    first_name    VARCHAR(50) NOT NULL,
    last_name     VARCHAR(50) NOT NULL,
    date_of_birth DATE        NOT NULL,
    PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS product
(
    id           INT         NOT NULL AUTO_INCREMENT,
    product_name VARCHAR(50) NOT NULL,
    price        INT         NOT NULL,
    PRIMARY KEY (id),
    CHECK (price > 0)
);

-- duration in minutes
CREATE TABLE IF NOT EXISTS movie
(
    id         INT         NOT NULL AUTO_INCREMENT,
    movie_name VARCHAR(50) NOT NULL,
    rating     VARCHAR(50) NOT NULL,
    duration   INT         NOT NULL,
    PRIMARY KEY (id),
    CHECK (duration > 0 AND rating IN ('G', 'PG', 'PG-13', 'R'))
);

CREATE TABLE IF NOT EXISTS theater
(
    room_number INT     NOT NULL,
    is_3d       TINYINT NOT NULL DEFAULT 0,
    seats       INT     NOT NULL,
    is_vip      TINYINT NOT NULL DEFAULT 0,
    PRIMARY KEY (room_number),
    CHECK (seats > 0 AND is_3d IN (0, 1) AND is_vip IN (0, 1))
);

CREATE TABLE IF NOT EXISTS customer
(
    id            INT          NOT NULL AUTO_INCREMENT,
    customer_name VARCHAR(100) NOT NULL,
    date_of_birth DATE         NOT NULL,
    PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS department
(
    id              INT          NOT NULL AUTO_INCREMENT,
    department_name VARCHAR(100) NOT NULL,
    manager_id      INT          NOT NULL,
    PRIMARY KEY (id),
    INDEX idx_fk_department (manager_id),
    CONSTRAINT fk_department FOREIGN KEY (manager_id) REFERENCES employee (id)
        ON DELETE NO ACTION
        ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS food
(
    id           INT     NOT NULL UNIQUE,
    need_cooling TINYINT NOT NULL DEFAULT 0,
    allergy      VARCHAR(10),
    min_age      INT     NOT NULL,
    CHECK ( need_cooling IN (0, 1) AND min_age > 0 AND allergy IN ('nuts', 'milk', 'soy')),
    INDEX idx_fk_food (id),
    CONSTRAINT fk_food FOREIGN KEY (id) REFERENCES product (id)
        ON DELETE NO ACTION
        ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS screen
(
    screen_time DATETIME NOT NULL,
    room_number INT      NOT NULL,
    movie_id    INT      NOT NULL,
    PRIMARY KEY (screen_time, room_number),
    INDEX idx_fk_screen_room (room_number),
    CONSTRAINT fk_screen_room FOREIGN KEY (room_number) REFERENCES theater (room_number)
        ON DELETE NO ACTION
        ON UPDATE CASCADE,
    INDEX idx_fk_screen_movie (movie_id),
    CONSTRAINT fk_screen_movie FOREIGN KEY (movie_id) REFERENCES movie (id)
        ON DELETE NO ACTION
        ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS sell
(
    employee_id INT      NOT NULL,
    customer_id INT      NOT NULL,
    product_id  INT      NOT NULL,
    sell_time   DATETIME NOT NULL,
    PRIMARY KEY (employee_id, customer_id, product_id, sell_time),
    INDEX idx_fk_sell_employee (employee_id),
    CONSTRAINT fk_sell_employee FOREIGN KEY (employee_id) REFERENCES employee (id)
        ON DELETE NO ACTION
        ON UPDATE CASCADE,
    INDEX idx_fk_sell_customer (customer_id),
    CONSTRAINT fk_sell_customer FOREIGN KEY (customer_id) REFERENCES customer (id)
        ON DELETE NO ACTION
        ON UPDATE CASCADE,
    INDEX idx_fk_sell_product (product_id),
    CONSTRAINT fk_sell_product FOREIGN KEY (product_id) REFERENCES product (id)
        ON DELETE NO ACTION
        ON UPDATE CASCADE,
    INDEX idx_fk_sell_screen (sell_time),
    CONSTRAINT fk_sell_screen FOREIGN KEY (sell_time) REFERENCES screen (screen_time)
        ON DELETE NO ACTION
        ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS ticket
(
    id          INT      NOT NULL,
    seat_number INT      NOT NULL,
    screen_time DATETIME NOT NULL,
    room_number INT      NOT NULL,
    screen_id   INT      NOT NULL,
    PRIMARY KEY (screen_id, seat_number),
    INDEX idx_fk_ticket (id),
    CONSTRAINT fk_ticket FOREIGN KEY (id) REFERENCES product (id)
        ON DELETE NO ACTION
        ON UPDATE CASCADE,
    INDEX idx_fk_ticket_screen (screen_time, room_number),
    CONSTRAINT fk_ticket_screen
        FOREIGN KEY (screen_time, room_number) REFERENCES screen (screen_time, room_number)
            ON DELETE CASCADE
            ON UPDATE CASCADE
);
