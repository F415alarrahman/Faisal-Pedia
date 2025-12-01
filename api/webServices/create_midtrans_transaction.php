<?php
require_once "../config/connect.php";
require_once "../config/midtrans_config.php";

use Midtrans\Snap;

date_default_timezone_set('Asia/Jakarta');
$tglSekarang = date('Y-m-d H:i:s');
$tgl         = date('Y-m-d');
$headers     = getallheaders();
$xusername   = isset($headers['x-username']) ? $headers['x-username'] : '';
$xpassword   = isset($headers['x-password']) ? $headers['x-password'] : '';

ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
  $response = [];

  // ===== DATA DARI CLIENT =====
  $token    = isset($_POST['token']) ? $_POST['token'] : '';
  $id_user  = isset($_POST['id_user']) ? (int)$_POST['id_user'] : 0;
  $id_order = isset($_POST['id_order']) ? (int)$_POST['id_order'] : 0;

  if ($token == '' || $id_user == 0 || $id_order == 0) {
    $response['value']   = 0;
    $response['message'] = 'Data tidak lengkap (token / id_user / id_order)!';
    echo json_encode($response);
    exit;
  }

  // ===== CEK SECURITY HEADER =====
  $cekSecurity = mysqli_query(
    $con,
    "SELECT * FROM settings WHERE xusername='$xusername' AND xpassword=MD5('$xpassword')"
  );
  if (mysqli_num_rows($cekSecurity) == 0) {
    $response['value']   = 0;
    $response['message'] = "You don't have authorizations!";
    echo json_encode($response);
    exit;
  }

  // ===== CEK TOKEN =====
  $cekSettings = mysqli_query($con, "SELECT * FROM settings WHERE token = '$token'");
  $do = mysqli_fetch_array($cekSettings);
  if (!$do) {
    $response['value']   = 0;
    $response['message'] = "Token Invalid!";
    echo json_encode($response);
    exit;
  }

  // ===== AMBIL DATA ORDER =====
  // sesuaikan nama kolom di tabel orders
  $sqlOrder = "SELECT o.*, u.nama_lengkap, u.email 
               FROM orders o 
               LEFT JOIN users u ON o.id_user = u.id_user
               WHERE o.id_order = '$id_order' AND o.id_user = '$id_user'";

  $qOrder = mysqli_query($con, $sqlOrder);
  $order  = mysqli_fetch_array($qOrder);

  if (!$order) {
    $response['value']   = 0;
    $response['message'] = "Order tidak ditemukan!";
    echo json_encode($response);
    exit;
  }

  // kalau sudah pernah dibuat snap_token, pakai yang lama saja
  if (!empty($order['midtrans_snap_token'])) {
    $response['value']            = 1;
    $response['message']          = "Transaksi Midtrans sudah ada.";
    $response['snap_token']       = $order['midtrans_snap_token'];
    $response['midtrans_orderid'] = $order['midtrans_order_id'];
    echo json_encode($response);
    exit;
  }

  // ===== SIAPKAN PARAMETER KE MIDTRANS =====
  // bikin order id khusus Midtrans tapi tetap relate
  $midtransOrderId = 'FP-' . $order['kode_order'];

  $transaction_details = [
    'order_id'     => $midtransOrderId,
    'gross_amount' => (int)$order['total_amount'], // total bayar
  ];

  // data pembeli – pakai fallback dari users kalau kolom khusus tidak ada
  $namaPembeli = $order['nama_pembeli']  ?? $order['nama_lengkap'] ?? 'Customer';
  $emailPembeli = $order['email_pembeli'] ?? $order['email'] ?? 'no-reply@example.com';
  $noHpPembeli = $order['no_hp_pembeli']  ?? ''; // kalau belum ada kolom, biarin kosong

  $customer_details = [
    'first_name' => $namaPembeli,
    'email'      => $emailPembeli,
    'phone'      => $noHpPembeli,
  ];

  // item detail (opsional)
  $item_details = [];
  $qItems = mysqli_query($con, "SELECT * FROM order_items WHERE id_order = '$id_order'");
  while ($it = mysqli_fetch_array($qItems)) {

    $idItem   = isset($it['id_product']) ? $it['id_product'] : ($it['id_item'] ?? 0);
    $namaProd = $it['nama_produk'] ?? ('Produk ' . $idItem);
    $harga    = isset($it['harga']) ? (int)$it['harga'] : (isset($it['price']) ? (int)$it['price'] : 0);
    $qty      = isset($it['qty']) ? (int)$it['qty'] : 1;

    $item_details[] = [
      'id'       => $idItem,
      'price'    => $harga,
      'quantity' => $qty,
      'name'     => $namaProd,
    ];
  }

  $payload = [
    'transaction_details' => $transaction_details,
    'customer_details'    => $customer_details,
  ];

  if (!empty($item_details)) {
    $payload['item_details'] = $item_details;
  }

  try {
    // ===== CALL MIDTRANS SNAP =====
    $snapToken = Snap::getSnapToken($payload);

    // simpan ke database
    mysqli_query(
      $con,
      "UPDATE orders 
       SET midtrans_order_id   = '$midtransOrderId',
           midtrans_snap_token = '$snapToken',
           midtrans_status     = 'PENDING'
       WHERE id_order = '$id_order'"
    );

    $response['value']            = 1;
    $response['message']          = "Berhasil membuat transaksi Midtrans.";
    $response['snap_token']       = $snapToken;
    $response['midtrans_orderid'] = $midtransOrderId;
    echo json_encode($response);
  } catch (Exception $e) {
    $response['value']       = 0;
    $response['message']     = "Gagal membuat transaksi Midtrans.";
    $response['error_debug'] = $e->getMessage(); // boleh dihapus nanti
    echo json_encode($response);
  }
}
