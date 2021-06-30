
import 'dart:io';

import 'package:flutter_chat_ui_starter/services/alertsUsingToast.dart';
import 'package:flutter_document_picker/flutter_document_picker.dart';

Future<File> pickFile()async{
  final path = await FlutterDocumentPicker.openDocument();
if(path != null) {
   File file = File(path);
   print(file.path);
   return file;
} else {
   alertToast("no file picked");
   return null;
}
}