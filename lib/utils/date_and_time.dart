import 'package:intl/intl.dart';

class DateAndTime {
  static DateTime format() {
    final now = DateTime.now();
    final dateFormat = DateFormat('y/M/d');
    final timeInString = "09:00:00 PM";
    final todayInString = dateFormat.format(now);
    final completeString = "$todayInString $timeInString";
    final completeFormat = DateFormat('y/M/d h:m:s a');
    var completeDatetimeObject = completeFormat.parseStrict(completeString);
    var newCompleteDatetimeObject =
        completeDatetimeObject.add(Duration(seconds: 5));
    return newCompleteDatetimeObject;
  }
}
