
import 'dart:io';

import 'package:flutter_document_picker/flutter_document_picker.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

Future<File> pickFile()async{
  final path = await FlutterDocumentPicker.openDocument();
if(path != null) {
   File file = File(path);
   print(file.path);
   return file;
} else {
   EasyLoading.showInfo("no file picked",duration: Duration(milliseconds: 800));
   return null;
}
}