import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:recyclers/welcome.dart';



class ForgetPassScreen extends StatefulWidget {
  ForgetPassScreen({Key key}) : super(key: key);

  @override
  _ForgetPassScreenState createState() => _ForgetPassScreenState();
}

class _ForgetPassScreenState extends State<ForgetPassScreen> {

@override
  void initState() {
    super.initState();

  }

  onResetPress()
  {

  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        padding: EdgeInsets.only(left: 20, right: 20, top: 40),
       child: ListView(
         
          children: <Widget>[
            Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.only(bottom: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
              Text("FORGET PASSWORD", style: TextStyle(
                    fontFamily: "Oswald",
                    fontSize: 25,
                    color: Colors.black
                  ),),
            Text("reset it ...", style: TextStyle(
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
              margin: EdgeInsets.only(top: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  FlatButton(
                  
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 45),
                    onPressed: onResetPress,
                    color: Color(0xff00b661),
                    shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                    child: Container(
                      alignment: Alignment.center,
                      width: 100,
                      child: Text("Reset", style: TextStyle(
                      color: Colors.white,
                    fontSize: 18
                    ),
                    )),
                  ),

  
                ],
              ),
            )
          ],
        ),
      )
       
    );
  }
}
