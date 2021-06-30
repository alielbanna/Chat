import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:auto_direction/auto_direction.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui_starter/models/post.dart';
import 'package:flutter_chat_ui_starter/screens/chat_screen.dart';
import 'package:flutter_chat_ui_starter/screens/profile_screen.dart';
import 'package:flutter_chat_ui_starter/services/alertsUsingToast.dart';
import 'package:flutter_chat_ui_starter/services/navigation_service.dart';
import 'package:flutter_chat_ui_starter/widgets/category_selector.dart';
import 'package:flutter_chat_ui_starter/providers/auth_provider.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:flutter_chat_ui_starter/services/database_service.dart';

class HomeScreen extends StatefulWidget {
  static const String id = 'home_screen';
  final List<String> list = List.generate(10, (index) => 'Text $index');

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  AuthProvider _auth;
  String text = '';
  bool isRTL = false;
  final postTextController = TextEditingController();
  AudioPlayer audioPlayer = AudioPlayer();
  AudioCache audioCache = AudioCache();
  @override
      void initState() {
        super.initState();
    
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        if (message.data["senderId"] != FirebaseAuth.instance.currentUser.uid) {
          await audioCache.play("audio/sound.wav");
        }
    });
    FirebaseMessaging.onBackgroundMessage((message) async{
      Navigator.push(
                    NavigationService.instance.navigatorKey.currentState.context,
                    MaterialPageRoute(
                        builder: (context) => ChatScreen(
                             chatID: message.data["id"],
                             receiverID: message.data["id"],
                             chatImage: message.data["image"],
                             chatName: message.data["name"],
                            )));
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
            Navigator.push(
                    NavigationService.instance.navigatorKey.currentState.context,
                    MaterialPageRoute(
                        builder: (context) => ChatScreen(
                             chatID: message.data["id"],
                             receiverID: message.data["id"],
                             chatImage: message.data["image"],
                             chatName: message.data["name"],
                            )));
          
        });
      }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Container(
        child: SafeArea(
          child: Container(
            height: MediaQuery.of(context).size.height,
            child: NestedScrollView(
              physics: NeverScrollableScrollPhysics(),
              headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                return [
                  SliverOverlapAbsorber(
                    handle:
                        NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                    sliver: SliverAppBar(
                      automaticallyImplyLeading: false,
                      expandedHeight: 40.0,
                      backgroundColor: Theme.of(context).accentColor,
                      title: Text(
                        'UniChat',
                        style: TextStyle(
                          fontFamily: 'RobotoSlab',
                          fontSize: 28.0,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      elevation: 0.0,
                      actions: [
                        ChangeNotifierProvider<AuthProvider>.value(
                          value: AuthProvider.instance,
                          child: Builder(builder: (BuildContext context) {
                            _auth = Provider.of<AuthProvider>(context);
                            return StreamBuilder(
                                stream: DatabaseService.instance
                                    .getUserData(_auth.user.uid),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return Container(
                                      color: Theme.of(context).accentColor,
                                    );
                                  }
                                  var userData = snapshot.data;
                                  return Padding(
                                    padding: EdgeInsets.all(5.0),
                                    child: GestureDetector(
                                      child: Hero(
                                        tag: 'image',
                                        child: CircleAvatar(
                                          radius: 25.0,
                                          backgroundImage:
                                              NetworkImage(userData.image),
                                        ),
                                      ),
                                      onTap: () {
                                        Navigator.pushNamed(
                                            context, ProfileScreen.id);
                                      },
                                    ),
                                  );
                                });
                          }),
                        ),
                        SizedBox(
                          width: 10.0,
                        )
                      ],
                    ),
                  )
                ];
              },
              body: CategorySelector(),
            ),
          ),
        ),
      ),
      floatingActionButton: Container(
        height: 70.0,
        width: 70.0,
        child: FloatingActionButton(
          elevation: 0.0,
          child: Image.asset(
            'assets/images/icon.png',
            width: 30.0,
            height: 30.0,
          ),
          onPressed: () {
            showModalBottomSheet(
              isScrollControlled: true,
              context: context,
              builder: (builder) {
                return Container(
                  height: MediaQuery.of(context).size.height*0.2,
                  color: Colors
                      .transparent, //could change this to Color(0xFF737373),
                  //so you don't have to change MaterialApp canvasColor
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(10.0),
                            topRight: const Radius.circular(10.0))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Write a new post',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20.0),
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: AutoDirection(
                                onDirectionChange: (isRTL) {
                                  setState(() {
                                    this.isRTL = isRTL;
                                  });
                                },
                                text: text,
                                child: Container(
                                  //padding: EdgeInsets.all(10.0),
                                  margin: EdgeInsets.only(
                                    right: 10.0,
                                    left: 10.0,
                                    bottom: 10.0,
                                  ),
                                  decoration: BoxDecoration(
                                    //color: Color(0xFFF3F7FA),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10.0)),
                                  ),
                                  child: TextField(
                                    controller: postTextController,
                                    onChanged: (value) {
                                      setState(() {
                                        text = value;
                                      });
                                    },
                                    keyboardType: TextInputType.multiline,
                                    maxLines: 3,
                                    textCapitalization:
                                        TextCapitalization.sentences,
                                    cursorColor: Colors.blueGrey,
                                    decoration: InputDecoration(
                                      isDense: true,
                                      border: InputBorder.none,
                                      hintText: 'Type something',
                                      hintStyle: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).accentColor,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0)),
                                ),
                                alignment: Alignment.center,
                                child: GestureDetector(
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Text(
                                      'Post',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 17.0,
                                      ),
                                    ),
                                  ),
                                  onTap: () {
                                    if(postTextController.text.trim() != ""){
                                    postTextController.clear();

                                    DatabaseService.instance.sendPost(
                                      Post(
                                        post: text,
                                        time: Timestamp.now(),
                                        senderID: _auth.user.uid,
                                      ),
                                    );
                                    setState(() {
                                      text = '';
                                    });
                                    }else{
                                      EasyLoading.showInfo("Please Enter some Text",duration: Duration(milliseconds: 800));
                                    }
                                  },
                                ),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
