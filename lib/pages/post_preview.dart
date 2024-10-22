import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:irent/pages/profile_screen.dart';
import 'package:irent/utilities/global_variable.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../methods/firestore_methods.dart';
import '../utilities/colors.dart';
import '../widgets/like_animation.dart';
import '../widgets/preview_img.dart';
import 'chat.dart';

class PostPreview extends StatefulWidget {
  final snap;
  const PostPreview({super.key, this.snap});

  @override
  State<PostPreview> createState() => _PostPreviewState();
}

class _PostPreviewState extends State<PostPreview> {

  late bool loggedIn;
  String userid = "nothing";
  bool isLikeAnimating = false, exists = false;

  @override
  void initState() {
    updateViews();
    getUserData();
    super.initState();
  }
  void updateViews() {
    FirestoreMethods().updateViews(
        widget.snap['view'],
        widget.snap['postid']);

  }

  getUserData() async {

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String str = prefs.getString('status') ?? 'email ...';

    userid =  prefs.getString('userid') ?? 'id';
    // sender_name =  prefs.getString('fullname') ?? 'name';
    // sender_pics =  prefs.getString('imageurl') ?? 'imageurl';
    // sender_role =  prefs.getString('status') ?? 'role';

    exists = widget.snap['likes'].contains(userid);

    setState(() {

    });
  }

