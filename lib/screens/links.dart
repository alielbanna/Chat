import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui_starter/services/alertsUsingToast.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:timeago/timeago.dart' as timeago;


class Links extends StatefulWidget{
  final String chatId;
  Links(this.chatId);
  @override
  _LinksState createState() => _LinksState();
}

class _LinksState extends State<Links> {
   List<String> times = [];
   List<String> messages = []; 
   List<String> senderId = []; 
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection("Chats").doc(widget.chatId).snapshots(),
      builder: (context , snapshot){
      switch (snapshot.connectionState) {
          case ConnectionState.waiting: return Center(
            child: Center(child: CircularProgressIndicator())
          );
          default:
          times = [];
          messages = [];
          senderId = [];
          List messegesData = snapshot.data["messages"];
          for (var i = 0; i < messegesData.length; i++) {
            String message = messegesData[i]["message"];
            if((message.contains("www") || message.contains("http")) && messegesData[i]["type"] == "text"){
            
            Timestamp time = messegesData[i]["time"];
            times.add(timeago.format(time.toDate()).toString());
            messages.add(messegesData[i]["message"]);
            senderId.add(messegesData[i]["senderID"]);
            }
            }
            print(messages);
            print(times);
          return Container(
         child:ListView.builder(
         shrinkWrap: true,
         itemCount: senderId.length,
          itemBuilder: (context, index){
            return MessageData(times[index], messages[index] , senderId[index]);
          },
          )
            );
            }
            }
    );
  }
  
    // (name , time , message , senderId)
}

class MessageData extends StatefulWidget{
  final String time;
  final String message;
  final String senderId;
  MessageData(this.time,this.message,this.senderId);

  @override
  _MessageDataState createState() => _MessageDataState();
}

class _MessageDataState extends State<MessageData> {
  @override
  void initState() {
    getName();
    super.initState();
  }
  String name = "";
  @override
  Widget build(BuildContext context) {
    return Container(
    margin: EdgeInsets.only(top:10,left:10,right: 10),
    padding: EdgeInsets.all(18),
    decoration: BoxDecoration(
    color: Colors.black12,
    borderRadius: BorderRadius.circular(10)
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$name",
          style: TextStyle(
            color: Theme.of(context).accentColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height:5),
        Text(
                    "${widget.time}",
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 12.0,
                    ),
        ),
        SizedBox(height:15),
        SelectableLinkify(
                      onOpen: (link) async {
                        if (await canLaunch(link.url)) {
                          await launch(link.url);
                        } else {
                          alertToast('Could not launch $link');
                        }
                      },
                      enableInteractiveSelection: false,
                      linkStyle: TextStyle(
                          color:
                               Colors.lightBlue[700]),
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15.0,
                      ),
                      text: widget.message,
                    ),
                    SizedBox(height:5),
      ],
    ),
 );
  }
  getName()async{
    FirebaseFirestore.instance.collection("Users").doc(widget.senderId).snapshots().listen((value) {
    FirebaseAuth.instance.currentUser.uid == widget.senderId ? name = "Me" : name = value["fullName"];
    setState(() {
      name = name;
    });
    });
  }
}