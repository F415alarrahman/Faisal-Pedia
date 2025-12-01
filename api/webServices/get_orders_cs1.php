<?php
require_once "../config/connect.php";

header('Content-Type: application/json; charset=utf-8');

mysqli_report(MYSQLI_REPORT_ERROR | MYSQLI_REPORT_STRICT);
$conn->set_charset("utf8");

$response = [
  "value"   => 0,
  "message" => "Terjadi kesalahan",
  "data"    => []
];

try {
  // ambil status filter (optional, default MENUNGGU_VERIFIKASI_CS1)
  $statusFilter = isset($_GET['status']) && $_GET['status'] !== ''
    ? $_GET['status']
    : 'MENUNGGU_VERIFIKASI_CS1';

  // 1) AUTO CANCEL: order > 24 jam & masih MENUNGGU_VERIFIKASI_CS1 → DIBATALKAN
  $now = date('Y-m-d H:i:s');
  $stmtAuto = $conn->prepare("
        UPDATE orders 
        SET status = 'DIBATALKAN', updated_at = ?
        WHERE status = 'MENUNGGU_VERIFIKASI_CS1'
          AND created_at <= DATE_SUB(?, INTERVAL 1 DAY)
    ");
  $stmtAuto->bind_param("ss", $now, $now);
  $stmtAuto->execute();

  // 2) AMBIL DATA (sesuai filter status aktif)
  $stmt = $conn->prepare("
        SELECT 
            o.id                AS orderId,
            o.created_at        AS createdAt,
            o.updated_at        AS lastUpdatedAt,
            o.status            AS status,
            o.total_amount      AS totalAmount,
            o.item_count        AS itemCount,    -- kalau tidak ada, bisa COUNT item di Flutter
            o.payment_proof     AS paymentProof, -- path bukti gambar
            c.name              AS buyerName,
            c.phone             AS buyerPhone,
            c.address           AS buyerAddress
        FROM orders o
        LEFT JOIN customers c ON c.id = o.customer_id
        WHERE o.status = ?
        ORDER BY o.created_at ASC
    ");
  $stmt->bind_param("s", $statusFilter);
  $stmt->execute();
  $result = $stmt->get_result();

  $data = [];
  while ($row = $result->fetch_assoc()) {
    $data[] = [
      "orderId"        => $row["orderId"],
      "createdAt"      => $row["createdAt"],
      "lastUpdatedAt"  => $row["lastUpdatedAt"],
      "status"         => $row["status"],
      "totalAmount"    => (float)$row["totalAmount"],
      "itemCount"      => isset($row["itemCount"]) ? (int)$row["itemCount"] : 0,
      "paymentProof"   => $row["paymentProof"],
      "buyerName"      => $row["buyerName"],
      "buyerPhone"     => $row["buyerPhone"],
      "buyerAddress"   => $row["buyerAddress"],
    ];
  }

  $response["value"]   = 1;
  $response["message"] = "Data pesanan CS1 berhasil diambil";
  $response["data"]    = $data;
} catch (Exception $e) {
  $response["value"]   = 0;
  $response["message"] = "Error: " . $e->getMessage();
}

echo json_encode($response);