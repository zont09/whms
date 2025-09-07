import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart' as picker;
import 'package:intl/intl.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/untils/scale_utils.dart';

class DateTimeUtils {
  static String formatDateDayMonthYear(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  static DateTime getCurrentDate() {
    DateTime now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  static Timestamp getTimestampNow() {
    DateTime now = DateTime.now();
    DateTime dateTimeWithTime =
        DateTime(now.year, now.month, now.day, now.hour, now.minute);
    return Timestamp.fromDate(dateTimeWithTime);
  }

  static Timestamp getTimestampWithTimeOfDay(TimeOfDay time) {
    DateTime now = DateTime.now();
    DateTime dateTimeWithTime =
        DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return Timestamp.fromDate(dateTimeWithTime);
  }

  static Timestamp getTimestampWithDay(DateTime time) {
    DateTime dateTimeWithTime = DateTime(time.year, time.month, time.day);
    return Timestamp.fromDate(dateTimeWithTime);
  }

  static Timestamp getTimestampWithDateTime(DateTime time) {
    DateTime dateTimeWithTime = DateTime(time.year, time.month, time.day, time.hour, time.minute);
    return Timestamp.fromDate(dateTimeWithTime);
  }

  static String convertTimestampToString(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('HH:mm dd/MM/yyyy').format(dateTime);
  }

  static String convertTimestampToDateString(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('dd/MM/yyyy').format(dateTime);
  }

  static String convertTimestampToTime(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    String formattedTime = DateFormat('HH:mm').format(dateTime);
    return formattedTime;
  }

  static DateTime convertTimestampToDateTime(int timestamp) {
    return DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
  }

  static DateTime convertToDateTime(String dateString) {
    return DateFormat('dd/MM/yyyy').parse(dateString);
  }

  static String formatDuration(int x) {
    if (x < 60) {
      return '$x phút';
    } else {
      int hours = x ~/ 60; // Lấy phần nguyên (giờ)
      int minutes = x % 60; // Lấy phần dư (phút)
      return '$hours giờ ${minutes > 0 ? '$minutes phút' : ''}'.trim();
    }
  }

  static DateTime getStartOfThisWeek(DateTime inputDate) {
    return inputDate.subtract(Duration(days: inputDate.weekday - 1));
  }

  static DateTime getStartOfLastMonth(DateTime inputDate) {
    DateTime firstDayOfLastMonth = DateTime(inputDate.year, inputDate.month - 1, 1);
    return firstDayOfLastMonth;
  }

  static DateTime getEndOfLastMonth(DateTime inputDate) {
    // Lấy tháng trước
    DateTime firstDayOfCurrentMonth = DateTime(inputDate.year, inputDate.month, 1);
    // Trừ đi một ngày để có ngày cuối cùng của tháng trước
    DateTime lastDayOfLastMonth = firstDayOfCurrentMonth.subtract(Duration(days: 1));
    return lastDayOfLastMonth;
  }

  static List<Map<String, int>> getQuartersFromYear(int year) {
    List<Map<String, int>> quarters = [];
    int currentYear = DateTime.now().year;
    int currentQuarter = ((DateTime.now().month - 1) ~/ 3) + 1;

    for (int y = year; y <= currentYear; y++) {
      for (int quarter = 1; quarter <= 4; quarter++) {
        if (y == currentYear && quarter > currentQuarter) break;
        quarters.add({'year': y, 'quarter': quarter});
      }
    }

    return quarters;
  }

  static String getQuarterDates(int year, int quarter) {
    DateTime startDate;
    DateTime endDate;

    switch (quarter) {
      case 1: // Q1
        startDate = DateTime(year, 1, 1);
        endDate = DateTime(year, 3, 31);
        break;
      case 2: // Q2
        startDate = DateTime(year, 4, 1);
        endDate = DateTime(year, 6, 30);
        break;
      case 3: // Q3
        startDate = DateTime(year, 7, 1);
        endDate = DateTime(year, 9, 30);
        break;
      case 4: // Q4
        startDate = DateTime(year, 10, 1);
        endDate = DateTime(year, 12, 31);
        break;
      default:
        throw ArgumentError('Quarter must be between 1 and 4');
    }

    return "Ngày ${formatDateDayMonthYear(startDate)} - ${formatDateDayMonthYear(endDate)}";
  }

  static Map<String, DateTime> getQuarterDateRange(int quarter, int year) {
    if (quarter < 1 || quarter > 4) {
      throw ArgumentError("Quarter must be between 1 and 4.");
    }

    // Xác định ngày bắt đầu của quý
    final startMonth = (quarter - 1) * 3 + 1; // Tháng đầu tiên của quý
    final startDate = DateTime(year, startMonth, 1);

    // Xác định ngày kết thúc của quý
    final endMonth = startMonth + 2; // Tháng cuối cùng của quý
    final lastDayOfEndMonth = DateTime(year, endMonth + 1, 0); // Ngày cuối cùng của tháng

    // So sánh với ngày hiện tại (giới hạn ngày kết thúc)
    final now = DateTime.now();
    final endDate = lastDayOfEndMonth.isAfter(now) ? now : lastDayOfEndMonth;

    return {
      "startDate": startDate,
      "endDate": endDate,
    };
  }

  static Map<String, int> getQuarterAndYear(DateTime date) {
    final int month = date.month;
    final int quarter = ((month - 1) ~/ 3) + 1; // Tính toán quý từ tháng
    final int year = date.year; // Lấy năm từ ngày truyền vào

    return {
      "quarter": quarter,
      "year": year,
    };
  }

  static String formatFullDateTime(DateTime dateTime) {
    final weekdays = ['Chủ Nhật', 'Thứ Hai', 'Thứ Ba', 'Thứ Tư', 'Thứ Năm', 'Thứ Sáu', 'Thứ Bảy'];

    String formattedTime = "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
    String formattedDate = "${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}";
    String weekday = weekdays[dateTime.weekday % 7];

    return "$formattedTime $weekday  .  $formattedDate";
  }

  static String getWeekday(DateTime dateTime) {
    List<String> weekdays = ['Th2', 'Th3', 'Th4', 'Th5', 'Th6', 'Th7', 'CN'];
    return weekdays[dateTime.weekday - 1]; // weekday trả về giá trị từ 1 đến 7
  }

  static Map<String, DateTime> getStartAndEndOfWeek(int weeksAhead) {
    // Lấy ngày hiện tại
    final now = DateTime.now();

    // Tìm ngày đầu tiên của tuần hiện tại (thứ Hai)
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

    // Tính ngày đầu tiên của tuần mới
    final startOfTargetWeek = startOfWeek.add(Duration(days: weeksAhead * 7));

    // Tính ngày cuối cùng của tuần mới (Chủ Nhật)
    final endOfTargetWeek = startOfTargetWeek.add(Duration(days: 6));

    // Định dạng ngày theo dd/MM
    return {
      "start": startOfTargetWeek,
      "end": endOfTargetWeek,
    };
  }
  static Map<String, DateTime> getStartAndEndOfMonth(int monthsAhead) {
    // Lấy ngày hiện tại
    final now = DateTime.now();

    // Tính tháng và năm của tháng cần tính
    final targetMonth = now.month + monthsAhead;
    final targetYear = now.year + (targetMonth - 1) ~/ 12;
    final adjustedMonth = (targetMonth - 1) % 12 + 1;

    // Tính ngày đầu tiên của tháng
    final startOfMonth = DateTime(targetYear, adjustedMonth, 1);

    // Tính ngày cuối cùng của tháng
    final endOfMonth = DateTime(targetYear, adjustedMonth + 1, 0);


    // Trả về chuỗi kết quả
    return {
      "start": startOfMonth,
      "end": endOfMonth
    };
  }

  static Future<DateTime?> pickDateTime(BuildContext ctx, {DateTime? initDate}) async {
    return showDatePicker(
        context: ctx,
        initialDate: initDate ?? DateTime.now(),
        firstDate: DateTime(2004),
        lastDate: DateTime(2209),
        builder: (BuildContext context, Widget? child) {
          return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: ColorConfig.primary3,
                  surface: Colors.white,
                ),
              ),
              child: child!);
        });
  }

  static Future<DateTime?> pickTimeAndDate(BuildContext ctx, {DateTime? initDate}) async {
    return picker.DatePicker.showDateTimePicker(
      ctx,
      showTitleActions: true,
      minTime: DateTime(2000, 1, 1), // Ngày tối thiểu có thể chọn
      maxTime: DateTime(2100, 12, 31), // Ngày tối đa có thể chọn
      currentTime: initDate ?? DateTime.now(), // Ngày và giờ hiện tại được chọn mặc định
      locale: picker.LocaleType.vi, // Ngôn ngữ (tiếng Việt)
      onConfirm: (date) {
        print('Ngày và giờ đã chọn: $date');
      },
      theme: picker.DatePickerTheme(
        backgroundColor: Colors.white,
        itemStyle: TextStyle(color: ColorConfig.primary3, fontSize: ScaleUtils.scaleSize(16, ctx)),
        doneStyle: TextStyle(color: ColorConfig.primary3, fontSize: ScaleUtils.scaleSize(16, ctx)),
        cancelStyle: TextStyle(color: ColorConfig.primary3, fontSize: ScaleUtils.scaleSize(16, ctx)),
      ),
    );
  }
}
