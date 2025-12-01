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

  $token    = $_POST['token']    ?? '';
  $id_order = $_POST['id_order'] ?? '';

  if ($token == '' || $id_order == '') {
    $response["value"]   = 0;
    $response["message"] = "Token dan id_order tidak boleh kosong!";
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

      $idOrderEsc = mysqli_real_escape_string($con, $id_order);

      // DATA ORDER
      $sqlOrder = "
        SELECT 
          id_order,
          kode_order,
          buyer_name,
          buyer_phone,
          buyer_address,
          status,
          total_amount,
          item_count,
          created_at,
          updated_at,
          paid_at,
          payment_proof,
          midtrans_status
        FROM orders
        WHERE id_order = '$idOrderEsc'
        LIMIT 1
      ";

      $cekOrder = mysqli_query($con, $sqlOrder);

      if (mysqli_num_rows($cekOrder) == 0) {
        $response["value"]   = 0;
        $response["message"] = "Order tidak ditemukan!";
        echo json_encode($response);
        exit;
      }

      $order = mysqli_fetch_assoc($cekOrder);

      // DATA ITEM
      $sqlItems = "
        SELECT 
          id_item,
          id_product,
          nama_product,
          harga,
          qty,
          subtotal
        FROM order_items
        WHERE id_order = '$idOrderEsc'
      ";

      $cekItems = mysqli_query($con, $sqlItems);
      $items    = array();

      while ($row = mysqli_fetch_assoc($cekItems)) {
        $items[] = array(
          "id_item"      => (int)$row['id_item'],
          "id_product"   => (int)$row['id_product'],
          "nama_product" => $row['nama_product'],
          "harga"        => (int)$row['harga'],
          "qty"          => (int)$row['qty'],
          "subtotal"     => (int)$row['subtotal'],
        );
      }

      $response["value"]   = 1;
      $response["message"] = "Berhasil!";
      $response["data"]    = array(
        "order" => array(
          "id_order"       => (int)$order['id_order'],
          "kode_order"     => $order['kode_order'],
          "buyer_name"     => $order['buyer_name'],
          "buyer_phone"    => $order['buyer_phone'],
          "buyer_address"  => $order['buyer_address'],
          "status"         => $order['status'],
          "total_amount"   => (int)$order['total_amount'],
          "item_count"     => (int)$order['item_count'],
          "created_at"     => $order['created_at'],
          "updated_at"     => $order['updated_at'],
          "paid_at"        => $order['paid_at'],
          "payment_proof"  => $order['payment_proof'],
          "midtrans_status" => $order['midtrans_status'],
        ),
        "items" => $items
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
