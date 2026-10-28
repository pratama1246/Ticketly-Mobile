# AGENTS.md — Ticketly Backend

Panduan utama untuk AI coding agents (Claude Code, Cursor, Antigravity, dll).
Baca file ini sebelum melakukan perubahan apapun pada project ini.

---

## Project Overview

**Ticketly** adalah platform tiket event berbasis web dengan mobile app (Flutter).

- Framework: CodeIgniter 4
- Auth: CodeIgniter Shield (session-based untuk web, JWT custom untuk API)
- Database: MySQL
- Frontend web: Blade-style CI4 views + Tailwind CSS + Flowbite
- Mobile: Flutter — konsumsi REST API dari `app/Controllers/Api/`

Project ini adalah **existing project yang sedang dirapikan**, bukan project baru.
Tugas utama adalah **merapikan dan menyamakan layer API** dengan existing project serta menjaga konsistensi, bukan membangun ulang backend dari nol.

### Fokus Utama Perapian API:
- API Controller (`app/Controllers/Api/`)
- JWT/Auth Flow & Helpers (`app/Helpers/jwt_helper.php`)
- Filter/Middleware (`app/Filters/JwtFilter.php` & `CorsFilter.php`)
- Validation Rules
- API Routes (`app/Config/Routes.php` grup API)
- Response Structure (keseragaman format JSON)
- Pagination, Search, & Filter API

---

## Directory Structure

```
app/
  Config/           — Konfigurasi CI4 (Routes, Filters, Auth, Autoload)
  Controllers/
    Admin/          — Web controller untuk area admin
    Api/            — API controller untuk Flutter
    Public/         — Web controller untuk halaman publik
    User/           — Web controller untuk user/checkout
  Filters/          — JWT filter, CORS filter
  Helpers/          — jwt_helper.php (createJWT, decodeJWT)
  Models/           — Semua model CI4
  Database/
    Migrations/     — Schema migrations
    Seeds/          — Seeder data
```

---

## Backend Architecture Rules

### Yang Boleh Disentuh

- `app/Controllers/Api/` — API layer untuk Flutter
- `app/Filters/` — hanya kalau ada bug atau inkonsistensi nyata
- `app/Helpers/` — jwt_helper.php
- `app/Models/` — hanya tambah field di `$allowedFields` kalau perlu
- `app/Config/Routes.php` — tambah route baru di grup yang sudah ada

### Yang Tidak Boleh Disentuh Tanpa Alasan Kuat

- Web controllers (`Admin/`, `Public/`, `User/`) — sudah stabil
- `app/Config/Auth.php` dan `app/Config/AuthGroups.php`
- Struktur tabel database yang sudah ada
- Migration yang sudah di-run

### Prinsip Utama

- **Existing project adalah source of truth** — ikuti pola yang sudah ada, bukan best practice dari luar
- **Consistency over perfection** — lebih baik konsisten dengan pola lama daripada "benar" tapi beda sendiri
- **Minimal changes** — ubah hanya yang perlu diubah, jangan refactor sekalian
- **Jangan buat abstraction baru** kalau project tidak konsisten memakainya

---

## Naming Convention

### Controllers

```
app/Controllers/Api/EventController.php       → namespace App\Controllers\Api
app/Controllers/Admin/EventController.php     → namespace App\Controllers\Admin
app/Controllers/Public/EventController.php    → namespace App\Controllers\Public
```

Nama method ikuti pola CI4 resource: `index`, `show`, `create`, `store`, `edit`, `update`, `delete`.

### Models

```php
protected $table         = 'ticket_types';   // snake_case, plural
protected $allowedFields = ['event_id', ...]; // snake_case
protected $returnType    = 'array';           // selalu array, bukan object
```

### Routes API

```
GET    /api/events                    → index (list)
GET    /api/events/{slug}             → show (detail by slug)
GET    /api/events/{id}/tickets       → resource nested
POST   /api/checkout/start            → action
GET    /api/checkout/payment-methods  → action dengan resource noun
```

Gunakan kebab-case untuk URL, snake_case untuk JSON keys.

### Status Order

Selalu **lowercase**. Tidak ada kapital.

```
pending | completed | cancelled | expired
```

Jangan pakai `Pending`, `Completed`, `Cancelled`, `Expired`.

---

## API Consistency Rules

### Auth Flow

JWT diimplementasi custom, bukan Shield JWT bawaan.

```php
// Generate token (di AuthController login)
$token = createJWT($userId, $email);   // dari jwt_helper.php

// Validasi token (di JwtFilter)
$decoded = decodeJWT($token);
$_SERVER['JWT_USER_ID'] = $decoded->userId;
$_SERVER['JWT_EMAIL']   = $decoded->email;

// Ambil user ID di protected controller
$userId = $_SERVER['JWT_USER_ID'] ?? null;
if (!$userId) { /* return 401 */ }
```

Jangan ganti flow ini dengan Shield JWT atau library lain.

### Protected Routes

Route yang butuh login dibungkus dengan filter `jwt`:

```php
$routes->group('', ['filter' => 'jwt'], function ($routes) {
    $routes->get('profile', 'ProfileController::index');
    // ...
});
```

Public routes tidak perlu filter apapun.

---

## Response Structure

Semua API response harus mengikuti struktur ini **tanpa pengecualian**:

```json
{
  "status": "success",
  "message": "Pesan yang jelas.",
  "data": { } | [ ] | null
}
```

