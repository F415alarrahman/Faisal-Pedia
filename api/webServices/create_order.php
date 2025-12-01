<?php
require_once "../config/connect.php";

date_default_timezone_set('Asia/Jakarta');
header('Content-Type: application/json; charset=utf-8');
$tglSekarang = date('Y-m-d H:i:s');
$tgl         = date('Y-m-d');
$headers     = getallheaders();
$xusername   = isset($headers['x-username']) ? $headers['x-username'] : '';
$xpassword   = isset($headers['x-password']) ? $headers['x-password'] : '';

ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

$response = [];

if ($_SERVER['REQUEST_METHOD'] != "POST") {
  $response["value"]   = 0;
  $response["message"] = "Method not allowed!";
  echo json_encode($response);
  exit;
}

// ========= INPUT =========
$token         = isset($_POST['token']) ? $_POST['token'] : '';
$id_user       = isset($_POST['id_user']) ? $_POST['id_user'] : '';
$buyer_name    = isset($_POST['buyer_name']) ? trim($_POST['buyer_name']) : '';
$buyer_phone   = isset($_POST['buyer_phone']) ? trim($_POST['buyer_phone']) : '';
$buyer_address = isset($_POST['buyer_address']) ? trim($_POST['buyer_address']) : '';
$items_json    = isset($_POST['items_json']) ? $_POST['items_json'] : '';

// Wajib token, nama, items_json
if ($token == '' || $buyer_name == '' || $items_json == '') {
  $response["value"]   = 0;
  $response["message"] = "Data tidak lengkap!";
  echo json_encode($response);
  exit;
}

// ========= CEK SECURITY HEADER =========
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

// ========= CEK TOKEN =========
$cekSettings = mysqli_query($con, "SELECT * FROM settings WHERE token = '$token'");
$do = mysqli_fetch_array($cekSettings);
if (!$do) {
  $response["value"]   = 0;
  $response["message"] = "Token Invalid!";
  echo json_encode($response);
  exit;
}

// ========= PARSE ITEMS =========
$items = json_decode($items_json, true);
if (!is_array($items) || count($items) == 0) {
  $response["value"]   = 0;
  $response["message"] = "Item pesanan tidak valid!";
  echo json_encode($response);
  exit;
}

$statusAwal   = 'MENUNGGU_UPLOAD_BUKTI';
$addAmount    = 0; // total tambahan dari request ini
$addItemCount = 0;
$detailItems  = [];

// ========= VALIDASI PRODUK & HITUNG SUBTOTAL =========
foreach ($items as $it) {
  $idp = isset($it['id_product']) ? (int)$it['id_product'] : 0;
  $qty = isset($it['qty']) ? (int)$it['qty'] : 0;

  if ($idp <= 0 || $qty <= 0) {
    $response["value"]   = 0;
    $response["message"] = "Item pesanan mengandung data tidak valid!";
    echo json_encode($response);
    exit;
  }

  $cekProduk = mysqli_query(
    $con,
    "SELECT id_product, nama, harga, stok 
     FROM products 
     WHERE id_product='$idp'"
  );
  if (mysqli_num_rows($cekProduk) == 0) {
    $response["value"]   = 0;
    $response["message"] = "Produk dengan ID $idp tidak ditemukan!";
    echo json_encode($response);
    exit;
  }

  $p = mysqli_fetch_array($cekProduk);

  if ($qty > (int)$p['stok']) {
    $response["value"]   = 0;
    $response["message"] = "Stok produk {$p['nama']} tidak mencukupi!";
    echo json_encode($response);
    exit;
  }

  $harga    = (int)$p['harga'];
  $subtotal = $harga * $qty;

  $addAmount    += $subtotal;
  $addItemCount += $qty;

  $detailItems[] = [
    "id_product"   => (int)$p['id_product'],
    "nama_product" => $p['nama'],
    "harga"        => $harga,
    "qty"          => $qty,
    "subtotal"     => $subtotal,
  ];
}

