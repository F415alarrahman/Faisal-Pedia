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

  $token    = $_POST['token'] ?? '';
  $id_order = $_POST['id_order'] ?? '';

  if ($token == '' || $id_order == '') {
    $response["value"]   = 0;
    $response["message"] = "Token dan id_order wajib!";
    echo json_encode($response);
    exit;
  }

  if (!isset($_FILES['bukti'])) {
    $response["value"]   = 0;
    $response["message"] = "File bukti tidak ada!";
    echo json_encode($response);
    exit;
  }

  // VALIDATE SECURITY
  $cekSecurity = mysqli_query(
    $con,
    "SELECT * FROM settings WHERE xusername='$xusername' AND xpassword=MD5('$xpassword')"
  );

  if (mysqli_num_rows($cekSecurity) == 0) {
    $response["value"]   = 0;
    $response["message"] = "Unauthorized!";
    echo json_encode($response);
    exit;
  }

  // VALIDATE TOKEN
  $cekSettings = mysqli_query($con, "SELECT * FROM settings WHERE token='$token'");
  if (!mysqli_num_rows($cekSettings)) {
    $response["value"]   = 0;
    $response["message"] = "Token invalid!";
    echo json_encode($response);
    exit;
  }

  // file upload section
  $fileName = time() . "_" . basename($_FILES["bukti"]["name"]);
  $targetDir = "../uploads/bukti/";
  $targetFile = $targetDir . $fileName;

  if (!is_dir($targetDir)) {
    mkdir($targetDir, 0777, true);
  }

  if (!move_uploaded_file($_FILES["bukti"]["tmp_name"], $targetFile)) {
    $response["value"]   = 0;
    $response["message"] = "Upload bukti gagal!";
    echo json_encode($response);
    exit;
  }

  // UPDATE DATABASE
  mysqli_query(
    $con,
    "UPDATE orders SET 
      payment_proof='$fileName',
      status='MENUNGGU_VERIFIKASI_CS1',
      updated_at='$tglSekarang'
     WHERE id_order='$id_order'"
  );

  $response["value"]   = 1;
  $response["message"] = "Bukti pembayaran berhasil diupload!";
  $response["file"]    = $fileName;

  echo json_encode($response);
}
