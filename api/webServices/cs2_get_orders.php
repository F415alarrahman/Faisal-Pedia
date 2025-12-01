<?php
require_once "../config/connect.php";

date_default_timezone_set('Asia/Jakarta');
$tglSekarang = date('Y-m-d H:i:s');

$headers   = getallheaders();
$xusername = isset($headers['x-username']) ? $headers['x-username'] : '';
$xpassword = isset($headers['x-password']) ? $headers['x-password'] : '';

header('Content-Type: application/json; charset=utf-8');

ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

if ($_SERVER['REQUEST_METHOD'] !== "POST") {
  echo json_encode([
    "value"   => 0,
    "message" => "Method not allowed!",
  ]);
  exit;
}

$token  = $_POST['token']  ?? '';
$status = trim($_POST['status'] ?? ''); // boleh kosong / ALL / status spesifik

if ($token === '') {
  echo json_encode([
    "value"   => 0,
    "message" => "Token tidak boleh kosong!",
  ]);
  exit;
}

// cek security header
$cekSecurity = mysqli_query(
  $con,
  "SELECT * FROM settings 
   WHERE xusername='$xusername' 
     AND xpassword=MD5('$xpassword')"
);

if (mysqli_num_rows($cekSecurity) === 0) {
  echo json_encode([
    "value"   => 0,
    "message" => "You don't have authorization!",
  ]);
  exit;
}

// cek token
$cekSettings = mysqli_query($con, "SELECT * FROM settings WHERE token = '$token'");
$do = mysqli_fetch_array($cekSettings);

if (!$do) {
  echo json_encode([
    "value"   => 0,
    "message" => "Token Invalid!",
  ]);
  exit;
}

// ====== STATUS FILTER UNTUK FLOW CS2 ======
$flowStatuses = "('MENUNGGU_DIPROSES_CS2','SEDANG_DIPROSES','DIKIRIM','SELESAI')";

if ($status === '' || strtoupper($status) === 'ALL') {
  // kalau kosong / ALL -> ambil semua status flow CS2
  $whereStatus = "status IN $flowStatuses";
} else {
  $statusEsc   = mysqli_real_escape_string($con, $status);
  $whereStatus = "status = '$statusEsc'";
}

$response         = [];
$response['data'] = [];

// AMBIL ORDER
$sqlOrders = "
  SELECT 
    id_order,
    kode_order,
    id_user,
    buyer_name,
    buyer_phone,
    buyer_address,
    status,
    total_amount,
    item_count,
    created_at,
    updated_at,
    midtrans_order_id,
    midtrans_snap_token,
    payment_proof,
    midtrans_status
  FROM orders
  WHERE $whereStatus
  ORDER BY created_at ASC
";

$cekOrders = mysqli_query($con, $sqlOrders);

while ($row = mysqli_fetch_assoc($cekOrders)) {
  $idOrder = (int)$row['id_order'];

  // AMBIL ITEM PER ORDER (+ THUMBNAIL)
  $items = [];
  $sqlItems = "
    SELECT 
      oi.id_item,
      oi.id_product,
      oi.nama_product,
      oi.harga,
      oi.qty,
      oi.subtotal,
      p.thumbnail
    FROM order_items oi
    LEFT JOIN products p ON oi.id_product = p.id_product
    WHERE oi.id_order = '$idOrder'
  ";
  $cekItems = mysqli_query($con, $sqlItems);
  while ($it = mysqli_fetch_assoc($cekItems)) {
    $items[] = [
      "id_item"      => (int)$it['id_item'],
      "id_product"   => (int)$it['id_product'],
      "nama_product" => $it['nama_product'],
      "harga"        => (int)$it['harga'],
      "qty"          => (int)$it['qty'],
      "subtotal"     => (int)$it['subtotal'],
      "thumbnail"    => $it['thumbnail'] ?? "",
    ];
  }

  $response['data'][] = [
    "id_order"            => $idOrder,
    "kode_order"          => $row['kode_order'],
    "buyer_name"          => $row['buyer_name'],
    "buyer_phone"         => $row['buyer_phone'],
    "buyer_address"       => $row['buyer_address'],
    "status"              => $row['status'],
    "total_amount"        => (int)$row['total_amount'],
    "item_count"          => (int)$row['item_count'],
    "created_at"          => $row['created_at'],
    "updated_at"          => $row['updated_at'],
    "midtrans_order_id"   => $row['midtrans_order_id'],
    "midtrans_snap_token" => $row['midtrans_snap_token'],
    "payment_proof"       => $row['payment_proof'],
    "items"               => $items,
  ];
}

$response["value"]   = 1;
$response["message"] = "Berhasil!";
echo json_encode($response);
exit;
