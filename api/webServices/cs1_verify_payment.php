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
  $action   = isset($_POST['action']) ? strtoupper(trim($_POST['action'])) : ''; // ACCEPT / REJECT
  $note     = $_POST['note'] ?? ''; // optional catatan

  if ($token == '' || $id_order == '' || $action == '') {
    $response["value"]   = 0;
    $response["message"] = "Token, id_order, dan action tidak boleh kosong!";
    echo json_encode($response);
    exit;
  }

  if ($action != 'ACCEPT' && $action != 'REJECT') {
    $response["value"]   = 0;
    $response["message"] = "Action harus ACCEPT atau REJECT!";
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
      $noteEsc    = mysqli_real_escape_string($con, $note);

      // cek order & status
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

      $order = mysqli_fetch_assoc($cekOrder);

      if ($order['status'] != 'MENUNGGU_VERIFIKASI_CS1') {
        $response["value"]   = 0;
        $response["message"] = "Status order tidak valid untuk aksi CS1!";
        echo json_encode($response);
        exit;
      }

      $newStatus = ($action == 'ACCEPT') ? 'MENUNGGU_DIPROSES_CS2' : 'DIBATALKAN';

      // mulai transaksi
      $con->begin_transaction();

      try {

        if ($action == 'ACCEPT') {
          // kurangi stok dari order_items
          $sqlItems = "
            SELECT id_product, qty 
            FROM order_items
            WHERE id_order = '$idOrderEsc'
          ";
          $cekItems = mysqli_query($con, $sqlItems);

          while ($row = mysqli_fetch_assoc($cekItems)) {
            $idProduct = (int)$row['id_product'];
            $qty       = (int)$row['qty'];

            $sqlStok = "
              UPDATE products
              SET stok = GREATEST(stok - $qty, 0)
              WHERE id_product = $idProduct
            ";
            mysqli_query($con, $sqlStok);
          }
        }

        // update status order
        $sqlUpdate = "
          UPDATE orders
          SET status        = '$newStatus',
              updated_at    = '$tglSekarang',
              canceled_reason = IF('$newStatus' = 'DIBATALKAN', 
                                   CONCAT(IFNULL(canceled_reason, ''), IF('$noteEsc' != '', CONCAT(' | ', '$noteEsc'), '')),
                                   canceled_reason)
          WHERE id_order = '$idOrderEsc'
        ";
        mysqli_query($con, $sqlUpdate);

        $con->commit();

        $response["value"]      = 1;
        $response["message"]    = "Aksi CS1 berhasil. Status diubah menjadi: $newStatus";
        $response["new_status"] = $newStatus;
        echo json_encode($response);
      } catch (Throwable $e) {
        $con->rollback();
        $response["value"]   = 0;
        $response["message"] = "Terjadi kesalahan: " . $e->getMessage();
        echo json_encode($response);
      }
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
