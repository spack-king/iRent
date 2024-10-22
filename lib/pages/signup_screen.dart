import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:irent/pages/update_state.dart';
import 'package:url_launcher/url_launcher.dart';

import '../methods/auth_methods.dart';
import '../model/all_user_data.dart';
import '../utilities/colors.dart';
import '../utilities/global_variable.dart';
import '../widgets/text_field_input.dart';
import '../widgets/utils.dart';
import 'login.dart';

class SignUpScreenState extends StatefulWidget {
  const SignUpScreenState({Key? key}) : super(key: key);

  @override
  State<SignUpScreenState> createState() => _SignUpScreenStateState();
}

class _SignUpScreenStateState extends State<SignUpScreenState> {
  final TextEditingController _emailEditingController = TextEditingController();
  final TextEditingController _passwordEditingController = TextEditingController();
  final TextEditingController _fullnameEditingController = TextEditingController();
  //final TextEditingController _passwordEditingController = TextEditingController();
  late String selectedImage;
  late XFile? file_str;
  String text = '';
  bool _isLoading = false, checked_box = false;
  bool _isObscure = true;
  @override
  void dispose(){
    super.dispose();
    _emailEditingController.dispose();
    _passwordEditingController.dispose();
    _fullnameEditingController.dispose();
  }

  void selectImage() async{
    //ImagePicker().pickImage(source: source);
     final image = await  ImagePicker().pickImage(source: ImageSource.gallery);
     if(image == null) return;

    setState(() {
      selectedImage = image.path;
      file_str = image ;
      text = 'add';

      // ...
      // if (kIsWeb) {
      // Image.network(pickedFile.path);
      // } else {
      // Image.file(File(pickedFile.path));
      // }
    });
  }

  void signUp()
  async {
    String res = 'Fill all spaces!';
     if(_isLoading){
    showSpackSnackBar('Account creation in progress!', context,Colors.amberAccent, Icons.timelapse_outlined);
    }else{
       if(text == ''){
         showSpackSnackBar("Add your profile pics!", context, Colors.amberAccent, Icons.add_a_photo);
       }else if(_fullnameEditingController.text.isEmpty){
         res = "Please enter your Full name";
         showSpackSnackBar(res,  context, Colors.amberAccent, Icons.person);
       }else if(_emailEditingController.text.isEmpty){
         res = "Enter your email address";
         showSpackSnackBar(res,  context, Colors.amberAccent, Icons.email);
       }
       else if(_passwordEditingController.text.isEmpty){
         res = "Enter your password";
         showSpackSnackBar(res,  context, Colors.amberAccent, Icons.lock);
       }else if(!checked_box){

         showSpackSnackBar('Confirm the terms of use!', context, Colors.amberAccent, Icons.check_box);
       }

       else{
         setState(() {
           _isLoading = true;
         });
         res = await AuthMethods().signUpUser(username: '',
             fullname: _fullnameEditingController.text,
             email: _emailEditingController.text,
             password: _passwordEditingController.text, file:file_str);


         if(res == 'Account created successfully!'){
           //ad data to sharedpref
           var userSnap = await FirebaseFirestore.instance.collection('user')
               .doc(FirebaseAuth.instance.currentUser?.uid)
               .get();
            final userData = userSnap.data()!;
           // final userid = userData['userid'];
           // final fullname = userData['fullname'];
           // final username = userData['username'];
           // final email = userData['email'];
           // final password = userData['password'];
            final imageurl = userData['imageurl'];
           // final state = userData['state'];
           // final city = userData['city'];
            final link = userData['link'];
           // final timestamp = userData['timestamp'];

           UserData().updateAllData(FirebaseAuth.instance.currentUser!.uid, _fullnameEditingController.text, _fullnameEditingController.text,
               _emailEditingController.text, _passwordEditingController.text,
               imageurl, '', '',link, 'user', 'timestamp');

           showSpackSnackBar('Account created successfully!',  context, Colors.green, Icons.done);
           Navigator.of(context).pushReplacement(MaterialPageRoute(
               builder: (context) =>
                   // ResponsiveLayout(
                   // webScreenLayout: MyTabWeb(), mobileScreenLayout: MyTab())
             UpdateState()
           ));

         }else{
           showSpackSnackBar(res,  context, Colors.red, Icons.error);
         }
         setState(() {
           _isLoading = false;
         });
       }
     }
  }

