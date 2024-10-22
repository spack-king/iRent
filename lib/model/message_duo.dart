import 'package:firebase_database/firebase_database.dart';
import 'package:irent/model/message.dart';

class MessageDao{
  final DatabaseReference _messageRef = FirebaseDatabase.instance.ref().child('messages');

  //add new data (message)
  //Message message = Message(text: text, date: date)

  void saveMessage(MessageSpack message){

   // String time = '${DateTime.timestamp().millisecondsSinceEpoch}';
    _messageRef.child(message.key).set(message.toJson());
  }
  Query getMessageQuery(){
    return _messageRef.orderByChild('timestamp');//.orderByChild('time');
  }
}