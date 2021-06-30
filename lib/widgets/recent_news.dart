import 'package:flutter/material.dart';
import 'package:flutter_chat_ui_starter/models/chat.dart';
import 'package:flutter_chat_ui_starter/models/contact.dart';
import 'package:flutter_chat_ui_starter/services/database_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter_chat_ui_starter/providers/auth_provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class RecentNews extends StatefulWidget {
  @override
  _RecentNewsState createState() => _RecentNewsState();
}

class _RecentNewsState extends State<RecentNews> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ChangeNotifierProvider<AuthProvider>.value(
        value: AuthProvider.instance,
        child: Builder(
          builder: (BuildContext _context) {
            var _auth = Provider.of<AuthProvider>(_context);
            return StreamBuilder<List<NewSnippet>>(
              stream: DatabaseService.instance.getUserNews(_auth.user.uid),
              builder: (context, _snapshot) {
                var _data = _snapshot.data;
                if (!_snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.lightBlueAccent,
                    ),
                  );
                }
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
                    child: StreamBuilder<New>(
                        stream:
                            DatabaseService.instance.getNew(_data[0].postID),
                        builder: (context, _snapshot) {
                          var _postData = _snapshot.data;
                          if (!_snapshot.hasData) {
                            return Center(
                              child: CircularProgressIndicator(
                                backgroundColor: Colors.lightBlueAccent,
                              ),
                            );
                          }
                          return ListView.builder(
                            padding: EdgeInsets.all(0.0),
                            itemCount: _postData.news.length,
                            itemBuilder: (BuildContext context, int _index) {
                              if (!_snapshot.hasData) {
                                return Center(
                                  child: CircularProgressIndicator(
                                    backgroundColor: Colors.lightBlueAccent,
                                  ),
                                );
                              }
                              var reversed = List.from(_postData.news.reversed);
                              return Container(
                                margin: EdgeInsets.only(
                                    top: 5.0,
                                    bottom: 5.0,
                                    right: 5.0,
                                    left: 5.0),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20.0, vertical: 10.0),
                                decoration: BoxDecoration(
                                  color: Color(0xFFEEEEEE),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0)),
                                ),
                                child: StreamBuilder<Contact>(
                                  stream: DatabaseService.instance
                                      .getUserData(reversed[_index].senderID),
                                  builder: (context, _snapshot) {
                                    var _senderData = _snapshot.data;
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            _senderData != null
                                                ? CircleAvatar(
                                                    radius: 20.0,
                                                    backgroundImage:
                                                        NetworkImage(
                                                            _senderData.image),
                                                  )
                                                : Container(),
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
                                                  child: _senderData == null
                                                      ? Text('')
                                                      : Text(
                                                          _senderData.name,
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'RobotoSlab',
                                                            color: Colors.black,
                                                            fontSize: 17.0,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                ),
                                                SizedBox(
                                                  height: 3.0,
                                                ),
                                                _postData == null
                                                    ? Text('')
                                                    : Text(
                                                        timeago.format(
                                                            reversed[_index]
                                                                .time
                                                                .toDate()),
                                                        style: TextStyle(
                                                          color: Colors.grey,
                                                          fontSize: 15.0,
                                                        ),
                                                      ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Text(
                                            reversed[_index].post,
                                            style: TextStyle(
                                              fontSize: 17.0,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              );
                            },
                          );
                        }),
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
