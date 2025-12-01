<?php
require_once "../config/connect.php";

date_default_timezone_set('Asia/Jakarta');
$tglSekarang = date('Y-m-d H:i:s');
$tgl         = date('Y-m-d');

$headers   = getallheaders();
$xusername = isset($headers['x-username']) ? $headers['x-username'] : '';
$xpassword = isset($headers['x-password']) ? $headers['x-password'] : '';

ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

if ($_SERVER['REQUEST_METHOD'] == "POST") {

  $response = array();

  $token     = $_POST['token']     ?? '';
  $idProduct = (int)($_POST['id_product'] ?? 0);

  if ($token == '' || $idProduct <= 0) {
    $response["value"]   = 0;
    $response["message"] = "Data tidak lengkap!";
    echo json_encode($response);
    exit;
  }

  // cek header security
  $cekSecurity = mysqli_query(
    $con,
    "SELECT * FROM settings 
     WHERE xusername='$xusername' 
       AND xpassword=MD5('$xpassword')"
  );

  if (mysqli_num_rows($cekSecurity) == 0) {
    $response["value"]   = 0;
    $response["message"] = "You don't have authorization!";
    echo json_encode($response);
    exit;
  }

  // cek token
  $cekSettings = mysqli_query($con, "SELECT * FROM settings WHERE token = '$token'");
  $do = mysqli_fetch_array($cekSettings);
  if (!isset($do)) {
    $response["value"]   = 0;
    $response["message"] = "Token Invalid!";
    echo json_encode($response);
    exit;
  }

  // cek product exist
  $cekProduk = mysqli_query($con, "SELECT * FROM products WHERE id_product=$idProduct");
  if (mysqli_num_rows($cekProduk) == 0) {
    $response["value"]   = 0;
    $response["message"] = "Produk tidak ditemukan!";
    echo json_encode($response);
    exit;
  }

  // cek file images[]
  if (!isset($_FILES['images'])) {
    $response["value"]   = 0;
    $response["message"] = "File gambar tidak ditemukan!";
    echo json_encode($response);
    exit;
  }

  $files = $_FILES['images'];

  // pastikan multiple (bisa 1 atau lebih)
  $jumlahFile = is_array($files['name']) ? count($files['name']) : 0;
  if ($jumlahFile == 0) {
    $response["value"]   = 0;
    $response["message"] = "Tidak ada file yang diupload!";
    echo json_encode($response);
    exit;
  }

  // folder upload (di server)
  $folderUpload = __DIR__ . '/../upload/produk/';
  if (!is_dir($folderUpload)) {
    mkdir($folderUpload, 0775, true);
  }

  $allowedExt = ['jpg', 'jpeg', 'png', 'webp'];
  $savedFiles = [];

  for ($i = 0; $i < $jumlahFile; $i++) {
    if ($files['error'][$i] !== UPLOAD_ERR_OK) {
      continue; // skip kalau error
    }

    $namaAsli = $files['name'][$i];
    $tmpPath  = $files['tmp_name'][$i];

    $ext = strtolower(pathinfo($namaAsli, PATHINFO_EXTENSION));
    if (!in_array($ext, $allowedExt)) {
      continue; // skip format tidak didukung
    }

    $namaBaru = 'p' . $idProduct . '_' . time() . '_' . $i . '.' . $ext;
    $pathDisk = $folderUpload . $namaBaru;

    if (move_uploaded_file($tmpPath, $pathDisk)) {
      // path yg disimpan di DB → relative path
      $relativePath = 'upload/produk/' . $namaBaru;

      // insert ke product_images
      mysqli_query(
        $con,
        "INSERT INTO product_images (id_product, file_path) 
         VALUES ($idProduct, '$relativePath')"
      );

      $savedFiles[] = $relativePath;
    }
  }

  if (count($savedFiles) == 0) {
    $response["value"]   = 0;
    $response["message"] = "Tidak ada file gambar yang berhasil diupload!";
    echo json_encode($response);
    exit;
  }

  $response["value"]   = 1;
  $response["message"] = "Berhasil mengupload gambar produk.";
  $response["data"]    = $savedFiles;
  echo json_encode($response);
}
