import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui_starter/models/chat.dart';
import 'package:flutter_chat_ui_starter/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_chat_ui_starter/services/database_service.dart';

// ignore: must_be_immutable
class SeenMessages extends StatefulWidget {
  String message;
  int index;
  String chatId;
  int len;
  SeenMessages({this.message,this.index,this.chatId,this.len});

  @override
  _SeenMessagesState createState() => _SeenMessagesState();
}

class _SeenMessagesState extends State<SeenMessages> {
  bool enabled = false;
  List<String> listSeen = [];
  List<String> listImages = [];
  List<String> listNames = [];
  var myId = FirebaseAuth.instance.currentUser.uid;
  @override
  void initState() {
    FirebaseFirestore.instance.collection("Chats").doc(widget.chatId).collection("seen").doc("main").get().then((value){
      if(value.data().containsKey("seenMessage")){
        Map<String , int> seen = Map.from(value["seenMessage"]);
        seen.forEach((key, value) {

          print(widget.len - widget.index -1);
          if (value >= widget.len - widget.index -1) {
             FirebaseFirestore.instance.collection("Users").doc(key).get().then((user){
               listSeen.add(key);
               listImages.add(user["image"]);
               listNames.add(user["name"]);
               setState(() {
               });
          });
          }
        });
      }
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
                stream: DatabaseService.instance.getChat(this.widget.chatId),
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
                        
                        
                        SizedBox(height: 20,),
                        Padding(
                          padding: EdgeInsets.only(bottom:10.0 , left: 20,right: 20),
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.remove_red_eye,
                                    color: Colors.grey,
                                    size: 27.0,
                                  ),
                                  SizedBox(
                                    width: 10.0,
                                  ),
                                  Text(
                                        'Seen',
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
                                            itemCount: (listSeen.length) ?? 0,
                                            itemBuilder:
                                                (BuildContext context, int _index) {
                                              return personInfo(listImages[_index], listNames[_index]);
                                                    
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
    print(imageurl);
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
