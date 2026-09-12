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

INSERT INTO routes
    (route_name, origin, destination, vehicle_type,
     regular_fare, discounted_fare, operating_hours, notes, is_active)
VALUES
    ('Angeles - Dau Terminal', 'Nepo Mart, Angeles City', 'Dau Bus Terminal',
     'jeepney', 15.00, 12.00, '4:30 AM - 10:00 PM',
     'Passes through MacArthur Highway. Heavy traffic during rush hour.', 1),

    ('Sta. Ana - San Fernando', 'Sta. Ana Public Market', 'SM City Pampanga',
     'jeepney', 35.00, 28.00, '5:00 AM - 9:00 PM',
     'Limited trips after 7:00 PM.', 1),

    ('Balibago - Clark Main Gate', 'Balibago Rotonda', 'Clark Main Gate',
     'tricycle', 60.00, 60.00, '24 hours',
     'Special rate. Negotiable at night.', 1),

    ('Pampanga - Cubao', 'San Fernando Terminal', 'Cubao, Quezon City',
     'bus', 180.00, 144.00, '3:00 AM - 11:00 PM',
     'Airconditioned. Student and senior discount available.', 1),

    ('Angeles - Baguio', 'Dau Terminal', 'Baguio City',
     'uv_express', 450.00, 360.00, '6:00 AM, 10:00 AM, 2:00 PM',
     'Advance booking recommended on weekends.', 0);