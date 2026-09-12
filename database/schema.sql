CREATE DATABASE IF NOT EXISTS pasahero_db
  DEFAULT CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE pasahero_db;

DROP TABLE IF EXISTS routes;

CREATE TABLE routes (
    id               INT AUTO_INCREMENT PRIMARY KEY,
    route_name       VARCHAR(120)  NOT NULL,
    origin           VARCHAR(120)  NOT NULL,
    destination      VARCHAR(120)  NOT NULL,
    vehicle_type     ENUM('jeepney','tricycle','bus','uv_express')
                     NOT NULL DEFAULT 'jeepney',
    regular_fare     DECIMAL(7,2)  NOT NULL DEFAULT 0.00,
    discounted_fare  DECIMAL(7,2)  NOT NULL DEFAULT 0.00,
    operating_hours  VARCHAR(80)   NOT NULL DEFAULT '',
    notes            TEXT          NULL,
    is_active        TINYINT(1)    NOT NULL DEFAULT 1,
    created_at       TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at       TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP
                     ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_routes_vehicle (vehicle_type),
    INDEX idx_routes_active  (is_active)
) ENGINE=InnoDB;