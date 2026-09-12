<?php
declare(strict_types=1);

require_once __DIR__ . '/config.php';

/**
 * CREATE — inserts a new transport route.
 *
 *   POST /api/routes_create.php
 */

requireMethod('POST');

$input = payload();

$routeName      = textField($input, 'route_name', 120);
$origin         = textField($input, 'origin', 120);
$destination    = textField($input, 'destination', 120);
$operatingHours = textField($input, 'operating_hours', 80, false);
$notes          = textField($input, 'notes', 1000, false);

$vehicleType = enumField(
    $input,
    'vehicle_type',
    ['jeepney', 'tricycle', 'bus', 'uv_express'],
    'jeepney'
);

$regularFare    = moneyField($input, 'regular_fare');
$discountedFare = moneyField($input, 'discounted_fare');
$isActive       = boolField($input, 'is_active', true);