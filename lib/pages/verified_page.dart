import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../responsive/responsive_layout_screen.dart';
import '../responsive/web_home.dart';
import '../utilities/global_variable.dart';
import '../responsive/mobile_home.dart';

class VerifiedPage extends StatefulWidget {
  const VerifiedPage({super.key});

  @override
  State<VerifiedPage> createState() => _VerifiedPageState();
}

class _VerifiedPageState extends State<VerifiedPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body:  Center(
        child: Container(
          padding: MediaQuery.of(context).size.width > webScreenSize
              ?  EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width /3)
              : const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(child: Image.asset("asset/toon_2.png", height: 250, width: 250,)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Account verified',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold), ),
                  Icon(Icons.verified, color: Colors.blue,).animate().shakeY(duration: 1000.ms, delay: 3000.ms),
                ],
              ),
              SizedBox(height: 16,),
              const Text('Congratulations, you are now a registered agent!',
                style: TextStyle(fontSize: 15), ),
              SizedBox(height: 26,),
              InkWell(

                onTap: () async {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>
                      ResponsiveLayout(
                        mobileScreenLayout: MobileHome(),
                        webScreenLayout: WebHome(),)
                  ));
                },
                child: kIsWeb ? Container(
                  width: double.infinity,
                  height: 60,
                  alignment: Alignment.center,
                  decoration:const ShapeDecoration(shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(25),)
                  ),
                      color: Colors.lightBlue
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('Proceed', style: TextStyle( color: Colors.white, fontWeight: FontWeight.bold),),
                        Icon(Icons.arrow_right_alt_outlined, size: 30, color: Colors.white,),
                      ]
                    ),
                  ),
                )
                : Container(
                  width: double.infinity,
                  height: 60,
                  alignment: Alignment.center,
                  decoration:const ShapeDecoration(shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(25),)
                  ),
                      color: Colors.lightBlue
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text('Proceed', style: TextStyle( color: Colors.white, fontWeight: FontWeight.bold),),
                          Icon(Icons.arrow_right_alt_outlined, size: 30, color: Colors.white,),
                        ]
                    ),
                  ),
                ).animate().shimmer(duration: 500.ms, delay: 3000.ms)
              )
              // Text('Page still under construction! Follow us on Instagram to know when we\'ve fully launched!', style: TextStyle(backgroundColor: Colors.yellow),)
            ].animate(interval: 100.ms).slide(duration: 500.ms, ),
          ),
        ),
      ),
    );
  }
}
