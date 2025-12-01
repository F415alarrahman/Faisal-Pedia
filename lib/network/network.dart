const token = "initokensemogabisalolosyaAllah";
const xusername = "faisalapi";
const xpassword = "faisal123";
const url = "https://faisalarrp.online/api/webServices";
const assetsBukti = "https://faisalarrp.online/api/uploads/bukti";
const assetsProducts = "https://faisalarrp.online/api";

class NetworkUrl {
  static String login() {
    return "$url/login.php";
  }

  static String register() {
    return "$url/register.php";
  }

  static String getProduct() {
    return "$url/get_products.php";
  }

  static String createOrder() {
    return "$url/create_order.php";
  }

  static String getOrders() {
    return "$url/get_orders.php";
  }

  static String updateOrderItem() {
    return "$url/update_order_item.php";
  }

  static String deleteOrderItem() {
    return "$url/delete_order_item.php";
  }

  static String createMidtransTransaction() {
    return "$url/create_midtrans_transaction.php";
  }

  static String uploadBukti() {
    return "$url/upload_bukti.php";
  }

  static String invoiceOrder(String idOrder) {
    return "$url/invoice_pdf.php?id_order=$idOrder";
  }

  static String openInvoice(String idOrder) {
    return "$url/lihat_pdf.php?id_order=$idOrder";
  }

  static String getCs1Order() {
    return "$url/cs1_get_orders.php";
  }

  static String getCs1OrderDetail() {
    return "$url/cs1_get_order_detail.php";
  }

  static String cs1ExportOrdersCsv() {
    return "$url/cs1_export_orders_csv.php";
  }

  static String cs1VerifyOrder() {
    return "$url/cs1_verify_payment.php";
  }

  static String getCs2Order() {
    return "$url/cs2_get_orders.php";
  }

  static String cs2ExportOrdersCsv() {
    return "$url/cs2_export_orders_csv.php";
  }

  static String cs2UpdateStatus() {
    return "$url/cs2_update_status.php";
  }

  static String searchProduct() {
    return "$url/cari_produk.php";
  }
}
