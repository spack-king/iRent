import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:irent/methods/firestore_methods.dart';
import 'package:irent/model/message_list.dart';
import 'package:irent/model/message_list_duo.dart';
import 'package:irent/model/message.dart';
import 'package:irent/model/message_duo.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Chat extends StatefulWidget {
  final uid, name,profilePics, role;
  const Chat({super.key, required this.name,required this.profilePics, required this.role,required this.uid});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  ScrollController chat_controller = ScrollController();
  TextEditingController textEditingController = TextEditingController();
  bool textEmpty = true;
  var chat = MessageDao();
  var chatlist = ChatListDao();
  late DatabaseReference _counterRef;
  var userData;// = {};
  bool loading = true;
  String sender_id = '', sender_name = '', sender_pics = '', sender_role = '';
 // String message_read = 'not';
  late Query _messageRef ;
  String token = '';

  @override
  void dispose(){
    super.dispose();
    textEditingController.dispose();
    chat_controller.dispose();
  }

  @override
  void initState() {
    super.initState();
    initDatebase();
    getMyData();
    _scrollDown();
  }


  getMyData() async {
    setState(() {
      loading = true;
    });
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String str = prefs.getString('status') ?? 'email ...';

    sender_id =  prefs.getString('userid') ?? 'id';
    sender_name =  prefs.getString('fullname') ?? 'name';
    sender_pics =  prefs.getString('imageurl') ?? 'imageurl';
    sender_role =  prefs.getString('status') ?? 'role';

    _messageRef = FirebaseDatabase.instance.ref().child('messages').orderByChild('timestamp');

    UpdateReadMessage();
    // print(uid);
    setState(() {
      loading = false;
    });

  }

  UpdateReadMessage(){
    DatabaseReference _ChatListRef2 = FirebaseDatabase.instance.ref().child('ChatList');
    _ChatListRef2.child(sender_id).child(widget.uid).onValue.listen((event) {
      final data = event.snapshot.value;
      final json = event.snapshot.value as Map<dynamic, dynamic>;
      final chatlist_item = ChatList.fromJson(json);

      if(chatlist_item.receiver_id == sender_id){
        if(chatlist_item.read == 'false'){

          chatlist.updateRead(sender_id, widget.uid);
          return;
        }
      }else{
        print(chatlist_item.receiver_id);
      }
    });



  }

  Future<void> initDatebase() async {
    _counterRef = FirebaseDatabase.instance.ref('messages');

    final database = FirebaseDatabase.instance;

    if (!kIsWeb) {
      database.setPersistenceEnabled(true);
      database.setPersistenceCacheSizeBytes(10000000);
      await _counterRef.keepSynced(true);
    }
  }

  void sendMessage(){
    textEmpty = true;
    int time = DateTime.timestamp().millisecondsSinceEpoch;
    int x = -time;
    _scrollDown();
    if(textEditingController.text.isNotEmpty){
      final message = MessageSpack(
          sender: sender_id,
          receiver: widget.uid,
          message: textEditingController.text.trim(),
          time: DateTime.now(),
          key: '${time}', timestamp: x);
      final ChatList_sender = ChatList(
          profile_pics: sender_pics,
          username: sender_name,
          userid: sender_id,
          message: textEditingController.text.trim(),
          time: x,
          read: "false",
          receiver_id: widget.uid,
          role: sender_role, date: DateTime.now());
      final ChatList_receiver = ChatList(
          profile_pics: widget.profilePics,
          username: widget.name,
          userid: widget.uid,
          message: textEditingController.text.trim(),
          time: x,
          read: "false",
          receiver_id: widget.uid,
          role: widget.role, date: DateTime.now());

      chat.saveMessage(message);
      chatlist.saveChatList(
          ChatList_sender, ChatList_receiver, sender_id, widget.uid);

      FirestoreMethods().SENDNotificationSpack(receiverid: widget.uid,
          message:textEditingController.text );
    }
    textEditingController.clear();
    setState(() {

    });
  }

  void _scrollDown() {

    setState(() {

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if(chat_controller.hasClients){
          chat_controller.animateTo(
            chat_controller.position.minScrollExtent,
            duration: Duration(seconds: 2),
            curve: Curves.fastOutSlowIn,
          );

        }
      });
    });

  }

  @override
  Widget build(BuildContext context) {

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if(chat_controller.hasClients){
        chat_controller.animateTo(
          chat_controller.position.minScrollExtent,
          duration: Duration(seconds: 2),
          curve: Curves.fastOutSlowIn,
        );

      }
    });
    final inputBorder = OutlineInputBorder(
      borderRadius:  const BorderRadius.all(Radius.circular(10.0)),
        borderSide: Divider.createBorderSide(context)
    );
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: false,
        title: Row(
          children: [
            Stack(
              children: [
                // CachedNetworkImage(
                //     alignment: Alignment.center,
                //     imageUrl: widget.profilePics,
                //     imageBuilder: (context, imageProvider) =>
                //         Container(
                //           width: 50,
                //           height: 50,
                //           decoration: BoxDecoration(
                //               color: Colors.grey,
                //               shape: BoxShape.circle,
                //               image: DecorationImage(
                //                 image: imageProvider,
                //                 fit: BoxFit.cover,
                //                 // colorFilter: ColorFilter.mode(Colors.red, BlendMode.colorBurn)
                //               )
                //           ),
                //         ),
                //     placeholder: (context, url) =>  const Center(child: Icon(CupertinoIcons.person_circle)),
                //     errorWidget: (context, url, error) =>   const Center(child: Icon(CupertinoIcons.person_circle))
                // ),
                CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white,
                    foregroundImage: CachedNetworkImageProvider(
                      widget.profilePics,
                    ),
                   // backgroundImage: NetworkImage(widget.profilePics)
                ),
                Visibility(
                  visible: widget.role.toString().endsWith('gent'),
                  child: Positioned(
                      bottom: 0,
                      right: 0,
                      child: Icon(Icons.verified, color: Colors.blue, size: 20,)),
                )
              ],
            ),
            const SizedBox(width: 10,),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(widget.name, style: TextStyle(fontSize: 20), overflow: TextOverflow.ellipsis,),
                Text(widget.role, style: TextStyle(color: Colors.blue, fontSize: 10),)
              ],
            )
          ],
        ),
        // actions: [
        //   message_read == 'not' ? Container()
        //      : message_read == 'yes' ? Icon(CupertinoIcons.envelope_open_fill) : Icon(CupertinoIcons.envelope_badge_fill),
        // ],
      ),
      body: loading ? const Center(child: CircularProgressIndicator()) : Column(
        children: [
          Expanded(
              child: FirebaseAnimatedList(
                reverse: true,
                physics: const BouncingScrollPhysics(),
                controller: chat_controller,
                query: _messageRef,
                itemBuilder: (BuildContext context, DataSnapshot snapshot, Animation<double> animation, int index)
                {
                  final json = snapshot.value as Map<dynamic, dynamic>;
                  final message = MessageSpack.fromJson(json);

                  if(message.sender == sender_id && message.receiver == widget.uid
                  || message.sender == widget.uid && message.receiver == sender_id){

                    if(message.sender == sender_id){
                      return ChatItemRight(message.message, message.time);
                    }else{
                      return ChatItemLeft(message.message, message.time);
                    }

                  }else{
                    return Container();
                  }

                },

              )
          ),

          Container(
            margin: EdgeInsets.all(15.0),
            child: Row(
              children: [
                Expanded(
                  child:  TextField(
                    onChanged: (s){
                      textEmpty = s.trim().isEmpty;
                      setState(() {
                      });
                    },
                    enableSuggestions: true,
                    controller: textEditingController,
                    minLines: 1,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: 'Write a message ...',

                      border: inputBorder,
                      focusedBorder: inputBorder,
                      enabledBorder: inputBorder,
                      filled: true,
                      contentPadding: const EdgeInsets.all(8),

                    ),
                    keyboardType: TextInputType.multiline,
                  ),
                ),
                textEmpty ? Container() : IconButton(onPressed: (){
                  sendMessage();
                }, icon: Icon(Icons.send_outlined), tooltip: 'Send a message',)
              ],
            ),
          ),
        ],
      ),
    );
  }
  //chat bubble item
  Widget ChatItemRight(String message, DateTime time){
    return Container(

      margin: EdgeInsets.only(bottom: 15.0, right: 20.0, left: 60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft:Radius.circular(25.0),
                bottomLeft:Radius.circular(25.0),
                topRight:Radius.circular(25.0),)
            ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(message, style:
                TextStyle(
                  fontSize: 16, ),),
              )),

         // Text('${time.(DateTime.now())}')
          Text('${DateFormat.MMMMEEEEd().format(time)}', style: TextStyle(fontSize: 12),)
        ],
      ),
    );
  }
  

  Widget ChatItemLeft(String message, DateTime time){
    return Container(

      margin: const EdgeInsets.only(bottom: 15.0, left: 20.0, right: 60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            color: Colors.blue,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    bottomRight:Radius.circular(25.0),
                    bottomLeft:Radius.circular(25.0),
                    topRight:Radius.circular(25.0),)
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(message, style:
                TextStyle(
                  fontSize: 16, ),),
              )),

          // Text('${time.(DateTime.now())}')
          Text('${DateFormat.MMMMEEEEd().format(time)}', style: TextStyle(fontSize: 12),)
        ],
      ),
    );
  }
}
