<?php
declare(strict_types=1);

require_once __DIR__ . '/config.php';

/**
 * READ — returns all routes, a filtered subset, or a single route by id.
 *
 *   GET /api/routes_read.php
 *   GET /api/routes_read.php?id=3
 *   GET /api/routes_read.php?search=dau&vehicle_type=jeepney
 */

requireMethod('GET');

if (isset($_GET['id'])) {
    $route = findRouteOrFail(idField($_GET));
    respond(true, 'Route retrieved successfully.', mapRoute($route));
}

$search  = trim((string)($_GET['search'] ?? ''));
$vehicle = trim((string)($_GET['vehicle_type'] ?? ''));

$allowedVehicles = ['jeepney', 'tricycle', 'bus', 'uv_express'];

$sql        = 'SELECT * FROM routes WHERE 1 = 1';
$types      = '';
$parameters = [];

if ($search !== '') {
    $sql .= ' AND (route_name LIKE ? OR origin LIKE ? OR destination LIKE ?)';
    $needle = '%' . $search . '%';
    $types .= 'sss';
    $parameters[] = $needle;
    $parameters[] = $needle;
    $parameters[] = $needle;
}

if ($vehicle !== '' && in_array(strtolower($vehicle), $allowedVehicles, true)) {
    $sql .= ' AND vehicle_type = ?';
    $types .= 's';
    $parameters[] = strtolower($vehicle);
}

$sql .= ' ORDER BY is_active DESC, route_name ASC';

$stmt = db()->prepare($sql);

if ($types !== '') {
    $stmt->bind_param($types, ...$parameters);
}

$stmt->execute();
$result = $stmt->get_result();

$routes = [];
while ($row = $result->fetch_assoc()) {
    $routes[] = mapRoute($row);
}

$stmt->close();

respond(true, count($routes) . ' route(s) retrieved.', $routes);
