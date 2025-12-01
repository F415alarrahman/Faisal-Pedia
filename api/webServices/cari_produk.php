<?php
// ====== CORS & JSON HEADER (opsional tapi enak buat Flutter/Web) ======
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, X-Requested-With, Authorization, x-username, x-password");
header("Content-Type: application/json; charset=utf-8");

// Handle preflight (OPTIONS)
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
  http_response_code(200);
  exit;
}

// ====== KONEKSI DB ======
require_once "../config/connect.php";

date_default_timezone_set('Asia/Jakarta');
$tglSekarang = date('Y-m-d H:i:s');

$headers   = getallheaders();
$xusername = isset($headers['x-username']) ? $headers['x-username'] : '';
$xpassword = isset($headers['x-password']) ? $headers['x-password'] : '';

// DEBUG OFF DI SERVER PRODUKSI
ini_set('display_errors', 0);
ini_set('display_startup_errors', 0);
error_reporting(E_ALL);

$response = [];

// ====== CEK METHOD ======
if ($_SERVER['REQUEST_METHOD'] !== "POST") {
  $response["value"]   = 0;
  $response["message"] = "Method not allowed!";
  echo json_encode($response);
  exit;
}

// ====== AMBIL PARAM ======
$token  = $_POST['token']  ?? '';
$search = $_POST['search'] ?? '';   // ⬅️ keyword pencarian

if ($token === '') {
  $response["value"]   = 0;
  $response["message"] = "Token tidak boleh kosong!";
  echo json_encode($response);
  exit;
}

// ====== CEK SECURITY HEADER (x-username / x-password) ======
$cekSecurity = mysqli_query(
  $con,
  "SELECT * FROM settings 
   WHERE xusername='$xusername' 
     AND xpassword=MD5('$xpassword')"
);

if (mysqli_num_rows($cekSecurity) === 0) {
  $response["value"]   = 0;
  $response["message"] = "You don't have authorization!";
  echo json_encode($response);
  exit;
}

// ====== CEK TOKEN ======
$cekSettings = mysqli_query($con, "SELECT * FROM settings WHERE token = '$token'");
$do = mysqli_fetch_array($cekSettings);

if (!$do) {
  $response["value"]   = 0;
  $response["message"] = "Token Invalid!";
  echo json_encode($response);
  exit;
}

// ====== LOGIKA SEARCH PRODUK ======
$response['data'] = [];

$where = "";
if ($search !== '') {
  $searchEsc = mysqli_real_escape_string($con, $search);
  $where = "WHERE nama LIKE '%$searchEsc%'";
}

// ambil produk utama
$sqlProduk = "
  SELECT 
    id_product,
    nama,
    deskripsi,
    harga,
    stok,
    thumbnail
  FROM products
  $where
  ORDER BY nama ASC
";

$cekProduk = mysqli_query($con, $sqlProduk);

while ($row = mysqli_fetch_assoc($cekProduk)) {
  $idProduct = (int)$row['id_product'];

  // ambil gambar tambahan dari product_images (kalau tabelnya ada)
  $gambarTambahan = [];
  $qImg = mysqli_query(
    $con,
    "SELECT file_path 
     FROM product_images 
     WHERE id_product = $idProduct 
     ORDER BY id_image ASC"
  );
  while ($img = mysqli_fetch_assoc($qImg)) {
    $gambarTambahan[] = $img['file_path'];
  }

  $response['data'][] = [
    "id_product"      => $idProduct,
    "nama"            => $row['nama'],
    "deskripsi"       => $row['deskripsi'],
    "harga"           => (int)$row['harga'],
    "stok"            => (int)$row['stok'],
    "thumbnail"       => $row['thumbnail'],
    "gambar_tambahan" => $gambarTambahan,
  ];
}

$response["value"]   = 1;
$response["message"] = "Berhasil!";
echo json_encode($response);
exit;