### HTTP Status Code

| Kondisi | Code |
|---|---|
| Berhasil GET/POST | 200 |
| Berhasil CREATE | 201 |
| Validasi gagal | 422 |
| Unauthorized (no/invalid token) | 401 |
| Not found | 404 |
| Conflict (stok habis, status salah) | 409 |
| Gone (order expired) | 410 |
| Server error | 500 |

### Shape `data` per Tipe Response

```json
// Single resource
"data": { "id": 1, "name": "..." }

// List / collection
"data": [ {...}, {...} ]

// Operasi tanpa return data (logout, cancel)
"data": null

// Error validasi
"data": { "field_name": "pesan error" }
```

### Pagination

Hanya endpoint list yang perlu pagination. Gunakan **sidecar `meta`**:

```json
{
  "status": "success",
  "message": "...",
  "data": [ ],
  "meta": {
    "total": 42,
    "per_page": 10,
    "current_page": 1,
    "last_page": 5
  }
}
```

`data` tetap flat array. `meta` hanya muncul di endpoint yang paginatable.
Endpoint lain tidak perlu `meta`.

Default: `page=1`, `limit=10`, max limit=50.

---

## Workflow Saat Melakukan Perubahan

### Sebelum Nulis Kode

1. Baca file yang akan diubah terlebih dahulu
2. Identifikasi pola yang sudah dipakai di file lain yang sejenis
3. Tentukan scope perubahan — catat apa yang diubah dan apa yang tidak
4. Kalau ragu soal pola, lihat controller yang sudah stabil sebagai referensi

### Saat Nulis Kode

1. Ikuti pola file yang sudah ada — jangan introduce pattern baru tanpa alasan
2. Ubah hanya yang masuk scope, jangan refactor sekalian
3. Jangan rename variable atau method yang sudah ada tanpa alasan jelas
4. Jangan tambah `use` statement untuk class yang tidak dipakai

### Setelah Perubahan

1. Cek apakah response structure tetap konsisten
2. Cek apakah ada status string yang tidak lowercase
3. Kalau ada perubahan yang menyentuh data lama di DB, sertakan query normalisasi

### Urutan Perubahan yang Aman

```
Config → Models → Helpers → Filters → Controllers
```

Mulai dari yang paling tidak berisiko. Controllers diubah paling akhir.

---

## Dangerous Operations

Hindari ini tanpa diskusi eksplisit:

```
JANGAN ubah struktur tabel yang sudah ada
JANGAN rename kolom database
JANGAN hapus atau pindahkan web controller yang sudah stabil
JANGAN ganti JWT flow dengan implementasi lain
JANGAN tambah Service layer / Repository layer / UseCase layer
JANGAN buat BaseApiController atau abstraction tambahan kalau tidak semua controller ikut
JANGAN ubah $validFields di Auth.php
JANGAN jalankan php artisan migrate:fresh atau truncate production data
JANGAN ubah Shield auth flow untuk web
```

---

## Anti-Patterns yang Harus Dihindari

```php
// JANGAN: overengineering response wrapper
class ApiResponse {
    public static function success($data) { ... }
}

// LAKUKAN: langsung inline seperti controller lain
return $this->response->setStatusCode(200)->setJSON([
    'status'  => 'success',
    'message' => '...',
    'data'    => $data
]);
```

```php
// JANGAN: buat interface atau abstract class baru
interface OrderRepositoryInterface { ... }

// LAKUKAN: pakai Model langsung seperti controller lain
$orderModel = new OrderModel();
$order = $orderModel->find($id);
```

```php
// JANGAN: status string kapital
['status' => 'Pending']

// LAKUKAN: selalu lowercase
['status' => 'pending']
```

---

## Checklist Sebelum Commit

- [ ] Response structure ikuti `{ status, message, data }`
- [ ] Status order selalu lowercase (`pending`, `completed`, dll)
- [ ] Tidak ada `addGroup()` duplikat atau logic yang diulang
- [ ] Pagination pakai sidecar `meta`, bukan membungkus `data`
- [ ] Tidak ada web controller yang ikut terubah
- [ ] Tidak ada abstraction baru yang tidak konsisten dengan project
- [ ] Kalau ada perubahan status di DB, sertakan query normalisasi data lama

---

## Referensi File Penting

| File | Fungsi |
|---|---|
| `app/Config/Routes.php` | Semua route web dan API |
| `app/Config/Filters.php` | Alias filter termasuk `jwt` dan `cors` |
| `app/Helpers/jwt_helper.php` | `createJWT()` dan `decodeJWT()` |
| `app/Filters/JwtFilter.php` | Validasi token, inject ke `$_SERVER` |
| `app/Controllers/Api/AuthController.php` | Login, register, logout |
| `app/Controllers/Api/EventController.php` | List, detail, featured events |
| `app/Controllers/Api/CheckoutController.php` | Full checkout flow API |
| `app/Models/OrderModel.php` | Termasuk `autoExpireOrders()` |


## Existing UI/API Priority

Jika ada konflik antara:
- best practice modern
- preferensi AI
- existing implementation

maka prioritaskan existing implementation selama masih stabil dan konsisten.

## Token & Context Efficiency

- jangan meminta seluruh repository jika tidak diperlukan
- prioritaskan representative files
- lakukan audit sebelum generate besar
- generate perubahan per file/module