  void navigateToLogin(){
    //Navigator.pop(context);
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) =>LoginPage()));
  }
  @override
  Widget build(BuildContext context) {
    final inputBorder = OutlineInputBorder(
        borderSide: Divider.createBorderSide(context)
    );
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('1 0f 1 step'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Container(
            padding: MediaQuery.of(context).size.width > webScreenSize
                ?  EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width /3)
                : const EdgeInsets.symmetric(horizontal: 32),
           // width: double.infinity,
            child: Column(
             // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Flexible(child: Container(), flex: 2,),
                // Image.asset('assets/unical.png', height: 100,),
                // const SizedBox(height: 64,),
                //PROFILE PICS
                Stack(
                  children: [
                    text != ''
                        ?
                    kIsWeb ? CircleAvatar(
                        radius: 64,
                        backgroundImage: NetworkImage(selectedImage) )
                        :CircleAvatar(
                        radius: 64,
                        backgroundImage: FileImage(File(selectedImage)) )
                        :
                    const CircleAvatar(
                      radius: 64,
                      backgroundImage: AssetImage('asset/profle_placeholder.png'),
                    ),
                    !_isLoading ? Positioned(
                        bottom: 0.0,
                        right: 0.0,
                        child: IconButton(
                          icon: Icon(Icons.add_a_photo,),
                          onPressed: () => selectImage(),
                        ))
                    //empty
                        : Positioned(
                        bottom: 0.0,
                        right: 0.0,
                        child: Container()),
                  ],
                ),
                SizedBox(height: 16,),
                //fullname textbox
                TextFieldInput(
                  enabled: !_isLoading,
                  icon: Icons.person,
                  textEditingController: _fullnameEditingController,
                  hintText: "John Doe",
                  textInputType: TextInputType.emailAddress, labelText: 'Enter your fullname',),
                SizedBox(height: 16,),
                //nickname textbox
                // TextFieldInput(
                //   enabled: !_isLoading,
                //   icon: Icons.face,
                //   textEditingController: _usernameEditingController,
                //   hintText: "e.g: Johnny",
                //   textInputType: TextInputType.emailAddress, labelText: 'Enter your nick name',),
                // SizedBox(height: 16,),
                //email textbox
                TextFieldInput(
                  enabled: !_isLoading,
                  icon: Icons.email,
                  textEditingController: _emailEditingController,
                  hintText: "abcd@email.com",
                  textInputType: TextInputType.emailAddress, labelText: 'Enter your Email address',),
                SizedBox(height: 16,),
                //password
                TextField(
                  enableSuggestions: true,
                  controller: _passwordEditingController,
                  enabled: !_isLoading,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    labelText: 'Enter your Password',

                    border: inputBorder,
                    focusedBorder: inputBorder,
                    enabledBorder: inputBorder,
                    filled: true,
                    contentPadding: const EdgeInsets.all(8),
                    suffixIcon: IconButton(
                      onPressed: (){
                        setState(() {
                          _isObscure = !_isObscure;
                        });
                      },
                      icon: Icon(  _isObscure ? Icons.visibility : Icons.visibility_off),
                    ),
                    prefixIcon: Icon(
                      Icons.lock,
                      color: Colors.grey,
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  obscureText: _isObscure,
                ),
                SizedBox(height: 24,),
                //checkbox
                CheckboxListTile(
                  enabled: !_isLoading,
                  value: checked_box, onChanged: (newValue){
                  setState(() {
                    checked_box = newValue!;
                  });
                },
                  checkColor: Colors.blue,

                  title: Container(
                    child:  InkWell(
                      onTap: () async {
                        String uri = 'https://irented.web.app/terms';
                        //var urr_launchable = await //;
                        if(await canLaunch(uri)){
                          await launch(uri);
                        }else{
                          print('cant launch');
                        }
                      },
                      child: RichText(
                          text: const TextSpan(
                              text: '',
                              style: TextStyle(fontSize: 16),
                              children: <TextSpan> [
                                TextSpan(text: 'I\'ve read and agreed to the ', style: TextStyle(color: Colors.white)),
                                TextSpan(text:'Terms of use', style: const TextStyle(
                                    color: Colors.blue
                                )),
                              ]
                          )),
                    ),
                  ),),
                SizedBox(height: 16,),

                InkWell(
                  onTap: () => signUp(),
                  child: Container(
                    width: double.infinity,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    decoration:const ShapeDecoration(shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25),)
                    ),
                        color: Colors.blue
                    ),
                    child: _isLoading ? const Center(child: CircularProgressIndicator(
                      color: primaryColor,
                    ),): const Text('Sign up'),
                  ),
                ),
                const SizedBox(height: 12,),
               // Flexible(child: Container(), flex: 2,),

              ].animate(interval: 100.ms).fade(duration: 500.ms, ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        margin: EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              child: Text("Already have an account? "),
              padding: const EdgeInsets.symmetric(
                  vertical: 8
              ),
            ) ,
            InkWell(
              onTap: navigateToLogin,
              child: Container(
                child: Text("Log in",
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),),
                padding: const EdgeInsets.symmetric(
                    vertical: 8
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}