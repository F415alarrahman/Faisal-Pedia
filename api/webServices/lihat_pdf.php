<?php
require_once "../config/connect.php";
require_once "../vendor/autoload.php";

use Dompdf\Dompdf;

// =========================
// AMBIL PARAMETER
// =========================
$id = isset($_GET['id_order']) ? (int)$_GET['id_order'] : 0;
if ($id <= 0) {
  die("id_order wajib");
}

// (Opsional) Kalau mau pakai security header, bisa ambil di sini:
// $headers   = getallheaders();
// $xusername = $headers['x-username'] ?? '';
// $xpassword = $headers['x-password'] ?? '';
// Lalu cek ke tabel settings kalau memang mau dibatasi.

// =========================
// AMBIL DATA ORDER + USER
// =========================
$stmt = $con->prepare("
  SELECT o.*, u.email 
  FROM orders o
  LEFT JOIN users u ON o.id_user = u.id_user
  WHERE o.id_order = ?
  LIMIT 1
");
$stmt->bind_param("i", $id);
$stmt->execute();
$order = $stmt->get_result()->fetch_assoc();
$stmt->close();

if (!$order) {
  die("Order tidak ditemukan");
}

// =========================
// AMBIL ITEM ORDER
// =========================
$qItems = $con->prepare("
  SELECT *
  FROM order_items
  WHERE id_order = ?
");
$qItems->bind_param("i", $id);
$qItems->execute();
$itemsResult = $qItems->get_result();

$items = [];
while ($row = $itemsResult->fetch_assoc()) {
  $items[] = $row;
}
$qItems->close();

// =========================
// MAPPING DATA KE VARIABEL
// =========================

// Header perusahaan
$companyName    = "Faisal Pedia";
$companyAddress = "Jl. Raya No.123 Jakarta";
$companyPhone   = "08123456789";

// Info invoice
$invoiceNumber  = "INV-" . $order['kode_order'];
$invoiceDate    = date("Y-m-d", strtotime($order['created_at']));
$invoiceStatus  = strtoupper($order['status']);

// Data pelanggan
$customerName   = $order['buyer_name'];
$customerPhone  = $order['buyer_phone'];
$customerEmail  = $order['email'] ?? '-';
$customerAddr   = $order['buyer_address'];

// Ringkasan order
$orderId        = $order['id_order'];
$orderCode      = $order['kode_order'];
$itemCount      = (int)($order['item_count'] ?? count($items));
$totalAmount    = (int)$order['total_amount'];

// Midtrans (kolom di tabel orders)
$paymentType = $order['payment_type']
  ?? $order['midtrans_payment_type']
  ?? '';

$transactionId = $order['transaction_id']
  ?? $order['midtrans_transaction_id']
  ?? '';

$midtransOrderId = $order['midtrans_order_id'] ?? '';
$bankName        = $order['bank']          ?? ($order['midtrans_bank'] ?? '');
$vaNumber        = $order['va_number']     ?? ($order['midtrans_va_number'] ?? '');
$paidAt          = $order['paid_at']       ?? '';

// Bukti pembayaran (kalau mau ditampilkan di template)
$paymentProof    = $order['payment_proof'] ?? '';

// Helper format rupiah
function formatRupiah($angka)
{
  return "Rp " . number_format((int)$angka, 0, ',', '.');
}

// =========================
// RENDER HTML → PDF
// =========================
ob_start();
include "invoice_template_html.php"; // gunakan variabel di atas + $items
$html = ob_get_clean();

// =========================
// GENERATE PDF
// =========================
$dompdf = new Dompdf();
$dompdf->loadHtml($html);
$dompdf->setPaper('A4', 'portrait');
$dompdf->render();

$pdfOutput = $dompdf->output();

// Pastikan tidak ada header lain yang bocor
if (!headers_sent()) {
  header_remove();
}

// =========================
// TAMPILKAN PDF (PREVIEW)
// =========================
header('Content-Type: application/pdf');
// inline = coba TAMPILKAN di browser / viewer
header('Content-Disposition: inline; filename="' . $invoiceNumber . '.pdf"');
header('Content-Length: ' . strlen($pdfOutput));
header('Cache-Control: private, max-age=0, must-revalidate');
header('Pragma: public');

echo $pdfOutput;
exit;
