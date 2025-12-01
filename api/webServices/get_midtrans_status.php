<?php
require_once "../config/connect.php";
require '../config/midtrans_config.php';

use Midtrans\Transaction;

date_default_timezone_set('Asia/Jakarta');
$headers   = getallheaders();
$xusername = $headers['x-username'] ?? '';
$xpassword = $headers['x-password'] ?? '';

ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
  $response = [];

  $token    = $_POST['token']    ?? '';
  $id_user  = $_POST['id_user']  ?? '';
  $id_order = $_POST['id_order'] ?? '';

  // cek security header
  $cekSecurity = mysqli_query($con, "SELECT * FROM settings WHERE xusername='$xusername' and xpassword=md5('$xpassword')");
  if (mysqli_num_rows($cekSecurity) == 0) {
    $response["value"]   = 0;
    $response["message"] = "You don't have authorizations!";
    echo json_encode($response);
    exit;
  }

  // cek token
  $cekSettings = mysqli_query($con, "SELECT * FROM settings WHERE token='$token'");
  $do = mysqli_fetch_array($cekSettings);
  if (!$do) {
    $response["value"]   = 0;
    $response["message"] = "Token Invalid!";
    echo json_encode($response);
    exit;
  }

  // Ambil order
  $qOrder = mysqli_query($con, "
        SELECT * FROM orders 
        WHERE id_order='$id_order' AND id_user='$id_user'
        LIMIT 1
    ");
  if (mysqli_num_rows($qOrder) == 0) {
    $response["value"]   = 0;
    $response["message"] = "Order tidak ditemukan!";
    echo json_encode($response);
    exit;
  }

  $order = mysqli_fetch_array($qOrder);

  // Kalau mau, bisa panggil status ke Midtrans juga:
  // $statusMid = Transaction::status($order['midtrans_order_id']);
  // lalu sync lagi ke DB (opsional, karena notifikasi udah cukup)

  $response["value"]            = 1;
  $response["message"]          = "Berhasil";
  $response["id_order"]         = (int)$order['id_order'];
  $response["status_order"]     = $order['status_order'];
  $response["midtrans_status"]  = $order['midtrans_status'];
  $response["payment_method"]   = $order['payment_method'];
  $response["total_amount"]     = (int)$order['total_amount'];
  $response["midtrans_orderid"] = $order['midtrans_order_id'];

  echo json_encode($response);
}
