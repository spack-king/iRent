import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:irent/pages/login.dart';
import 'package:irent/pages/update_state.dart';
import 'package:irent/utilities/colors.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../methods/auth_methods.dart';
import '../widgets/post_card.dart';
import '../widgets/preview_img.dart';
import 'agent_login.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController textEditingController = TextEditingController();
  bool isSearching = false, gettinUserData = true;
  String selected = 'Single room', state = '';

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  @override
  void dispose() {
    super.dispose();
    textEditingController.dispose();
  }


  @override
  void initState() {
    super.initState();
    getUserData();
    //notification
    initInfo();
    requestPermission();
    getToken();
    saveToken();
  }

  void requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if(settings.authorizationStatus == AuthorizationStatus.authorized){
      print('permission granted');
    }else if(settings.authorizationStatus == AuthorizationStatus.provisional){
      print('provisional permit');
    }else{
      print('declined');
    }
  }
  void getToken() async {
    await FirebaseMessaging.instance.getToken().then(
            (token){
          setState(() {
            token = token;
            print('Spack $token');
          });
        });
  }
  void saveToken() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String userid =  prefs.getString('userid') ?? 'id';

    final token =  await FirebaseMessaging.instance.getToken();

    await FirebaseFirestore.instance.collection('token').doc(userid)
        .set(
        {
          'token': token,
        });
  }
  initInfo() async {
    var androidInitialise = const AndroidInitializationSettings('@mipmap/icon..png');
    var IosInitialize = const DarwinInitializationSettings();//FORMELY IOSIMITIALIZATIONSETTINGS()
    var initilazationSettings = InitializationSettings(android: androidInitialise, iOS: IosInitialize);
    await flutterLocalNotificationsPlugin.initialize(initilazationSettings);
    // Future<void> showNotification(RemoteMessage message, [bool importance = true]) async {
    //   dynamic notification = message.data;
    //   final prefs = await SharedPreferences.getInstance();
    //
    //   // check message ID is valid or not
    //   prefs.setBool('hasMsgId', message.messageId != null ? true : false);
    //
    //   await flutterLocalNotificationsPlugin.show(
    //     message.hashCode,
    //     notification['title'],
    //     notification['body'],
    //     _setPlatFormSpecificSettings(importance),
    //     payload: notification['docId'],
    //   );
    // }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print('messaaged');

      BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
        message.notification!.body.toString(), htmlFormatBigText: true,
        contentTitle: message.notification!.title.toString(), htmlFormatContent: true,
      );
      AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
        'com.irent.irent','com.irent.irent', importance:Importance.high,
        styleInformation: bigTextStyleInformation, priority: Priority.high, playSound: true,
       // sound: RawResourceAndroidNotificationSound('raw here')
      );
      NotificationDetails platformChannelSpecifics = NotificationDetails(
          android: androidNotificationDetails,
          iOS: const DarwinNotificationDetails()
      );
      await flutterLocalNotificationsPlugin.show(0, message.notification?.title,
          message.notification?.body, platformChannelSpecifics,
          payload: message.data['title']);
    });
  }
  getUserData() async {
    setState(() {
      gettinUserData = true;
    });
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    //final String str = prefs.getString('status') ?? 'status ...';

    // userid =  prefs.getString('userid') ?? 'Fullname';
    // fullname =  prefs.getString('fullname') ?? 'email';
    state =  prefs.getString('state') ?? 'state';

    setState(() {
      gettinUserData = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final inputBorder = OutlineInputBorder(
        borderSide: Divider.createBorderSide(context)
    );
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        margin: EdgeInsets.all(15),
        child: Column(
          children: [
            TextField(
              enableSuggestions: true,
              controller: textEditingController,

              decoration: InputDecoration(
                hintText: 'Search by city e.g: Onitsha...',
                //labelText: 'Enter your Password',

                border: inputBorder,
                focusedBorder: inputBorder,
                enabledBorder: inputBorder,
                filled: true,
                contentPadding: const EdgeInsets.all(8),
                suffixIcon: SpackPopUpMenuList(),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey,
                ),
              ),
              keyboardType: TextInputType.streetAddress,
              // onSubmitted: (String _){
              //   //print(_);
              //   setState(() {
              //     isSearching = true;
              //   });
              // },
              onChanged: (String s){
               // textEditingController.text = s;
                if(s == ''){
                  isSearching = false;
                }
                else{
                  isSearching = true;
                }
                setState(() {

                });
              },
            ),
            const SizedBox(height: 5,),
            Expanded(
              child: isSearching
                  ? FutureBuilder(
                  future:
                  FirebaseFirestore.instance.collection('post')
                      .where('category', isEqualTo: selected)
                      .get()
                  ,
                  builder: (context, snapshot){
                    if(snapshot.connectionState == ConnectionState.waiting){
                      return const Center(
                        child: CircularProgressIndicator());
                         // child: ShimmerWidget());
                    }
                    return ListView.builder(
                      //reverse: true,
                        physics: const BouncingScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: (snapshot.data! as dynamic).docs.length,

                        itemBuilder: (context, index){
                          DocumentSnapshot snap = (snapshot.data! as dynamic).docs[index];

                          if(snap['city'].toString().toLowerCase().contains(textEditingController.text.toLowerCase())){

                            return Stack(
                              children: [
                                PostCard(snap: snap,),
                                Positioned(child:
                                Text(snap['city'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, shadows: [
                                  Shadow(color: Colors.black, offset: Offset(1.0,1.0), blurRadius: 10.0)]),),
                                  top: 40, left: 16,),
                              ],
                            );
                          }else{
                            return Stack(
                              children: [
                                PostCard(snap: snap,),
                                Positioned(child: Text('Recommended for you',style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, shadows: [
                                  Shadow(color: Colors.black, offset: Offset(1.0,1.0), blurRadius: 10.0)])), top: 40, left: 16,)
                              ],
                            );
                          }
                        }
                    );
                  }
              )
                  : FutureBuilder(
                  future:
                  FirebaseFirestore.instance.collection('post')
                     // .orderBy('time', descending: true)
                  .where('category', isEqualTo: selected)
                      .get()
                  ,
                  builder: (context, snapshot){

                    if(snapshot.connectionState == ConnectionState.waiting){
                      return const Center(
                          child: CircularProgressIndicator());
                      // child: ShimmerWidget());
                    }
                    // if(!snapshot.hasData || snapshot.hasError){
                    //   return Center(child: Text('No data found yet,  '),);
                    // }
                    return ListView.builder(
                      //reverse: true,
                        physics: const BouncingScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: (snapshot.data! as dynamic).docs.length,

                        itemBuilder: (context, index){
                          DocumentSnapshot snap = (snapshot.data! as dynamic).docs[index];


                          if(state.toLowerCase() == (snap['state'].toString().toLowerCase())){

                            return Stack(
                              children: [
                                PostCard(snap: snap,),
                                Positioned(child:
                                Text(snap['city'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, shadows: [
                                  Shadow(color: Colors.black, offset: Offset(1.0,1.0), blurRadius: 10.0)]),),
                                  top: 40, left: 16,),
                              ],
                            );
                          }else{
                            return Stack(
                              children: [
                                PostCard(snap: snap,),
                                Positioned(child: Text('Recommended for you', style: TextStyle(fontSize: 12),), top: 40, left: 16,)
                              ],
                            );
                          }
                        }
                    );
                  }
              ),
            ),
          ],
        ),
      ),
          );
  }

  Widget SpackPopUpMenuList(){

    return PopupMenuButton<String>(

      icon: Icon( Icons.filter_list ),
      onSelected: (value) {
        setState(() {
          textEditingController.clear();
          selected = value;
        });
      },
      itemBuilder: (BuildContext contesxt) {

        return [
          PopupMenuItem(
            child: ListTile(title: Text("Building"), trailing: selected == 'Building' ? Icon(Icons.done, color: Colors.green,) : null ,),
            value: "Building",
          ),
          PopupMenuItem(
            child: ListTile(title: Text("Full flat"), trailing: selected == 'Full flat' ? Icon(Icons.done, color: Colors.green,) : null ,),
            value: "Full flat",
          ),
          PopupMenuItem(
            child: ListTile(title: Text("Land"), trailing: selected == 'Land' ? Icon(Icons.done, color: Colors.green,) : null ,),
            value: "Land",
          ),
          PopupMenuItem(
            child: ListTile(title: Text("Self-contained"), trailing: selected == 'Self-contained' ? Icon(Icons.done, color: Colors.green,) : null ,),
            value: "Self-contained",
          ),
          PopupMenuItem(
            child: ListTile(title: Text("Single room"), trailing: selected == 'Single room' ? Icon(Icons.done, color: Colors.green,) : null ,),
            value: "Single room",
          ),
          PopupMenuItem(
            child: ListTile(title: Text("Plaza"), trailing: selected == 'Plaza' ? Icon(Icons.done, color: Colors.green,) : null ,),
            value: "Plaza",
          ),
          PopupMenuItem(
            child: ListTile(title: Text("Shop"), trailing: selected == 'Shop' ? Icon(Icons.done, color: Colors.green,) : null ,),
            value: "Shop",
          ),
          PopupMenuItem(
            child: ListTile(title: Text("Warehouse"), trailing: selected == 'Warehouse' ? Icon(Icons.done, color: Colors.green,) : null ,),
            value: "Warehouse",
          ),
        ];
      },
    );
  }
  Widget ShimmerWidget(){
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
          children: [
            const SizedBox(height: 5,),
            Container(
              decoration:const ShapeDecoration(
                color: mobileSearchColor,
                  shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15),))),
              width: double.infinity,
              height: 150,
            ),
            SizedBox(height: 5,),
            Container(
              width: double.infinity,
              height: 150,
              decoration:const ShapeDecoration(
                  color: mobileSearchColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15),))),
            ),
            SizedBox(height: 5,),
            Container(
              width: double.infinity,
              height: 150,
              decoration:const ShapeDecoration(
                  color: mobileSearchColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15),))),
            ),
            SizedBox(height: 5,),
            Container(
              width: double.infinity,
              height: 150,
              decoration:const ShapeDecoration(
                  color: mobileSearchColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15),))),
            ),
            SizedBox(height: 5,),
            Container(
              width: double.infinity,
              height: 150,
              decoration:const ShapeDecoration(
                  color: mobileSearchColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15),))),
            ),
            SizedBox(height: 5,),
          ].animate(interval: 100.ms).fade(duration: 500.ms,).shimmer(duration: 400.ms, delay: 2000.ms),
        ),
    );
  }
}

