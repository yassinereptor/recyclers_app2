import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:country_pickers/country.dart';
import 'package:flutter/material.dart';
import 'package:country_pickers/country_pickers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:recyclers/config/config.dart';
import 'package:recyclers/home.dart';
import 'package:recyclers/maps.dart';
import 'package:geocoder/geocoder.dart';
import 'package:image_picker/image_picker.dart';
import 'models/user.dart';
import 'package:crypt/crypt.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:localstorage/localstorage.dart';

class Signup4Screen extends StatefulWidget {
  final UserData user;
  Signup4Screen({Key key, @required this.user}) : super(key: key);


  @override
  _Signup4ScreenState createState() => _Signup4ScreenState(user);
}

class _Signup4ScreenState extends State<Signup4Screen> {

  File _image;

  Future getImageCamera() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);

    setState(() {
      _image = image;
    });
  }

  Future getImageLib() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = image;
    });
  }

@override
  void initState() {
    super.initState();

  
  }


  UserData user;


  _Signup4ScreenState(UserData user)
  {
    this.user = user;
    
  }

  Response response;
  Dio dio = new Dio();

  saveData(data) async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("user_data", jsonEncode(data).toString());
  }

  onSignupPress() async {
      response = await dio.post("${AppConfig.ip}/api/signup", data: {
        "email": user.email,
        "password": Crypt.sha256(user.password, salt: '1337fil').toString(),
        "name": user.name,
        "company_name": user.company_name,
        "company_id": user.company_id,
        "cin": user.cin,
        "phone": user.phone,
        "seller": user.seller,
        "bayer": user.bayer,
        "lat": user.latLng.latitude.toString(),
        "lng": user.latLng.longitude.toString(),
        "country": user.country,
        "pos": user.pos,
        "profile": _image != null? base64Encode(_image.readAsBytesSync()) : "non"
      });
      print(response);
      if(response.statusCode == 200)
      {
        saveData(response.data);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen(data: response)),
          ModalRoute.withName("home")
        );
      }
  }

  onCancelPress()
  {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen(data: null)),
          ModalRoute.withName("home")
        );
  }

  onCancelImagePress()
  {
    setState(() {
      _image = null;
    });
  }

  onBackPress()
  {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: Container(
        padding: EdgeInsets.only(left: 20, right: 20, top: 50),
       child: ListView(
         
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(bottom: 40),
              child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(

              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
              Text("SIGN UP", style: TextStyle(
                    fontFamily: "Oswald",
                    fontSize: 25,
                    color: Colors.black
                  ),),
            Text("to continue ", style: TextStyle(
              fontFamily: "Oswald",
              fontSize: 15,
              color: Color(0xff00b661)
            ),),
              ],
            ),
            ),
            Container(
              child: IconButton(icon: Icon(Icons.keyboard_arrow_left), iconSize: 60, color: Color(0xff00b661), onPressed: onBackPress, alignment: Alignment.center),
            )
              ],
            ),
            ),
        
            Container(
              margin: EdgeInsets.only(top: 20, bottom: 5),
              alignment: Alignment.center,
              child: SizedBox(
                width: 200,
                height: 200,
                child: Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(color: Colors.black26, offset: Offset.zero, blurRadius: 5, spreadRadius: 1),
                        ],
                        color: Colors.black,
                        shape: BoxShape.circle,
                        image: new DecorationImage(
                            fit: BoxFit.cover,
                            image: _image == null ? AssetImage("assets/images/profile.png") : FileImage(_image)
                        )
                      ),
                    ),
              ),
            ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                       alignment: Alignment.topRight,
                        child: IconButton(icon: Icon(Icons.photo_camera), iconSize: 40, color: Color(0xff00b661), onPressed: getImageCamera, alignment: Alignment.center),
                      ),
                       Container(
                       alignment: Alignment.topRight,
                        child: IconButton(icon: Icon(Icons.photo_library), iconSize: 40, color: Color(0xff00b661), onPressed: getImageLib, alignment: Alignment.center),
                      ),
                      Container(
                       alignment: Alignment.topRight,
                        child: IconButton(icon: Icon(Icons.cancel), iconSize: 40, color: Colors.red, onPressed: onCancelImagePress, alignment: Alignment.center),
                      ),
                ],
              ),
            Container(
              margin: EdgeInsets.only(top: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  FlatButton(
                  
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 45),
                    onPressed: onSignupPress,
                    color: Color(0xff00b661),
                    shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                    child: Container(
                      alignment: Alignment.center,
                      width: 100,
                      child: Text("Sign up", style: TextStyle(
                      color: Colors.white,
                    fontSize: 18
                    ),
                    )),
                  ),
                 
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  FlatButton(
                  
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 45),
                    onPressed: onCancelPress,
                    color: Colors.white,
                    shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                    child: Container(
                      alignment: Alignment.center,
                      width: 100,
                      child: Text("Cancel", style: TextStyle(
                      color: Color(0xff00b661),
                    fontSize: 18
                    ),
                    )),
                  ),
                 
                ],
              ),
            )
          ],
        ),
      ),
       
    );
  }
}
