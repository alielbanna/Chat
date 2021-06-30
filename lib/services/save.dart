import 'dart:io';
import 'dart:math';


import 'package:flowder/flowder.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
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
          final progress = (current / total);
          print('Downloading: $progress');
          EasyLoading.showProgress(progress , status: "Downloading ...");
        },
        file: File('$saveDir/${Random().nextInt(100000000)}.jpeg'),
        progress: ProgressImplementation(),
        onDone: () => EasyLoading.showSuccess('Saved Successfully',duration: Duration(milliseconds: 800)),
        deleteOnCancel: true,
      );
      final core = await Flowder.download('$url', downloaderUtils);
    } catch (e) {
      EasyLoading.showInfo('Check Network',duration: Duration(milliseconds: 800));
    }
  });
}

saveFile(String url , String ext) async {
  await getPathInExternalStorage().then((saveDir) async {
    try {
      //EasyLoading.show(status: "Uploading ...");
      final downloaderUtils = DownloaderUtils(
        progressCallback: (current, total) {
          final progress = (current / total);
          EasyLoading.showProgress(progress , status: "Downloading ...");
          print('Downloading: $progress');
        },
        file: File('$saveDir/${DateTime.now()}.$ext'),
        progress: ProgressImplementation(),
        onDone: () => EasyLoading.showSuccess('Saved Successfully',duration: Duration(milliseconds: 800)),
        deleteOnCancel: true,
      );
      final core = await Flowder.download('$url', downloaderUtils);
    } catch (e) {
      print(e);
      EasyLoading.showInfo('Check Network',duration: Duration(milliseconds: 800));
    }
  });
}
