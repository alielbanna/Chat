import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:path/path.dart';

class CloudStorageService {
  CloudStorageService() {
    storage = FirebaseStorage.instance;
    _baseRef = storage.ref();
  }

  static CloudStorageService instance = CloudStorageService();
  FirebaseStorage storage;
  Reference databaseReference;

  String _messages = 'messages';
  String _images = 'images';

  Reference _baseRef;

  Future<TaskSnapshot> uploadMediaMessage(String _uid, File _file) {
    var _time = DateTime.now();
    var _fileName = basename(_file.path);
    _fileName += "_${_time.toString()}";
    try {
      UploadTask uploadTask = _baseRef
          .child(_messages)
          .child(_uid)
          .child(_images)
          .child("$_fileName.m4a")
          .putFile(_file);
          
           EasyLoading.show(status: "uploading ...");
      return uploadTask;
    } catch (e) {}
  }
}
