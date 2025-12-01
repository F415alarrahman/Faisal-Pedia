<!DOCTYPE html>
<html>

<head>
  <meta charset="UTF-8">
  <title>Invoice <?= htmlspecialchars($invoiceNumber) ?></title>
  <style>
    * {
      box-sizing: border-box;
    }

    body {
      font-family: DejaVu Sans, sans-serif;
      font-size: 11pt;
      margin: 0;
      padding: 24px;
    }

    .invoice-wrapper {
      width: 100%;
    }

    .text-right {
      text-align: right;
    }

    .text-center {
      text-align: center;
    }

    .text-muted {
      color: #666;
    }

    .mt-5 {
      margin-top: 5px;
    }

    .mt-10 {
      margin-top: 10px;
    }

    .mt-15 {
      margin-top: 15px;
    }

    .mt-20 {
      margin-top: 20px;
    }

    .mt-30 {
      margin-top: 30px;
    }

    .company-name {
      font-size: 16pt;
      font-weight: bold;
    }

    .invoice-title {
      font-size: 22pt;
      font-weight: bold;
    }

    hr {
      border: none;
      border-top: 1px solid #ddd;
      margin: 15px 0;
    }

    table {
      border-collapse: collapse;
      width: 100%;
    }

    .info-table td {
      vertical-align: top;
      padding: 2px 0;
    }

    .section-title {
      font-size: 11pt;
      font-weight: bold;
      margin-bottom: 6px;
      text-transform: uppercase;
    }

    .items-table {
      margin-top: 10px;
    }

    .items-table th,
    .items-table td {
      border: 1px solid #ccc;
      padding: 6px 8px;
    }

    .items-table th {
      background-color: #f5f5f5;
      font-weight: bold;
    }

    .summary-table {
      width: 40%;
      float: right;
      margin-top: 10px;
    }

    .summary-table td {
      padding: 4px 6px;
    }

    .summary-table .label {
      font-weight: bold;
    }

    .box {
      border: 1px solid #ccc;
      padding: 8px;
    }

    .small-text {
      font-size: 9pt;
    }

    /* STATUS (tanpa border, cuma warna teks) */
    .status-text {
      font-weight: bold;
    }

    .status-complete {
      color: #2e7d32;
    }

    .status-ship {
      color: #1565c0;
    }

    .status-pending {
      color: #ff8f00;
    }

    .status-cancel {
      color: #c62828;
    }

    .footer-note {
      margin-top: 30px;
      font-size: 8.5pt;
      color: #777;
      border-top: 1px dashed #ccc;
      padding-top: 8px;
    }

    /* header kanan biar nggak numpuk */
    .header-right-inner {
      display: inline-block;
      text-align: left;
    }
  </style>
</head>

