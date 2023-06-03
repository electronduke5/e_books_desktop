import 'package:intl/intl.dart';

class DateTimeHelper {
  static String getDate(DateTime date) => DateFormat('dd.MM.yyyy').format(date.toLocal());
  static String getDateWithTime(DateTime date) => DateFormat('dd.MM.yyyy HH:mm').format(date.toLocal());
}