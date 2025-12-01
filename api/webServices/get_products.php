<?php
// ====== CORS & JSON HEADER ======
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, X-Requested-With, Authorization, x-username, x-password");
header("Content-Type: application/json; charset=utf-8");

// Handle preflight (OPTIONS)
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
  http_response_code(200);
  exit;
}

// ====== FILE LAMA MULAI DI SINI ======
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

  $token  = $_POST['token']  ?? '';
  $search = $_POST['search'] ?? '';

  if ($token == '') {
    $response["value"]   = 0;
    $response["message"] = "Token tidak boleh kosong!";
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

  if (mysqli_num_rows($cekSecurity) > 0) {

    // cek token
    $cekSettings = mysqli_query($con, "SELECT * FROM settings WHERE token = '$token'");
    $do = mysqli_fetch_array($cekSettings);

    if (isset($do)) {

      $response['data'] = array();

      // filter search kalau ada
      $where = "";
      if ($search != '') {
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

        // ambil gambar tambahan dari product_images
        $gambarTambahan = [];
        $qImg = mysqli_query(
          $con,
          "SELECT file_path FROM product_images WHERE id_product=$idProduct ORDER BY id_image ASC"
        );
        while ($img = mysqli_fetch_assoc($qImg)) {
          $gambarTambahan[] = $img['file_path'];
        }

        $response['data'][] = array(
          "id_product"      => $idProduct,
          "nama"            => $row['nama'],
          "deskripsi"       => $row['deskripsi'],
          "harga"           => (int)$row['harga'],
          "stok"            => (int)$row['stok'],
          "thumbnail"       => $row['thumbnail'],
          "gambar_tambahan" => $gambarTambahan
        );
      }

      $response["value"]   = 1;
      $response["message"] = "Berhasil!";
      echo json_encode($response);
    } else {
      $response["value"]   = 0;
      $response["message"] = "Token Invalid!";
      echo json_encode($response);
    }
  } else {
    $response["value"]   = 0;
    $response["message"] = "You don't have authorization!";
    echo json_encode($response);
  }
}