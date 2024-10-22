import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

import '../methods/firestore_methods.dart';
import '../utilities/colors.dart';
import '../utilities/global_variable.dart';
import '../widgets/utils.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {

  final picker = ImagePicker();
  late XFile? videoFile;
  //late Uint8List? uint8list;
  late String _video ='';

  TextEditingController controller = TextEditingController();
  TextEditingController amount_controller = TextEditingController();
  TextEditingController city_controller = TextEditingController();
  bool isloading = false, gettinUserData = true;

  String selectedState = 'Select', category = 'Select category';
  String tag = 'Select tag';
  String payment_type = 'Select payment type';
  Duration float = 0.ms;
  List<States> _links = <States>[];
  List<States> _category_list = <States>[];
  List<States> _tag_list = <States>[];
  List<States> _payment_type_list = <States>[];
  late String userid, fullname, imageurl;

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
    city_controller.dispose();
    amount_controller.dispose();
  }

  @override
  void initState() {
    super.initState();
    _links
      ..add(States( statename: 'Abia', capital: 'Umuahia'))

      ..add(States( statename: 'Adamawa', capital: 'Yola'))
      ..add(States( statename: 'Akwa Ibom', capital: 'Uyo'))
      ..add(States( statename: 'Anambra', capital: 'Awka'))
      ..add(States( statename: 'Bauchi', capital: 'Bauchi'))
      ..add(States( statename: 'Benue', capital: 'Yenagoa'))
      ..add(States( statename: 'Borno', capital: 'Makurdi'))
      ..add(States( statename: 'Bayelsa', capital: 'Maiduguri'))
      ..add(States( statename: 'Cross River', capital: 'Calabar'))
      ..add(States( statename: 'Delta', capital: 'Asaba'))
      ..add(States( statename: 'Ebonyi', capital: 'Abakaliki'))
      ..add(States( statename: 'Edo', capital: 'Benin City'))
      ..add(States( statename: 'Ekiti', capital: 'Ado Ekiti'))
      ..add(States( statename: 'Enugu', capital: 'Enugu'))
      ..add(States( statename: 'Federal Capital Territory', capital: 'Abuja'))
      ..add(States( statename: 'Gombe', capital: 'Gombe'))
      ..add(States( statename: 'Imo', capital: 'Owerri'))
      ..add(States( statename: 'Jigawa', capital: 'Dutse'))
      ..add(States( statename: 'Kaduna', capital: 'Kaduna'))
      ..add(States( statename: 'Kano', capital: 'Kano'))
      ..add(States( statename: 'Katsina', capital: 'Katsina'))
      ..add(States( statename: 'Kebbi', capital: 'Birnin Kebbi'))
      ..add(States( statename: 'Kogi', capital: 'Lokoja'))
      ..add(States( statename: 'Kwara', capital: 'Ilorin'))
      ..add(States( statename: 'Lagos', capital: 'Ikeja'))
      ..add(States( statename: 'Nasarawa', capital: 'Lafia'))
      ..add(States( statename: 'Niger', capital: 'Minna'))
      ..add(States( statename: 'Ogun', capital: 'Abeokuta'))
      ..add(States( statename: 'Ondo', capital: 'Akure'))
      ..add(States( statename: 'Osun', capital: 'Oshogbo'))
      ..add(States( statename: 'Oyo', capital: 'Ogbomosho'))
      ..add(States( statename: 'Plateau', capital: 'Jos'))
      ..add(States( statename: 'Rivers', capital: 'Port Harcourt'))
      ..add(States( statename: 'Sokoto', capital: 'Sokoto'))
      ..add(States( statename: 'Taraba', capital: 'Jalingo'))
      ..add(States( statename: 'Yobe', capital: 'Damaturu'))
      ..add(States( statename: 'Zamfara', capital: 'Gusau'));

    //category
    _category_list
      ..add(States( statename: 'Building', capital: ''))
      ..add(States( statename: 'Full flat', capital: ''))
      ..add(States( statename: 'Land', capital: ''))
      ..add(States( statename: 'Self-contained', capital: ''))
      ..add(States( statename: 'Single room', capital: ''))
      ..add(States( statename: 'Plaza', capital: ''))
      ..add(States( statename: 'Shop', capital: ''))
      ..add(States( statename: 'Warehouse', capital: ''));
    //tag
    _tag_list
      ..add(States( statename: 'For Rent', capital: ''))
      ..add(States( statename: 'For Sell', capital: ''));
    //payment type
    _payment_type_list
      ..add(States( statename: 'One time payment', capital: ''))
      ..add(States( statename: 'Weekly payment', capital: ''))
      ..add(States( statename: 'Monthly payment', capital: ''))
      ..add(States( statename: 'Yearly payment', capital: ''));

    //add states

    getUserData();
  }
  getUserData() async {
    setState(() {
      gettinUserData = true;
    });
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String str = prefs.getString('status') ?? 'status ...';

    userid =  prefs.getString('userid') ?? 'Fullname';
     fullname =  prefs.getString('fullname') ?? 'email';
    imageurl =  prefs.getString('imageurl') ?? 'imageurl';

    setState(() {
      gettinUserData = false;
    });
  }

  void postImage(String uid, String username, String profImage) async {

    // start the loading
    if(isloading) {
      showSpackSnackBar(
          'Upload in progress',
          context, Colors.amberAccent, Icons.timelapse_outlined
      );
    }
      else{
      setState(() {
        isloading = true;
      });
        if(selectedState == 'Select'){
        showSpackSnackBar(
            'Please select a state',
            context, Colors.amberAccent, Icons.add_location_alt_outlined
        );
      }else if(category == 'Select category'){
          showSpackSnackBar(
              'Please select a Category',
              context, Colors.amberAccent, Icons.category
          );
        }else if(tag == 'Select tag'){
          showSpackSnackBar(
              'Please select a tag',
              context, Colors.amberAccent, Icons.label
          );
        }else if(payment_type == 'Select payment type'){
          showSpackSnackBar(
              'Please select a payment type',
              context, Colors.amberAccent, Icons.payment_sharp
          );
        }else if(controller.text.isEmpty){
        showSpackSnackBar(
            'Please add a description',
            context, Colors.amberAccent, Icons.description
        );
      }else if(amount_controller.text.isEmpty){
        showSpackSnackBar(
            'Please Enter the price',
            context, Colors.amberAccent, Icons.money_sharp
        );
      }else if(city_controller.text.isEmpty){
        showSpackSnackBar(
            'Please Enter the Location city',
            context, Colors.amberAccent, Icons.location_city
        );
      }else{
        try {
          // upload to storage and db
          String res = await FirestoreMethods().uploadPost(
            //AutofillHints.countryCode
            tag,
            payment_type,
            controller.text,
            amount_controller.text,
            city_controller.text,
            selectedState,
            category,
            videoFile,
            uid,
            username,
            profImage,
          );
          if (res == "Done successfully!") {
            setState(() {
              isloading = false;
            });
            if (context.mounted) {
              showSpackSnackBar(
                  'Posted successfully!',
                  context, Colors.green, Icons.done
              );
            }
            Navigator.pop(context);
          } else {
            if (context.mounted) {
              showSpackSnackBar(res, context, Colors.red, Icons.error);
            }
          }
        } catch (err) {

          showSpackSnackBar(
              err.toString(),
              context, Colors.red, Icons.error
          );
        }
      }

      //end
      setState(() {
        isloading = false;
      });
    }
  }
  _selectVideoType(BuildContext parentContext) async {
    return showDialog(
      context: parentContext,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Add an image'),
          children: <Widget>[
            SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('Take a picture'),
                onPressed: () async {
                  Navigator.pop(context);
                  videoFile =
                  await ImagePicker().pickImage(source: ImageSource.camera);

                  _video = videoFile?.path ?? '';

                  setState(() {
                  });
                }),
            SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('Choose from Gallery'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  videoFile =
                  await ImagePicker().pickImage(source: ImageSource.gallery);

                  _video = videoFile?.path ?? '';

                  setState(() {

                  });
                }),
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              child: const Text("Cancel", style: TextStyle(color: Colors.red),),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }
  showPreview (){
    return showDialog(
        context: context,
        builder: (BuildContext build){
          return SimpleDialog(
            children: [
              const SizedBox(height: 30,),
              SimpleDialogOption(
                child: Center(
                    child: Text('This is a 30 seconds sample video of a 1 bedroom apartment for rent')),

              ),
              const SizedBox(height: 25,),
              SimpleDialogOption(
                onPressed: (){

                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) =>
                      SampleVideo()
                  ));
                },
                child: Icon(Icons.play_circle_outlined,),
              )
            ],
          );
        });
  }

  shoCategoryList(BuildContext context) async {
    if(!isloading) {
      return showDialog(
          context: context,
          builder: (BuildContext build) {
            return AlertDialog(
              actions: [
                InkWell(child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text('Cancel', style: TextStyle(color: Colors.red),),
                ), onTap: () {
                  Navigator.pop(context);
                },)
              ],
              title: Text('Category that best suit the accommodation:'),
              content: Container(
                width: double.minPositive,
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _category_list.length,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(

                        onTap: () {
                          setState(() {
                            category = '${_category_list[index].statename}';
                          });
                          Navigator.pop(context);
                        },

                        title: Text(_category_list[index].statename),
                        trailing: category ==
                            '${_category_list[index].statename}'
                            ? Icon(Icons.done, color: Colors.green,)
                            : null,
                      );
                    }
                ),
              ),
              // title:

            );
          });
    }
  }
  showPaymwntType(BuildContext context) async {
    if(!isloading) {
      return showDialog(
          context: context,
          builder: (BuildContext build) {
            return AlertDialog(
              actions: [
                InkWell(child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text('Cancel', style: TextStyle(color: Colors.red),),
                ), onTap: () {
                  Navigator.pop(context);
                },)
              ],
              title: Text('Payment type:'),
              content: Container(
                 width: double.minPositive,
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _payment_type_list.length,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(

                        onTap: () {
                          setState(() {
                            payment_type =
                            '${_payment_type_list[index].statename}';
                          });
                          Navigator.pop(context);
                        },

                        title: Text(_payment_type_list[index].statename),
                        trailing: payment_type ==
                            '${_payment_type_list[index].statename}'
                            ? Icon(Icons.done, color: Colors.green,)
                            : null,
                      );
                    }
                ),
              ),
              // title:

            );
          });
    }
  }
  showTag(BuildContext context) async {
    if(!isloading){

      return showDialog(
          context: context,
          builder: (BuildContext build){
            return AlertDialog(
              actions: [
                InkWell(child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text('Cancel', style: TextStyle(color: Colors.red),),
                ), onTap: (){
                  Navigator.pop(context);
                },)
              ],
              title:  Text('Select tag'),
              content:  Container(
                width: double.minPositive,
                //height:MediaQuery.of(context).size.height,
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: 2,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (BuildContext context, int index){

                      return ListTile(

                        onTap: (){
                          setState(() {
                            tag = '${_tag_list[index].statename}';
                          });
                          Navigator.pop(context);
                        },

                        title: Text(_tag_list[index].statename),
                        trailing: tag == '${_tag_list[index].statename}'
                            ? Icon(Icons.done, color: Colors.green,)
                            : null,
                      );
                    }
                ),
              ),
              // title:

            );
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: false,
        title: const Text('Post a property'),
        actions: [
          _video == ''
              ? Container()
              : IconButton(
            tooltip: 'Tap to add a state',
            // backgroundColor: Colors.blue,
            onPressed:(){
              showAlert(context);
            } ,
            icon: Icon(Icons.add_location_alt),
          ).animate().shakeX(duration: float,)
        ],
      ),
      body: gettinUserData ?const Center(child: CircularProgressIndicator(),)
      : _video == ''
          ?
          //show this center widget if no video is selected
      Center(
            child: IconButton(
            tooltip: 'Select an image to add',
            onPressed: ()  {
              _selectVideoType(context);
            }, icon: Icon(Icons.add_photo_alternate, size: 30,)),
          )
          : _video != ''
          ? Center(
            child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Container(
              margin: EdgeInsets.symmetric(
                  horizontal: width > webScreenSize
                      ?  width * 0.2:10.0,
                  vertical: width > webScreenSize
                      ?  10:10.0
              ),
              child: Column(
                children: [
                  isloading ? LinearProgressIndicator() : Container(),
                  SizedBox(height: 20,),
                  selectedState == 'Select'
                      ? Container(

                    decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.yellowAccent,)
                    ),
                        child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        Text('Tap on the'),
                        Icon(Icons.add_location_alt),
                        Text('to select a state'),
                    ],
                  ),
                      )
                      :Text(selectedState, style: TextStyle(fontSize: 20, color: Colors.green),),
                  const SizedBox(height: 15,),
                  kIsWeb ? SizedBox(
                    height: 200,
                    width: double.infinity,
                    child: Image.network(_video),
                  )
                      :SizedBox(
                    height: 200,
                    width: double.infinity,
                    child: Image.file(File(_video)),
                  ),
                  // Container(
                  //
                  //     decoration: ShapeDecoration(
                  //         image: DecorationImage(
                  //             image: kIsWeb ? NetworkImage(_video) : FileImage(File(_video)),
                  //             fit: BoxFit.fitWidth
                  //         ),
                  //         color: mobileSearchColor,
                  //         shape: RoundedRectangleBorder(
                  //             borderRadius: BorderRadius.all(Radius.circular(15),
                  //             ))),
                  //   height: 172,),
                  const SizedBox(height: 20,),

                  InkWell(
                    onTap: (){
                      shoCategoryList(context);
                    },
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all(color: category == 'Select category' ? Colors.yellowAccent : Colors.grey, )
                        ),
                          child: Text(category, style: TextStyle(fontSize: 16,
                              color: category == 'Select category' ? Colors.yellowAccent : Colors.grey,),))),

                  const SizedBox(height: 10,),
                  const Divider(),
                  const SizedBox(height: 10,),
                  InkWell(
                      onTap: (){
                        showTag(context);
                      },
                      child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              border: Border.all(color:tag == 'Select tag' ? Colors.yellowAccent : Colors.grey, )
                          ),
                          child: Text(tag, style: TextStyle(fontSize: 16,
                              color: tag == 'Select tag' ? Colors.yellowAccent : Colors.grey,
                          ),))),
                  const SizedBox(height: 10,),
                  InkWell(
                      onTap: (){
                        showPaymwntType(context);
                      },
                      child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              border: Border.all(
                                color: payment_type == 'Select payment type' ? Colors.yellowAccent : Colors.grey, )
                          ),
                          child: Text(payment_type, style: TextStyle(fontSize: 16,
                              color: payment_type == 'Select payment type' ? Colors.yellowAccent : Colors.grey,),))),
                  const SizedBox(height: 10,),
                  const Divider(),
                  //description
                  Container(
                    margin: EdgeInsets.only(top: 20.0),
                    child: TextFormField(
                      controller: controller,
                      minLines: 1,
                      maxLines: 7,
                      decoration: InputDecoration(
                          labelText: 'Description',
                          hintText: 'e.g: Single room with 24hrs light ...',
                          contentPadding: EdgeInsets.fromLTRB(8, 5, 10, 5),
                          // fillColor: Colors.white,
                          filled: true,
                          enabled: !isloading,
                          prefixIcon: Icon(Icons.description),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(2.0),
                          )
                      ),
                      keyboardType: TextInputType.multiline,
                    ),
                  ),
                  //amount
                  Container(
                    margin: EdgeInsets.only(top: 10.0),
                    child: TextFormField(
                      controller: amount_controller,
                      maxLength: 15,
                      decoration: InputDecoration(
                          labelText: 'Enter amount in naira',
                          hintText: 'e.g: 100,000',
                          contentPadding: EdgeInsets.fromLTRB(8, 5, 10, 5),
                          // fillColor: Colors.white,
                          filled: true,
                          enabled: !isloading,
                          prefixIcon: Icon(Icons.money_sharp),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(2.0),
                          )
                      ),
                      keyboardType: const TextInputType.numberWithOptions(signed: false, decimal: false),
                    ),
                  ),
                  const SizedBox(height: 10,),
                  const Divider(),
                  //city
                  Container(
                    margin: EdgeInsets.only(top: 10.0),
                    child: TextFormField(
                      controller: city_controller,

                      decoration: InputDecoration(
                          labelText: 'Location city',
                          hintText: 'e.g: Calabar',
                          contentPadding: EdgeInsets.fromLTRB(8, 5, 10, 5),
                          // fillColor: Colors.white,
                          filled: true,
                          enabled: !isloading,
                          prefixIcon: Icon(Icons.location_city),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(2.0),
                          )
                      ),
                      keyboardType: TextInputType.streetAddress,
                    ),
                  ),

                  const SizedBox(height: 20,),
                  InkWell(
                    onTap: (){
                      postImage(userid,fullname,imageurl,);
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
                      child: isloading ?
                      const Center(
                          child: CircularProgressIndicator( color: Colors.white,))
                          : const Text('Post'),
                    ),
                  ),
                ],
              )),
      ),
          ) : const SizedBox(),
    );
  }


  void showAlert(BuildContext context) async {
    if(!isloading) {
      return showDialog(
          context: context,
          builder: (BuildContext build) {
            return AlertDialog(
              actions: [
                InkWell(child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text('Done', style: TextStyle(color: Colors.green),),
                ), onTap: () {
                  Navigator.pop(context);
                },)
              ],
              title: Text('State where the property is:'),
              content: Container(
                width: double.maxFinite,
                child: ListView.builder(
                    itemCount: _links.length,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(

                        onTap: () {
                          setState(() {
                            selectedState = '${_links[index].statename} State';
                          });
                          Navigator.pop(context);
                        },

                        title: Text(_links[index].statename),
                        subtitle: Text(_links[index].capital),
                        trailing: selectedState ==
                            '${_links[index].statename} State'
                            ? Icon(Icons.done, color: Colors.green,)
                            : null,
                      );
                    }
                ),
              ),
              // title:

            );
          });
    }
  }
}

class States {
  String statename;
  String capital;
  States({required this.statename,required this.capital });
}

class SampleVideo extends StatefulWidget {
  const SampleVideo({super.key});

  @override
  State<SampleVideo> createState() => _SampleVideoState();
}

class _SampleVideoState extends State<SampleVideo> {

  late VideoPlayerController _controller;
  late ChewieController chewieController;

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    chewieController.dispose();
  }


  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('asset/sample.mp4')
      ..initialize().then((value){
        setState(() {

        });
      });

    chewieController = ChewieController(
      videoPlayerController: _controller,
      autoPlay: false,
      looping: true,
    );
    if(!chewieController.isPlaying){
      chewieController.play();
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sample video'),
        backgroundColor: Colors.transparent,
      ),
      body: Chewie(controller: chewieController,),
    );
  }
}
