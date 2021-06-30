import 'package:flutter_chat_ui_starter/services/alertsUsingToast.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class MediaService {
  static MediaService instance = MediaService();
  Future<File> getImageFromLibrary() async {
    final pickedFile =
        await ImagePicker().getImage(source: ImageSource.gallery);
    if (pickedFile == null) {
      alertToast("you don't picked any Image");
      return null;
    }else{
    final File file = File(pickedFile.path);
    alertToast("Image Picked Successfully");
    return file;
    }
  }
}
