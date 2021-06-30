import 'dart:async';
import 'dart:io';
import 'package:clipboard/clipboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flui/flui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui_starter/models/chat.dart';
import 'package:flutter_chat_ui_starter/models/message.dart';
import 'package:auto_direction/auto_direction.dart';
import 'package:flutter_chat_ui_starter/providers/auth_provider.dart';
import 'package:flutter_chat_ui_starter/screens/chat_information.dart';
import 'package:flutter_chat_ui_starter/screens/photoView.dart';
import 'package:flutter_chat_ui_starter/screens/seen.dart';
import 'package:flutter_chat_ui_starter/services/audio.dart';
import 'package:flutter_chat_ui_starter/services/cloud_storage_service.dart';
import 'package:flutter_chat_ui_starter/services/database_service.dart';
import 'package:flutter_chat_ui_starter/services/files.dart';
import 'package:flutter_chat_ui_starter/services/navigation_service.dart';
import 'package:flutter_chat_ui_starter/services/permission.dart';
import 'package:flutter_chat_ui_starter/services/save.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:provider/provider.dart';
import 'package:flutter_chat_ui_starter/services/media_service.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/cloud_storage_service.dart';
import '../services/database_service.dart';
import 'Media.dart';
import 'links.dart';

// ignore: must_be_immutable
class ChatScreen extends StatefulWidget {
  static const String id = 'chat_screen';

  String chatID;
  String receiverID;
  String chatImage;
  String chatName;


  
  ChatScreen({this.chatID, this.receiverID, this.chatImage, this.chatName});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  int selectedIndex = 0;
  final List<String> media = ['Chat', 'Media', "links"];
  final messageTextController = TextEditingController();
  AuthProvider _auth;
  String messageText;
  bool recording = false;

  bool isRTL = false;
  String text = '';
  Timer timer;
  int timerForRecordSeconds = 0;
  int timerForRecordMinutes = 0;
  
  PageController pageViewController = PageController();