class LeftDrawer extends StatefulWidget {
  const LeftDrawer({super.key});

  @override
  State<LeftDrawer> createState() => _LeftDrawerState();
}

class _LeftDrawerState extends State<LeftDrawer> {
  bool verified = false;
  late String status, fullname, state, imageurl;
  bool loading = true;
  @override
  void initState(){
    super.initState();
    getUserData();
  }

  getUserData() async {
    setState(() {
      loading = true;
    });
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String str = prefs.getString('status') ?? 'email ...';
    status = str;
    fullname =  prefs.getString('fullname') ?? 'Fullname';
    state =  prefs.getString('state') ?? 'email';
    imageurl =  prefs.getString('imageurl') ?? 'imageurl';
    if(status == 'agent'){
    verified = true;
    }
    // print(uid);
    setState(() {
      loading = false;
    });

  }
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
              currentAccountPicture: Stack(
                children: [
                  loading ? Icon(CupertinoIcons.profile_circled)
                  : InkWell(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) =>
                          PreviewImage(img: imageurl)
                      ));
                    },
                    child: Hero(
                      tag: 'img',
                      child: CachedNetworkImage(
                        alignment: Alignment.center,
                        imageUrl: imageurl,
                        imageBuilder: (context, imageProvider) =>
                            Container(
                              width: 150,
                              height: 150,
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
                        errorWidget: (context, url, error) =>   const Center(child: Icon(CupertinoIcons.person_circle))
                      ),
                    ),
                  ),
                //   CircleAvatar(
                //       radius: 50,
                // backgroundColor: Colors.white,
                // backgroundImage: NetworkImage(imageurl)
                //   ),
                  Visibility(
                    visible: verified,
                    child: Positioned(
                      bottom: 0,
                        right: 0,
                        child: Icon(Icons.verified, color: Colors.blue,)),
                  )
                ],
              ),

            accountName: loading
                ? null
            :Text(fullname,
              maxLines: 1,style: TextStyle(fontWeight: FontWeight.bold),),
            accountEmail: loading
                ? null
                :Text('Based on $state', maxLines: 1,),

          otherAccountsPictures: [
            //IconButton(tooltip: 'Edit profile',onPressed: (){}, icon: Icon(Icons.edit))
          ],
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('asset/wall.jpg'),
              fit: BoxFit.cover
            ),
          ),
          ),
          MenuListTileWidget()
        ],
      ),
    );
  }
}

