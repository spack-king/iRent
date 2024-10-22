import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

import '../methods/firestore_methods.dart';
import '../pages/post_preview.dart';
import '../utilities/colors.dart';
import 'like_animation.dart';

class PostCard extends StatefulWidget {
  final snap;
  const PostCard({super.key, this.snap});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {

  late bool loggedIn;
  String userid = "nothing";
  bool isLikeAnimating = false, exists = false;

  @override
  void initState() {
       getUserData();
    super.initState();
  }

  getUserData() async {

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    userid =  prefs.getString('userid') ?? 'userid';
    exists = widget.snap['likes'].contains(userid);
    setState(() {

    });
  }
  addFav() async {
    await FirestoreMethods().addFav(
        widget.snap['postid'], userid,
        widget.snap['likes']);

    setState(() {
      if(!exists){
        exists =true;
      }
      else{
        exists = false;
      }
      isLikeAnimating = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (context) =>
            PostPreview(snap: widget.snap)
        ));
      },
      child: kIsWeb ? Container(
        margin: EdgeInsets.all(5.0),
        decoration:const ShapeDecoration(
            color: mobileSearchColor,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15),))),
        width: double.infinity,
        height: 200,
        child: Stack(
          children: [
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
                   // colorFilter: ColorFilter.mode(Colors.red, BlendMode.colorBurn)
                  )
                ),
              ),
              placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, error) => const Center(child: Icon(Icons.error))
              ,
            ),
            // Container(
            //
            //   decoration: ShapeDecoration(
            //       image: DecorationImage(
            //           image: NetworkImage(widget.snap['uri']),
            //           fit: BoxFit.fitWidth
            //       ),
            //       color: mobileSearchColor,
            //       shape: RoundedRectangleBorder(
            //           borderRadius: BorderRadius.all(Radius.circular(15),
            //           ))),
            //   height: 172,),
            Center(
              child:  AnimatedOpacity(
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

            Align(
              alignment: Alignment.topRight,
              child: LikeAnimation(

                  isAnimating: isLikeAnimating,
                  smallLike: true,
                  child: IconButton(

                      icon: exists  ?
                      const Icon(
                        Icons.favorite,
                        color: Colors.red,)
                          : const Icon(
                        Icons.favorite_border,
                        color: Colors.red,),
                    onPressed: addFav,
                  )),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('NGN ${widget.snap['amount']}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30, shadows: [
                      Shadow(color: Colors.black, offset: Offset(1.0,1.0), blurRadius: 10.0)]),),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [

                      Icon(Icons.payments_rounded, size: 15,),
                      Text(' ${widget.snap['pay_type']}', style: TextStyle( shadows: [
                        Shadow(color: Colors.black, offset: Offset(1.0,1.0), blurRadius: 10.0)]),)
                    ],)
                  ],
                ),
              ),
            )
          ],
        ),
      )
      : Container(
        margin: EdgeInsets.all(5.0),
        decoration:const ShapeDecoration(
            color: mobileSearchColor,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15),))),
        width: double.infinity,
        height: 200,
        child: Stack(
          children: [
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
                          // colorFilter: ColorFilter.mode(Colors.red, BlendMode.colorBurn)
                        )
                    ),
                  ),
              placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, error) => const Center(child: Icon(Icons.error))
              ,
            ),
            // Container(
            //
            //   decoration: ShapeDecoration(
            //       image: DecorationImage(
            //           image: NetworkImage(widget.snap['uri']),
            //           fit: BoxFit.fitWidth
            //       ),
            //       color: mobileSearchColor,
            //       shape: RoundedRectangleBorder(
            //           borderRadius: BorderRadius.all(Radius.circular(15),
            //           ))),
            //   height: 172,),
            Center(
              child:  AnimatedOpacity(
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

            Align(
              alignment: Alignment.topRight,
              child: LikeAnimation(

                  isAnimating: isLikeAnimating,
                  smallLike: true,
                  child: IconButton(

                    icon: exists  ?
                    const Icon(
                      Icons.favorite,
                      color: Colors.red,)
                        : const Icon(
                      Icons.favorite_border,
                      color: Colors.red,),
                    onPressed: addFav,
                  )),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('NGN ${widget.snap['amount']}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30, shadows: [
                      Shadow(color: Colors.black, offset: Offset(1.0,1.0), blurRadius: 10.0)]),),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [

                        Icon(Icons.payments_rounded, size: 15,),
                        Text(' ${widget.snap['pay_type']}', style: TextStyle( shadows: [
                          Shadow(color: Colors.black, offset: Offset(1.0,1.0), blurRadius: 10.0)]),)
                      ],)
                  ],
                ),
              ),
            )
          ],
        ),
      ).animate().fade(duration: 500.ms,).shimmer(duration: 400.ms, delay: 2000.ms),
    );
  }
}


//onTap: (){
//                     Navigator.push(context, MaterialPageRoute(builder: (context) =>
//                         VideoPage(videourl: widget.snap['uri'],
//                           username: widget.snap['username'],
//                           link: widget.snap['link'],
//                           views: widget.snap['view'],
//                           postid: widget.snap['postid'],caption: widget.snap['caption'],
//                         )));
//                   },