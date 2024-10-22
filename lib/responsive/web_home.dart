import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:irent/pages/chatlist.dart';
import 'package:irent/pages/profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/message_list.dart';
import '../pages/favourite_page.dart';
import '../pages/home_fragment.dart';
import '../utilities/colors.dart';
import '../utilities/global_variable.dart';

class WebHome extends StatefulWidget {
  const WebHome({super.key});

  @override
  State<WebHome> createState() => _WebHomeState();
}

class _WebHomeState extends State<WebHome> {
  bool isLoading = true;
  String title = 'iRent';

  bool verified = false;
  late String status = 'user', imageurl, userid;
  bool loading = true;
  int counter = 0;

  int _page = 0;
  late PageController pageController;
  late DatabaseReference _counterRef;

  @override
  void initState(){
    super.initState();

    initDatebase();
    getUserData();
    pageController = PageController();
  }

  getUserData() async {
    setState(() {
      loading = true;
    });
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    status = prefs.getString('status') ?? 'status ...';
    userid =  prefs.getString('userid') ?? 'Fullname';
    // email_address =  prefs.getString('email') ?? 'email';
    imageurl =  prefs.getString('imageurl') ?? 'imageurl';

    if(status == 'agent'){
      verified = true;
    }
    // print(uid);
    setState(() {
      messageCounter();
      loading = false;
    });
  }

  Future<void> initDatebase() async {
    _counterRef = FirebaseDatabase.instance.ref().child('ChatList');

    final database = FirebaseDatabase.instance;

    if (!kIsWeb) {
      database.setPersistenceEnabled(true);
      database.setPersistenceCacheSizeBytes(10000000);
      await _counterRef.keepSynced(true);
    }
  }
  void messageCounter(){
    DatabaseReference _ChatListRef = FirebaseDatabase.instance.ref().child('ChatList').child(userid);

    _ChatListRef
        .onValue.listen((event) {
      final y = event.snapshot;
      y.children.forEach((element) {
        final json = Map<dynamic, dynamic>.from(element.value as Map);
        final chatlist_item = ChatList.fromJson(json);
        counter = 0;
        if(chatlist_item.receiver_id == userid && chatlist_item.read == 'false'){

          setState(() {
            counter++;
          });
        }
        //print(chatlist_item.username);
      });

    });
  }


  void navigationTapped(int page){
    pageController.jumpToPage(page);
    switch(page){
      case 0:
        title = 'iRent';
        break;
      case 1:
        title = 'My Favorite';
        break;
      case 2:
        title = 'Chats';
        break;
    }
  }

  void onPageChanged(int page){
    setState(() {
      _page = page;
    });
  }

  @override
  Widget build(BuildContext context) {

    final width = MediaQuery.of(context).size.width;
    return Scaffold(

        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(title, style: TextStyle(fontWeight: FontWeight.bold),),
          centerTitle: true,
          actions: [
            IconButton(onPressed: () => navigationTapped(0), icon: Icon(Icons.home, color: _page == 0 ? Colors.white : Colors.grey),tooltip: 'Home',),
            IconButton(onPressed: () => navigationTapped(1), icon: Icon(Icons.favorite, color: _page == 1 ? Colors.white : Colors.grey),tooltip: 'My favorite',),
            IconButton(onPressed: () => navigationTapped(2), icon: Badge(
              label: counter == 0 ? null
                  :Container(
                  padding: EdgeInsets.all(1),
                  decoration: new BoxDecoration(
                    //color: Colors.blue,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  constraints: BoxConstraints(
                    minWidth: 12,
                    minHeight: 12,
                  ),
                  child: Text('$counter', style: TextStyle(color: Colors.white),)),
              child: Icon(CupertinoIcons.chat_bubble_fill, color: _page == 2 ? Colors.white : Colors.grey),),tooltip: 'Chats',),

            const SizedBox(width: 15,),
            InkWell(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) =>
                    ProfileScreen()
                ));
              },
              child: Visibility(
                visible: verified,
                child: loading
                    ? CircleAvatar(
                  radius: 17,
                  backgroundColor: Colors.white,
                  // backgroundImage: Ass(userData['imageurl'])
                )
                    :

                CachedNetworkImage(
                  alignment: Alignment.center,
                  imageUrl: imageurl,
                  imageBuilder: (context, imageProvider) =>
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                            color: Colors.grey,
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.cover,
                              // colorFilter: ColorFilter.mode(Colors.red, BlendMode.colorBurn)
                            )
                        ),
                      ),
                  placeholder: (context, url) =>  const Center(child: Icon(CupertinoIcons.person_circle)),
                  errorWidget: (context, url, error) =>   const Center(child: Icon(CupertinoIcons.person_circle)),
                )
                // CircleAvatar(
                //     radius: 17,
                //     backgroundColor: Colors.white,
                //     backgroundImage: NetworkImage(imageurl)
                // )
                ,).animate().shakeX(duration: 1000.ms, delay: 500.ms),
            ),
            const SizedBox(width: 15,)
          ],
        ),

        drawer:const LeftDrawer(),
        body:Container(
        //  padding: const EdgeInsets.symmetric(vertical: 15),

          decoration: BoxDecoration(
            color: webBackgroundColor,
            borderRadius: BorderRadius.circular(10),
           // border: Border.all()

          ),
          margin: EdgeInsets.symmetric(
              horizontal:  width * 0.2,
              vertical:  10
          ) ,
          child: PageView(
            physics: NeverScrollableScrollPhysics(),
            controller: pageController,
            onPageChanged: onPageChanged,
            children: [
              HomePage(),
              FavouritePage(),
              ChatListPage()
            ],
          ),
        ),

    );
  }
}
