import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_chat_ui_starter/models/chat.dart';
import 'package:flutter_chat_ui_starter/models/contact.dart';
import 'package:flutter_chat_ui_starter/models/message.dart';
import 'package:flutter_chat_ui_starter/models/post.dart';

class DatabaseService {
  DatabaseService() {
    _database = FirebaseFirestore.instance;
  }

  FirebaseFirestore _database;
  String _userCollection = 'Users';
  String _chatsCollection = 'Chats';
  String _newsCollection = 'News';
  String _sectionsCollection = 'Sections';
  final _fcm = FirebaseMessaging.instance;

  static DatabaseService instance = DatabaseService();

  Future<void> updateUserLastSeenTime(String _userID) {
    var _ref = _database.collection(_userCollection).doc(_userID);
    return _ref.update({'lastSeen': Timestamp.now()});
  }
  Future<void> updateUsertoken(String _userID) {
    _fcm.getToken().then((fcmToken){
    var _ref = _database.collection(_userCollection).doc(_userID).collection("Chats").get().then((value) {
      value.docs.forEach((docsChatId) {
        String chatId = docsChatId["chatID"];
          _database.collection(_chatsCollection).doc(chatId).collection("tokens").doc("main").get().then((inTokens) {
            if(inTokens.exists){
            List<String> tokensList = List.from(inTokens["tokens"]);
            if (!(tokensList.contains(fcmToken))) {
              return _database.collection(_chatsCollection).doc(chatId).collection("tokens").doc("main").update({
                'tokens' : FieldValue.arrayUnion([fcmToken])
              });
            }
            }else{
              return _database.collection(_chatsCollection).doc(chatId).collection("tokens").doc("main").set({"tokens":[fcmToken]});
            }
          });
      });
    });
    });
  }

  Future updateProfilePhoto(String _url , String _uid){
    var _ref =  _database.collection(_userCollection).doc(_uid);
    return _ref.update({'image': _url});
  }
  Future updateSeenMessage(String chatId , String _uid){
    _database.collection(_chatsCollection).doc(chatId).collection("seen").doc("main").get().then((value) {
      if (value.exists) {
        Map<String , int> seen = Map.from(value["listSeen"]);
        Map<String , int> newMap = {};
        seen.forEach((k , v) {
          if (_uid != k) {
            newMap.putIfAbsent(k, () => v+1);
          }else{
            newMap.putIfAbsent(k, () => 0);
          }
        });
        _database.collection(_chatsCollection).doc(chatId).collection("seen").doc("main").set({
              "listSeen" : newMap
           });
      }else{
        _database.collection(_chatsCollection).doc(chatId).get().then((value){
          List<String> members = List.from(value["members"]);
          Map<String , int> seenData = {};
          members.forEach((element) {
            if(_uid != element){
            seenData.putIfAbsent(element, () => 1);
            }else{
            seenData.putIfAbsent(element, () => 0);
          }
          });
           _database.collection(_chatsCollection).doc(chatId).collection("seen").doc("main").set({
              "listSeen" : seenData
           });
        });
        
      }
    });
  }
  Future setSeenMessage(String chatId , String _uid){
    _database.collection(_chatsCollection).doc(chatId).collection("seen").doc("main").get().then((value) {
      if (value.exists) {
        Map<String , int> seen = Map.from(value["listSeen"]);
        Map<String , int> newMap = {};
        seen.forEach((k , v) {
          if (_uid != k) {
            newMap.putIfAbsent(k, () => v);
          }
        });
        newMap.putIfAbsent(_uid, () => 0);
        _database.collection(_chatsCollection).doc(chatId).collection("seen").doc("main").set({
              "listSeen" : newMap
        });
      }
    });
  }

  Future<void> sendMessage(String _chatID, Message _message , {String fileExt}) {
    var _ref = _database.collection(_chatsCollection).doc(_chatID);
    var _messageType = '';
    switch (_message.type) {
      case MessageType.Text:
        _messageType = 'text';
        break;
      case MessageType.Image:
        _messageType = 'image';
        break;
        case MessageType.Voice:
        _messageType = 'voice';
        break;
        case MessageType.Doc:
        _messageType = 'doc';
        break;
      default:
    }
    return _messageType == "doc" ?
    _ref.update({
      'messages': FieldValue.arrayUnion(
        [
          {
            'message': _message.message,
            'senderID': _message.senderID,
            'time': _message.time,
            'type': _messageType,
            'ext' : fileExt
          },
        ],
      ),
    }): _ref.update({
      'messages': FieldValue.arrayUnion(
        [
          {
            'message': _message.message,
            'senderID': _message.senderID,
            'time': _message.time,
            'type': _messageType,
          },
        ],
      ),
    });
  }

  Future<void> sendPost(Post _post) {
    var _ref =
        _database.collection(_newsCollection).doc('Hx6nQYcoOXg3hs57QTcD');

    return _ref.update({
      'news': FieldValue.arrayUnion(
        [
          {
            'post': _post.post,
            'senderID': _post.senderID,
            'time': _post.time,
          },
        ],
      ),
    });
  }

  Stream<Contact> getUserData(String _userID) {
    var _reference = _database.collection(_userCollection).doc(_userID);
    return _reference.get().asStream().map((_snapshot) {
      return Contact.fromFirestore(_snapshot);
    });
  }

  Stream<List<ChatSnippet>> getUserChats(String _userID) {
    var _reference = _database
        .collection(_userCollection)
        .doc(_userID)
        .collection(_chatsCollection);
    return _reference.snapshots().map((_snapshot) {
      return _snapshot.docs.map((_doc) {
        return ChatSnippet.fromFirestore(_doc);
      }).toList();
    });
  }

  Stream<List<ChatSnippet>> getUserSections(String _userID) {
    var _reference = _database
        .collection(_userCollection)
        .doc(_userID)
        .collection(_sectionsCollection);
    return _reference.snapshots().map((_snapshot) {
      return _snapshot.docs.map((_doc) {
        return ChatSnippet.fromFirestore(_doc);
      }).toList();
    });
  }

  Stream<List<NewSnippet>> getUserNews(String _userID) {
    var _reference = _database
        .collection(_userCollection)
        .doc(_userID)
        .collection(_newsCollection);
    return _reference.snapshots().map((_snapshot) {
      return _snapshot.docs.map((_doc) {
        return NewSnippet.fromFirestore(_doc);
      }).toList();
    });
  }

  Stream<Chat> getChat(String _chatID) {
    var _reference = _database.collection(_chatsCollection).doc(_chatID);
    return _reference.snapshots().map(
      (_doc) {
        return Chat.fromFirestore(_doc);
      },
    );
  }

  Stream<New> getNew(String _postID) {
    var _reference = _database.collection(_newsCollection).doc(_postID);
    return _reference.snapshots().map(
      (_doc) {
        return New.fromFirestore(_doc);
      },
    );
  }
}
