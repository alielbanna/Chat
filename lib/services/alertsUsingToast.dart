
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

Future alertToast(String message) {
  return Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Color(0xff222222),
        textColor: Colors.white,
        fontSize: 16.0
    );
}