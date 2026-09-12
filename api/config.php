<?php
declare(strict_types=1);

/**
 * PasaHero API — shared configuration, database bootstrap, and helpers.
 */

header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Headers: Content-Type, Accept');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Content-Type: application/json; charset=utf-8');
header('Cache-Control: no-store');

if (($_SERVER['REQUEST_METHOD'] ?? '') === 'OPTIONS') {
    http_response_code(204);
    exit;
}

define('DB_HOST', 'localhost');
define('DB_USER', 'root');
define('DB_PASS', '');
define('DB_NAME', 'pasahero_db');

define('API_NAME', 'pasahero-api');
define('API_VERSION', '1.0.0');

/** Sends a uniform JSON envelope and terminates the request. */
function respond(bool $success, string $message, mixed $data = null, int $code = 200): void
{
    http_response_code($code);
    echo json_encode([
        'success' => $success,
        'message' => $message,
        'data'    => $data,
    ], JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
    exit;
}

function db(): mysqli
{
    static $conn = null;

    if ($conn instanceof mysqli) {
        return $conn;
    }

    mysqli_report(MYSQLI_REPORT_ERROR | MYSQLI_REPORT_STRICT);

    try {
        $conn = new mysqli(DB_HOST, DB_USER, DB_PASS, DB_NAME);
        $conn->set_charset('utf8mb4');
    } catch (Throwable $e) {
        respond(false, 'Database connection failed. Make sure MySQL is running.', null, 500);
    }

    return $conn;
}

function payload(): array
{
    $raw = file_get_contents('php://input');

    if ($raw === false || trim($raw) === '') {
        return $_POST;
    }

    $decoded = json_decode($raw, true);

    if (!is_array($decoded)) {
        respond(false, 'Request body is not valid JSON.', null, 400);
    }

    return $decoded;
}

function requireMethod(string $method): void
{
    if (($_SERVER['REQUEST_METHOD'] ?? '') !== $method) {
        respond(false, 'Method not allowed. This endpoint expects ' . $method . '.', null, 405);
    }
}

function label(string $key): string
{
    return ucfirst(str_replace('_', ' ', $key));
}

function textField(array $src, string $key, int $max, bool $required = true): string
{
    $value = trim((string)($src[$key] ?? ''));

    if ($required && $value === '') {
        respond(false, label($key) . ' is required.', null, 422);
    }

    if (mb_strlen($value) > $max) {
        respond(false, label($key) . ' must not exceed ' . $max . ' characters.', null, 422);
    }

    return $value;
}

function moneyField(array $src, string $key): float
{
    $raw = $src[$key] ?? 0;

    if (!is_numeric($raw)) {
        respond(false, label($key) . ' must be a number.', null, 422);
    }

    $value = round((float)$raw, 2);

    if ($value < 0) {
        respond(false, label($key) . ' cannot be negative.', null, 422);
    }

    if ($value > 99999.99) {
        respond(false, label($key) . ' is out of range.', null, 422);
    }

    return $value;
}

function enumField(array $src, string $key, array $allowed, string $fallback): string
{
    $value = strtolower(trim((string)($src[$key] ?? $fallback)));

    if (!in_array($value, $allowed, true)) {
        respond(false, label($key) . ' must be one of: ' . implode(', ', $allowed) . '.', null, 422);
    }

    return $value;
}