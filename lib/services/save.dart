import 'dart:io';
import 'dart:math';


import 'package:flowder/flowder.dart';
import 'package:flutter_chat_ui_starter/services/alertsUsingToast.dart';
import 'package:path_provider/path_provider.dart';

Future<String> getPathInExternalStorage() async {
  Directory tempDir = await getExternalStorageDirectory();
  String tempPath = tempDir.path;
  List<String> listTemp = tempPath.split("0/");
  String pictureTemp = "${listTemp[0]}0/";
  if(!(await Directory("$pictureTemp/Hager's App").exists())){
    createNewMediaFolder(pictureTemp);
  }
  return "$pictureTemp/Hager's App";
}

createNewMediaFolder(pictureTemp)async{
  Directory("$pictureTemp/Hager's App").create(recursive: true);
}

saveNetworkImage(String url) async {
  await getPathInExternalStorage().then((saveDir) async {
    try {
      final downloaderUtils = DownloaderUtils(
        progressCallback: (current, total) {
          final progress = (current / total) * 100;
          print('Downloading: $progress');
        },
        file: File('$saveDir/${Random().nextInt(100000000)}.jpeg'),
        progress: ProgressImplementation(),
        onDone: () => alertToast('Saved Successfully'),
        deleteOnCancel: true,
      );
      final core = await Flowder.download('$url', downloaderUtils);
    } catch (e) {
      
      alertToast("Check Network");
    }
  });
}

saveFile(String url , String ext) async {
  await getPathInExternalStorage().then((saveDir) async {
    try {
      alertToast('Please Wait a moment ...');
      final downloaderUtils = DownloaderUtils(
        progressCallback: (current, total) {
          final progress = (current / total) * 100;
          print('Downloading: $progress');
        },
        file: File('$saveDir/${DateTime.now()}.$ext'),
        progress: ProgressImplementation(),
        onDone: () => alertToast('Saved Successfully'),
        deleteOnCancel: true,
      );
      final core = await Flowder.download('$url', downloaderUtils);
    } catch (e) {
      print(e);
      alertToast("Check Network");
    }
  });
}
