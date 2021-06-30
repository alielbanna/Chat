import 'package:flutter/material.dart';

class SnackBarService {
  SnackBarService() {}

  BuildContext context;
  static SnackBarService instance = SnackBarService();

  set buildContext(BuildContext buildContext) {
    context = buildContext;
  }

  void showSnackBarError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        message,
        style: TextStyle(
          color: Colors.white,
          fontSize: 15.0,
        ),
      ),
      backgroundColor: Colors.red,
      duration: Duration(
        seconds: 2,
      ),
    ));
  }

  void showSnackBarSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        message,
        style: TextStyle(
          color: Colors.white,
          fontSize: 15.0,
        ),
      ),
      backgroundColor: Colors.green,
      duration: Duration(
        seconds: 2,
      ),
    ));
  }
}
