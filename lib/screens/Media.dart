import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui_starter/screens/photoView.dart';
import 'package:flutter_chat_ui_starter/services/permission.dart';
import 'package:flutter_chat_ui_starter/services/save.dart';

import 'audioPlayerScreen.dart';


class Media extends StatefulWidget{
  final String chatId;
  Media(this.chatId);
  @override
  _MediaState createState() => _MediaState();
}

class _MediaState extends State<Media> {
  List<String> listImages = [];
  List<String> listVoices = [];
  List<String> listDocs = [];
  List<String> listDocsExt = [];

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
          listImages = [];
          listVoices = [];
          listDocs = [];
          listDocsExt = [];
          List messeges = snapshot.data["messages"];
          for (var i = 0; i < messeges.length ; i++) {
            if(snapshot.data["messages"][i]["type"] == "doc"){
              listDocs.add(snapshot.data["messages"][i]["message"]);
              listDocsExt.add(snapshot.data["messages"][i]["ext"]);
            }
            else if(snapshot.data["messages"][i]["type"] == "voice"){
              listVoices.add(snapshot.data["messages"][i]["message"]);
            }
            else if(snapshot.data["messages"][i]["type"] == "image"){
              listImages.add(snapshot.data["messages"][i]["message"]);
            }
          }
          return Directionality(
        textDirection: TextDirection.ltr,
            child: Container(
              padding: EdgeInsets.all(15),
             child:ListView(
               shrinkWrap: true,
                children: <Widget>[
                  Container(
                margin: EdgeInsets.symmetric(vertical:10),
              child: Text("Images", style: TextStyle(color: Theme.of(context).accentColor , fontSize: 16 , fontWeight: FontWeight.bold),)),
                GridView.builder(
              physics: NeverScrollableScrollPhysics(),
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemBuilder: (context , index){
                return GestureDetector(
                  onTap:(){
                    Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => PhotoViewCustom(index ,listImages , true)));
                  },      
                  child:viewSources(listImages[index] ,"image")  
                );
              },
              gridDelegate:SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
              itemCount: listImages.length,
              ),

              Container(
                margin: EdgeInsets.symmetric(vertical:10),
              child: Text("voices", style: TextStyle(color: Theme.of(context).accentColor , fontSize: 16 , fontWeight: FontWeight.bold),)),
              GridView.builder(
              physics: NeverScrollableScrollPhysics(),
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemBuilder: (context , index){
                return GestureDetector(
                  onTap:(){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>AudioPlayerScreen(listVoices[index])));
                  },      
                  child:viewSources(listVoices[index] ,"voice")  
                );
              },
              gridDelegate:SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
              itemCount: listVoices.length,
              ),

              Container(
                margin: EdgeInsets.symmetric(vertical:10),
              child: Text("Documents", style: TextStyle(color: Theme.of(context).accentColor , fontSize: 16 , fontWeight: FontWeight.bold),)),
              GridView.builder(
              physics: NeverScrollableScrollPhysics(),
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemBuilder: (context , index){
                return GestureDetector(
                  onTap:(){
                    showDialog(
                  context: context,
                  builder: (BuildContext context) => CupertinoAlertDialog(
                        title: Text('Download Folder'),
                        content: Text(
                            'Do you want to Download this file ?'),
                        actions: <Widget>[
                          CupertinoDialogAction(
                            child: Text('Cancel'),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          CupertinoDialogAction(
                            child: Text('Save'),
                            onPressed: () { 
                              permissionStorage(context).then((value) {
                                  if(value == "PermissionStatus.allow"){
                                  saveFile(listDocs[index], listDocsExt[index]);
                              }
                            });},
                          ),
                        ],
                      ));
                  },      
                  child:viewSources(listDocs[index] ,"doc" , ext: listDocsExt[index])  
                );
              },
              gridDelegate:SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
              itemCount: listDocs.length,
              ) 
              
              
              ],)
              ),
          );
      }}
    );
  }
  Widget viewSources(String url , String type , {String ext}){
  return type == "image"? Container(
          margin: EdgeInsets.all(1.0),
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: NetworkImage(url), fit: BoxFit.fill))) : 
                        type == "voice"? Container(
                          alignment: Alignment.center,
                          margin: EdgeInsets.all(1.0),
                          color: Theme.of(context).accentColor,
                          child: Icon(Icons.music_note , color: Colors.white , size: 40,),
                        ):Container(
                          alignment: Alignment.center,
                          margin: EdgeInsets.all(1.0),
                          padding: EdgeInsets.all(9),
                          color: Theme.of(context).accentColor,
                          child: Text("$ext", style: TextStyle(color: Colors.white , fontSize: 13 , fontWeight: FontWeight.bold),)
                        );

}
}