import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../model/posts.dart';
import 'package:http/http.dart' as http;

class FirestoreMethods{
final FirebaseFirestore _firestore = FirebaseFirestore.instance;


Future<String> createdDynamicLink({required String desc, required String imageurl, required String id}) async {
  String link = 'https://irented.web.app/?ty=ps&n=$id';
  String uriPrefix = 'https://irented.page.link';
  try{
    final dynamicLinkParams = DynamicLinkParameters(
        link: Uri.parse(link),
        uriPrefix: uriPrefix,
        androidParameters: const AndroidParameters(packageName: 'com.irent.irent'),
        iosParameters: const IOSParameters(bundleId: 'com.irent.irent'),
        socialMetaTagParameters: SocialMetaTagParameters(
            title: desc,
            description: 'Discover more single room, self-contained, full flat, land, shop, plaza, buildings that suits you in your area!',
            imageUrl: Uri.parse(imageurl)));
    final dynamicLnk = await FirebaseDynamicLinks.instance.buildShortLink(dynamicLinkParams);
    link = dynamicLnk.shortUrl.toString();
  }catch(e){
    print(e);
  }
  return link;
}

Future<String> uploadPost(String rent_sell,String pay_type,String description,String amount,String city,
    String state,String category,XFile? file, String uid,
    String username, String profileImage) async{
  String res = "Some error occurred!";
  String link = 'https://irented.web.app';
  try{
    String photoUrl = await StorageMethods().uploadImageToStorage('posts', file, true);
    String postid = '${Timestamp.now().millisecondsSinceEpoch}_$uid';//const Uuid().v1();

    if(!kIsWeb){
      link = await createdDynamicLink(desc: '$description at $city', imageurl: photoUrl, id: postid);
    }
    Post post = Post(
        rent_sell: rent_sell,
        pay_type: pay_type,
        description: description,
        amount: amount,
        city: city,
        state: state,
        category: category,
        publisherid: uid,
        username: username,
        postid: postid,
        time: DateTime.now(),
        uri: photoUrl,
        view: 0,
        link: link,
        profilepics: profileImage, likes: [], storage_location: '');

    _firestore.collection('post').doc(postid).set(
        post.toJson(),
    );
    res = "Done successfully!";
  }catch(err){
    res = err.toString();
  }
  return res;
}
//
  Future<void> addFav(String postid, String uid, List likes) async {
    try{

      if(likes.contains(uid)){
        await _firestore.collection('post').doc(postid).update({
          'likes': FieldValue.arrayRemove([uid]),
        });
      }else{
        await _firestore.collection('post').doc(postid).update({
          'likes': FieldValue.arrayUnion([uid]),
        });
      }
    }catch(e){
      print(e.toString(),);
    }
  }

  Future<void> add2Fav(String postid, String uid, List fav) async {
  try{

    if(fav.contains(postid)){
      await _firestore.collection('user').doc(uid).update({
        'fav': FieldValue.arrayRemove([postid]),
      });
    }else{
      await _firestore.collection('user').doc(uid).update({
        'fav': FieldValue.arrayUnion([postid]),
      });
    }
  }catch(e){
    print(e.toString(),);
  }
}
//
Future<void> postComment(String postid, String text, String uid, String name, String profilePic) async {
  try{
    if(text.isNotEmpty){
      String commentId  = const Uuid().v1();
     await _firestore.collection('post').doc(postid).collection('comments').doc(commentId).set(
        {
          'profilePic': profilePic,
          'name': name,
          'uid': uid,
          'text': text,
          'commentId': commentId,
          'datePublished': DateTime.now(),
        }
      );
    }else{
      print('Text is empty');
    }
  }catch(e){
    print(e.toString());
  }
}
//
// Future<void> deletePost(String postId) async {
//   try{
//    await _firestore.collection('post')
//         .doc(postId).delete();
//   }catch(err){
//     print(err.toString());
//   }
// }
//
Future<void> updateViews(int view, String postid) async{
  //print('$postid $view');
  int added = view +1;
  await _firestore.collection('post').doc(postid)//.collection('Post').doc(postid)
      .update(
      {
        'view': added,
      }
  );
}
  pickVideo() async{
  final picker = ImagePicker();
  XFile? videoFile;
  try{
   videoFile = await picker.pickVideo(source: ImageSource.gallery);
   return videoFile!.path;
  }catch(e){
    print('Error: $e');
  }
  }
  Future<void> SENDNotificationSpack(
      {required String receiverid, required String message}) async {
    DocumentSnapshot snap =
    await FirebaseFirestore.instance.collection('token').doc(receiverid)
        .get();
    String token = snap['token'];
    print(token);
    pushNotification(token, message);
  }

  void pushNotification(String token, String message) async {
    try{

      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=AAAACM9IO5E:APA91bEffXyOavxZr0xZ5mpXfG-URH7HOH7DhZ-ZbIuWheR9dcZ1tHjyqik7GBvca5y2xcWbyk1rZ2fFZSAjD82XvSOOCCAjp1UGId7ch30JtG76eeNgstZAzfYt0vTxd58xXqfyzojZ'
        },
        body: jsonEncode(
          <String, dynamic>{
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'status': 'done',
              'body': message,
              'title': 'New message',
            },

            "notification": <String, dynamic>{
              "title": "New message",
              "body": message,
              "android_channel_id": "com.irent.ient"
            },
            "to": token,

          }
        )
      );

    }catch(e){
      if(kDebugMode){
        print('error because app is in debug mode');
      }
    }
  }
}


class StorageMethods{
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> uploadImageToStorage(String childname, XFile? file, bool isPost) async{
    Reference ref =  _storage.ref().child(childname).child(_auth.currentUser!.uid);

    var metadata;
    metadata = SettableMetadata(
      contentType: 'image/jpeg',
      customMetadata: {'picked-file-path': file!.path},
    );

    if(isPost){
      String id = const Uuid().v1();
      ref = ref.child(id);
      metadata = SettableMetadata(
       // contentType: 'video/mp4',
        contentType: 'image/jpeg',
        customMetadata: {'picked-file-path': file.path},
      );
    }


    UploadTask uploadTask = ref.putData(await file.readAsBytes(),metadata) ;

    TaskSnapshot snap = await uploadTask;

    String downloadUrl = await snap.ref.getDownloadURL();
    return downloadUrl;
  }


}