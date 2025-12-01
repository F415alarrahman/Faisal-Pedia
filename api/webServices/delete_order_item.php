<?php
require_once "../config/connect.php";

date_default_timezone_set('Asia/Jakarta');
$tglSekarang = date('Y-m-d H:i:s');

$headers   = getallheaders();
$xusername = isset($headers['x-username']) ? $headers['x-username'] : '';
$xpassword = isset($headers['x-password']) ? $headers['x-password'] : '';

ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

header('Content-Type: application/json; charset=utf-8');

if ($_SERVER['REQUEST_METHOD'] == "POST") {
  $response = array();

  $token   = isset($_POST['token'])   ? $_POST['token']   : '';
  $id_item = isset($_POST['id_item']) ? $_POST['id_item'] : '';

  if ($token == '' || $id_item == '') {
    $response["value"]   = 0;
    $response["message"] = "Data tidak lengkap!";
    echo json_encode($response);
    exit;
  }

  $cekSecurity = mysqli_query(
    $con,
    "SELECT * FROM settings 
     WHERE xusername='$xusername' 
       AND xpassword=MD5('$xpassword')"
  );

  if (mysqli_num_rows($cekSecurity) == 0) {
    $response["value"]   = 0;
    $response["message"] = "You don't have authorization!";
    echo json_encode($response);
    exit;
  }

  $cekSettings = mysqli_query($con, "SELECT * FROM settings WHERE token='$token'");
  if (!mysqli_fetch_array($cekSettings)) {
    $response["value"]   = 0;
    $response["message"] = "Token invalid!";
    echo json_encode($response);
    exit;
  }

  $id_item_int = (int)$id_item;

  // ambil dulu id_order
  $cekItem = mysqli_query(
    $con,
    "SELECT id_order FROM order_items WHERE id_item = $id_item_int LIMIT 1"
  );
  if (mysqli_num_rows($cekItem) == 0) {
    $response["value"]   = 0;
    $response["message"] = "Item tidak ditemukan!";
    echo json_encode($response);
    exit;
  }

  $row     = mysqli_fetch_assoc($cekItem);
  $idOrder = (int)$row['id_order'];

  mysqli_begin_transaction($con);
  try {
    // hapus item
    $sqlDel = "DELETE FROM order_items WHERE id_item = $id_item_int";
    if (!mysqli_query($con, $sqlDel)) {
      throw new Exception("Gagal menghapus item!");
    }

    // hitung ulang total
    $sqlSum = "
      SELECT COALESCE(SUM(subtotal),0) AS total_amount,
             COALESCE(SUM(qty),0)      AS item_count
        FROM order_items
       WHERE id_order = $idOrder
    ";
    $resSum = mysqli_query($con, $sqlSum);
    $sum    = mysqli_fetch_assoc($resSum);

    $totalAmount = (int)$sum['total_amount'];
    $itemCount   = (int)$sum['item_count'];

    $sqlOrder = "
      UPDATE orders
         SET total_amount = $totalAmount,
             item_count   = $itemCount,
             updated_at   = '$tglSekarang'
       WHERE id_order = $idOrder
    ";
    if (!mysqli_query($con, $sqlOrder)) {
      throw new Exception("Gagal update total order!");
    }

    mysqli_commit($con);

    $response["value"]        = 1;
    $response["message"]      = "Item berhasil dihapus.";
    $response["id_order"]     = $idOrder;
    $response["total_amount"] = $totalAmount;
    $response["item_count"]   = $itemCount;

    echo json_encode($response);
  } catch (Exception $e) {
    mysqli_rollback($con);
    $response["value"]   = 0;
    $response["message"] = $e->getMessage();
    echo json_encode($response);
  }
}
