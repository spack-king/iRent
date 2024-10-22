import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:irent/model/message_list.dart';

class ChatListDao{
  DatabaseReference _ChatListRef = FirebaseDatabase.instance.ref().child('ChatList');


  //add new data (ChatList)
  //ChatList ChatList = ChatList(text: text, date: date)

  void saveChatList(ChatList ChatList_sender, ChatList ChatList_receiver, String sender, String receiver){
    _ChatListRef.child(sender).child(receiver).set(ChatList_receiver.toJson());
    _ChatListRef.child(receiver).child(sender).set(ChatList_sender.toJson());
  }

  void updateRead(String me, String receiver){
  _ChatListRef.child(me).child(receiver).update({
     'read': "true",
   });
   _ChatListRef.child(receiver).child(me).update({
     'read': "true",
   });

  }

  Query getChatListQuery(String userid){
    return _ChatListRef;//.child(userid);
  }
  void removeListener(){
    _ChatListRef.onValue.listen((event) { }).cancel();
  }
}