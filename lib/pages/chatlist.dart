import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/message_list.dart';
import '../model/message_list_duo.dart';
import 'chat.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {

  var chatlist = ChatListDao();
  late DatabaseReference _counterRef;
  bool loading = true;
  String my_userid = '';// sender_name = '', sender_pics = '', sender_role = '';
  late Query _ChatListRefChild ;

  @override
  void initState() {
    super.initState();

    initDatebase();
    getMyData();
  }

  getMyData() async {
    setState(() {
      loading = true;
    });
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String str = prefs.getString('status') ?? 'email ...';

    my_userid =  prefs.getString('userid') ?? 'id';
    // fullname =  prefs.getString('fullname') ?? 'name';
    // imageurl =  prefs.getString('imageurl') ?? 'imageurl';
    // status =  prefs.getString('status') ?? 'role';
    _ChatListRefChild = FirebaseDatabase.instance.ref().child('ChatList').child(my_userid).orderByChild('time');
    // print(uid);
    setState(() {
      loading = false;
    });

  }


  Future<void> initDatebase() async {
    _counterRef = FirebaseDatabase.instance.ref('ChatList');

    final database = FirebaseDatabase.instance;

    if (!kIsWeb) {
      database.setPersistenceEnabled(true);
      database.setPersistenceCacheSizeBytes(10000000);
      await _counterRef.keepSynced(true);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: loading ? const Center(child: CircularProgressIndicator()) : FirebaseAnimatedList(
       // reverse: true,
        physics: const BouncingScrollPhysics(),
        query: _ChatListRefChild,
        itemBuilder: (BuildContext context, DataSnapshot snapshot, Animation<double> animation, int index)
        {
          final json = snapshot.value as Map<dynamic, dynamic>;
          final chatlist_item = ChatList.fromJson(json);
          bool iAmReceiver, read = true, seen = false;

         // if((snapshot.data! as dynamic).docs.length == 0){

          if(chatlist_item.receiver_id == my_userid){
            iAmReceiver = true;
            if(chatlist_item.read == 'true'){
              read = true;
            }else{
              read = false;
            }
          }else{
            iAmReceiver = false;
            if (chatlist_item.read == ' true'){
              seen = true;
            }else{
              seen = false;
            }
          }
          //debugPrint(chatlist_item.message);
          //Map map = snapshot.value as Map;

          //DataSnapshot snap = (snapshot.value! as dynamic).docs[index];

          if(snapshot.exists){
            return UserList(iAmReceiver, read, seen, chatlist_item.message,
                chatlist_item.username, chatlist_item.userid, chatlist_item.profile_pics,
                chatlist_item.role, chatlist_item.date, index, chatlist_item.receiver_id);

          }else{
            return Center(child: Text('No chats yet!'),);
          }

        },

      ),

    );
  }
  Widget UserList(bool iAmReceiver, bool read, bool seen, String message, String username, String userid, String profile_pics, String role, DateTime time, int index, String receiver_id){
    return Container(
        margin: EdgeInsets.all(2),
        child: Stack(
          children: [
            ListTile(
              onTap: (){

                Navigator.push(context, MaterialPageRoute(builder: (context) =>
                    Chat(
                      uid: userid,
                      name: username,
                      profilePics: profile_pics,
                      role: role,
                    )
                ));
              },
              leading:
              Stack(
                children: [
                  // CachedNetworkImage(
                  //   alignment: Alignment.center,
                  //   imageUrl: profile_pics,
                  //   imageBuilder: (context, imageProvider) =>
                  //       Container(
                  //         width: 10,
                  //         height: 10,
                  //         decoration: BoxDecoration(
                  //             color: Colors.grey,
                  //             shape: BoxShape.circle,
                  //             image: DecorationImage(
                  //               image: imageProvider,
                  //               fit: BoxFit.cover,
                  //               // colorFilter: ColorFilter.mode(Colors.red, BlendMode.colorBurn)
                  //             )
                  //         ),
                  //       ),
                  //   placeholder: (context, url) =>  const Center(child: Icon(CupertinoIcons.person_circle)),
                  //   errorWidget: (context, url, error) =>   const Center(child: Icon(CupertinoIcons.person_circle)),
                  // ),
                  kIsWeb
                  ? CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white,
                    backgroundImage: NetworkImage(profile_pics),
                  )
                  : CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white,
                    foregroundImage: CachedNetworkImageProvider(
                      profile_pics,
                    ),
                    // backgroundImage: NetworkImage(profile_pics),
                  ),
                  Visibility(
                    visible: role.endsWith('gent') ,
                    child: const Positioned(
                        bottom: 0,
                        right: 0,
                        child: Icon(Icons.verified, color: Colors.blue, size: 20,)),
                  )
                ],
              ),
              title: Text('$username', maxLines: 1, overflow: TextOverflow.ellipsis,),
              subtitle: Row(
                children: [
                  Visibility(
                    visible: !iAmReceiver,
                    child: Container(
                        child: seen ? Icon(Icons.done_all, color: Colors.blue, size: 20,) :  Icon(Icons.done_all, color: Colors.grey, size: 20,)
                    ),
                  ),
                  Text(' $message', maxLines: 1, overflow: TextOverflow.fade, ),
                ],
              ),
              trailing: iAmReceiver ? Visibility(
                  visible: !read,
                  child: const CircleAvatar(backgroundColor: Colors.blue, radius: 5,)) : null,
            ),
            //
            iAmReceiver ?  Visibility(
              visible: !read,
              child: Align(alignment: Alignment.topRight,
                  child: Text('${DateFormat.MMMMEEEEd().format(time)}', style: TextStyle(fontSize: 10, color: Colors.blue),)),
            ) : Container(),
          ],
        ));
  }
}
