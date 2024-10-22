import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:irent/responsive/mobile_home.dart';
import 'package:irent/responsive/responsive_layout_screen.dart';
import 'package:irent/responsive/web_home.dart';
import 'package:irent/utilities/colors.dart';
import 'package:irent/utilities/global_variable.dart';

import 'firebase_options.dart';
import 'pages/login.dart';

Future<void> _fireMessageBacground(RemoteMessage message) async{
  print('bg message');
}
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebaseMessaging.instance.getInitialMessage();
  FirebaseMessaging.onBackgroundMessage(_fireMessageBacground);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'iRent',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
      scaffoldBackgroundColor: mobileBackgroundColor,
    ),

      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot){
          if( snapshot.connectionState == ConnectionState.active){
            if(snapshot.hasData){
              return ResponsiveLayout(
                mobileScreenLayout: MobileHome(),
                webScreenLayout: WebHome(),);
            }
            else if(snapshot.hasError){
              return Center(
                child: Text('${snapshot.error}'),
              );
            }
          }
          if(snapshot.connectionState == ConnectionState.waiting){
            return const Center(
              child: CircularProgressIndicator(
                color: primaryColor,
              ),
            );
          }
          return const SplashScreen();
        },
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:  Align(
        alignment: Alignment.bottomLeft,
        child: Container(
          padding: MediaQuery.of(context).size.width > webScreenSize
              ?  EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width /3)
              : const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
               Container(child: Image.asset("asset/toon.png", height: 250, width: 250,)),
              const Text('You are welcome to iRent',
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold), ),
              SizedBox(height: 16,),
              const Text('Find an accommodation that suits you!',
                style: TextStyle(fontSize: 20), ),
              SizedBox(height: 26,),
              InkWell(

                onTap: () async {
                  Navigator.push(context, MaterialPageRoute(builder: (context) =>
                  LoginPage()
                  ));
                },
                child: kIsWeb ? Container(
                  width: double.infinity,
                  height: 60,
                  alignment: Alignment.center,
                  decoration:const ShapeDecoration(
                      color: Colors.lightBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(25),)
                  ),

                  ),
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('Continue', style: TextStyle( color: Colors.white, fontWeight: FontWeight.bold),),
                        Icon(Icons.arrow_right_alt_outlined, size: 30, color: Colors.white,),
                      ].animate(interval: 1000.milliseconds).shakeX(duration: 500.milliseconds, delay: 2000.milliseconds),
                    ),
                  ),
                )
                : Container(
                  width: double.infinity,
                  height: 60,
                  alignment: Alignment.center,
                  decoration:const ShapeDecoration(
                    color: Colors.lightBlue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25),)
                    ),

                  ),
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('Continue', style: TextStyle( color: Colors.white, fontWeight: FontWeight.bold),),
                        Icon(Icons.arrow_right_alt_outlined, size: 30, color: Colors.white,),
                      ].animate(interval: 1000.milliseconds).shakeX(duration: 500.milliseconds, delay: 2000.milliseconds),
                    ),
                  ),
                ).animate().shimmer(duration: 500.ms, delay: 3000.ms),
              )
              // Text('Page still under construction! Follow us on Instagram to know when we\'ve fully launched!', style: TextStyle(backgroundColor: Colors.yellow),)
            ].animate(interval: 100.ms).slide(duration: 500.ms, ),
          ),
        ),
      ),
    );

  }

}

