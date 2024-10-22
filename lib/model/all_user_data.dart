import 'package:shared_preferences/shared_preferences.dart';

class UserData{


  Future<void> updateAllData(String userid, String fullname, String username, String email, String password, String imageurl, String state,
      String city,String link,
      String status, String timestamp,) async {

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userid', userid);
    await prefs.setString('fullname', fullname);
    await prefs.setString('username', username);
    await prefs.setString('email', email);
    await prefs.setString('password', password);
    await prefs.setString('imageurl', imageurl);
    await prefs.setString('state', state);
    await prefs.setString('city', city);
    await prefs.setString('link', link);
    await prefs.setString('status', status);
    await prefs.setString('timestamp', timestamp);
  }

  Future<void> setFullname(String fullname) async{

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('fullname', fullname);
  }
  Future<void> setUsername(String username) async{

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
  }
  Future<void> setEmail(String email) async{

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', email);
  }
  Future<void> setImagUrl(String imageurl) async{

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('imageurl', imageurl);
  }
  Future<void> setState(String state) async{

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('state', state);
  }
  Future<void> setCity(String city) async{

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('city', city);
  }
  Future<void> setStatus(String status) async{

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('status', status);
  }
  Future<void> setTime(String timestamp) async{

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('timestamp', timestamp);
  }


  Future<String> getFullname() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String str = prefs.getString('fullname') ?? 'Fullname';
    return str;
  }
  Future<String> getUsername() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String str = prefs.getString('username') ?? 'username...';
    return str;
  }
  Future<String> getEmail() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String str = prefs.getString('email') ?? 'email ...';
    return str;
  }
  Future<String> getImageurl() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String str = prefs.getString('imageurl') ?? 'imageurl';
    return str;
  }
  Future<String> getState() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String str = prefs.getString('state') ?? 'state ...';
    return str;
  }
  Future<String> getCity() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String str = prefs.getString('city') ?? 'city...';
    return str;
  }
  Future<String> getTime() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String str = prefs.getString('timestamp') ?? 'timestamp...';
    return str;
  }

}