class MenuListTileWidget extends StatefulWidget {
  const MenuListTileWidget({super.key});

  @override
  State<MenuListTileWidget> createState() => _MenuListTileWidgetState();
}

class _MenuListTileWidgetState extends State<MenuListTileWidget> {

  bool verified = false;
  var userData;// = {};
  bool loading = true;
  late String status;

  @override
  void initState(){
    super.initState();
    getUserData();
  }

  getUserData() async {
    setState(() {
      loading = true;
    });
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String str = prefs.getString('status') ?? 'email ...';
    status = str;
    // fullname =  prefs.getString('fullname') ?? 'Fullname';
    // email_address =  prefs.getString('email') ?? 'email';
    // imageurl =  prefs.getString('imageurl') ?? 'imageurl';
    if(status == 'agent'){
      verified = true;
    }
    // print(uid);
    setState(() {
      loading = false;
    });

  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Column(
          children: [
            ListTile(
              leading: Icon(Icons.edit_location_alt),
              title: Text('Change my location'),
              //subtitle: Text('Change to a preferred state'),
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) =>
                const UpdateState()
                ));
              },
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.share),
              title: Text('Share iRent with family and friends'),
              onTap: (){
                Share.share('Discover Single rooms, self-contained, full flats close to your work place for rent  https://irented.web.app/',
                    subject: 'Share iRent');
              },
            ),
            ListTile(
              leading: Icon(Icons.rate_review),
              title: Text('Rate iRent app'),
              onTap: () async {
                String uri = "https://play.google.com/store/apps/details?id=com.ulonet.irent";
                //var urr_launchable = await //;
                if(await canLaunch(uri)){
                await launch(uri);
                }else{
                print('cant launch');
                }
              },
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.support_agent),
              title: Text('Report an issue'),
              onTap: () async {
                String uri = "https://mailto:spackpw@gmail.com";
                //var urr_launchable = await //;
                if(await canLaunch(uri)){
                await launch(uri);
                }else{
                print('cant launch');
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.facebook_outlined),
              title: Text('Follow us for more tips'),
              onTap: () async {
                String uri = "https://instagram.com/irent.app";
                //var urr_launchable = await //;
                if (await canLaunch(uri)) {
                    await launch(uri);
                  } else {
                    print('cant launch');
                  }
              },
            ),
            const Divider(
            ),
            loading ? Container() : Visibility(
              visible: !verified,
              child: ListTile(
                leading: Icon(Icons.login),
                title: Text('Login as an agent'),
                trailing: CircleAvatar(
                  radius: 5.0,
                  backgroundColor: Colors.green,
                ),
                onTap: (){
                  if(kIsWeb){
                    ShowDownloadAppDialog(context);
                  }else {
                    Navigator.push(context, MaterialPageRoute(builder: (context) =>
                        AgentLogin()
                    ));
                  }
                },
              ),
            )
            ,
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Sign out'),
              onTap: ()  {
                showAlert(context);
              },
            ),
            const SizedBox(height: 20,),
            kIsWeb ?
            InkWell( onTap: () async {
              String uri = "https://irented.page.link/app";
              //var urr_launchable = await //;
              if (await canLaunch(uri)) {
                await launch(uri);
              } else {
                print('cant launch');
              }
            },
              child: Container(
                margin: EdgeInsets.all(20),
                width: double.infinity,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration:const ShapeDecoration(shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15),)
                ),
                    color: Colors.blue
                ),
                child: const Text('Open iRent App'),
              ),
            )
                : Container()

          ],
        ),
      ],
    );
  }

  void ShowDownloadAppDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (BuildContext build){
          return SimpleDialog(
            children: [
              const SizedBox(height: 30,),
              Container(
                child: Center(child: Text('Open app to login as an Agent!')),
              ),
              const SizedBox(height: 20,),
              SimpleDialogOption(
                onPressed: () async {

                  Navigator.pop(context);
                  String uri = "https://irented.web.app/app";
                  //var urr_launchable = await //;
                  if (await canLaunch(uri)) {
                    await launch(uri);
                  } else {
                    print('cant launch');
                  }
                },
                child: Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration:const ShapeDecoration(shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15),)
                  ),
                      color: Colors.blue
                  ),
                  child: const Text('Open iRent App'),
                ),
              )
            ],
          );
        });
  }
  void showAlert(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (BuildContext build){
          return SimpleDialog(

            title: const Text('Are you sure you want to sign out?'),

            children: [
              const SizedBox(height: 30,),
              SimpleDialogOption(
                child: Center(child: Text('Yes, sign out', style: TextStyle(color: Colors.red),)),
                onPressed: () async {
                  Navigator.pop(context);
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>
                      LoginPage()
                  ));
                  await AuthMethods().signout();

                },
              ),
              const SizedBox(height: 20,),
              SimpleDialogOption(
                onPressed: (){

                  Navigator.pop(context);
                },
                child: Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration:const ShapeDecoration(shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15),)
                  ),
                      color: Colors.blue
                  ),
                  child: const Text('No, cancel'),
                ),
              )
            ],
          );
        });
  }
}