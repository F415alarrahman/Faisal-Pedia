import 'package:intl/intl.dart';

String formatRupiah(dynamic value) {
  final number = num.tryParse(value.toString()) ?? 0;

  final formatter = NumberFormat.decimalPattern('id_ID');
  return "Rp ${formatter.format(number)}";
}
