import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:irent/model/all_user_data.dart';
import 'package:irent/pages/signup_screen.dart';
import 'package:irent/utilities/global_variable.dart';
import 'package:irent/widgets/utils.dart';
import 'package:url_launcher/url_launcher.dart';

import '../methods/auth_methods.dart';
import '../responsive/mobile_home.dart';
import '../responsive/responsive_layout_screen.dart';
import '../responsive/web_home.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailEditingController = TextEditingController();
  final TextEditingController _passwordEditingController = TextEditingController();
  bool _isloading = false;
  bool _isObscure = true, checked = false;
  late Duration email, pass;


  @override
  void initState() {
    email = 0.ms;
    pass = 0.ms;
  }

  @override
  void dispose(){
    super.dispose();
    _emailEditingController.dispose();
    _passwordEditingController.dispose();
  }

  void loginUser() async {


    if(_isloading){
      showSpackSnackBar('Login in progress!', context,Colors.amberAccent, Icons.timelapse_outlined);
    } else if(_emailEditingController.text.isEmpty){
      setState(() {
        email = 500.ms;
      });

      showSpackSnackBar('Enter your email address!', context, Colors.amberAccent, Icons.email);
    } else if(_passwordEditingController.text.isEmpty){
      setState(() {
        pass = 500.ms;
      });
      showSpackSnackBar('Enter your password!', context, Colors.amberAccent, Icons.password);
    }else if(!checked){

      showSpackSnackBar('Confirm the terms of use!', context, Colors.amberAccent, Icons.check_box);
    }
    else{
      setState(() {
        _isloading = true;
      });

      String res = await AuthMethods().loginUser(email: _emailEditingController.text, password: _passwordEditingController.text);

      if(res == 'Logged in successfully!'){
        var userSnap = await FirebaseFirestore.instance.collection('user')
            .doc(FirebaseAuth.instance.currentUser?.uid)
            .get();
        final userData = userSnap.data()!;
        final userid = userData['userid'];
        final fullname = userData['fullname'];
       // final username = userData['username'];
        final email = userData['email'];
        final password = userData['password'];
        final imageurl = userData['imageurl'];
        final state = userData['state'];
        final link = userData['link'];
        final status = userData['status'];
        final timestamp = userData['timestamp'];

        UserData().updateAllData(userid, fullname, 'username', email, password, imageurl, state, 'city',link, status, '${timestamp}');

        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) =>
                ResponsiveLayout(
                  mobileScreenLayout: MobileHome(),
                  webScreenLayout: WebHome(),)
        ));

        showSpackSnackBar(res, context, Colors.green, Icons.done_rounded);
      }else{

        showSpackSnackBar(res, context, Colors.red, Icons.error);
      }
      setState(() {
        _isloading = false;
      });
    }

  }

  void navigateToSignUp(){
   // Navigator.pop(context);
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) =>SignUpScreenState()));
  }

  @override
  Widget build(BuildContext context) {
    final inputBorder = OutlineInputBorder(
        borderSide: Divider.createBorderSide(context)
    );
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Login'),
      ),

      body: Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Container(
            padding: MediaQuery.of(context).size.width > webScreenSize
                ?  EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width /3)
                : const EdgeInsets.symmetric(horizontal: 32),
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Flexible(child: Container(), flex: 2,),
                Image.asset('asset/logo.png', height: 100,),
                const SizedBox(height: 40,),
                //EMAIL ADDRESS INPUT
                TextField(
                  enableSuggestions: true,
                  controller: _emailEditingController,
                  enabled: !_isloading,
                  decoration: InputDecoration(
                    hintText: 'abcd@mail.com',
                    labelText: 'Enter your Email address',

                    border: inputBorder,
                    focusedBorder: inputBorder,
                    enabledBorder: inputBorder,
                    filled: true,
                    contentPadding: const EdgeInsets.all(8),
                   prefixIcon: Icon(
                      Icons.email,
                      color: Colors.grey,
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                 ).animate().shakeX(duration: email,),

                const SizedBox(height: 16,),
//PASSWORD ADDRESS INPUT
                TextField(
                  enableSuggestions: true,
                  controller: _passwordEditingController,
                  enabled: !_isloading,
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
                ).animate().shakeX(duration: pass,),
                SizedBox(height: 24,),
                //checkbox
                CheckboxListTile(
                    value: checked, onChanged: (newValue){
                    setState(() {
                      checked = newValue!;
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
                InkWell(
                  onTap: loginUser,
                  child: Container(
                    width: double.infinity,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    decoration:const ShapeDecoration(shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25),)
                    ),
                        color: Colors.blue
                    ),
                    child: _isloading ?
                    const Center(
                        child: CircularProgressIndicator( color: Colors.white,))
                        : const Text('Log in'),
                  ),
                ),
                SizedBox(height: 24,),

                // Flexible(child: Container(), flex: 2,),

              ].animate(interval: 100.ms).fade(duration: 500.ms,),
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
              child: Text("Don't have an account? "),
              padding: const EdgeInsets.symmetric(
                  vertical: 8
              ),
            ) ,
            InkWell(
              onTap:  navigateToSignUp,
              child: Container(
                child: Text("Sign up", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),),
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
