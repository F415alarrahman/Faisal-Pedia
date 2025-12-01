<?php
require_once "../config/connect.php";

date_default_timezone_set('Asia/Jakarta');

$headers   = getallheaders();
$xusername = $headers['x-username'] ?? '';
$xpassword = $headers['x-password'] ?? '';

if ($_SERVER["REQUEST_METHOD"] == "POST") {

  $token        = $_POST['token'] ?? '';
  $email        = trim($_POST['email'] ?? '');
  $kodeReset    = trim($_POST['kode_reset'] ?? '');
  $passwordBaru = $_POST['password_baru'] ?? '';

  $response = [];

  if ($token == '' || $email == '' || $kodeReset == '' || $passwordBaru == '') {
    $response["value"]   = 0;
    $response["message"] = "Data tidak lengkap!";
    echo json_encode($response);
    exit;
  }

  // cek security header
  $cekSecurity = mysqli_query(
    $con,
    "SELECT * FROM settings WHERE xusername='$xusername' AND xpassword=md5('$xpassword')"
  );
  if (mysqli_num_rows($cekSecurity) == 0) {
    $response["value"]   = 0;
    $response["message"] = "You don't have authorizations!";
    echo json_encode($response);
    exit;
  }

  // cek token API
  $cekSettings = mysqli_query(
    $con,
    "SELECT * FROM settings WHERE token = '$token'"
  );
  if (!mysqli_fetch_array($cekSettings)) {
    $response["value"]   = 0;
    $response["message"] = "Token Invalid!";
    echo json_encode($response);
    exit;
  }

  // cek user + kode + expired
  $now = date('Y-m-d H:i:s');

  $cekUser = mysqli_query(
    $con,
    "SELECT * FROM users 
         WHERE email='$email' 
           AND reset_token='$kodeReset'
           AND reset_expired IS NOT NULL
           AND reset_expired >= '$now'
           AND status_aktif=1"
  );

  if (mysqli_num_rows($cekUser) == 0) {
    $response["value"]   = 0;
    $response["message"] = "Kode reset tidak valid atau sudah kadaluarsa.";
    echo json_encode($response);
    exit;
  }

  $user = mysqli_fetch_array($cekUser);

  // update password
  $passwordHash = md5($passwordBaru); // (ikutin sistem yg sekarang)
  $update = mysqli_query(
    $con,
    "UPDATE users
         SET password_hash='$passwordHash', reset_token=NULL, reset_expired=NULL
         WHERE id_user={$user['id_user']}"
  );

  if ($update) {
    $response["value"]   = 1;
    $response["message"] = "Password berhasil direset. Silakan login dengan password baru.";
    echo json_encode($response);
    exit;
  } else {
    $response["value"]   = 0;
    $response["message"] = "Gagal reset password, coba beberapa saat lagi.";
    echo json_encode($response);
    exit;
  }
}
