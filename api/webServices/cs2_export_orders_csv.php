<?php
require_once "../config/connect.php";

date_default_timezone_set('Asia/Jakarta');

$headers   = getallheaders();
$xusername = $headers['x-username'] ?? '';
$xpassword = $headers['x-password'] ?? '';

header('Content-Type: application/json; charset=utf-8');

ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

$response = [];

if ($_SERVER['REQUEST_METHOD'] !== "POST") {
  $response["value"]   = 0;
  $response["message"] = "Method not allowed!";
  echo json_encode($response);
  exit;
}

$token  = $_POST['token']  ?? '';
$status = $_POST['status'] ?? 'ALL';

if ($token === '') {
  $response["value"]   = 0;
  $response["message"] = "Token tidak boleh kosong!";
  echo json_encode($response);
  exit;
}

// cek security
$cekSecurity = mysqli_query(
  $con,
  "SELECT * FROM settings 
   WHERE xusername='$xusername' 
     AND xpassword=MD5('$xpassword')"
);

if (mysqli_num_rows($cekSecurity) == 0) {
  $response["value"]   = 0;
  $response["message"] = "Unauthorized!";
  echo json_encode($response);
  exit;
}

// cek token
$cekToken = mysqli_query($con, "SELECT * FROM settings WHERE token='$token'");
if (mysqli_num_rows($cekToken) == 0) {
  $response["value"]   = 0;
  $response["message"] = "Token Invalid!";
  echo json_encode($response);
  exit;
}

// status flow CS2
$flowStatuses = "('MENUNGGU_DIPROSES_CS2','SEDANG_DIPROSES','DIKIRIM','SELESAI')";

if ($status === '' || strtoupper($status) === 'ALL') {
  $whereStatus = "status IN $flowStatuses";
  $statusKey   = "ALL";
} else {
  $statusEsc   = mysqli_real_escape_string($con, $status);
  $whereStatus = "status = '$statusEsc'";
  $statusKey   = $statusEsc;
}

// ambil data orders
$sql = "
  SELECT 
    id_order,
    created_at,
    buyer_name,
    total_amount,
    status,
    item_count,
    updated_at
  FROM orders
  WHERE $whereStatus
  ORDER BY created_at ASC
";

$res = mysqli_query($con, $sql);

// nama file & path di server (disimpan di folder yang sama dengan script)
$filename  = "EXPORT_ORDERS_CS2_{$statusKey}_" . date("Ymd_His") . ".csv";
$filePath  = $filename; // ../api/webServices/EXPORT_...

// buka file untuk ditulis
$fp = fopen($filePath, 'w');

if ($fp === false) {
  $response["value"]   = 0;
  $response["message"] = "Gagal membuat file CSV di server!";
  echo json_encode($response);
  exit;
}

// tulis header kolom
fputcsv($fp, [
  "orderId",
  "createdAt",
  "buyerName",
  "totalAmount",
  "status",
  "itemCount",
  "lastUpdatedAt"
]);

// tulis data baris
while ($row = mysqli_fetch_assoc($res)) {
  fputcsv($fp, [
    $row['id_order'],
    $row['created_at'],
    $row['buyer_name'],
    $row['total_amount'],
    $row['status'],
    $row['item_count'],
    $row['updated_at'],
  ]);
}

fclose($fp);

// URL publik untuk di-download dari Flutter
$publicUrl = "https://faisalarrp.online/api/webServices/" . $filename;

$response["value"]   = 1;
$response["url"]     = $publicUrl;
$response["message"] = "Export data CS2 berhasil.";

echo json_encode($response);
exit;
