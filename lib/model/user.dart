import 'package:cloud_firestore/cloud_firestore.dart';

class User{
  final String userid;
  final String fullname;
  final String username;
  final String email;
  final String password;
  final String imageurl;
  final String status;
  final String state;
  final String city;
  final String link;
  final DateTime timestamp;
  final List fav;

  const User({
    required this.userid,
    required this.fullname,
    required this.username,
    required this.email,
    required this.password,
    required this.imageurl,
    required this.state,
    required this.city,
    required this.link,
    required this.status,
    required this.timestamp,
    required this.fav,
  });

  Map<String, dynamic> toJson() => {
    "userid": userid,
    "fullname": fullname,
    "username": username,
    "email": email,
    "password": password,
    "imageurl": imageurl,
    "state": state,
    "city": city,
    "link": link,
    "status": status,
    "timestamp": timestamp,
    "fav": fav,
  };
  static User fromSnap(DocumentSnapshot snap){
    var snapshot = snap.data() as Map<String, dynamic>;

    return User(
        userid: snapshot['userid'],
        fullname: snapshot['fullname'],
        username: snapshot['username'],
        email: snapshot['email'],
        password: snapshot['password'],
        imageurl: snapshot['imageurl'],
        state: snapshot['state'],
        city: snapshot['city'],
        link: snapshot['link'],
        status: snapshot['status'],
        timestamp: snapshot['timestamp'],
        fav: snapshot['fav']);
        // followers: snapshot['followers'],
        // following: snapshot['following']);
  }
}
