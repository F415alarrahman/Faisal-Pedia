<?php
require_once "../config/connect.php";

date_default_timezone_set('Asia/Jakarta');

$headers   = getallheaders();
$xusername = $headers['x-username'] ?? '';
$xpassword = $headers['x-password'] ?? '';

if ($_SERVER['REQUEST_METHOD'] == 'POST') {

  $token  = $_POST['token'] ?? '';
  $idUser = (int)($_POST['id_user'] ?? 0);

  $response = [];

  if ($token == '' || $idUser == 0 || !isset($_FILES['foto'])) {
    $response["value"] = 0;
    $response["message"] = "Data tidak lengkap!";
    echo json_encode($response);
    exit;
  }

  // cek security
  $cekSecurity = mysqli_query(
    $con,
    "SELECT * FROM settings WHERE xusername='$xusername' AND xpassword=md5('$xpassword')"
  );
  if (mysqli_num_rows($cekSecurity) == 0) {
    $response["value"] = 0;
    $response["message"] = "You don't have authorizations!";
    echo json_encode($response);
    exit;
  }

  // cek token
  $cekSettings = mysqli_query(
    $con,
    "SELECT * FROM settings WHERE token='$token'"
  );
  if (!mysqli_fetch_array($cekSettings)) {
    $response["value"] = 0;
    $response["message"] = "Token invalid!";
    echo json_encode($response);
    exit;
  }

  // cek user
  $cekUser = mysqli_query(
    $con,
    "SELECT * FROM users WHERE id_user=$idUser"
  );
  if (mysqli_num_rows($cekUser) == 0) {
    $response["value"] = 0;
    $response["message"] = "User tidak ditemukan!";
    echo json_encode($response);
    exit;
  }

  $file = $_FILES['foto'];

  if ($file['error'] !== UPLOAD_ERR_OK) {
    $response["value"] = 0;
    $response["message"] = "Upload gagal!";
    echo json_encode($response);
    exit;
  }

  $ext = strtolower(pathinfo($file['name'], PATHINFO_EXTENSION));
  $allowed = ['jpg', 'jpeg', 'png', 'webp'];

  if (!in_array($ext, $allowed)) {
    $response["value"] = 0;
    $response["message"] = "Format file tidak didukung!";
    echo json_encode($response);
    exit;
  }

  $folderUpload = '../upload/profile/';
  if (!is_dir($folderUpload)) {
    mkdir($folderUpload, 0775, true);
  }

  $namaBaru = 'user_' . $idUser . '_' . time() . '.' . $ext;
  $pathFile = $folderUpload . $namaBaru;

  if (!move_uploaded_file($file['tmp_name'], $pathFile)) {
    $response["value"] = 0;
    $response["message"] = "Gagal menyimpan file!";
    echo json_encode($response);
    exit;
  }

  // path yang disimpan di DB (versi URL)
  $urlFoto = 'https://apifaisalarrp.online/upload/profile/' . $namaBaru; // sesuaikan domain

  mysqli_query(
    $con,
    "UPDATE users SET foto='$urlFoto' WHERE id_user=$idUser"
  );

  $response["value"] = 1;
  $response["message"] = "Foto profil berhasil diupdate.";
  $response["foto"] = $urlFoto;
  echo json_encode($response);
}