<body>
  <div class="invoice-wrapper">

    <!-- HEADER -->
    <table>
      <tr>
        <td width="60%">
          <div class="company-name">
            <?= htmlspecialchars($companyName) ?>
          </div>
          <div class="text-muted mt-5">
            <?= nl2br(htmlspecialchars($companyAddress)) ?>
          </div>
          <div class="text-muted mt-5">
            Telp: <?= htmlspecialchars($companyPhone) ?>
          </div>
        </td>
        <td width="40%" class="text-right">
          <div class="invoice-title">INVOICE</div>
          <div class="mt-10 header-right-inner">
            <table class="info-table">
              <tr>
                <td>No.</td>
                <td>: <?= htmlspecialchars($invoiceNumber) ?></td>
              </tr>
              <tr>
                <td>Tanggal</td>
                <td>: <?= htmlspecialchars($invoiceDate) ?></td>
              </tr>
              <tr>
                <td>Status</td>
                <td>:
                  <?php
                  $statusUpper = strtoupper(trim($invoiceStatus));
                  $statusClass = 'status-pending';

                  if (in_array($statusUpper, ['COMPLETE', 'PAID', 'SETTLEMENT'])) {
                    $statusClass = 'status-complete';
                  } elseif (in_array($statusUpper, ['SHIP', 'SHIPPED'])) {
                    $statusClass = 'status-ship';
                  } elseif (in_array($statusUpper, ['CANCEL', 'FAILED', 'EXPIRE'])) {
                    $statusClass = 'status-cancel';
                  }
                  ?>
                  <span class="status-text <?= $statusClass ?>">
                    <?= htmlspecialchars($statusUpper) ?>
                  </span>
                </td>
              </tr>
            </table>
          </div>
        </td>
      </tr>
    </table>

    <hr>

    <!-- CUSTOMER & ORDER INFO -->
    <table class="mt-10">
      <tr>
        <!-- DATA PELANGGAN -->
        <td width="50%" valign="top">
          <div class="section-title">Data Pelanggan</div>
          <table class="info-table">
            <tr>
              <td width="30%">Nama</td>
              <td>: <?= htmlspecialchars($customerName) ?></td>
            </tr>
            <?php if (!empty($customerEmail) && $customerEmail !== '-'): ?>
              <tr>
                <td>Email</td>
                <td>: <?= htmlspecialchars($customerEmail) ?></td>
              </tr>
            <?php endif; ?>
            <?php if (!empty($customerPhone)): ?>
              <tr>
                <td>Telepon</td>
                <td>: <?= htmlspecialchars($customerPhone) ?></td>
              </tr>
            <?php endif; ?>
            <?php if (!empty($customerAddr)): ?>
              <tr>
                <td>Alamat</td>
                <td>: <?= nl2br(htmlspecialchars($customerAddr)) ?></td>
              </tr>
            <?php endif; ?>
          </table>
        </td>

        <!-- DATA ORDER -->
        <td width="50%" valign="top">
          <div class="section-title">Data Order</div>
          <table class="info-table">
            <tr>
              <td width="35%">Kode Order</td>
              <td>: <?= htmlspecialchars($orderCode) ?></td>
            </tr>
            <tr>
              <td>Tanggal Order</td>
              <td>: <?= htmlspecialchars($invoiceDate) ?></td>
            </tr>
            <tr>
              <td>Jumlah Item</td>
              <td>: <?= htmlspecialchars($itemCount) ?> item</td>
            </tr>
            <tr>
              <td>Total</td>
              <td>: <?= formatRupiah($totalAmount) ?></td>
            </tr>
          </table>
        </td>
      </tr>
    </table>

    <!-- ITEMS -->
    <div class="mt-20 section-title">Rincian Tagihan</div>
    <table class="items-table">
      <thead>
        <tr>
          <th>Deskripsi</th>
          <th width="10%">Qty</th>
          <th width="20%" class="text-right">Harga</th>
          <th width="20%" class="text-right">Subtotal</th>
        </tr>
      </thead>
      <tbody>
        <?php foreach ($items as $it): ?>
          <tr>
            <td><?= htmlspecialchars($it['nama_product']) ?></td>
            <td class="text-center"><?= (int)$it['qty'] ?></td>
            <td class="text-right"><?= formatRupiah((int)$it['harga']) ?></td>
            <td class="text-right"><?= formatRupiah((int)$it['subtotal']) ?></td>
          </tr>
        <?php endforeach; ?>
      </tbody>
    </table>

    <!-- SUMMARY -->
    <table class="summary-table">
      <tr>
        <td class="label">Total</td>
        <td class="text-right"><?= formatRupiah($totalAmount) ?></td>
      </tr>
    </table>

    <div style="clear: both;"></div>

    <!-- MIDTRANS DETAIL -->
    <div class="mt-20 section-title">Detail Pembayaran (Midtrans)</div>
    <table class="box small-text">
      <tr>
        <td width="30%">Payment Type</td>
        <td>: <?= htmlspecialchars($paymentType) ?></td>
      </tr>
      <tr>
        <td>Transaction ID</td>
        <td>: <?= htmlspecialchars($transactionId) ?></td>
      </tr>
      <tr>
        <td>Midtrans Order ID</td>
        <td>: <?= htmlspecialchars($midtransOrderId) ?></td>
      </tr>
      <?php if (!empty($bankName)): ?>
        <tr>
          <td>Bank</td>
          <td>: <?= htmlspecialchars($bankName) ?></td>
        </tr>
      <?php endif; ?>
      <?php if (!empty($vaNumber)): ?>
        <tr>
          <td>VA Number</td>
          <td>: <?= htmlspecialchars($vaNumber) ?></td>
        </tr>
      <?php endif; ?>
      <?php if (!empty($paidAt)): ?>
        <tr>
          <td>Paid At</td>
          <td>: <?= htmlspecialchars($paidAt) ?></td>
        </tr>
      <?php endif; ?>
    </table>

    <!-- FOOTER NOTE -->
    <div class="footer-note">
      Dokumen ini merupakan bukti pembayaran yang sah dan diterbitkan secara otomatis oleh sistem.
      Simpan invoice ini sebagai arsip pembayaran Anda.
    </div>

  </div>
</body>

</html>