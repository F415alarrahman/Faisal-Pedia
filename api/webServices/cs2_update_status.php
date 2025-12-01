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
  $action   = isset($_POST['action']) ? strtoupper(trim($_POST['action'])) : ''; // PROCESS / SHIP / COMPLETE

  if ($token == '' || $id_order == '' || $action == '') {
    $response["value"]   = 0;
    $response["message"] = "Token, id_order, dan action tidak boleh kosong!";
    echo json_encode($response);
    exit;
  }

  if (!in_array($action, ['PROCESS', 'SHIP', 'COMPLETE'])) {
    $response["value"]   = 0;
    $response["message"] = "Action tidak dikenal! Gunakan PROCESS / SHIP / COMPLETE.";
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

      $idOrderEsc = mysqli_real_escape_string($con, $id_order);

      // cek order & status sekarang
      $cekOrder = mysqli_query(
        $con,
        "SELECT status FROM orders WHERE id_order = '$idOrderEsc' LIMIT 1"
      );

      if (mysqli_num_rows($cekOrder) == 0) {
        $response["value"]   = 0;
        $response["message"] = "Order tidak ditemukan!";
        echo json_encode($response);
        exit;
      }

      $order  = mysqli_fetch_assoc($cekOrder);
      $status = $order['status'];
      $newStatus = '';

      // logic transisi status
      if ($action == 'PROCESS') {
        // hanya boleh dari MENUNGGU_DIPROSES_CS2
        if ($status != 'MENUNGGU_DIPROSES_CS2') {
          $response["value"]   = 0;
          $response["message"] = "Order tidak bisa di-PROCESS dari status: $status";
          echo json_encode($response);
          exit;
        }
        $newStatus = 'SEDANG_DIPROSES';
      } elseif ($action == 'SHIP') {
        // boleh dari MENUNGGU_DIPROSES_CS2 / SEDANG_DIPROSES
        if (!in_array($status, ['MENUNGGU_DIPROSES_CS2', 'SEDANG_DIPROSES'])) {
          $response["value"]   = 0;
          $response["message"] = "Order tidak bisa di-SHIP dari status: $status";
          echo json_encode($response);
          exit;
        }
        $newStatus = 'DIKIRIM';
      } elseif ($action == 'COMPLETE') {
        // boleh hanya dari DIKIRIM
        if ($status != 'DIKIRIM') {
          $response["value"]   = 0;
          $response["message"] = "Order tidak bisa di-COMPLETE dari status: $status";
          echo json_encode($response);
          exit;
        }
        $newStatus = 'SELESAI';
      }

      // update status
      $sqlUpdate = "
        UPDATE orders
        SET status    = '$newStatus',
            updated_at = '$tglSekarang'
        WHERE id_order = '$idOrderEsc'
      ";
      mysqli_query($con, $sqlUpdate);

      $response["value"]      = 1;
      $response["message"]    = "Status berhasil diubah menjadi: $newStatus";
      $response["new_status"] = $newStatus;
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
