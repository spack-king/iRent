import 'package:cloud_firestore/cloud_firestore.dart';

class ChatList{
  final String profile_pics;
  final String username;
  final String userid;
  final String message;
  final int time;
  final DateTime date;
  final String read;
  final String receiver_id;
  final String role;

  const ChatList( {
    required this.date,
    required this.role,required this.profile_pics, required this.username, required this.userid, required this.message, required this.time, required this.read, required this.receiver_id,
  });



  ChatList.fromJson(Map<dynamic, dynamic> json) :
  profile_pics = json['profile_pics'] as String,
        date = DateTime.parse(json['date'] as String),
  username = json['username'] as String,
  message = json['message'] as String,
        time = json['time'],
  userid = json['userid'] as String,
  read = json['read'] as String,
        receiver_id = json['receiver_id'] as String,
  role = json['role'] as String;

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
    'time': time,
    'date': date.toString(),
  'profile_pics': profile_pics,
  'username': username,
  'message': message,
  'userid': userid,
  'read': read,
    'receiver_id': receiver_id,
    'role': role,
  };

}



