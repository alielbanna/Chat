import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_chat_ui_starter/providers/auth_provider.dart';
import 'package:flutter_chat_ui_starter/screens/photoView.dart';
import 'package:flutter_chat_ui_starter/services/alertsUsingToast.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:flutter_chat_ui_starter/models/contact.dart';
import 'package:flutter_chat_ui_starter/services/database_service.dart';

import '../services/cloud_storage_service.dart';
import '../services/database_service.dart';
import '../services/media_service.dart';

class ProfileScreen extends StatefulWidget {
  static const String id = 'profile_screen';
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isSwitched = false;
  File image;
  AuthProvider _auth;
  bool enabled = false;

  showAlertDialog(BuildContext context) {
    // set up the button
    Widget yesButton = TextButton(
      child: Text(
        'Yes',
        style: TextStyle(color: Colors.blue),
      ),
      onPressed: () {
        _auth.logoutUser(() {});
      },
    );
    Widget noButton = TextButton(
      child: Text(
        'No',
        style: TextStyle(color: Colors.blue),
      ),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    AlertDialog alert = AlertDialog(
      title: Text('Do you want to logout?'),
      content: Text('If you press \'Yes\', you will logout.'),
      actions: [
        yesButton,
        noButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Theme.of(context).accentColor,
        elevation: 0.0,
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      body: SafeArea(
        child: ChangeNotifierProvider<AuthProvider>.value(
          value: AuthProvider.instance,
          child: Builder(
            builder: (BuildContext context) {
              _auth = Provider.of<AuthProvider>(context);
              return StreamBuilder<Contact>(
                stream: DatabaseService.instance.getUserData(_auth.user.uid),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(
                        backgroundColor: Colors.lightBlueAccent,
                      ),
                    );
                  }
                  var userData = snapshot.data;
                  print(userData);
                  return Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).accentColor,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(15.0),
                            bottomRight: Radius.circular(15.0),
                          ),
                        ),
                        height: 170.0,
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    List<String> newUrlList = [userData.image];
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                PhotoViewCustom(
                                                    0, newUrlList, false)));
                                  },
                                  child: Hero(
                                    tag: 'image',
                                    child: CircleAvatar(
                                      radius: 60.0,
                                      backgroundImage:
                                          NetworkImage(userData.image),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  child: GestureDetector(
                                    onTap: () {
                                      MediaService.instance
                                          .getImageFromLibrary()
                                          .then((_file) {
                                        if (_file != null) {
                                          EasyLoading.show(status: "uploading ...");
                                          CloudStorageService.instance
                                              .uploadMediaMessage(
                                                  _auth.user.uid, _file)
                                              .then((data) {
                                            data.ref
                                                .getDownloadURL()
                                                .then((_url) {
                                              DatabaseService.instance
                                                  .updateProfilePhoto(
                                                      _url, _auth.user.uid)
                                                  .whenComplete(() =>
                                                      EasyLoading.showSuccess('Success',duration: Duration(milliseconds: 800)));
                                            });
                                          });
                                        }
                                      });
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                          bottomRight: Radius.circular(80),
                                          bottomLeft: Radius.circular(80),
                                        ),
                                        color: Colors.black54,
                                      ),
                                      width: 120,
                                      height: 60,
                                      child: Icon(
                                        Icons.camera_alt,
                                        color: Colors.white,
                                        size: 28,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            Text(
                              userData.fullName ?? "",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          top: 20.0,
                          left: 20.0,
                          bottom: 20.0,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(25.0),
                                ),
                                color: Colors.red,
                              ),
                              child: Icon(
                                Icons.alternate_email_rounded,
                                color: Colors.white,
                                size: 27.0,
                              ),
                            ),
                            SizedBox(
                              width: 10.0,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Email',
                                  style: TextStyle(
                                    color: Colors.indigo,
                                    fontSize: 19.0,
                                  ),
                                ),
                                Text(userData.email ?? ""),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          left: 20.0,
                          bottom: 20.0,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(25.0),
                                ),
                                color: Colors.grey,
                              ),
                              child: Icon(
                                Icons.info_outline_rounded,
                                color: Colors.white,
                                size: 27.0,
                              ),
                            ),
                            SizedBox(
                              width: 10.0,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'About',
                                  style: TextStyle(
                                    color: Colors.indigo,
                                    fontSize: 19.0,
                                  ),
                                ),
                                Text(userData.about ?? ""),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 150.0,
                      ),
                      GestureDetector(
                        child: Container(
                          height: 50,
                          margin: EdgeInsets.symmetric(horizontal: 100.0),
                          decoration: BoxDecoration(
                            color: enabled == true
                                ? Theme.of(context).accentColor
                                : Theme.of(context).primaryColor,
                            border: Border.all(
                              color: Theme.of(context).accentColor,
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(15.0),
                            //color: Theme.of(context).accentColor,
                          ),
                          child: Center(
                            child: Text(
                              'Logout',
                              style: TextStyle(
                                  fontFamily: 'RobotoSlab',
                                  color: enabled == true
                                      ? Colors.white
                                      : Theme.of(context).accentColor,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            enabled = true;
                          });
                          showAlertDialog(context);
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
