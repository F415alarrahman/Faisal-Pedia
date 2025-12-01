<?php
require_once "../config/connect.php";

date_default_timezone_set('Asia/Jakarta');
$tglSekarang = date('Y-m-d H:i:s');
$tgl         = date('Y-m-d');
$headers     = getallheaders();
$xusername   = isset($headers['x-username']) ? $headers['x-username'] : '';
$xpassword   = isset($headers['x-password']) ? $headers['x-password'] : '';

ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

if ($_SERVER['REQUEST_METHOD'] == "POST") {

  $response = array();

  $token   = isset($_POST['token']) ? $_POST['token'] : '';
  $id_user = isset($_POST['id_user']) ? (int)$_POST['id_user'] : 0;

  if ($token == '' || $id_user <= 0) {
    $response["value"]   = 0;
    $response["message"] = "Data tidak lengkap!";
    echo json_encode($response);
    exit;
  }

  $cekSecurity = mysqli_query($con, "SELECT * FROM settings WHERE xusername='$xusername' and xpassword=MD5('$xpassword')");
  if (mysqli_num_rows($cekSecurity) > 0) {

    $cekSettings = mysqli_query($con, "SELECT * FROM settings WHERE token = '$token'");
    $do = mysqli_fetch_array($cekSettings);
    if (isset($do)) {

      $response["data"] = array();

      $cekOrder = mysqli_query($con, "
        SELECT id_order, kode_order, total_amount, item_count, status, created_at, updated_at
        FROM orders
        WHERE id_user='$id_user'
        ORDER BY created_at DESC
      ");

      while ($o = mysqli_fetch_array($cekOrder)) {
        $response["data"][] = array(
          "id_order"     => (int)$o['id_order'],
          "kode_order"   => $o['kode_order'],
          "total_amount" => (int)$o['total_amount'],
          "item_count"   => (int)$o['item_count'],
          "status"       => $o['status'],
          "created_at"   => $o['created_at'],
          "updated_at"   => $o['updated_at'],
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
