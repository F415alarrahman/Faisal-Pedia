<?php
require_once "../config/connect.php";

date_default_timezone_set('Asia/Jakarta');
$tglSekarang = date('Y-m-d H:i:s');

$headers   = getallheaders();
$xusername = isset($headers['x-username']) ? $headers['x-username'] : '';
$xpassword = isset($headers['x-password']) ? $headers['x-password'] : '';

ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

header('Content-Type: application/json; charset=utf-8');

$response = array();

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
  $response['value']   = 0;
  $response['message'] = 'Method not allowed!';
  echo json_encode($response);
  exit;
}

// ====== AMBIL PARAMETER ======
$token   = isset($_POST['token'])   ? $_POST['token']   : '';
$id_user = isset($_POST['id_user']) ? $_POST['id_user'] : '';
$status  = isset($_POST['status'])  ? trim($_POST['status']) : ''; // optional

if ($token === '' || $id_user === '') {
  $response['value']   = 0;
  $response['message'] = 'Token dan id_user tidak boleh kosong!';
  echo json_encode($response);
  exit;
}

// ====== CEK SECURITY HEADER ======
$cekSecurity = mysqli_query(
  $con,
  "SELECT * FROM settings 
   WHERE xusername='$xusername' 
     AND xpassword=MD5('$xpassword')"
);

if (mysqli_num_rows($cekSecurity) == 0) {
  $response['value']   = 0;
  $response['message'] = "You don't have authorization!";
  echo json_encode($response);
  exit;
}

// ====== CEK TOKEN ======
$cekSettings = mysqli_query(
  $con,
  "SELECT * FROM settings WHERE token='$token'"
);
if (!mysqli_fetch_array($cekSettings)) {
  $response['value']   = 0;
  $response['message'] = 'Token invalid!';
  echo json_encode($response);
  exit;
}

// ====== AMBIL DATA ORDER USER ======
$id_user_int = (int)$id_user;

$whereStatus = '';
if ($status !== '') {
  $statusEsc   = mysqli_real_escape_string($con, $status);
  $whereStatus = " AND o.status = '$statusEsc' ";
}

$sqlOrder = "
  SELECT 
    o.id_order,
    o.kode_order,
    o.buyer_name,
    o.buyer_phone,
    o.buyer_address,
    o.status,
    o.total_amount,
    o.item_count,
    o.created_at
  FROM orders o
  WHERE o.id_user = $id_user_int
  $whereStatus
  ORDER BY o.id_order DESC
";

$cekOrder = mysqli_query($con, $sqlOrder);

$response['data'] = array();

while ($row = mysqli_fetch_assoc($cekOrder)) {

  $idOrder = (int)$row['id_order'];

  // AMBIL ITEM PER ORDER
  $items = array();
  $sqlItem = "
    SELECT 
      oi.id_item,
      oi.id_product,
      oi.nama_product,
      oi.harga,
      oi.qty,
      oi.subtotal,
      p.thumbnail
    FROM order_items oi
    LEFT JOIN products p 
      ON oi.id_product = p.id_product
    WHERE oi.id_order = $idOrder
  ";
  $cekItem = mysqli_query($con, $sqlItem);
  while ($it = mysqli_fetch_assoc($cekItem)) {
    $items[] = array(
      'id_item'      => (int)$it['id_item'],
      'id_product'   => (int)$it['id_product'],
      'nama_product' => $it['nama_product'],
      'harga'        => (int)$it['harga'],
      'qty'          => (int)$it['qty'],
      'subtotal'     => (int)$it['subtotal'],
      'thumbnail'    => $it['thumbnail'], // relative path, contoh: upload/produk_a.png
    );
  }

  $response['data'][] = array(
    'id_order'     => $idOrder,
    'kode_order'   => $row['kode_order'],
    'buyer_name'   => $row['buyer_name'],
    'buyer_phone'  => $row['buyer_phone'],
    'buyer_address'=> $row['buyer_address'],
    'status'       => $row['status'],
    'total_amount' => (int)$row['total_amount'],
    'item_count'   => (int)$row['item_count'],
    'created_at'   => $row['created_at'],
    'items'        => $items,
  );
}

$response['value']   = 1;
$response['message'] = 'Berhasil!';
echo json_encode($response);