  addFav() async {
    await FirestoreMethods().addFav(
        widget.snap['postid'], userid,
        widget.snap['likes']);

    if(!exists){
      exists =true;
    }
    else{
      exists = false;
    }
    isLikeAnimating = true;
    setState(() {
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('Details'),
        actions: [
          IconButton(onPressed: (){
            Share.share('${widget.snap['description']} at ${widget.snap['city']}  ${widget.snap['link']}',
                subject: 'Share iRent');
          }, icon: Icon(Icons.ios_share), tooltip: 'Share', ),

        ],
      ),
      body: Container(

        margin: EdgeInsets.symmetric(
            horizontal: width > webScreenSize ?  width * 0.2:15,
            vertical: width > webScreenSize ? 10:15
        ) ,
        child: SingleChildScrollView(
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      InkWell(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context) =>
                              PreviewImage(img: widget.snap['uri'])
                          ));
                        },
                        child: Hero(
                          tag: 'img',
                          child: kIsWeb ?
                          CachedNetworkImage(
                            alignment: Alignment.center,
                            imageUrl: widget.snap['uri'],
                            imageBuilder: (context, imageProvider) =>
                                Container(
                                  height: 172,
                                  decoration: BoxDecoration(
                                      image: DecorationImage(
                                          image: imageProvider,
                                          fit: BoxFit.cover,
                                          //colorFilter: ColorFilter.mode(Colors.red, BlendMode.)
                                      )
                                  ),
                                ),
                            placeholder: (context, url) => const CircularProgressIndicator(),
                            errorWidget: (context, url, error) {
                              return  Icon(Icons.error);
                            },
                          )
                          : CachedNetworkImage(
                            alignment: Alignment.center,
                            imageUrl: widget.snap['uri'],
                            imageBuilder: (context, imageProvider) =>
                                Container(
                                  height: 172,
                                  decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: imageProvider,
                                        fit: BoxFit.cover,
                                        //colorFilter: ColorFilter.mode(Colors.red, BlendMode.)
                                      )
                                  ),
                                ),
                            placeholder: (context, url) => const CircularProgressIndicator(),
                            errorWidget: (context, url, error) {
                              return  Icon(Icons.error);
                            },
                          )
                          // Container(
                          //
                          //     decoration: ShapeDecoration(
                          //         image: DecorationImage(
                          //             image: NetworkImage(widget.snap['uri']),
                          //             fit: BoxFit.fitWidth
                          //         ),
                          //         color: mobileSearchColor,
                          //         shape: RoundedRectangleBorder(
                          //             borderRadius: BorderRadius.all(Radius.circular(15),
                          //             ))),
                          //     height: 200,)
                              .animate().shimmer(duration: 400.ms, delay: 4000.ms),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: Align(
                          alignment: Alignment.topRight,
                          child: Container(
                            color: Colors.amberAccent,
                            padding: EdgeInsets.all(5),
                            child: Text(widget.snap['rent_sell'], style: TextStyle(color: Colors.black),),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20,),
                 Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   children: [
                     Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Text('NGN ${widget.snap['amount']}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30,),),
                         Row(
                           mainAxisAlignment: MainAxisAlignment.start,
                           children: [

                             Icon(Icons.payments_rounded, size: 15,),
                             Text(' ${widget.snap['pay_type']}',)
                           ],),
                       ],
                     ),
                     LikeAnimation(
                         isAnimating: isLikeAnimating ,
                         smallLike: true,
                         child: IconButton(
                           icon: exists ?
                           const Icon(
                             Icons.favorite,
                             color: Colors.red,)
                               : const Icon(
                             Icons.favorite_border,
                             color: Colors.red,),
                           onPressed:addFav,
                         )),
                   ],
                 ),
                  const SizedBox(height: 20,),
                  const Divider(),
                  const SizedBox(height: 20,),

                  Text('Viewed ${widget.snap['view']} times',style: TextStyle(color: Colors.grey,),),
                  Text('${widget.snap['description']}',style: TextStyle(fontSize: 25,),),
                  const SizedBox(height: 10,),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [

                        Icon(Icons.location_on, size: 25, ),
                        Text(' ${widget.snap['city']}, ${widget.snap['state']}', style: TextStyle(fontSize: 20,),)
                      ],),
                  ),

                ].animate(interval: 100.ms).fade(duration: 500.ms,),
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const SizedBox(height: 200,),
                  Center(
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200,),
                      opacity: isLikeAnimating ? 1 : 0,
                      child: LikeAnimation(
                        child: const Icon(Icons.favorite, color: Colors.white, size: 100,),
                        isAnimating: isLikeAnimating,
                        duration: const Duration(
                          milliseconds: 400,
                        ),
                        onEnd: (){
                          setState(() {
                            isLikeAnimating = false;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: userid == widget.snap['publisherid']
          ? Container(

        margin: EdgeInsets.symmetric(
            horizontal: width > webScreenSize ?  width * 0.2:15,
            vertical: width > webScreenSize ? 10:15
        ) ,
            child: InkWell(
        onTap: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) =>
                ProfileScreen()
            ));
        },
        child: Container(
            margin: EdgeInsets.all(15),
            width: double.infinity,
            height: 60,
            alignment: Alignment.center,
            decoration:const ShapeDecoration(shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(25),)
            ),
                color: Colors.green
            ),
            child: Padding(
              padding: EdgeInsets.all(15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('View my profile', style: TextStyle( color: Colors.white, fontWeight: FontWeight.bold),),
                  Icon(CupertinoIcons.profile_circled, size: 30, color: Colors.white,),
                ].animate(interval: 1000.milliseconds).shakeX(duration: 500.milliseconds, delay: 2000.milliseconds),
              ),
            ),
        ),
      ),
          )
          : Container(
        margin: EdgeInsets.symmetric(
            horizontal: width > webScreenSize ?  width * 0.2:15,
            vertical: width > webScreenSize ? 10:15
        ) ,
            child: InkWell(
        onTap: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) =>
                Chat(
                  uid: widget.snap['publisherid'],
                  name: widget.snap['username'],
                  profilePics: widget.snap['profilepics'],
                  role: 'Agent',
                )
            ));
        },
        child: Container(
            margin: EdgeInsets.all(15),
            width: double.infinity,
            height: 60,
            alignment: Alignment.center,
            decoration:const ShapeDecoration(shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(25),)
            ),
                color: Colors.lightBlue
            ),
            child: Padding(
              padding: EdgeInsets.all(15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('Contact the Agent', style: TextStyle( color: Colors.white, fontWeight: FontWeight.bold),),
                  Icon(CupertinoIcons.chat_bubble_2_fill, size: 30, color: Colors.white,),
                ].animate(interval: 1000.milliseconds).shakeX(duration: 500.milliseconds, delay: 2000.milliseconds),
              ),
            ),
        ),
      ),
          ),
    );
  }
}
