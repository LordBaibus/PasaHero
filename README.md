# PasaHero

A Flutter mobile application that manages local transport routes and fares
(jeepney, tricycle, bus, UV Express) through a native PHP API served by XAMPP
over a local network connection.

The application cannot be used until a reachable server IP address has been
entered and verified, and it detects and reports the server going offline while
the application is running.

## Features

- Server IP address entry screen with format validation and live connectivity check
- Full CRUD against a native PHP API (no framework)
- Automatic detection of server disconnection, with a dialog and a Close button
- Interface built with Liquid Glass widgets (`liquid_glass_widgets`)

## Requirements

- Flutter **3.41.0 or newer** (`liquid_glass_widgets` needs recent shader APIs)
- XAMPP with Apache and MySQL
- Phone and server on the **same Wi-Fi network**

## Backend setup (XAMPP)

The PHP backend is not included in this repository, as allowed by the activity
specification. To recreate it:

1. Create the folder `C:\xampp\htdocs\pasahero_api\api\`.
2. Add `config.php`, `ping.php`, `routes_read.php`, `routes_create.php`,
   `routes_update.php`, and `routes_delete.php`.
3. Start **Apache** and **MySQL** from the XAMPP Control Panel.
4. Open `http://localhost/phpmyadmin`, go to the **SQL** tab, and run the
   schema in the *Database* section below.
5. Run `ipconfig` and note the **IPv4 Address** of your Wi-Fi adapter.
6. Verify from the phone's browser:
   `http://<your-ip>/pasahero_api/api/ping.php`

## Running the app

```bash
flutter pub get
flutter run
```

On the first screen, type the server IP address (for example `192.168.1.14`)
and tap **Connect to Server**. A port may be included if Apache is not on
port 80, for example `192.168.1.14:8080`.

## API documentation

Base URL: `http://<server-ip>/pasahero_api/api`

All endpoints return the same JSON envelope:

```json
{ "success": true, "message": "Route created successfully.", "data": { } }
```

### GET `ping.php`

Health check. Used both to validate the IP the user typed and to detect
disconnection while the app is running.

```json
{
  "success": true,
  "message": "PasaHero API is online.",
  "data": {
    "api": "pasahero-api",
    "version": "1.0.0",
    "server_time": "2026-09-11T10:24:00+08:00",
    "route_count": 5
  }
}
```

The client verifies that `data.api` equals `pasahero-api` so that an unrelated
web server is not mistaken for this backend.

### GET `routes_read.php`

| Query param    | Required | Description                                  |
| -------------- | -------- | -------------------------------------------- |
| `id`           | no       | Returns one route instead of a list           |
| `search`       | no       | Matches route name, origin, or destination    |
| `vehicle_type` | no       | `jeepney`, `tricycle`, `bus`, or `uv_express` |

`data` is an array of route objects, or a single object when `id` is supplied.

### POST `routes_create.php`

Body (JSON):

```json
{
  "route_name": "Angeles - Dau Terminal",
  "origin": "Nepo Mart, Angeles City",
  "destination": "Dau Bus Terminal",
  "vehicle_type": "jeepney",
  "regular_fare": 15.00,
  "discounted_fare": 12.00,
  "operating_hours": "4:30 AM - 10:00 PM",
  "notes": "Passes through MacArthur Highway.",
  "is_active": true
}
```

Returns `201` with the created record in `data`.

### POST `routes_update.php`

Same body as create, plus a required `id`. Returns the updated record.

### POST `routes_delete.php`

```json
{ "id": 3 }
```

Returns `data: { "id": 3 }` on success.

### Validation rules enforced by the API

- `route_name`, `origin`, and `destination` are required
- `origin` and `destination` must be different
- `discounted_fare` may not exceed `regular_fare`
- Fares must be numeric and not negative
- `route_name` + `vehicle_type` must be unique (returns `409` otherwise)

### Error responses

| Status | Meaning                                    |
| ------ | ------------------------------------------ |
| 400    | Request body was not valid JSON            |
| 404    | Route id does not exist                    |
| 405    | Wrong HTTP method for the endpoint         |
| 409    | Duplicate route name for that vehicle type |
| 422    | A field failed validation                  |
| 500    | Database connection or query failure       |

## Database

Database name: `pasahero_db`, table: `routes`.

| Column            | Type                                          | Notes                    |
| ----------------- | --------------------------------------------- | ------------------------ |
| `id`              | INT AUTO_INCREMENT                            | Primary key              |
| `route_name`      | VARCHAR(120)                                  | Required                 |
| `origin`          | VARCHAR(120)                                  | Required                 |
| `destination`     | VARCHAR(120)                                  | Required                 |
| `vehicle_type`    | ENUM(jeepney, tricycle, bus, uv_express)      | Default `jeepney`        |
| `regular_fare`    | DECIMAL(7,2)                                  |                          |
| `discounted_fare` | DECIMAL(7,2)                                  | Must be <= regular fare  |
| `operating_hours` | VARCHAR(80)                                   | Optional                 |
| `notes`           | TEXT                                          | Optional                 |
| `is_active`       | TINYINT(1)                                    | Default 1                |
| `created_at`      | TIMESTAMP                                     | Auto                     |
| `updated_at`      | TIMESTAMP                                     | Auto on update           |

## Troubleshooting

**The phone cannot reach the server even though `localhost` works on the PC.**
Apache only answers on localhost by default on some setups. Open
`C:\xampp\apache\conf\extra\httpd-xampp.conf`, find the
`<Directory "C:/xampp/htdocs">` block, and make sure it contains
`Require all granted`. Restart Apache afterwards.

**Connection times out from the phone.**
Windows Firewall is usually blocking port 80. Add an inbound rule allowing
TCP port 80, or temporarily disable the firewall for the private network while
demonstrating.

**The app connects but immediately reports a disconnection.**
MySQL is not running. Apache answers `ping.php`, but the database query inside
it fails and returns `success: false`.

**Text shows yellow debug underlines.**
The app must run under `CupertinoApp`, not `MaterialApp`.
`liquid_glass_widgets` is Material-free by design.

**`flutter pub get` fails on `liquid_glass_widgets`.**
Flutter is older than 3.41.0. Run `flutter upgrade`.

## Team

| Member    | Responsibility                                            |
|-----------| --------------------------------------------------------- |
| Enriquez  | PHP API, database, project setup, documentation           |
| Sison     | Networking layer, IP validation, connect screen, dialogs  |
| Maniago   | Glass theme, data model, CRUD service, home screen (Read) |
| Collantes | Create and Update forms, input validation                 |
| Bautista  | Detail screen, Delete, disconnection detection            |
