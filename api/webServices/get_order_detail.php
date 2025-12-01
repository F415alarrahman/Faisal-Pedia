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

  $token    = isset($_POST['token']) ? $_POST['token'] : '';
  $id_order = isset($_POST['id_order']) ? (int)$_POST['id_order'] : 0;

  if ($token == '' || $id_order <= 0) {
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

      $cekOrder = mysqli_query($con, "SELECT * FROM orders WHERE id_order='$id_order'");
      if (mysqli_num_rows($cekOrder) == 0) {
        $response["value"]   = 0;
        $response["message"] = "Order tidak ditemukan!";
        echo json_encode($response);
        exit;
      }

      $order = mysqli_fetch_array($cekOrder);

      $items = array();
      $cekItems = mysqli_query($con, "SELECT * FROM order_items WHERE id_order='$id_order'");
      while ($i = mysqli_fetch_array($cekItems)) {
        $items[] = array(
          "id_item"      => (int)$i['id_item'],
          "id_product"   => (int)$i['id_product'],
          "nama_product" => $i['nama_product'],
          "harga"        => (int)$i['harga'],
          "qty"          => (int)$i['qty'],
          "subtotal"     => (int)$i['subtotal'],
        );
      }

      $response["value"]   = 1;
      $response["message"] = "Berhasil!";

      $response["data"] = array(
        "id_order"       => (int)$order['id_order'],
        "kode_order"     => $order['kode_order'],
        "id_user"        => $order['id_user'] == null ? null : (int)$order['id_user'],
        "buyer_name"     => $order['buyer_name'],
        "buyer_phone"    => $order['buyer_phone'],
        "buyer_address"  => $order['buyer_address'],
        "status"         => $order['status'],
        "total_amount"   => (int)$order['total_amount'],
        "item_count"     => (int)$order['item_count'],
        "payment_proof"  => $order['payment_proof'],
        "canceled_reason" => $order['canceled_reason'],
        "created_at"     => $order['created_at'],
        "updated_at"     => $order['updated_at'],
        "items"          => $items
      );

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
