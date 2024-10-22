import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:irent/model/user.dart' as model;
import 'package:get_thumbnail_video/video_thumbnail.dart';
import 'firestore_methods.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

class AuthMethods{
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //User details
  Future<model.User> getUserDetails() async {
    User currentUser = _auth.currentUser!;

    DocumentSnapshot snapshot = await _firestore.collection('user')
        .doc(currentUser.uid)
        .get();
    return model.User.fromSnap(snapshot);
    //
    //  followers: (snapshot.data() as Map<String, dynamic>)['folloe'];
    //snapshot.data() as Map<String, dynamic>)['username'];
  }


  Future<String> updateLocation({required String state}) async {
    String res = '';
    try{

      await _firestore.collection('user').doc(_auth.currentUser?.uid).update({
        'state': state,
      });
      res = 'Updated successful!';

    }
    catch(err){
      res = 'Failed to update location!';
    }
    print(res);
    return res;
  }
  Future<String> updateAgentInfo() async {
    String res = '';
    try{

      await _firestore.collection('user').doc(_auth.currentUser?.uid).update({
        'status': 'agent',
      });
      res = 'Updated successful!';

    }
    catch(err){
      res = 'Failed to update location!';
    }
    print(res);
    return res;
  }

  //sign up user
  Future<String> signUpUser({
    required String username,
    required String fullname,
    required String email,
    required String password,
    required XFile? file,
  }) async {
    String res = "Fill in all the spaces!";
    String link = 'https://irented.web.app';
    try{
        if(await isUserUniqueNameExists(fullname) == 'Network failure!'){
          res = 'Network failure!';
        }else if(await isUserUniqueNameExists(fullname) == 'already exist'){

          res = 'User name already exist, try another username!';
        }
        else{
          //register user
          UserCredential cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
          //add user to firestore
          String photourl = await StorageMethods().uploadImageToStorage('profilepics', file, false);

          if(!kIsWeb){
            link = await createdDynamicLink(Username: fullname, imageurl: photourl);
          }
          model.User user =  model.User(
              userid: cred.user!.uid,
              fullname: fullname,
              username: username,
              email: email,
              timestamp: DateTime.timestamp(),
            state: 'Cross River',
            city: '',
            link: link,
            status: 'user',
              password: password,
            imageurl: photourl,
            fav: [],);

          await _firestore.collection('user').doc(cred.user!.uid).set(user.toJson());
          await _firestore.collection('UniqueUsernames').doc('unique').update({
            'userid': FieldValue.arrayUnion([fullname])
          });
          res = 'Account created successfully!';

        }

        // await _firestore.collection('User').add(data);
    } catch(err){{
      switch(err.toString()){
        case '[firebase_auth/email-already-in-use] The email address is already in use by another account.':
          res = 'The email address already exist!';
          break;
        case '[firebase_auth/invalid-email] The email address is badly formatted.':
          res = 'Invalid email address!';
          break;
        default:
          res = 'Something went wrong somewhere!';
      }
    }

    }

    print(res);
    return res;
  }

//login user
  Future<String> loginUser({
    required String email,
    required String password
  }) async {
    String res = "Some error occurred!";
    try{
      if(email.isNotEmpty || password.isNotEmpty){
        await _auth.signInWithEmailAndPassword(email: email, password: password);
        res = "Logged in successfully!";
      }else{
        res = "Please enter all the fields!";
      }
    }catch(err){
      switch(err.toString()){
        case '[firebase_auth/email-already-in-use] The email address is already in use by another account.':
          res = 'The email address already exist!';
          break;
        case '[firebase_auth/invalid-email] The email address is badly formatted.':
          res = "Invalid email address!";
          break;
        case '[firebase_auth/INVALID_LOGIN_CREDENTIALS] An internal error has occurred. [ INVALID_LOGIN_CREDENTIALS ]':
          res = "Incorrect password!";
          break;
        case '[firebase_auth/invalid-credential] The supplied auth credential is incorrect, malformed or has expired.':
          res = "Account does not exist!";
        default:
          res = 'Something went wrong somewhere!';
      }
      print(err);
    }
    return res;
  }

  Future<String> createdDynamicLink({required String Username, required String imageurl}) async {
    String link = 'https://irented.web.app/?ty=us&n=$Username';
    String uriPrefix = 'https://irented.page.link';
    try{
      final dynamicLinkParams = DynamicLinkParameters(
          link: Uri.parse(link),
          uriPrefix: uriPrefix,
      androidParameters: const AndroidParameters(packageName: 'com.irent.irent'),
      iosParameters: const IOSParameters(bundleId: 'com.irent.irent'),
      socialMetaTagParameters: SocialMetaTagParameters(
        title: '$Username: Discover accommodations that suits you in your area!',
          description: 'Single room, self-contained, full flat, land, shop, plaza, buildings ...',
      imageUrl: Uri.parse(imageurl)));
      final dynamicLnk = await FirebaseDynamicLinks.instance.buildShortLink(dynamicLinkParams);
      link = dynamicLnk.shortUrl.toString();
    }catch(e){
      print(e);
    }
    return link;
  }

  Future<void> signout() async{
    await _auth.signOut();

  }

  Future<String> isUserUniqueNameExists(String username) async {

    String exists = "Network failure!";
  try{
    DocumentSnapshot snap = await _firestore.collection('UniqueUsernames').doc('unique').get();
    List username_list = (snap.data()! as dynamic)['userid'];

    if(username_list.contains(username)){
      exists = 'already exist';

    }else{
      exists = 'not already exist';
    }
  }catch(e){
    print(e.toString());
  }

    return exists;
}
}