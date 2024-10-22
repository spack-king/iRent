import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:irent/pages/verified_page.dart';

import '../methods/auth_methods.dart';
import '../model/all_user_data.dart';

class AgentLogin extends StatefulWidget {

  const AgentLogin({super.key});

  @override
  State<AgentLogin> createState() => _AgentLoginState();
}

class _AgentLoginState extends State<AgentLogin> {
  bool _isloading = false;
  TextEditingController _controller = TextEditingController();
  //real
  var publicKey = 'pk_live_79cfe5b4d69c8d90982ea316d77397ffa4c059d7';
  //test
  ///var publicKey = 'pk_test_55e328c4e63fb8b883db8904cb79eb5fad5e529a';
  final plugin = PaystackPlugin();

  @override
  void initState() {
    super.initState();
    plugin.initialize(publicKey: publicKey);
  }

  void pay() async {
    setState(() {
      _isloading = true;
    });

    if (_controller.text.isNotEmpty){
      try{
        int amount = 7500 * 100;

        Charge charge = Charge()
          ..amount = amount
          ..reference = 'iRent_${DateTime.now()}'
          ..email = _controller.text
          ..currency = 'NGN';

        CheckoutResponse response = await plugin.checkout(context,
            charge: charge, method: CheckoutMethod.card);

        if (response.status == true) {
          showDialog(
              context: context,
              builder: (BuildContext build){
                return const SimpleDialog(
                  title: Text('Do not terminate this process!'),

                  children: [
                    SimpleDialogOption(
                      child: Center(child: Text('Verifying...', style: TextStyle(color: Colors.green),)),
                    ),
                    SizedBox(height: 25,),
                    SimpleDialogOption(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  ],
                );
              });

          updateUserInfo();

        } else {

          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              backgroundColor: Colors.red,
              content: Text(
                'Failed: ${response.message}',
              )));
        }
      }catch(err){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              '${err}',
            )));
      }

    }
    else{
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'Enter your email address',
          )));
    }

    setState(() {
      _isloading = false;
    });
  }

  Future<void> updateUserInfo() async {
    String res = await AuthMethods().updateAgentInfo();

    if(res == 'Updated successful!'){

      final status = 'agent';
      UserData().setStatus(status);

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>
      const VerifiedPage()
      ));

    }
  }

  @override
  Widget build(BuildContext context) {
    final inputBorder = OutlineInputBorder(
        borderSide: Divider.createBorderSide(context)
    );
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('Agent Login'),
        centerTitle: false,
      ),
      body:  Center(
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.all(15),
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.verified, size: 45,),
                  title: Text('Build more trust with accommodation finders', style: TextStyle(fontSize: 15),),
                ),
                const SizedBox(height: 10,),
                const ListTile(
                  leading: Icon(CupertinoIcons.chat_bubble_2_fill, size: 45,),
                  title: Text('Get direct message from each new post made', style: TextStyle(fontSize: 15),),
                ),
                const SizedBox(height: 10,),
                const ListTile(
                  leading: Icon(Icons.public, size: 45,),
                  title: Text('Discover more ways to publicise your properties', style: TextStyle(fontSize: 15),),
                ),
                const SizedBox(height: 10,),
                const ListTile(
                  leading: Icon(Icons.campaign, size: 45,),
                  title: Text('Promote your properties to wider audience', style: TextStyle(fontSize: 15),),
                ),
                const SizedBox(height: 10,),
                const ListTile(
                  leading: Icon(Icons.manage_accounts, size: 45,),
                  title: Text('Post and manage your properties on the go!', style: TextStyle(fontSize: 15),),
                ),
                const SizedBox(height: 10,),
                const ListTile(
                  leading: Icon(Icons.phone_iphone, size: 45,),
                  title: Text('Be the first to get and test the latest version of the app!', style: TextStyle(fontSize: 15),),
                ),
                const SizedBox(height: 25,),
                TextField(
                  enableSuggestions: true,
                  controller: _controller,
                  enabled: !_isloading,
                  decoration: InputDecoration(
                    hintText: 'Confirm your email address',
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
                ),
                const SizedBox(height: 15,),

                InkWell(
                  onTap: (){
                    pay();
                  },
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
                        : const Text('Log in as an Agent'),
                  ),
                ),
              ].animate(interval: 100.ms).fade(duration: 500.ms,),
            ),
          ),
        ),
      ),
    );
  }
}
