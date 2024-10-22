import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:irent/pages/post_screen.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utilities/global_variable.dart';
import '../widgets/post_card.dart';
import '../widgets/preview_img.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  bool loading = true;
  late String     userid, fullname, imageurl, status, link;
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

    userid =  prefs.getString('userid') ?? 'id';
    fullname =  prefs.getString('fullname') ?? 'name';
    imageurl =  prefs.getString('imageurl') ?? 'imageurl';
    status =  prefs.getString('status') ?? 'role';
    link =  prefs.getString('link') ?? 'link';

    // print(uid);
    setState(() {
      loading = false;
    });

  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: false,
        title: const Text('My profile'),
        actions: [
          //IconButton(onPressed: (){}, icon: Icon(Icons.autorenew), tooltip: 'Renew your account',),
         // SpackPopUpMenuList(),
          IconButton(onPressed: (){
            Share.share('Discover Single rooms, self-contained, full flats close to your work place for rent! $link',
                subject: 'Share iRent');
          }, icon: Icon(Icons.ios_share), tooltip: 'Share', ),
        ],
      ),
      body: loading
          ? Center(child: CircularProgressIndicator(),)
          : Container(
        margin: EdgeInsets.symmetric(
            horizontal: width > webScreenSize ?  width * 0.2:15,
            vertical: width > webScreenSize ? 10:15
        ) ,
            child: Column(

              children: [
                const SizedBox(height: 20,),
                Stack(
                  children: [

                    InkWell(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context) =>
                            PreviewImage(img: imageurl)
                        ));
                      },
                      child: Hero(
                        tag: 'img',
                        child: kIsWeb
                            ? CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.white,
                            backgroundImage: NetworkImage(imageurl)
                        )
                        : CachedNetworkImage(
                            alignment: Alignment.center,
                            imageUrl: imageurl,
                            imageBuilder: (context, imageProvider) =>
                                Container(
                                  width: 100,
                                  height: 100,
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
                        )

                      ),
                    ),

                    Positioned(
                        bottom: 0,
                        right: 0,
                        child: Icon(Icons.verified, color: Colors.blue,))
                  ],
                ),
                const SizedBox(height: 10,),
                Text(fullname,
                  maxLines: 1,style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
                const SizedBox(height: 20,),
                const Divider(),

                Expanded(
                  child: FutureBuilder(
                      future: FirebaseFirestore.instance.collection('post')
                          .where('publisherid', isEqualTo: userid)

                          .orderBy('time', descending: true)
                          .get(),
                      builder: (context, snapshot){
                        if(snapshot.connectionState == ConnectionState.waiting){
                          return Center(
                              child: CircularProgressIndicator());
                        }
                        return ListView.builder(

                          //reverse: true,
                          physics: BouncingScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: (snapshot.data! as dynamic).docs.length,

                            itemBuilder: (context, index){
                              DocumentSnapshot snap = (snapshot.data! as dynamic).docs[index];


                              return Stack(
                                children: [
                                  PostCard(snap: snap,),
                                  Positioned(child:
                                  Text(snap['city'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, shadows: [
                                    Shadow(color: Colors.black, offset: Offset(1.0,1.0), blurRadius: 10.0)]),),
                                    top: 40, left: 16,),
                                ],
                              );
                            }
                        );
                      }
                  ),
                )
              ],
            ),
          ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (context) =>
              PostScreen()
          ));
        },
        child: Icon(Icons.add_home_outlined),
      ),
    );
  }

}
