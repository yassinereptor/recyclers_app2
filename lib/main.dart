import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:recyclers/config/config.dart';
import 'package:recyclers/home.dart';
import 'package:recyclers/welcome.dart';
import 'package:toast/toast.dart';
import 'intro.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main(){
  runApp(MyApp());
}

//#265463
//#407A61
//#ABBD8D
//#EBE2DD
//#F7F1F1

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recyclers',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: new Color(0xff137547)
      ),
      home: AppScreen(),
//      routes: {
//        '/home': (context) => SplashScreen()
//      },
    );
  }
}

class AppScreen extends StatefulWidget {
  AppScreen({Key key}) : super(key: key);


  @override
  _AppScreenState createState() => _AppScreenState();
}

class _AppScreenState extends State<AppScreen> {

  @override
  void initState() {
    new Timer(new Duration(milliseconds: 1), () {
      move();
    });
    super.initState();
  }

  move()
  {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        settings: RouteSettings(name: "/home"),
        builder: (context) => SplashScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }


}

class SplashScreen extends StatefulWidget {
  SplashScreen({Key key}) : super(key: key);


  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {


  Future checkFirstSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool _seen = (prefs.getBool('intro_seen') ?? false);

    var tmp = prefs.getString("user_data");
    var data = tmp != null? jsonDecode(tmp) : null;
    print('%%%%%%%%%%%||${data}||%%%%%%%%%%');

    if (_seen) {
      if(data != null)
      {
        Navigator.of(context).pushReplacement(
        new MaterialPageRoute(builder: (context) => new HomeScreen(data: data,)));
      }
      else
      {
        Navigator.of(context).pushReplacement(
        new MaterialPageRoute(builder: (context) => new WelcomeScreen()));
      }
    } else {
   prefs.setBool('intro_seen', true);
    Navigator.of(context).pushReplacement(
        new MaterialPageRoute(builder: (context) => new IntroScreen()));
    }
  }

  bool flag;

  @override
  void initState() {
    super.initState();
    flag = false;
    new Timer(new Duration(milliseconds: 1500), () async {
//      if(AppConfig.checkCon(context) == true)
//      {
        try {
          final result = await InternetAddress.lookup('google.com');
          if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
            checkFirstSeen();

          }
        } on SocketException catch (_) {
          setState(() {
            flag = true;
          });
          Toast.show("You have no connection internet!", context, textColor: Colors.white, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM, backgroundColor: Colors.red);
        }
      //}
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Color(0xff00b661),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                alignment: Alignment.center,
                child: Padding(
                  child: Icon(IconData(0xe90a, fontFamily: "Iconmoon"), color: Colors.white, size: 150),
                  padding: EdgeInsets.only(right: 13),
                ),
              ),
            (flag)?Container(
                margin: EdgeInsets.only(top: 20),
                child: FlatButton(
                  color: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 45),
                  onPressed: () async {
                    try {
                      final result = await InternetAddress.lookup('google.com');
                      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
                        checkFirstSeen();

                      }
                    } on SocketException catch (_) {
                      Toast.show("You have no connection internet!", context, textColor: Colors.white, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM, backgroundColor: Colors.red);
                    }
                  },
                  shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                  child: Container(
                      alignment: Alignment.center,
                      width: 100,
                      child: Text("Retry", style: TextStyle(
                          color: Color(0xff00b661),
                          fontSize: 18
                      ),
                      )),
                ),
              ): Container()
            ],
          )
        )
      ),
    );
  }
}
