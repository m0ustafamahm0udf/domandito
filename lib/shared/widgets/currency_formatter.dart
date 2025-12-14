import 'package:intl/intl.dart';

String formatPrice(double price) {
  final formatter = NumberFormat("#,###", "en_US");
  return formatter.format(price);
}
