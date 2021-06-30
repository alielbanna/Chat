import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_ui_starter/models/post.dart';
import 'message.dart';

class ChatSnippet {
  ChatSnippet(
      {this.id,
      this.chatID,
      this.lastMessage,
      this.name,
      this.image,
      this.unseenCount,
      this.time});

  final String id;
  final String chatID;
  final String lastMessage;
  final String name;
  final String image;
  final int unseenCount;
  final Timestamp time;

  factory ChatSnippet.fromFirestore(DocumentSnapshot _snapshot) {
    var _data = _snapshot.data();
    return ChatSnippet(
      id: _snapshot.id,
      chatID: _data['chatID'],
      lastMessage: _data['lastMessage'] != null ? _data['lastMessage'] : '',
      unseenCount: _data['unseenCount'],
      time: _data['time'] != null ? _data['time'] : null,
      name: _data['name'],
      image: _data['image'],
    );
  }
}

class Chat {
  final String id;
  final List members;
  final List<Message> messages;
  final String admin;

  Chat({this.id, this.members, this.admin, this.messages});

  factory Chat.fromFirestore(DocumentSnapshot _snapshot) {
    var _data = _snapshot.data();
    List _messages = _data['messages'];
    if (_messages != null) {
      _messages = _messages.map(
        (_m) {
          return Message(
              type: _m['type'] == 'text' ? MessageType.Text : _m['type'] == 'image' ? MessageType.Image :  _m['type'] == 'voice'? MessageType.Voice : MessageType.Doc,
              message: _m['message'],
              time: _m['time'],
              senderID: _m['senderID']);
        },
      ).toList();
    } else {
      _messages = [];
    }
    return Chat(
        id: _snapshot.id,
        members: _data['members'],
        admin: _data['admin'],
        messages: _messages);
  }
}

class NewSnippet {
  NewSnippet({
    this.id,
    this.postID,
  });

  final String id;
  final String postID;

  factory NewSnippet.fromFirestore(DocumentSnapshot _snapshot) {
    var _data = _snapshot.data();
    return NewSnippet(
      id: _snapshot.id,
      postID: _data['postID'],
    );
  }
}

class New {
  final String id;
  final List viewers;
  final List<Post> news;

  New({this.id, this.viewers, this.news});

  factory New.fromFirestore(DocumentSnapshot _snapshot) {
    var _data = _snapshot.data();
    List _news = _data['news'];
    if (_news != null) {
      _news = _news.map(
        (_m) {
          return Post(
              post: _m['post'], time: _m['time'], senderID: _m['senderID']);
        },
      ).toList();
    } else {
      _news = [];
    }
    return New(id: _snapshot.id, viewers: _data['viewers'], news: _news);
  }
}
