import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/post_card.dart';

class FavouritePage extends StatefulWidget {
  const FavouritePage({super.key});

  @override
  State<FavouritePage> createState() => _FavouritePageState();
}

class _FavouritePageState extends State<FavouritePage> {

  late String userid;
  bool gettinUserData = true;
  @override
  void initState() {
    super.initState();
    getUserData();
  }

  getUserData() async {
    setState(() {
      gettinUserData = true;
    });
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    //final String str = prefs.getString('status') ?? 'status ...';

     userid =  prefs.getString('userid') ?? 'Fullname';
    // fullname =  prefs.getString('fullname') ?? 'email';
    //state =  prefs.getString('state') ?? 'state';

    setState(() {
      gettinUserData = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: gettinUserData ? const Center(child: CircularProgressIndicator(),)
      : Container(
        margin: EdgeInsets.all(5),
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder(
                  future:
                  FirebaseFirestore.instance.collection('post')
                  // .orderBy('time', descending: true)
                      .where('likes', arrayContains: userid)
                      .get()
                  ,
                  builder: (context, snapshot){

                    if(snapshot.connectionState == ConnectionState.waiting){
                      return const Center(
                          child: CircularProgressIndicator());
                      // child: ShimmerWidget());
                    }
                    if((snapshot.data! as dynamic).docs.length == 0){
                      return Center(child: Text('You don\'t have any favorite yet!')
                          .animate().flipH(duration: 200.ms,),);
                    }
                    return ListView.builder(
                      //reverse: true,
                        physics: const BouncingScrollPhysics(),
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
            ),
          ],
        ),
      ),
    );
  }
}
