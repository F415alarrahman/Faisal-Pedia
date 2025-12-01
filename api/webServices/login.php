<?php
require_once "../config/connect.php";

// PHPMailer manual (tanpa composer autoload)
require_once "../vendor/phpmailer/Exception.php";
require_once "../vendor/phpmailer/PHPMailer.php";
require_once "../vendor/phpmailer/SMTP.php";

use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;

date_default_timezone_set('Asia/Jakarta');

// DEBUG (boleh dimatikan kalau sudah stable)
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

header('Content-Type: application/json; charset=utf-8');

// ========================
// Helper IP & Location
// ========================
function getUserIP()
{
  if (!empty($_SERVER['HTTP_CLIENT_IP'])) return $_SERVER['HTTP_CLIENT_IP'];
  if (!empty($_SERVER['HTTP_X_FORWARDED_FOR'])) return explode(',', $_SERVER['HTTP_X_FORWARDED_FOR'])[0];
  return $_SERVER['REMOTE_ADDR'] ?? '-';
}

function getLocationFromIP($ip)
{
  $json = @file_get_contents("http://ip-api.com/json/$ip");
  $data = json_decode($json, true);
  if ($data && isset($data['status']) && $data['status'] === 'success') {
    return "{$data['city']}, {$data['regionName']}, {$data['country']}";
  }
  return "Lokasi tidak diketahui";
}

$ipAddress  = getUserIP();
$lokasi     = getLocationFromIP($ipAddress);
$device     = $_SERVER['HTTP_USER_AGENT'] ?? '-';
$waktuLogin = date('d M Y, H:i:s');

// ========================
// Ambil header security
// ========================
$headers   = getallheaders();
$xusername = $headers['x-username'] ?? '';
$xpassword = $headers['x-password'] ?? '';

$response = array();

if ($_SERVER["REQUEST_METHOD"] != "POST") {
  $response["value"]   = 0;
  $response["message"] = "Method not allowed!";
  echo json_encode($response);
  exit;
}

// ========================
// Ambil data POST
// ========================
$token    = $_POST['token']    ?? '';
$email    = trim($_POST['email'] ?? '');
$password = $_POST['password'] ?? '';

if ($token === '' || $email === '' || $password === '') {
  $response["value"]   = 0;
  $response["message"] = "Data tidak lengkap!";
  echo json_encode($response);
  exit;
}

// ========================
// Cek security header
// ========================
$cekSecurity = mysqli_query(
  $con,
  "SELECT * FROM settings 
   WHERE xusername='$xusername' 
     AND xpassword=MD5('$xpassword')"
);

if (mysqli_num_rows($cekSecurity) == 0) {
  $response["value"]   = 0;
  $response["message"] = "You don't have authorizations!";
  echo json_encode($response);
  exit;
}

// ========================
// Cek token
// ========================
$cekSettings = mysqli_query(
  $con,
  "SELECT * FROM settings WHERE token='$token'"
);
if (!mysqli_fetch_array($cekSettings)) {
  $response["value"]   = 0;
  $response["message"] = "Token invalid!";
  echo json_encode($response);
  exit;
}

// ========================
// Cek user & password
// ========================
$emailEsc    = mysqli_real_escape_string($con, $email);
$passwordMd5 = md5($password);

// cek user aktif
$cekUser = mysqli_query(
  $con,
  "SELECT * FROM users 
   WHERE email='$emailEsc' 
     AND status_aktif=1"
);

if (mysqli_num_rows($cekUser) == 0) {
  $response["value"]   = 0;
  $response["message"] = "Akun tidak ditemukan!";
  echo json_encode($response);
  exit;
}

// cek kombinasi email + password
$cekLogin = mysqli_query(
  $con,
  "SELECT * FROM users 
   WHERE email='$emailEsc' 
     AND password_hash='$passwordMd5' 
     AND status_aktif=1
   LIMIT 1"
);

if (mysqli_num_rows($cekLogin) == 0) {
  $response["value"]   = 0;
  $response["message"] = "Password salah!";
  echo json_encode($response);
  exit;
}

$data = mysqli_fetch_array($cekLogin);

// ========================
// Sukses login -> response
// ========================
$response["value"]        = 1;
$response["message"]      = "Login berhasil!";
$response["id_user"]      = (int)$data['id_user'];
$response["nama_lengkap"] = $data['nama_lengkap'];
$response["email"]        = $data['email'];
$response["role"]         = $data['role'];
$response["foto"]         = $data['foto']   ?? "";

// 🔥 tambahan baru
$response["no_hp"]        = $data['no_hp']  ?? "";
$response["alamat"]       = $data['alamat'] ?? "";

// ========================
// Kirim email notif login
// (kalau gagal, jangan ganggu JSON)
// ========================
try {
  $mail = new PHPMailer(true);

  $mail->isSMTP();
  $mail->Host       = 'smtp.gmail.com';
  $mail->SMTPAuth   = true;
  $mail->Username   = 'faisalarrahmanpratama@gmail.com';
  $mail->Password   = 'fuds kbxn zjvi pnms';
  $mail->SMTPSecure = "ssl";
  $mail->Port       = 465;

  $mail->setFrom('faisalarrahmanpratama@gmail.com', 'FaisalPedia');
  $mail->addAddress($data['email'], $data['nama_lengkap']);

  $mail->isHTML(true);
  $mail->Subject = "Login Terdeteksi di FaisalPedia";

  // load template
  $html = file_get_contents('../template/email_welcome.html');
  if ($html !== false) {
    $html = str_replace('{EMAIL_TITLE}',   "Login Terdeteksi", $html);
    $html = str_replace('{EMAIL_MESSAGE}', "Halo, {$data['nama_lengkap']} 👋", $html);
    $html = str_replace('{EMAIL_CONTENT}', "
        Kamu baru saja login ke FaisalPedia.<br><br>
        Waktu: $waktuLogin<br>
        IP: $ipAddress<br>
        Lokasi: $lokasi<br>
        Device: $device
    ", $html);

    $mail->Body = $html;
  } else {
    // fallback tanpa template
    $mail->Body = "
      <h3>Login Terdeteksi</h3>
      Halo, {$data['nama_lengkap']} 👋<br><br>
      Kamu baru saja login ke FaisalPedia.<br><br>
      Waktu: $waktuLogin<br>
      IP: $ipAddress<br>
      Lokasi: $lokasi<br>
      Device: $device
    ";
  }

  $mail->send();
} catch (Exception $e) {
  // jangan echo error, cukup log saja biar JSON tetap bersih
  error_log('PHPMailer login error: ' . $e->getMessage());
}

// terakhir: kirim JSON ke Flutter
echo json_encode($response);
exit;