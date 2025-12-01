<?php
require_once "../config/connect.php";
require_once "../config/midtrans_config.php";  // yang ada Config::$serverKey

use Midtrans\Config;

ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

// Ambil raw JSON dari Midtrans
$raw = file_get_contents('php://input');
$data = json_decode($raw, true);

// Log kalau mau debugging
// file_put_contents('midtrans_log.txt', $raw . PHP_EOL, FILE_APPEND);

if (!$data) {
  http_response_code(400);
  echo "Invalid JSON";
  exit;
}

$order_id       = $data['order_id']       ?? '';
$status_code    = $data['status_code']    ?? '';
$gross_amount   = $data['gross_amount']   ?? '';
$signature_key  = $data['signature_key']  ?? '';
$transaction_status = $data['transaction_status'] ?? '';
$payment_type   = $data['payment_type']   ?? '';
$fraud_status   = $data['fraud_status']   ?? '';

// Verifikasi signature
$mySig = hash('sha512', $order_id . $status_code . $gross_amount . Config::$serverKey);

if ($signature_key !== $mySig) {
  http_response_code(403);
  echo "Invalid signature";
  exit;
}

// Mapping status dari Midtrans ke status lokal
$status_order = 'MENUNGGU_PEMBAYARAN';

if ($transaction_status == 'capture' || $transaction_status == 'settlement') {
  // kartu kredit / full payment
  $status_order = 'LUNAS';
} elseif ($transaction_status == 'pending') {
  $status_order = 'MENUNGGU_PEMBAYARAN';
} elseif ($transaction_status == 'deny' || $transaction_status == 'cancel') {
  $status_order = 'DIBATALKAN';
} elseif ($transaction_status == 'expire') {
  $status_order = 'KADALUARSA';
}

// order_id dari Midtrans = midtrans_order_id (yang tadi kita set ke FP-XXXX)
$midtrans_order_id = $order_id;

// Update ke tabel orders
mysqli_query($con, "
    UPDATE orders 
    SET midtrans_status = '$transaction_status',
        status_order    = '$status_order'
    WHERE midtrans_order_id = '$midtrans_order_id'
");

// Boleh juga simpan log ke tabel lain kalau mau

http_response_code(200);
echo "OK";
