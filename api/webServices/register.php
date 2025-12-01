<?php
require_once "../config/connect.php";

// PHPMailer manual (tanpa composer autoload)
require_once "../vendor/phpmailer/Exception.php";
require_once "../vendor/phpmailer/PHPMailer.php";
require_once "../vendor/phpmailer/SMTP.php";

use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;

date_default_timezone_set('Asia/Jakarta');

// DEBUG (boleh dimatikan nanti)
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

header('Content-Type: application/json; charset=utf-8');

$tglSekarang = date('Y-m-d H:i:s');

// ========================
// Ambil header security
// ========================
$headers   = getallheaders();
$xusername = $headers['x-username'] ?? '';
$xpassword = $headers['x-password'] ?? '';

$response = [];

// ========================
// Validasi method
// ========================
if ($_SERVER["REQUEST_METHOD"] !== "POST") {
  $response["value"]   = 0;
  $response["message"] = "Method not allowed!";
  echo json_encode($response);
  exit;
}

// ========================
// Ambil data POST
// ========================
$token        = $_POST['token'] ?? '';
$nama_lengkap = trim($_POST['nama_lengkap'] ?? '');
$email        = trim($_POST['email'] ?? '');
$password     = $_POST['password'] ?? '';

if ($token === '' || $nama_lengkap === '' || $email === '' || $password === '') {
  $response["value"]   = 0;
  $response["message"] = "Data tidak lengkap!";
  echo json_encode($response);
  exit;
}

if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
  $response["value"]   = 0;
  $response["message"] = "Format email tidak valid!";
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
  "SELECT * FROM settings WHERE token = '$token'"
);

if (!mysqli_fetch_array($cekSettings)) {
  $response["value"]   = 0;
  $response["message"] = "Token Invalid!";
  echo json_encode($response);
  exit;
}

// ========================
// Cek email sudah ada
// ========================
$emailEsc = mysqli_real_escape_string($con, $email);
$cekData  = mysqli_query($con, "SELECT * FROM users WHERE email='$emailEsc'");

if (mysqli_num_rows($cekData) > 0) {
  $response["value"]   = 0;
  $response["message"] = "Email sudah terdaftar!";
  echo json_encode($response);
  exit;
}

// ========================
// Insert user baru
// ========================
$namaEsc      = mysqli_real_escape_string($con, $nama_lengkap);
$passwordHash = md5($password);
$role         = "pembeli";

$insert = mysqli_query(
  $con,
  "INSERT INTO users (nama_lengkap,email,password_hash,role,status_aktif,created_at)
   VALUES ('$namaEsc','$emailEsc','$passwordHash','$role',1,'$tglSekarang')"
);

if ($insert) {
  $idBaru = mysqli_insert_id($con);

  // ambil data user lengkap untuk dikirim ke Flutter
  $qUser = mysqli_query(
    $con,
    "SELECT * FROM users WHERE id_user='$idBaru' LIMIT 1"
  );
  $u = mysqli_fetch_assoc($qUser);

  // ========================
  // Kirim email welcome (optional)
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
    $mail->addAddress($email, $nama_lengkap);

    $mail->isHTML(true);
    $mail->Subject = "Selamat datang di FaisalPedia 🎉";

    $html = @file_get_contents('../template/email_welcome.html');
    if ($html === false) {
      // fallback sederhana kalau template tidak ditemukan
      $html = "
        <h3>Selamat datang di FaisalPedia</h3>
        <p>Halo, $nama_lengkap 👋</p>
        <p>Akun kamu berhasil dibuat.</p>
        <p>Email: $email<br>Waktu daftar: $tglSekarang</p>
      ";
    } else {
      $html = str_replace('{EMAIL_TITLE}',   "Selamat datang di FaisalPedia 🎉", $html);
      $html = str_replace('{EMAIL_MESSAGE}', "Halo, $nama_lengkap 👋",          $html);
      $html = str_replace('{EMAIL_CONTENT}', "
          Akun kamu berhasil dibuat.<br><br>
          Email: $email<br>
          Waktu daftar: $tglSekarang
      ", $html);
    }

    $mail->Body = $html;
    $mail->send();
  } catch (Exception $e) {
    // Jangan echo apa-apa di sini, cukup log kalau mau
    error_log('PHPMailer register error: ' . $e->getMessage());
  }

  // ========================
  // Response ke Flutter (match login.php)
  // ========================
  $response["value"]        = 1;
  $response["message"]      = "Registrasi berhasil!";
  $response["id_user"]      = (int)$u['id_user'];
  $response["nama_lengkap"] = $u['nama_lengkap'];
  $response["email"]        = $u['email'];
  $response["role"]         = $u['role'];
  $response["foto"]         = $u['foto'] ?? "";

  echo json_encode($response);
  exit;
}

// kalau sampai sini berarti INSERT gagal
$response["value"]   = 0;
$response["message"] = "Gagal registrasi!";
echo json_encode($response);