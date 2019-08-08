import 'dart:convert';

import 'package:crypt/crypt.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:recyclers/config/config.dart';
import 'package:recyclers/forgetpass.dart';
import 'package:recyclers/home.dart';
import 'package:recyclers/signup.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';



class LoginScreen extends StatefulWidget {
  LoginScreen({Key key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

@override
  void initState() {
    super.initState();

  
  }

  TextEditingController email_controller = TextEditingController();
  TextEditingController password_controller = TextEditingController();

  final _formKey = GlobalKey<FormState>();

   Response response;
  Dio dio = new Dio();

  onForgetPress()
  {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ForgetPassScreen()),
    );
  }

  onSignupPress()
  {
     Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignupScreen()),
    );
  }

  saveData(data) async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("user_data", jsonEncode(data).toString());
  }



  onLoginPress() async
  {
    if(_formKey.currentState.validate())
    {

       response = await dio.post("${AppConfig.ip}/api/login", data: {
        "email": email_controller.text,
        "password": Crypt.sha256(password_controller.text, salt: '1337fil').toString(),
      });
      if(response.statusCode == 200)
      {
        saveData(response.data);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen(data: response)),
          ModalRoute.withName("home")
        );
      }
      else if(response.statusCode == 422)
        Toast.show("Can't login try again!", context, textColor: Colors.white, duration: Toast.LENGTH_SHORT, gravity:  Toast.BOTTOM, backgroundColor: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Form(
        key: _formKey,
        child: Container(
        padding: EdgeInsets.only(left: 20, right: 20, top: 40),
       child: ListView(
         
          children: <Widget>[
            Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.only(bottom: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
              Text("SIGN IN", style: TextStyle(
                    fontFamily: "Oswald",
                    fontSize: 25,
                    color: Colors.black
                  ),),
            Text("to continue", style: TextStyle(
              fontFamily: "Oswald",
              fontSize: 15,
              color: Color(0xff00b661)
            ),),
              ],
            ),
            ),
              Container(
                padding: EdgeInsets.only(bottom: 20),
                child: new TextFormField(
                  controller: email_controller,
                      decoration: new InputDecoration(
                        labelText: "Enter Email",
                        labelStyle: TextStyle(
              // color: Color(0xff137547)
            ),
                        fillColor: Colors.white,
                        //fillColor: Colors.green
                      ),
                      validator: (val) {
                        if(val.length==0) {
                          return "Email cannot be empty";
                        }else{
                          return null;
                        }
                      },
                      keyboardType: TextInputType.emailAddress,
              ),
              ),
              Container(
                child: new TextFormField(
                  controller: password_controller,
                      decoration: new InputDecoration(
                        labelText: "Enter Password",
                        labelStyle: TextStyle(
              // color: Color(0xff137547)
            ),
                        fillColor: Colors.white,
                        //fillColor: Colors.green
                      ),
                      validator: (val) {
                        if(val.length==0) {
                          return "Password cannot be empty";
                        }else{
                          return null;
                        }
                      },
                      obscureText: true,
                      keyboardType: TextInputType.text,
              ),
              ),
              Container(
                alignment: Alignment.centerRight,
                padding: EdgeInsets.only(top: 10),
              child: FlatButton(
                    onPressed: onForgetPress,
                    shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                    child: Container(
                      height: 25,
                      alignment: Alignment.center,
                      child: Text("Forget password ?", style: TextStyle(
                      color: Color(0xff00b661),
                    ),
                    )),
                  ),
            ),
            Container(
              margin: EdgeInsets.only(top: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  FlatButton(
                  
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 45),
                    onPressed: onLoginPress,
                    color: Color(0xff00b661),
                    shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                    child: Container(
                      alignment: Alignment.center,
                      width: 100,
                      child: Text("Login", style: TextStyle(
                      color: Colors.white,
                    fontSize: 18
                    ),
                    )),
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 20, bottom: 10),
                    child: Text(
                      "Or",
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 18
                      ),
                    ),
                  ),
                  FlatButton(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 45),
                    onPressed: onSignupPress,
                    shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                    child: Container(
                      alignment: Alignment.center,
                      width: 100,
                      child: Text("Sign up", style: TextStyle(
                      color: Color(0xff00b661),
                    fontSize: 18
                    ),
                    )),
                  )
                ],
              ),
            )
          ],
        ),
      ),
      )
       
    );
  }
}
