<?php
require 'vendor/autoload.php';

use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;

$mail = new PHPMailer(true);

try {
    $mail->isSMTP();
    $mail->Host       = 'smtp.gmail.com';
    $mail->SMTPAuth   = true;
    $mail->Username   = 'faisalarrahmanpratama@gmail.com';
    $mail->Password   = 'fuds kbxn zjvi pnms'; // ganti!
    $mail->SMTPSecure = "ssl";
    $mail->Port       = 465;

    $mail->setFrom('faisalarrahmanpratama@gmail.com', 'Test');
    $mail->addAddress('faisalarrahmanpratama@gmail.com');

    $mail->isHTML(true);
    $mail->Subject = 'SMTP TEST';
    $mail->Body    = 'SMTP berjalan!';

    $mail->send();
    echo "BERHASIL TERKIRIM!";
} catch (Exception $e) {
    echo "ERROR SMTP:<br>";
    echo $mail->ErrorInfo;
}
