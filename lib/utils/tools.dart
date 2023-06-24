import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum PopupAction { add, edit }

class Tools {
  static List<T> nullFilter<T>(List<T?> list) => [...list.whereType<T>()];

  static SnackBar showNormalSnackBar(BuildContext context, String text,
      {SnackBarAction? snackBarAction, Duration? duration}) {
    duration ??= const Duration(milliseconds: 4000);
    SnackBar snackBar = SnackBar(
      duration: duration,
      content: Text(text),
      action: snackBarAction,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    return snackBar;
  }

  static String formatDate(DateTime date) {
    return DateFormat("dd/MM/yyyy").format(date);
  }

  static Future<DateTime?> selectDate(BuildContext context,
      DateTime selectedDate, TextEditingController dateController,
      {void Function()? setState}) async {
    final DateTime? dateTime = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2020),
        lastDate: DateTime(2050),
        initialDatePickerMode: DatePickerMode.day);
    if (dateTime != null) {
      selectedDate = dateTime;
      dateController.text = DateFormat("dd/MM/yyyy").format(selectedDate);
      if (setState != null) {
        setState();
      }
      return selectedDate;
    }
    return null;
  }
}