// ========= MULAI TRANSAKSI =========
mysqli_begin_transaction($con);
try {

  $id_user_val = ($id_user == '' ? 'NULL' : (int)$id_user);

  // 1) CARI ORDER AKTIF USER INI
  $orderAktif = null;
  if ($id_user_val !== 'NULL') {
    $qExist = mysqli_query(
      $con,
      "SELECT * FROM orders 
       WHERE id_user = $id_user_val 
         AND status = '$statusAwal'
       ORDER BY id_order DESC
       LIMIT 1"
    );
    $orderAktif = mysqli_fetch_array($qExist);
  }

  if ($orderAktif) {
    // ========= UPDATE ORDER YANG SUDAH ADA =========
    $id_order      = (int)$orderAktif['id_order'];
    $oldTotal      = (int)$orderAktif['total_amount'];
    $oldItemCount  = (int)$orderAktif['item_count'];

    $newTotal      = $oldTotal + $addAmount;
    $newItemCount  = $oldItemCount + $addItemCount;

    // Update header order (nama, hp, alamat boleh di-refresh juga)
    $sqlUpdateOrder = "
      UPDATE orders SET
        buyer_name    = '" . mysqli_real_escape_string($con, $buyer_name) . "',
        buyer_phone   = '" . mysqli_real_escape_string($con, $buyer_phone) . "',
        buyer_address = '" . mysqli_real_escape_string($con, $buyer_address) . "',
        total_amount  = $newTotal,
        item_count    = $newItemCount,
        updated_at    = '$tglSekarang'
      WHERE id_order = $id_order
    ";
    if (!mysqli_query($con, $sqlUpdateOrder)) {
      throw new Exception("Gagal update order!");
    }

    // UPDATE / INSERT DETAIL ITEM
    foreach ($detailItems as $d) {
      $idp = $d['id_product'];

      $qDet = mysqli_query(
        $con,
        "SELECT id_item, qty, subtotal 
         FROM order_items 
         WHERE id_order = $id_order 
           AND id_product = $idp
         LIMIT 1"
      );

      if ($rowDet = mysqli_fetch_array($qDet)) {
        // produk sudah ada → tambahkan qty
        $oldQty      = (int)$rowDet['qty'];
        $newQty      = $oldQty + $d['qty'];
        $newSubtotal = $newQty * $d['harga'];

        $sqlUpdItem = "
          UPDATE order_items SET
            qty      = $newQty,
            subtotal = $newSubtotal
          WHERE id_item = {$rowDet['id_item']}
        ";
        if (!mysqli_query($con, $sqlUpdItem)) {
          throw new Exception("Gagal update detail order!");
        }
      } else {
        // produk belum ada → insert item baru
        $sqlInsItem = "
          INSERT INTO order_items (
            id_order,
            id_product,
            nama_product,
            harga,
            qty,
            subtotal
          ) VALUES (
            $id_order,
            {$d['id_product']},
            '" . mysqli_real_escape_string($con, $d['nama_product']) . "',
            {$d['harga']},
            {$d['qty']},
            {$d['subtotal']}
          )
        ";
        if (!mysqli_query($con, $sqlInsItem)) {
          throw new Exception("Gagal menyimpan detail order baru!");
        }
      }
    }

    $kode_order = $orderAktif['kode_order'];
    $totalAmountFinal = $newTotal;
    $itemCountFinal   = $newItemCount;
    $msg = "Order berhasil diperbarui.";
  } else {
    // ========= BELUM ADA ORDER AKTIF → BUAT BARU =========
    $kode_order = 'FP' . date('YmdHis') . rand(100, 999);
    $now        = $tglSekarang;

    $sqlOrder = "
      INSERT INTO orders (
        kode_order,
        id_user,
        buyer_name,
        buyer_phone,
        buyer_address,
        status,
        total_amount,
        item_count,
        created_at,
        updated_at
      ) VALUES (
        '$kode_order',
        $id_user_val,
        '" . mysqli_real_escape_string($con, $buyer_name) . "',
        '" . mysqli_real_escape_string($con, $buyer_phone) . "',
        '" . mysqli_real_escape_string($con, $buyer_address) . "',
        '$statusAwal',
        $addAmount,
        $addItemCount,
        '$now',
        '$now'
      )
    ";

    $insOrder = mysqli_query($con, $sqlOrder);
    if (!$insOrder) {
      throw new Exception("Gagal membuat order!");
    }

    $id_order = mysqli_insert_id($con);

    foreach ($detailItems as $d) {
      $sqlItem = "
        INSERT INTO order_items (
          id_order,
          id_product,
          nama_product,
          harga,
          qty,
          subtotal
        ) VALUES (
          $id_order,
          {$d['id_product']},
          '" . mysqli_real_escape_string($con, $d['nama_product']) . "',
          {$d['harga']},
          {$d['qty']},
          {$d['subtotal']}
        )
      ";
      if (!mysqli_query($con, $sqlItem)) {
        throw new Exception("Gagal menyimpan detail order!");
      }
    }

    $totalAmountFinal = $addAmount;
    $itemCountFinal   = $addItemCount;
    $msg = "Order berhasil dibuat.";
  }

  mysqli_commit($con);

  $response["value"]        = 1;
  $response["message"]      = $msg;
  $response["id_order"]     = (int)$id_order;
  $response["kode_order"]   = $kode_order;
  $response["total_amount"] = $totalAmountFinal;
  $response["item_count"]   = $itemCountFinal;
  echo json_encode($response);
} catch (Exception $e) {
  mysqli_rollback($con);
  $response["value"]   = 0;
  $response["message"] = $e->getMessage();
  echo json_encode($response);
}
