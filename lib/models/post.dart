import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String senderID;
  final String post;
  final Timestamp time;

  Post({
    this.senderID,
    this.post,
    this.time,
  });
}
