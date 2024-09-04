import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class DisplayUtils {
  static void showErrorToast(String errorMessage) {
    Fluttertoast.showToast(
        msg: errorMessage,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red.shade400,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  static void showSuccessToast(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green.shade400,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  static void showWarningToast(String errorMessage) {
    Fluttertoast.showToast(
        msg: errorMessage,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.orange.shade400,
        textColor: Colors.white,
        fontSize: 16.0);
  }
}
