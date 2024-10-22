import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../methods/auth_methods.dart';
import '../model/all_user_data.dart';
import '../responsive/responsive_layout_screen.dart';
import '../responsive/web_home.dart';
import '../utilities/global_variable.dart';
import '../widgets/utils.dart';
import '../responsive/mobile_home.dart';

class UpdateState extends StatefulWidget {
  const UpdateState({super.key});

  @override
  State<UpdateState> createState() => _UpdateStateState();
}

class _UpdateStateState extends State<UpdateState> {
  bool isLoading = false;
  String selectedState = 'Select';
  Duration float = 0.ms;
  TextEditingController controller = TextEditingController();
  String search_text = "";
  List<States> _links = <States>[];
  String name = "";

  @override
  void initState() {

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

  }

  Future<void> updateLocation() async {

    setState(() {
      isLoading = true;
    });
    if(selectedState == 'Select'){
      float = 500.ms;

      showSpackSnackBar('Select your current state!', context, Colors.amberAccent, Icons.add_location_alt);
    }
    else{
      String res = await AuthMethods().updateLocation( state: selectedState  );

      if(res == 'Updated successful!'){
        UserData().setState(selectedState);

        showSpackSnackBar(res, context, Colors.green, Icons.done_rounded);
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) =>
                ResponsiveLayout(
                  mobileScreenLayout: MobileHome(),
                  webScreenLayout: WebHome(),)
        ));

    }
  }
    setState(() {
      isLoading = false;
    });

  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(name),
      ),
      body: Center(
        child: Container(
          margin: EdgeInsets.symmetric(
              horizontal: width > webScreenSize ?  width * 0.2:15,
              vertical: width > webScreenSize ? 10:15
          ) ,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
               selectedState == 'Select' 
                   ? const Row(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                   Text('Tap on the'),
                   Icon(Icons.add_location_alt),
                   Text('to select a state'),
                 ],
               )
                   :Text(
                  selectedState,
                style: const TextStyle(
                  fontSize: 25
                ),
              ),
              const SizedBox(height: 54,),
              InkWell(
                onTap: updateLocation,
                child: Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration:const ShapeDecoration(shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(25),)
                  ),
                      color: Colors.blue
                  ),
                  child: isLoading ?
                  const Center(
                      child: CircularProgressIndicator( color: Colors.white,))
                      : const Text('Update'),
                ),
              ),
              SizedBox(height: 24,),
              const Text('This helps us to display accommodations based on the state you have selected',
              style: TextStyle(fontSize: 13),),
            ].animate(interval: 100.ms).fade(duration: 500.ms,),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(

        tooltip: 'Tap to add a state',
        backgroundColor: Colors.blue,
        onPressed:(){
          showAlert(context);
        } ,
        child: Icon(Icons.add_location_alt),
      ).animate().shakeX(duration: float,)

    );
  }

  void showAlert(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (BuildContext build){
          return AlertDialog(
            actions: [
              InkWell(child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text('Done', style: TextStyle(color: Colors.green),),
              ), onTap: (){
                Navigator.pop(context);
              },)
            ],
            title:  Text('Select:'),
            // TextFormField(
            //   controller: controller,
            //   onChanged: (value){
            //     setState(() {
            //       search_text = value.toLowerCase();
            //
            //     });
            //   },
            //   decoration: InputDecoration(
            //       labelText: 'Search for a state...',
            //       prefixIcon: Icon(Icons.search),
            //       contentPadding: EdgeInsets.fromLTRB(8, 5, 10, 5),
            //       // fillColor: Colors.white,
            //       filled: true,
            //
            //       border: OutlineInputBorder(
            //         borderRadius: BorderRadius.circular(2.0),
            //       )
            //   ),
            // ),
            content:  Container(
              width: double.maxFinite,
              child: ListView.builder(
                  itemCount: _links.length,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (BuildContext context, int index){

                    return ListTile(

                      onTap: (){
                        setState(() {
                          selectedState = '${_links[index].statename} State';
                        });
                        Navigator.pop(context);
                      },

                      title: Text(_links[index].statename),
                      subtitle: Text(_links[index].capital),
                      trailing: selectedState == '${_links[index].statename} State'
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

class States {
  String statename;
  String capital;
  States({required this.statename,required this.capital });
}
