import 'package:cloud_firestore/cloud_firestore.dart';


class Post{
  final String rent_sell;
  final String pay_type;
  final String description;
final String amount;
final String city;
final String state;
final String category;
  final String publisherid;
  final String username;
  final String storage_location;
  final String postid;
  final time;
  final String uri;
  final String profilepics;
  final likes;
  final int view;
  final String link;

  const Post({
    required this.rent_sell,
    required this.pay_type,
    required this.description,
    required this.amount,
    required this.city,
    required this.state,
    required this.category,
    required this.publisherid,
    required this.username,
    required this.postid,
    required this.storage_location,
    required this.time,
    required this.uri,
    required this.profilepics,
    required this.likes,
    required this.view,
    required this.link,
  });

  Map<String, dynamic> toJson() => {
    "rent_sell": rent_sell,
    "pay_type": pay_type,
    "description": description,
    "amount": amount,
    "city": city,
    "state": state,
    "category": category,
    "publisherid": publisherid,
    "username": username,
    "postid": postid,
    "time": time,
    "storage_location": storage_location,
    "uri": uri,
    "profilepics": profilepics,
    "likes": likes,
    "view": view,
    "link": link,
  };
  static Post fromSnap(DocumentSnapshot snap){
    var snapshot = snap.data() as Map<String, dynamic>;

    return Post(
      rent_sell: snapshot['rent_sell'],
      pay_type: snapshot['pay_type'],
      description: snapshot['description'],
      amount: snapshot['amount'],
      city: snapshot['city'],
      state: snapshot['state'],
      category: snapshot['category'],
        publisherid: snapshot['publisherid'],
        username: snapshot['username'],
        postid: snapshot['postid'],
        time: snapshot['time'],
        storage_location: snapshot['storage_location'],
        uri: snapshot['uri'],
        profilepics: snapshot['profilepics'],
      likes: snapshot['likes'],
      view: snapshot['view'],
      link: snapshot['link'],
    );
  }
}
