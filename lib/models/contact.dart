import 'package:cloud_firestore/cloud_firestore.dart';

class Contact {
  final String id;
  final String email;
  final String image;
  final String name;
  final String fullName;
  final String username;
  final Timestamp lastSeen;
  final String about;

  Contact({
    this.id,
    this.email,
    this.name,
    this.fullName,
    this.username,
    this.image,
    this.lastSeen,
    this.about,
  });

  factory Contact.fromFirestore(DocumentSnapshot _snapshot) {
    var _data = _snapshot.data();
    return Contact(
      id: _snapshot.id,
      email: _data['email'],
      name: _data['name'],
      fullName: _data['fullName'],
      username: _data['username'],
      image: _data['image'],
      lastSeen: _data['lastSeen'],
      about: _data['about'],
    );
  }
}
