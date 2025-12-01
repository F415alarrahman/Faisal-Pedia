<?php
require_once "../config/connect.php";

date_default_timezone_set('Asia/Jakarta');
$tglSekarang = date('Y-m-d H:i:s');

$headers   = getallheaders();
$xusername = $headers['x-username'] ?? '';
$xpassword = $headers['x-password'] ?? '';

ini_set('display_errors', 1);
error_reporting(E_ALL);

if ($_SERVER['REQUEST_METHOD'] == "POST") {

  $response = [];

  $token  = $_POST['token']  ?? '';
  $status = $_POST['status'] ?? 'MENUNGGU_VERIFIKASI_CS1';

  if ($token == '') {
    $response["value"]   = 0;
    $response["message"] = "Token tidak boleh kosong!";
    echo json_encode($response);
    exit;
  }

  // cek security header
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

  // escape status
  $statusEsc = mysqli_real_escape_string($con, $status);

  // query data order
  $sql = "
      SELECT
          id_order,
          kode_order,
          buyer_name,
          total_amount,
          status,
          item_count,
          created_at,
          updated_at
      FROM orders
      WHERE status = '$statusEsc'
      ORDER BY created_at ASC
  ";

  $res = mysqli_query($con, $sql);

  // nama file CSV (pakai timestamp biar ga ketimpa)
  $fileName = "EXPORT_ORDERS_CS1_" . date("Ymd_His") . ".csv";
  $filePath = __DIR__ . "/" . $fileName;   // file disimpan di folder yang sama dengan script

  // buka file untuk tulis CSV
  $output = fopen($filePath, "w");
  if (!$output) {
    $response["value"]   = 0;
    $response["message"] = "Gagal membuat file CSV!";
    echo json_encode($response);
    exit;
  }

  // header kolom
  fputcsv($output, [
    'orderId',
    'kode_order',
    'buyer_name',
    'total_amount',
    'status',
    'item_count',
    'created_at',
    'updated_at'
  ]);

  // isi data
  while ($row = mysqli_fetch_assoc($res)) {
    fputcsv($output, [
      $row['id_order'],
      $row['kode_order'],
      $row['buyer_name'],
      $row['total_amount'],
      $row['status'],
      $row['item_count'],
      $row['created_at'],
      $row['updated_at']
    ]);
  }

  fclose($output);

  // response JSON (model sama kayak INFO_HIPOTENSI)
  $response["value"] = 1;
  $response["url"]   = "https://faisalarrp.online/api/webServices/" . $fileName;

  echo json_encode($response);
}
