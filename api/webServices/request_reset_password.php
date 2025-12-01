<?php
require_once "../config/connect.php";
require '../vendor/autoload.php';

use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;

date_default_timezone_set('Asia/Jakarta');

$headers   = getallheaders();
$xusername = $headers['x-username'] ?? '';
$xpassword = $headers['x-password'] ?? '';

if ($_SERVER["REQUEST_METHOD"] == "POST") {

  $token = $_POST['token'] ?? '';
  $email = trim($_POST['email'] ?? '');
  $response = [];

  // =========================
  // VALIDASI DASAR
  // =========================
  if ($token == '' || $email == '') {
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

  // =========================
  // CEK SECURITY HEADER
  // =========================
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

  // CEK TOKEN API
  $cekSettings = mysqli_query($con, "SELECT * FROM settings WHERE token = '$token'");
  if (!mysqli_fetch_array($cekSettings)) {
    $response["value"]   = 0;
    $response["message"] = "Token Invalid!";
    echo json_encode($response);
    exit;
  }

  // =========================
  // CEK USER
  // =========================
  $cekUser = mysqli_query(
    $con,
    "SELECT * FROM users WHERE email='$email' AND status_aktif=1"
  );
  if (mysqli_num_rows($cekUser) == 0) {
    $response["value"]   = 0;
    $response["message"] = "Akun dengan email tersebut tidak ditemukan.";
    echo json_encode($response);
    exit;
  }

  $user = mysqli_fetch_array($cekUser);
  $nama = $user['nama_lengkap'];

  // =========================
  // GENERATE KODE RESET
  // =========================
  $kodeReset = mt_rand(100000, 999999);
  $expiredAt = date('Y-m-d H:i:s', time() + 15 * 60); // 15 menit ke depan

  mysqli_query(
    $con,
    "UPDATE users 
         SET reset_token = '$kodeReset',
             reset_expired = '$expiredAt'
         WHERE id_user = {$user['id_user']}"
  );

  // =========================
  // KIRIM EMAIL RESET (SIMPLE HTML, TANPA TEMPLATE FILE)
  // =========================
  try {
    $mail = new PHPMailer(true);

    // === PENTING: SAMA PERSIS DENGAN YANG SUDAH JALAN DI REGISTER/LOGIN ===
    $mail->isSMTP();
    $mail->Host       = 'smtp.gmail.com';
    $mail->SMTPAuth   = true;
    $mail->Username   = 'faisalarrahmanpratama@gmail.com';
    $mail->Password   = 'fuds kbxn zjvi pnms'; // GANTI: app password 16 digit TANPA SPASI
    $mail->SMTPSecure = "ssl";
    $mail->Port       = 465;

    $mail->setFrom('faisalarrahmanpratama@gmail.com', 'FaisalPedia');
    $mail->addAddress($email, $nama);

    $mail->isHTML(true);
    $mail->Subject = "Kode Reset Password FaisalPedia";

    $body = "
        <html>
        <body style=\"font-family:'Segoe UI',Tahoma,Arial,sans-serif;\">
            <h2 style=\"color:#1d4ed8;margin-bottom:4px;\">Reset Password FaisalPedia</h2>
            <p>Halo, <b>$nama</b> 👋</p>
            <p>Berikut kode reset password kamu:</p>
            <div style=\"
                font-size:28px;
                font-weight:700;
                letter-spacing:6px;
                margin:12px 0;
                color:#111827;
            \">
                $kodeReset
            </div>
            <p style=\"font-size:13px;color:#4b5563;\">
                Kode ini berlaku sampai <b>$expiredAt</b> (WIB).<br>
                Jangan berikan kode ini kepada siapapun.
            </p>
            <hr style=\"border:none;border-top:1px solid #e5e7eb;margin:16px 0;\"/>
            <p style=\"font-size:11px;color:#9ca3af;\">
                Email ini dikirim otomatis oleh sistem <b>FaisalPedia</b>.
            </p>
        </body>
        </html>";

    $mail->Body = $body;
    $mail->AltBody = "Kode reset password kamu: $kodeReset (berlaku sampai $expiredAt)";

    $mail->send();

    $response["value"]   = 1;
    $response["message"] = "Kode reset password telah dikirim ke email kamu.";
    echo json_encode($response);
    exit;
  } catch (Exception $e) {
    // untuk debugging, sementara kirim ErrorInfo juga
    $response["value"]   = 0;
    $response["message"] = "Gagal mengirim email reset password: " . $mail->ErrorInfo;
    echo json_encode($response);
    exit;
  }
}
