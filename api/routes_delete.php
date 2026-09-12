<?php
declare(strict_types=1);

require_once __DIR__ . '/config.php';

requireMethod('POST');

$input = payload();
$id    = idField($input);

$route = findRouteOrFail($id);

$stmt = db()->prepare('DELETE FROM routes WHERE id = ?');
$stmt->bind_param('i', $id);
$stmt->execute();

$affected = $stmt->affected_rows;
$stmt->close();

if ($affected < 1) {
    respond(false, 'Delete failed. The route may have already been removed.', null, 409);
}

respond(true, 'Route "' . $route['route_name'] . '" deleted successfully.', [
    'id' => $id,
]);
