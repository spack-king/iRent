import 'package:cloud_firestore/cloud_firestore.dart';

class MessageSpack{
  final String sender;
  final String receiver;
  final String message;
  final DateTime time;
  final int timestamp;
  final String key;

  const MessageSpack({ required this.timestamp,
    required this.sender, required this.receiver, required this.message, required this.time, required this.key,
  });

  MessageSpack.fromJson(Map<dynamic, dynamic> json)
      : time = DateTime.parse(json['time'] as String),
        sender = json['sender'] as String,
        receiver = json['receiver'] as String,
        message = json['message'] as String,
        timestamp = json['timestamp'],
        key = json['key'] as String;

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
    'time': time.toString(),
    'sender': sender,
    'receiver': receiver,
    'message': message,
    'key': key,
    'timestamp': timestamp,
  };

}



