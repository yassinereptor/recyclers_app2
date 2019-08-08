import 'package:flutter/material.dart';
import 'package:recyclers/home.dart';
import 'package:recyclers/signup.dart';
import 'package:recyclers/login.dart';


class WelcomeScreen extends StatefulWidget {
  WelcomeScreen({Key key}) : super(key: key);

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {

  void onLoginPress()
  {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  void onSignupPress()
  {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignupScreen()),
    );
  }

  void onSkipPress()
  {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen(data: null,)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff00b661),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    child: Icon(IconData(0xe90a, fontFamily: "Iconmoon"), color: Colors.white, size: 150),
                    padding: EdgeInsets.only(right: 13),
                  ),
                Container(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: <Widget>[
                      
                      Text("RECYCLERS", style: TextStyle(
                      fontFamily: "Oswald",
                      fontSize: 25,
                      color: Colors.white
                    ),),
                      Text("ecology center", style: TextStyle(
                        fontFamily: "Oswald",
                        fontSize: 15,
                        color: Colors.white
                      ),),
                    ],
                  )
                )
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 80),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  FlatButton(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 45),
                    onPressed: onLoginPress,
                    color: Colors.white,
                    shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                    child: Container(
                      alignment: Alignment.center,
                      width: 100,
                      child: Text("Login", style: TextStyle(
                      color: Color(0xff00b661),
                    fontSize: 18
                    ),
                    )),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 5),
                    child: FlatButton(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 45),
                    onPressed: onSignupPress,
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
                  )
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 20),
              child: FlatButton(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 45),
                    onPressed: onSkipPress,
                    shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                    child: Container(
                      height: 25,
                      alignment: Alignment.center,
                      width: 150,
                      child: Text("Skip for now", style: TextStyle(
                      color: Colors.white,
                    fontSize: 18
                    ),
                    )),
                  ),
            )
          ],
        ),
      )
       
    );
  }
}

