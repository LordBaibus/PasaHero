<?php
declare(strict_types=1);

require_once __DIR__ . '/config.php';

/**
 * UPDATE — modifies an existing transport route.
 *
 *   POST /api/routes_update.php
 */

requireMethod('POST');

$input = payload();
$id    = idField($input);

findRouteOrFail($id);

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

if ($discountedFare > $regularFare) {
    respond(false, 'Discounted fare cannot be higher than the regular fare.', null, 422);
}

if (strcasecmp($origin, $destination) === 0) {
    respond(false, 'Origin and destination must be different.', null, 422);
}

$duplicateCheck = db()->prepare(
    'SELECT id FROM routes WHERE route_name = ? AND vehicle_type = ? AND id <> ? LIMIT 1'
);
$duplicateCheck->bind_param('ssi', $routeName, $vehicleType, $id);
$duplicateCheck->execute();
$existing = $duplicateCheck->get_result()->fetch_assoc();
$duplicateCheck->close();

if ($existing !== null) {
    respond(false, 'Another route already uses this name for that vehicle type.', null, 409);
}

$stmt = db()->prepare(
    'UPDATE routes SET
        route_name = ?, origin = ?, destination = ?, vehicle_type = ?,
        regular_fare = ?, discounted_fare = ?, operating_hours = ?,
        notes = ?, is_active = ?
     WHERE id = ?'
);

$stmt->bind_param(
    'ssssddssii',
    $routeName,
    $origin,
    $destination,
    $vehicleType,
    $regularFare,
    $discountedFare,
    $operatingHours,
    $notes,
    $isActive,
    $id
);

$stmt->execute();
$stmt->close();

respond(true, 'Route updated successfully.', mapRoute(findRouteOrFail($id)));
