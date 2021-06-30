import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui_starter/models/chat.dart';
import 'package:flutter_chat_ui_starter/providers/auth_provider.dart';
import 'package:flutter_chat_ui_starter/screens/Media.dart';
import 'package:provider/provider.dart';
import 'package:flutter_chat_ui_starter/models/contact.dart';
import 'package:flutter_chat_ui_starter/services/database_service.dart';

// ignore: must_be_immutable
class ChatInformation extends StatefulWidget {
  String chatID;
  String chatImage;
  String chatName;
  String chatAdminName;

  ChatInformation({this.chatID, this.chatImage, this.chatName , this.chatAdminName});

  @override
  _ChatInformationState createState() => _ChatInformationState();
}

class _ChatInformationState extends State<ChatInformation> {
  bool enabled = false;
  String chatAdminName = "";
  String chatAdminImage = "";
  @override
  void initState() {
    FirebaseFirestore.instance.collection("Chats").doc(widget.chatID).get().then((value){
      chatAdminName = value["admin"];
      FirebaseFirestore.instance.collection("Users").where("name", isEqualTo: value["admin"]).get().then((user){
        setState(() {
          chatAdminImage = user.docs[0]["image"];
        });
      });
    });
    super.initState();
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
              return StreamBuilder<Chat>(
                stream: DatabaseService.instance.getChat(this.widget.chatID),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(
                        backgroundColor: Colors.lightBlueAccent,
                      ),
                    );
                  }
                  var chatData = snapshot.data;

                  return SingleChildScrollView(
                      child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Theme.of(context).accentColor,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(15.0),
                              bottomRight: Radius.circular(15.0),
                            ),
                          ),
                          //height: 170.0,
                          width: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 60.0,
                                backgroundImage:
                                    NetworkImage(this.widget.chatImage),
                              ),
                              SizedBox(
                                height: 10.0,
                              ),
                              Text(
                                this.widget.chatName,
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
                          child: Container(
                            child: Column(
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.person,
                                      color: Colors.grey,
                                      size: 27.0,
                                    ),
                                    SizedBox(
                                      width: 10.0,
                                    ),
                                    Text(
                                      'Course Professor',
                                      style: TextStyle(
                                        fontSize: 19.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    ],
                                    ),
                              
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: 5.0,
                                    ),
                                    personInfo(chatAdminImage, chatAdminName)
                                  ],
                            ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(bottom:10.0 , left: 20,right: 20),
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.group,
                                    color: Colors.grey,
                                    size: 27.0,
                                  ),
                                  SizedBox(
                                    width: 10.0,
                                  ),
                                  Text(
                                        'Students',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 19.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      ],
                              ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height:10),
                                      Padding(
                                        padding: EdgeInsets.only(
                                          top: 5.0,
                                        ),
                                        child: Container(
                                          //height: MediaQuery.of(context).size.height * 0.45,
                                          width:
                                              MediaQuery.of(context).size.width ,
                                          child: ListView.builder(
                                            shrinkWrap: true,
                                            physics: NeverScrollableScrollPhysics(),
                                            itemCount: chatData.members.length,
                                            itemBuilder:
                                                (BuildContext context, int _index) {
                                              var _members = chatData.members[_index];

                                              return StreamBuilder<Contact>(
                                                  stream: DatabaseService.instance
                                                      .getUserData(_members),
                                                  builder: (context, snapshot) {
                                                    var _member = snapshot.data;

                                                    return _member != null
                                                        ? personInfo(_member.image, _member.fullName)
                                                        : Container();
                                                  });
                                            },
                                          ),
                                        ),
                                      ),
                                      SizedBox(height:5),
                                    ],
                                  ),
                                ],
                              ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
  Widget personInfo(String imageurl , String fullName){
    return Container(
      height: 60,
      width: MediaQuery.of(context).size.width*0.9,
      padding: EdgeInsets.only(right:5 , left:5 , top:10 , bottom:10),
      child: Row(
        children: [
         imageurl != null ?  ClipRRect(
          borderRadius: BorderRadius.circular(20),  
          child: Image(image: NetworkImage(imageurl),width: 40,height: 40,fit: BoxFit.cover,)):Container(),
          SizedBox(width:10),
          Container(
            width:MediaQuery.of(context).size.width*0.55,
              child: Text(
              fullName,
              style: TextStyle(
                fontSize: 16.0,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],       
      ),
    );
  }
}
