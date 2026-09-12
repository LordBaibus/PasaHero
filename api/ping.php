<?php
declare(strict_types=1);

require_once __DIR__ . '/config.php';

/**
 * Health-check endpoint.
 * The Flutter client calls this to validate the server IP address entered by
 * the user, and again every few seconds to detect a server that goes offline
 * while the application is running.
 */

requireMethod('GET');

$routeCount = 0;

try {
    $result = db()->query('SELECT COUNT(*) AS total FROM routes');
    $row = $result->fetch_assoc();
    $routeCount = (int)($row['total'] ?? 0);
} catch (Throwable $e) {
    respond(false, 'API reachable but the database query failed.', null, 500);
}

respond(true, 'PasaHero API is online.', [
    'api'         => API_NAME,
    'version'     => API_VERSION,
    'server_time' => date('c'),
    'route_count' => $routeCount,
]);