  Widget generateItem(String imageURL) {
    DecorationImage _image =
        DecorationImage(image: NetworkImage(imageURL), fit: BoxFit.cover);
    return Padding(
      padding: EdgeInsets.all(3.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
          color: Color(0xFF125589),
        ),
        padding: EdgeInsets.all(3.0),
        child: Container(
          height: 160.0,
          width: 121.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            image: _image,
          ),
        ),
      ),
    );
  }

  List<Widget> imageContainerList(int count, String imageURL) {
    List<Widget> items = [];
    for (int i = 0; i < count; i++) {
      items.add(generateItem(imageURL));
    }
    return items;
  }

  _buildMessage(String message, bool isMe, Timestamp time, String sender , int index , int len) {
    return FLBubbleMenuWidget(
      itemBuilder: (BuildContext context) {
      return isMe ? [
        FLBubbleMenuItem(
          text: 'Delete',
          value: 'Delete',
        ),
        FLBubbleMenuItem(
          text: 'Copy',
          value: 'Copy',
        ),
        FLBubbleMenuItem(
          text: 'Seen',
          value: 'Seen',
        ),
      ]:[
        FLBubbleMenuItem(
          text: 'Copy',
          value: 'Copy',
        ),
        FLBubbleMenuItem(
          text: 'Seen',
          value: 'Seen',
        ),
      ];
    },
    onSelected: (value) {
      if (value == "Delete") {
        var _ref = FirebaseFirestore.instance.collection("Chats").doc(widget.chatID);
        _ref.update({
          'messages': FieldValue.arrayRemove([
          {
            'message': message,
            'senderID': sender,
            'time': time,
            'type': "text",
          },
        ],)
        }).then((value) => EasyLoading.showSuccess("Deleted Successfully",duration: Duration(milliseconds: 800)));
      }else if(value == "Copy"){
        FlutterClipboard.copy('$message').then(( value ) => EasyLoading.showSuccess("Copied" , duration: Duration(milliseconds: 500)));
      }else if(value == "Seen"){
        Navigator.push(context, MaterialPageRoute(builder: (context)=> SeenMessages(
          message: message,
          index: index,
          chatId: widget.chatID,
          len: len,
        )));
      }
    },
      child: InkWell(
        onTap: (){          
        },
        child: StreamBuilder(
          stream: DatabaseService.instance.getUserData(sender),
          builder: (_context, _snapshot) {
            var _data = _snapshot.data;
      
            return Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    color: isMe ? Theme.of(context).accentColor : Color(0xFFF3F7FA),
                  ),
                  margin: isMe
                      ? EdgeInsets.only(
                          left: 150.0,
                          right: 20.0,
                          top: 10.0,
                          bottom: 10.0,
                        )
                      : EdgeInsets.only(
                          right: 150.0,
                          left: 20.0,
                          top: 10.0,
                          bottom: 10.0,
                        ),
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      isMe
                          ? Container(
                              width: 0.0,
                            )
                          : Text(
                              _data != null ? _data.name : '',
                              style: TextStyle(
                                fontSize: 15.0,
                                color: Colors.indigoAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                      SizedBox(
                        height: 2.0,
                      ),
                      AutoDirection(
                        onDirectionChange: (isRTL) {
                          setState(() {
                            this.isRTL = isRTL;
                          });
                        },
                        text: message,
                        child: SelectableLinkify(
                          onOpen: (link) async {
                            if (await canLaunch(link.url)) {
                              await launch(link.url);
                            } else {
                              EasyLoading.showError('Could not launch $link',duration: Duration(milliseconds: 500));
                            }
                          },
                          enableInteractiveSelection: false,
                          linkStyle: TextStyle(
                              color:
                                  isMe ? Colors.cyan[200] : Colors.lightBlue[700]),
                          style: TextStyle(
                            color: isMe ? Colors.white : Colors.black,
                            fontSize: 15.0,
                          ),
                          text: message,
                        ),
      // Text(
      //                       message,
      //                       style: TextStyle(
      //                         color: isMe ? Colors.white : Colors.black,
      //                         fontSize: 15.0,
      //                       ),
      //                     ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: isMe
                      ? EdgeInsets.only(
                          left: 150.0,
                          right: 20.0,
                        )
                      : EdgeInsets.only(
                          right: 150.0,
                          left: 20.0,
                        ),
                  child: Row(
                    mainAxisAlignment:
                        isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                    children: [
                      Text(
                        timeago.format(time.toDate()),
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 12.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

 _buildVoiceMessage(
      bool isMe, String voiceUrl, Timestamp time, String sender , int index , int len) {
    return FLBubbleMenuWidget(
      itemBuilder: (BuildContext context) {
      return isMe ? [
        FLBubbleMenuItem(
          text: 'Delete',
          value: 'Delete',
        ),
        FLBubbleMenuItem(
          text: 'Seen',
          value: 'Seen',
        ),
      ]:[
        FLBubbleMenuItem(
          text: 'Seen',
          value: 'Seen',
        ),
      ];
    },
    onSelected: (value) {
      if (value == "Delete") {
        var _ref = FirebaseFirestore.instance.collection("Chats").doc(widget.chatID);
        _ref.update({
          'messages': FieldValue.arrayRemove([
          {
            'message': voiceUrl,
            'senderID': sender,
            'time': time,
            'type': "voice",
          },
        ],)
        }).then((value) => EasyLoading.showSuccess("Deleted Successfully",duration: Duration(milliseconds: 800)));
      }else if(value == "Seen"){
        Navigator.push(context, MaterialPageRoute(builder: (context)=> SeenMessages(
          message: voiceUrl,
          index: index,
          chatId: widget.chatID,
          len: len,
        )));
      }
    },
      child: InkWell(
        child: StreamBuilder(
          stream: DatabaseService.instance.getUserData(sender),
          builder: (_context, _snapshot) {
            var _data = _snapshot.data;
            return Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    color: isMe ? Theme.of(context).accentColor : Color(0xFFF3F7FA),
                  ),
                  margin: isMe
                      ? EdgeInsets.only(
                          left: 100.0,
                          right: 20.0,
                          top: 10.0,
                          bottom: 10.0,
                        )
                      : EdgeInsets.only(
                          right: 100.0,
                          left: 20.0,
                          top: 10.0,
                          bottom: 10.0,
                        ),
                  padding: EdgeInsets.all(3.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          isMe
                              ? Container(
                                  width: 0.0,
                                )
                              : Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Text(
                                    _data != null ? _data.name : '',
                                    style: TextStyle(
                                      fontSize: 15.0,
                                      color: Colors.indigoAccent,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                          Container(
                            height: 60,
                            width: MediaQuery.of(context).size.width * 0.80,
                            child: AudioPlayerCustom(voiceUrl , isMe),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: isMe
                      ? EdgeInsets.only(
                          left: 150.0,
                          right: 20.0,
                        )
                      : EdgeInsets.only(
                          right: 150.0,
                          left: 20.0,
                        ),
                  child: Row(
                    mainAxisAlignment:
                        isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                    children: [
                      Text(
                        timeago.format(time.toDate()),
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 12.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
  
  
  

  _buildImageMessage(
      bool isMe, String imageURL, Timestamp time, String sender,int index, int len) {
    DecorationImage _image =
        DecorationImage(image: NetworkImage(imageURL), fit: BoxFit.cover);
    return FLBubbleMenuWidget(
      itemBuilder: (BuildContext context) {
      return isMe ? [
        FLBubbleMenuItem(
          text: 'Delete',
          value: 'Delete',
        ),
        FLBubbleMenuItem(
          text: 'Seen',
          value: 'Seen',
        ),
      ]:[
        FLBubbleMenuItem(
          text: 'Seen',
          value: 'Seen',
        ),
      ];
    },
    onSelected: (value) {
      if (value == "Delete") {
        var _ref = FirebaseFirestore.instance.collection("Chats").doc(widget.chatID);
        _ref.update({
          'messages': FieldValue.arrayRemove([
          {
            'message': imageURL,
            'senderID': sender,
            'time': time,
            'type': "image",
          },
        ],)
        }).then((value) => EasyLoading.showSuccess("Deleted Successfully",duration: Duration(milliseconds: 800)));
      }else if(value == "Seen"){
        Navigator.push(context, MaterialPageRoute(builder: (context)=> SeenMessages(
          message: imageURL,
          index: index,
          chatId: widget.chatID,
          len: len,
        )));
      }
    },
      child: InkWell(
        child: StreamBuilder(
          stream: DatabaseService.instance.getUserData(sender),
          builder: (_context, _snapshot) {
            var _data = _snapshot.data;
            return Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    color: isMe ? Theme.of(context).accentColor : Color(0xFFF3F7FA),
                  ),
                  margin: isMe
                      ? EdgeInsets.only(
                          left: 150.0,
                          right: 20.0,
                          top: 10.0,
                          bottom: 10.0,
                        )
                      : EdgeInsets.only(
                          right: 150.0,
                          left: 20.0,
                          top: 10.0,
                          bottom: 10.0,
                        ),
                  padding: EdgeInsets.all(3.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          isMe
                              ? Container(
                                  width: 0.0,
                                )
                              : Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Text(
                                    _data != null ? _data.name : '',
                                    style: TextStyle(
                                      fontSize: 15.0,
                                      color: Colors.indigoAccent,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                          GestureDetector(
                            onTap: () {
                              List<String> newUrlList = [imageURL];
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          PhotoViewCustom(0, newUrlList, true)));
                            },
                            child: Container(
                              height: MediaQuery.of(context).size.height * 0.30,
                              width: MediaQuery.of(context).size.width * 0.40,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                image: _image,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: isMe
                      ? EdgeInsets.only(
                          left: 150.0,
                          right: 20.0,
                        )
                      : EdgeInsets.only(
                          right: 150.0,
                          left: 20.0,
                        ),
                  child: Row(
                    mainAxisAlignment:
                        isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                    children: [
                      Text(
                        timeago.format(time.toDate()),
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 12.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  _buildMessageComposer() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: AutoDirection(
              onDirectionChange: (isRTL) {
                setState(() {
                  this.isRTL = isRTL;
                });
              },
              text: text,
              child: recording ? Container(
                padding: EdgeInsets.only(left: 10.0),
                margin: EdgeInsets.only(left: 11.0, top: 11.0, bottom: 11.0),
                decoration: BoxDecoration(
                  color: Color(0xFFF3F7FA),
                  border: Border.all(color: Theme.of(context).accentColor),
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lens , color: Colors.red, size: 20,),
                      SizedBox(width:10),
                      Text(timerForRecordSeconds < 10 && timerForRecordMinutes <10?
                      "0$timerForRecordMinutes:0$timerForRecordSeconds" :
                      timerForRecordSeconds < 10 && timerForRecordMinutes >10?
                      "$timerForRecordMinutes:0$timerForRecordSeconds" :
                      timerForRecordSeconds >= 10 && timerForRecordMinutes <10?
                      "0$timerForRecordMinutes:$timerForRecordSeconds":
                      "$timerForRecordMinutes:$timerForRecordSeconds"
                      , style: TextStyle(fontSize: 18),),
                      SizedBox(width:15),
                    ],
                  ) ,
                )
              ):Container(
                padding: EdgeInsets.only(left: 10.0),
                margin: EdgeInsets.only(left: 11.0, top: 11.0, bottom: 11.0),
                decoration: BoxDecoration(
                  color: Color(0xFFF3F7FA),
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
                child: Padding(
                  padding: EdgeInsets.all(7.5),
                  child: TextField(
                    controller: messageTextController,
                    onChanged: (value) {
                      setState(() {
                        text = value;
                      });
                    },
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                    cursorColor: Colors.blueGrey,
                    decoration: InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      hintText: 'Type a message',
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(
              //right: 11.0,
              top: 11.0,
              bottom: 11.0,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(10.0),
                bottomRight: Radius.circular(10.0),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.only(bottom:10.0, left: 10),
              child: GestureDetector(
                child: Icon(
                  Icons.camera_alt_rounded,
                  size: 24.0,
                  color: Theme.of(context).accentColor,
                ),
                onTap: () async {
                  var _image =
                      await MediaService.instance.getImageFromLibrary();
                  if (_image != null) {
                    var _result = await CloudStorageService.instance
                        .uploadMediaMessage(_auth.user.uid, _image);
                    var _imageURL = await _result.ref.getDownloadURL();
                    await DatabaseService.instance.sendMessage(
                      this.widget.chatID,
                      Message(
                          message: _imageURL,
                          senderID: _auth.user.uid,
                          time: Timestamp.now(),
                          type: MessageType.Image),
                    );
                    EasyLoading.dismiss();
                    await DatabaseService.instance.updateSeenMessage(widget.chatID,_auth.user.uid);
                  }
                },
              ),
            ),
          ),
           Container(
            margin: EdgeInsets.only(
              //right: 11.0,
              top: 11.0,
              bottom: 11.0,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(10.0),
                bottomRight: Radius.circular(10.0),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.only(bottom:10.0, left: 10),
              child: GestureDetector(
                child: Icon(
                  Icons.mic,
                  size: 24.0,
                  color: Theme.of(context).accentColor,
                ),
                onLongPressStart: (l)  {
                  permissionVoice(context).then((value) {
                    if(value == "PermissionStatus.allow"){
                    startRecording();
                      timer = Timer.periodic(Duration(seconds: 1), (timer) {
                        setState(() {
                          if(timerForRecordSeconds < 60){
                          timerForRecordSeconds = timerForRecordSeconds + 1 ;
                          }else{
                          timerForRecordSeconds = 0;
                           timerForRecordMinutes = timerForRecordMinutes + 1;
                          }
                        });
                      });
                      setState(() {
                        recording = true;
                      });
                    }else{
                       EasyLoading.showInfo("please allow access to microphone",duration: Duration(milliseconds: 800));
                      }
                  });
                },
                onLongPressEnd: (l){
                   int lastTime = timer.tick.toInt();
                   permissionVoice(context).then((value) {
                    if(value == "PermissionStatus.allow"){
                     stopRecording().then((path) {
                       setState(() {
                        recording = false;
                        timer.cancel();
                        timerForRecordSeconds = 0;
                        timerForRecordMinutes = 0;
                      });
                      if(lastTime>1){
                      
                      CloudStorageService.instance.uploadMediaMessage(_auth.user.uid, File(path)).then((value) {
                        value.ref.getDownloadURL().then((urlVoice) {
                          DatabaseService.instance.sendMessage(
                          this.widget.chatID,
                           Message(
                           message: urlVoice,
                           time: Timestamp.now(),
                           senderID: _auth.user.uid,
                           type: MessageType.Voice,
                           ),
                          );
                          DatabaseService.instance.updateSeenMessage(widget.chatID,_auth.user.uid);
                        });
                        EasyLoading.dismiss();
                      });
                     }
                     });
                     
                     
                      }
                  });
                },
              ),
            ),
          ),
           Container(
            margin: EdgeInsets.only(
              //right: 11.0,
              top: 11.0,
              bottom: 11.0,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(10.0),
                bottomRight: Radius.circular(10.0),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.only(bottom:10.0, left: 10),
              child: GestureDetector(
                child: Icon(
                  Icons.attachment,
                  size: 24.0,
                  color: Theme.of(context).accentColor,
                ),
                onTap: (){
                  permissionStorage(context).then((value) {
                  if(value == "PermissionStatus.allow"){
                  pickFile().then((file) {
                    String pth = file.path;
                    List<String> listExtension = pth.split("/");
                    
                    CloudStorageService.instance.uploadMediaMessage(_auth.user.uid, file).then((value){
                      value.ref.getDownloadURL().then((urlDoc) {
                          DatabaseService.instance.sendMessage(
                          this.widget.chatID,
                           Message(
                           message: urlDoc,
                           time: Timestamp.now(),
                           senderID: _auth.user.uid,
                           type: MessageType.Doc,
                           ),
                           fileExt: "${listExtension[listExtension.length-1]}"
                          );
                          DatabaseService.instance.updateSeenMessage(widget.chatID,_auth.user.uid);
                        });
                        EasyLoading.dismiss();
                    });
                  });
                }else{
                  EasyLoading.showInfo("please allow access to Storage",duration: Duration(milliseconds: 800));
                }
                });
                }
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(top: 2.0),
            margin: EdgeInsets.only(top: 11.0, bottom: 11.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
            child: IconButton(
              icon: Icon(Icons.send_rounded),
              iconSize: 27.0,
              color: Theme.of(context).accentColor,
              onPressed: () {
                if (messageTextController.text.trim() != "") {
                    messageTextController.clear();
                DatabaseService.instance.sendMessage(
                  this.widget.chatID,
                  Message(
                    message: text,
                    time: Timestamp.now(),
                    senderID: _auth.user.uid,
                    type: MessageType.Text,
                  ),
                );
                DatabaseService.instance.updateSeenMessage(widget.chatID,_auth.user.uid);
                setState(() {
                  text = '';
                });
                }
              },
            ),
          ),
        ],
      ),
    );
  }
  @override
  void initState() {
    DatabaseService.instance.setCounterMessage(widget.chatID,FirebaseAuth.instance.currentUser.uid);
    DatabaseService.instance.setSeenMessage(widget.chatID,FirebaseAuth.instance.currentUser.uid);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Theme.of(context).accentColor,
        automaticallyImplyLeading: false,
        title: Padding(
          padding: EdgeInsets.only(top: 5.0),
          child: Container(
            child: Row(
              children: [
                GestureDetector(
                  child: Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    radius: 20.0,
                    backgroundImage: NetworkImage(this.widget.chatImage),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    NavigationService.instance.navigateToRoute(
                      MaterialPageRoute(
                        builder: (BuildContext _context) {
                          return ChatInformation(
                            chatID: this.widget.chatID,
                            chatImage: this.widget.chatImage,
                            chatName: this.widget.chatName,
                          );
                        },
                      ),
                    );
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: Text(
                      this.widget.chatName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // actions: [
        //   IconButton(
        //     icon: Icon(Icons.more_vert),
        //     iconSize: 40.0,
        //     color: Colors.white,
        //     onPressed: () {},
        //   ),
        // ],
      ),
      body: ChangeNotifierProvider<AuthProvider>.value(
        value: AuthProvider.instance,
        child: SafeArea(
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: SingleChildScrollView(
                child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).accentColor,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(15.0),
                        bottomRight: Radius.circular(15.0),
                      ),
                    ),
                    height: 70.0,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 3,
                      itemBuilder: (BuildContext context, int index) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedIndex = index;
                            });
                            pageViewController.animateToPage(index, duration: Duration(milliseconds: 500), curve: Curves.ease);
                          },
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: 8.5,
                              top: 17.0,
                              bottom: 13.0,
                              left: 8.5,
                            ),
                            child: Container(
                              width: MediaQuery.of(context).size.width*0.3 -5,
                              decoration: BoxDecoration(
                                color:
                                    index == selectedIndex ? Colors.white : null,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0)),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                media[index],
                                style: TextStyle(
                                    color: index == selectedIndex
                                        ? Color(0xFF125589)
                                        : Colors.white,
                                    fontSize: 17.0,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height*0.8,
                    child: PageView(
                      controller: pageViewController,
                      onPageChanged: (page){
                        setState(() {
                          selectedIndex = page;
                        });
                      },
                      children:[
                       Column(
                         children: [
                           Builder(
                             builder: (BuildContext _context) {
                               String ext = "";
                               _auth = Provider.of<AuthProvider>(_context);
                               return Expanded(
                                 child: StreamBuilder<Chat>(
                                   stream: DatabaseService.instance
                                       .getChat(this.widget.chatID),
                                   builder:
                                       (BuildContext _context, _snapshot) {
                                     var _chatData = _snapshot.data;
                                     if (_chatData != null) {
                                       return ListView.builder(
                                         reverse: true,
                                         shrinkWrap: true,
                                         itemCount: _chatData.messages.length,
                                         itemBuilder: (BuildContext context,
                                             int _index) {
                                           var reverse = List.from(
                                               _chatData.messages.reversed);
                                           var _message = reverse[_index];
                                           bool isMe = _message.senderID ==
                                               _auth.user.uid;
                                           
                                           return _message.type ==
                                                   MessageType.Text
                                               ? _buildMessage(
                                                   _message.message,
                                                   isMe,
                                                   _message.time,
                                                   _message.senderID,
                                                   _index,
                                                   _chatData.messages.length)
                                               :  _message.type == 
                                                   MessageType.Image
                                               ?_buildImageMessage(
                                                   isMe,
                                                   _message.message,
                                                   _message.time,
                                                   _message.senderID,
                                                   _index,
                                                   _chatData.messages.length):
                                                   _message.type == 
                                                   MessageType.Voice
                                               ? _buildVoiceMessage(
                                                   isMe,
                                                   _message.message,
                                                   _message.time,
                                                   _message.senderID,
                                                   _index,
                                                   _chatData.messages.length
                                                   ):BuildDocMessage(
                                                   isMe,
                                                   _message.message,
                                                   _message.time,
                                                   _message.senderID,
                                                   widget.chatID,
                                                   _index,
                                                   _chatData.messages.length
                                                   );
                                         },
                                       );
                                     } else {
                                       return Center(
                                         child: CircularProgressIndicator(
                                           backgroundColor:
                                               Theme.of(context).accentColor,
                                         ),
                                       );
                                     }
                                   },
                                 ),
                               );
                             },
                           ),
                           //TODO
                           StreamBuilder<Chat>(
                                   stream: DatabaseService.instance
                                       .getChat(this.widget.chatID),
                                   builder:
                                       (BuildContext _context, _snapshot) {
                                     var _chatData = _snapshot.data;
                                     if (_chatData != null) {
                                       return _chatData.adminId != FirebaseAuth.instance.currentUser.uid && _chatData.status == "false" ?
                                       Column(
                                         children: [
                                           SizedBox(height: 10,),
                                           Divider(height: 0,color: Colors.black12,thickness: 1),
                                           Container(
                                             height: 50,
                                             child: Center(child: Text("Chat is Locked by Group Admin",style: TextStyle(fontSize: 15 , fontWeight: FontWeight.w600 , color: Theme.of(context).accentColor),),),
                                           ),
                                         ],
                                       ):_buildMessageComposer();
                                     }else {
                                       return Center(
                                         child: CircularProgressIndicator(
                                           backgroundColor:
                                               Theme.of(context).accentColor,
                                         ),
                                       );
                                     }})
                         ],
                       ),
                         Media(widget.chatID),
                         Links(widget.chatID),
                      ]
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


class BuildDocMessage extends StatefulWidget{
    final String chatID;
    final bool isMe; 
    final String docUrl; 
    final Timestamp time; 
    final String sender ; 
    final int i;
    final int len;
    BuildDocMessage(this.isMe,this.docUrl,this.time,this.sender,this.chatID,this.i,this.len);

  @override
  _BuildDocMessageState createState() => _BuildDocMessageState();
}

class _BuildDocMessageState extends State<BuildDocMessage> {
  String ext = "";
  String tag = "";
  @override
  void initState() {
    getExt();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {

    return FLBubbleMenuWidget(
      itemBuilder: (BuildContext context) {
      return widget.isMe ? [
        FLBubbleMenuItem(
          text: 'Delete',
          value: 'Delete',
        ),
        FLBubbleMenuItem(
          text: 'Seen',
          value: 'Seen',
        ),
        FLBubbleMenuItem(
          text: 'Download',
          value: 'Download',
        ),
      ]:[
        FLBubbleMenuItem(
          text: 'Seen',
          value: 'Seen',
        ),
        FLBubbleMenuItem(
          text: 'Download',
          value: 'Download',
        ),
      ];
    },
    onSelected: (value) {
      if (value == "Delete") {
        var _ref = FirebaseFirestore.instance.collection("Chats").doc(widget.chatID);
        _ref.update({
          'messages': FieldValue.arrayRemove([
          {
            'message': widget.docUrl,
            'senderID': widget.sender,
            'time': widget.time,
            'type': "doc",
            'ext' : ext
          },
        ],)
        }).then((value) => EasyLoading.showSuccess("Deleted Successfully",duration: Duration(milliseconds: 800)));
      }else if(value == "Seen"){
        Navigator.push(context, MaterialPageRoute(builder: (context)=> SeenMessages(
          message: widget.docUrl,
          index: widget.i,
          chatId: widget.chatID,
          len: widget.len,
        )));
      }else if(value == "Download"){
        permissionStorage(context).then((value) {
          if(value == "PermissionStatus.allow"){
        saveFile(widget.docUrl , ext);
          }
          });
      }
    },
      child: InkWell(
        child: StreamBuilder(
          stream: DatabaseService.instance.getUserData(widget.sender),
          builder: (_context, _snapshot) {
            var _data = _snapshot.data;
            return Column(
              crossAxisAlignment:
                  widget.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    color: widget.isMe ? Theme.of(context).accentColor : Color(0xFFF3F7FA),
                  ),
                  margin: widget.isMe
                      ? EdgeInsets.only(
                          left: 80.0,
                          right: 20.0,
                          top: 10.0,
                          bottom: 10.0,
                        )
                      : EdgeInsets.only(
                          right: 80.0,
                          left: 20.0,
                          top: 10.0,
                          bottom: 10.0,
                        ),
                  padding: EdgeInsets.all(3.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          widget.isMe
                              ? Container(
                                  width: 0.0,
                                )
                              : Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Text(
                                    _data != null ? _data.name : '',
                                    style: TextStyle(
                                      fontSize: 15.0,
                                      color: Colors.indigoAccent,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                          GestureDetector(
                            onTap: () {
                              
                            },
                            child: Container(
                              padding: EdgeInsets.only(left:20 , right:10),
                              height: 70,
                              width: MediaQuery.of(context).size.width * 0.90,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    height: 50,
                                    width: MediaQuery.of(context).size.width*0.48,
                                    child: Text(
                                      "$ext",
                                      style: TextStyle(
                                        fontSize: 13.0,
                                        color: widget.isMe? Colors.white : Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.fade,
                                    ),
                                  ),
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    height: 50,
                                    width: MediaQuery.of(context).size.width*0.1,
                                    child: Text(
                                      "$tag",
                                      style: TextStyle(
                                        fontSize: 13.0,
                                        color: widget.isMe? Colors.white : Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.clip,
                                    ),
                                  ),
                                ],                            
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: widget.isMe
                      ? EdgeInsets.only(
                          left: 150.0,
                          right: 20.0,
                        )
                      : EdgeInsets.only(
                          right: 150.0,
                          left: 20.0,
                        ),
                  child: Row(
                    mainAxisAlignment:
                        widget.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                    children: [
                      Text(
                        timeago.format(widget.time.toDate()),
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 12.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  } 
  getExt(){    
    FirebaseFirestore.instance.collection("Chats").doc(widget.chatID).snapshots().listen((docData) {
    List docMesseges = docData["messages"];
    for (var i = 0; i < docMesseges.length; i++) {
      if(docMesseges[i]["type"]== "doc" && docMesseges[i]["time"] == widget.time){
        ext = docMesseges[i]["ext"];
        List<String> spl = ext.split(".");
        tag = spl[spl.length-1].toString();
        break;
      }
    }
    setState(() {
    });
    });
  }
}