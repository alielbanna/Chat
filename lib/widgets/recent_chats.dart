import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui_starter/models/chat.dart';
import 'package:flutter_chat_ui_starter/models/message.dart';
import 'package:flutter_chat_ui_starter/screens/chat_screen.dart';
import 'package:flutter_chat_ui_starter/services/database_service.dart';
import 'package:flutter_chat_ui_starter/services/navigation_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter_chat_ui_starter/providers/auth_provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class RecentChats extends StatefulWidget {
  @override
  _RecentChatsState createState() => _RecentChatsState();
}

class _RecentChatsState extends State<RecentChats> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ChangeNotifierProvider<AuthProvider>.value(
        value: AuthProvider.instance,
        child: Builder(
          builder: (BuildContext _context) {
            var _auth = Provider.of<AuthProvider>(_context);
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15.0),
                  topRight: Radius.circular(15.0),
                ),
              ),
              child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15.0),
                    topRight: Radius.circular(15.0),
                  ),
                  child: StreamBuilder<List<ChatSnippet>>(
                    stream:
                      DatabaseService.instance.getUserChats(_auth.user.uid),
                    builder: (BuildContext _context, _snapshot) {
                      var _data = _snapshot.data;
                      return _snapshot.hasData
                          ? ListView.builder(
                              padding: EdgeInsets.all(0.0),
                              itemCount: _data.length,
                              itemBuilder: (BuildContext context, int _index) {
                                return GestureDetector(
                                  onTap: () {
                                    NavigationService.instance.navigateToRoute(
                                      MaterialPageRoute(
                                        builder: (BuildContext _context) {
                                          return ChatScreen(
                                            chatID: _data[_index].chatID,
                                            receiverID: _data[_index].id,
                                            chatImage: _data[_index].image,
                                            chatName: _data[_index].name,
                                          );
                                        },
                                      ),
                                    );
                                  },
                                  child: Container(
                                    height: 80,
                                    margin: EdgeInsets.only(
                                        top: 5.0,
                                        bottom: 5.0,
                                        right: 0,
                                        left: 5.0),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 15.0, vertical: 10.0),
                                    decoration: BoxDecoration(
                                      color: Color(0xFFEEEEEE),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10.0)),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 30.0,
                                              backgroundImage: NetworkImage(
                                                  _data[_index].image),
                                            ),
                                            SizedBox(
                                              width: 10.0,
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.45,
                                                  child: Text(
                                                    _data[_index].name,
                                                    style: TextStyle(
                                                      fontFamily: 'RobotoSlab',
                                                      color: Colors.black,
                                                      fontSize: 17.0,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 5.0,
                                                ),
                                                Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.45,
                                                  child: StreamBuilder<Chat>(
                                                      stream: DatabaseService
                                                          .instance
                                                          .getChat(_data[_index]
                                                              .chatID),
                                                      builder:
                                                          (context, _snapshot) {
                                                        if (!_snapshot
                                                            .hasData) {
                                                          return Text('');
                                                        }
                                                        var _chatData =
                                                            _snapshot.data;
                                                        var lastMessage =
                                                            _chatData.messages[
                                                                _chatData
                                                                        .messages
                                                                        .length -
                                                                    1];

                                                        return lastMessage
                                                                    .type ==
                                                                MessageType
                                                                    .Image
                                                            ? Container(
                                                                child: Row(
                                                                  children: [
                                                                    Icon(
                                                                      Icons
                                                                          .image_rounded,
                                                                      size:
                                                                          18.0,
                                                                      color: Colors
                                                                          .grey,
                                                                    ),
                                                                    Text(
                                                                      ' Image',
                                                                      style:
                                                                          TextStyle(
                                                                        color: Colors
                                                                            .grey,
                                                                        fontSize:
                                                                            15.0,
                                                                        fontWeight:
                                                                            FontWeight.w600,
                                                                      ),
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                    )
                                                                  ],
                                                                ),
                                                              )
                                                            : lastMessage
                                                                    .type ==
                                                                MessageType
                                                                    .Voice
                                                            ? Container(
                                                                child: Row(
                                                                  children: [
                                                                    Icon(
                                                                      Icons
                                                                          .mic,
                                                                      size:
                                                                          18.0,
                                                                      color: Colors
                                                                          .grey,
                                                                    ),
                                                                    Text(
                                                                      ' record',
                                                                      style:
                                                                          TextStyle(
                                                                        color: Colors
                                                                            .grey,
                                                                        fontSize:
                                                                            15.0,
                                                                        fontWeight:
                                                                            FontWeight.w600,
                                                                      ),
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                    )
                                                                  ],
                                                                ),
                                                              ) :lastMessage
                                                                    .type ==
                                                                MessageType
                                                                    .Doc
                                                            ? Container(
                                                                child: Row(
                                                                  children: [
                                                                    Icon(
                                                                      Icons
                                                                          .folder,
                                                                      size:
                                                                          18.0,
                                                                      color: Colors
                                                                          .grey,
                                                                    ),
                                                                    Text(
                                                                      ' Document',
                                                                      style:
                                                                          TextStyle(
                                                                        color: Colors
                                                                            .grey,
                                                                        fontSize:
                                                                            15.0,
                                                                        fontWeight:
                                                                            FontWeight.w600,
                                                                      ),
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                    )
                                                                  ],
                                                                ),
                                                              )
                                                               : Container(
                                                                 height: 25,
                                                                 child: Text(
                                                                  lastMessage
                                                                      .message,
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .grey,
                                                                    fontSize:
                                                                        15.0,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                  ),
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                              ),
                                                               );
                                                      }),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Container(
                                          alignment: Alignment.center,
                                          width: MediaQuery.of(context).size.width*0.25,
                                          child: StreamBuilder<Chat>(
                                              stream: DatabaseService.instance
                                                  .getChat(
                                                      _data[_index].chatID),
                                              builder: (context, _snapshot) {
                                                if (!_snapshot.hasData) {
                                                  return Text('');
                                                }
                                                var _chatData = _snapshot.data;
                                                var lastMessage = _chatData
                                                        .messages[
                                                    _chatData.messages.length -
                                                        1];

                                                return Column(
                                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                  children: [
                                                    Container(
                                                      alignment: Alignment.centerRight,
                                                      height: 27,
                                                      child: StreamBuilder(
                                                          stream:FirebaseFirestore.instance.collection("Chats").doc(_data[_index].chatID).collection("seen").doc("main").snapshots(),
                                                          builder: (context, _snapshot) {
                                                          Map<String,int> seenCount = {};
                                                          var auth = FirebaseAuth.instance.currentUser.uid;
                                                          if (_snapshot.hasData) {
                                                            seenCount = Map.from(_snapshot.data["listSeen"]);
                                                          }
                                                          return _snapshot.hasData && seenCount[auth] > 0 ? Container(
                                                          alignment: Alignment.center,
                                                          width: 27,
                                                          height: 27,
                                                          decoration: BoxDecoration(
                                                            color: Theme.of(context).accentColor,
                                                            borderRadius: BorderRadius.circular(30)
                                                          ),
                                                          child: Text(seenCount[auth] < 100 ? "${seenCount[auth]}" : "+99",style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 12.0,
                                                          )),
                                                        ):Container();
                                                          }
                                                      ),
                                                    ),

                                                    Text(
                                                      timeago.format(lastMessage
                                                          .time
                                                          .toDate()),
                                                      style: TextStyle(
                                                        color: Colors.grey,
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 14.0,
                                                      ),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                );
                                              }),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            )
                          : Center(
                              child: CircularProgressIndicator(
                                backgroundColor: Theme.of(context).accentColor,
                              ),
                            );
                    },
                  )),
            );
          },
        ),
      ),
    );
  }
}
