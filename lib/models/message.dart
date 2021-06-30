import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType {
  Text,
  Image,
  Voice,
  Doc
}

class Message {
  final String senderID;
  final String message;
  final Timestamp time;
  final MessageType type;

  Message({this.senderID, this.message, this.time, this.type});
}
