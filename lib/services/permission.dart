import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission/permission.dart';
import 'package:system_settings/system_settings.dart';

Future<String> permissionVoice(context) async {
  var permissions =
      await Permission.requestPermissions([PermissionName.Microphone]);
  var permissionsStates =
      await Permission.getPermissionsStatus([PermissionName.Microphone]);
  print(permissionsStates[0].permissionStatus);
  if (permissionsStates[0].permissionStatus == PermissionStatus.allow) {
    return (permissionsStates[0].permissionStatus).toString();
  } else if (permissionsStates[0].permissionStatus == PermissionStatus.deny) {
    await Permission.requestPermissions([PermissionName.Microphone])
        .then((value) {
      return (value[0].permissionStatus).toString();
    });
  } else if (permissionsStates[0].permissionStatus ==
      PermissionStatus.notAgain) {
    showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
              title: Text('Microphone Permission'),
              content:
                  Text('This app needs microphone access to make a record '),
              actions: <Widget>[
                CupertinoDialogAction(
                  child: Text('Deny'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                CupertinoDialogAction(
                  child: Text('Settings'),
                  onPressed: () => SystemSettings.app(),
                ),
              ],
            ));
    var permissionsStates2 =
        await Permission.getPermissionsStatus([PermissionName.Microphone]);
    return (permissionsStates2[0].permissionStatus).toString();
  }
}

Future<String> permissionStorage(context) async {
  var permissions =
      await Permission.requestPermissions([PermissionName.Storage]);
  var permissionsStates =
      await Permission.getPermissionsStatus([PermissionName.Storage]);
  print(permissionsStates[0].permissionStatus);

  if (permissionsStates[0].permissionStatus == PermissionStatus.allow) {
    return (permissionsStates[0].permissionStatus).toString();
  } else if (permissionsStates[0].permissionStatus == PermissionStatus.deny) {
    await Permission.requestPermissions([PermissionName.Storage]).then((value) {
      return (value[0].permissionStatus).toString();
    });
  } else if (permissionsStates[0].permissionStatus ==
      PermissionStatus.notAgain) {
    showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
              title: Text('Storage Permission'),
              content: Text('This app needs storage access to get Documents '),
              actions: <Widget>[
                CupertinoDialogAction(
                  child: Text('Deny'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                CupertinoDialogAction(
                  child: Text('Settings'),
                  onPressed: () => SystemSettings.app(),
                ),
              ],
            ));
    var permissionsStates2 =
        await Permission.getPermissionsStatus([PermissionName.Storage]);
    return (permissionsStates2[0].permissionStatus).toString();
  }
}
