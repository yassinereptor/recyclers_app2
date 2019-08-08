import 'package:flutter/material.dart';
import 'package:recyclers/models/user.dart';
import 'package:recyclers/signup2.dart';


class SignupScreen extends StatefulWidget {
  SignupScreen({Key key}) : super(key: key);

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {

@override
  void initState() {
    super.initState();

  
  }

  
  final TextEditingController name_controller = TextEditingController(); 
  final TextEditingController email_controller = TextEditingController(); 
  final TextEditingController pass_controller = TextEditingController(); 
  final TextEditingController conf_pass_controller = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  onSignupPress()
  {
      UserData user = new UserData();

    if(_formKey.currentState.validate())
    {
        user.name = name_controller.text;
        user.email = email_controller.text;
        user.password = pass_controller.text;

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Signup2Screen(user: user,)),
        );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Form(
        key: _formKey,
        child: Container(
        padding: EdgeInsets.only(left: 20, right: 20, top: 50),
       child: ListView(
         
          children: <Widget>[
            Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.only(bottom: 35),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

              children: <Widget>[
              Text("SIGN UP", style: TextStyle(
                    fontFamily: "Oswald",
                    fontSize: 25,
                    color: Colors.black
                  ),),
            Row(
              children: <Widget>[
                Text("to continue ", style: TextStyle(
              fontFamily: "Oswald",
              fontSize: 15,
              color: Color(0xff00b661)
            ),),
            Text("(* : mandatory)", style: TextStyle(
              fontFamily: "Oswald",
              fontSize: 15,
              color: Colors.red
            ),),
              ],
            )
              ],
            ),
            ),
              Container(
                padding: EdgeInsets.only(bottom: 10),
                child: new TextFormField(
                  controller: name_controller,
                      decoration: new InputDecoration(
                        labelText: "Enter Name *",
                        labelStyle: TextStyle(
              // color: Color(0xff137547)
            ),
                        fillColor: Colors.white,
                        //fillColor: Colors.green
                      ),
                      validator: (val) {
                        if(val.length==0) {
                          return "Name cannot be empty";
                        }else{
                          return null;
                        }
                      },
                      keyboardType: TextInputType.emailAddress,
              ),
              ),
              Container(
                padding: EdgeInsets.only(bottom: 10),

                child: new TextFormField(
                  controller: email_controller,
                      decoration: new InputDecoration(
                        labelText: "Enter Email *",
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
                      keyboardType: TextInputType.text,
              ),
              ),
              Container(
                padding: EdgeInsets.only(bottom: 10),

                child: new TextFormField(
                  controller: pass_controller,
                      decoration: new InputDecoration(
                        labelText: "Enter Password *",
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
                padding: EdgeInsets.only(bottom: 10),

                child: new TextFormField(
                  controller: conf_pass_controller,
                      decoration: new InputDecoration(
                        labelText: "Confirm Password *",
                        labelStyle: TextStyle(
              // color: Color(0xff137547)
            ),
                        fillColor: Colors.white,
                        //fillColor: Colors.green
                      ),
                      validator: (val) {
                        if(val.length==0) {
                          return "Confirmation Password cannot be empty";
                        }
                        else if(val != pass_controller.text)
                        {
                          return "Invalide";
                        }
                        else{
                          return null;
                        }
                      },
                      obscureText: true,
                      keyboardType: TextInputType.text,
              ),
              ),
            Container(
              margin: EdgeInsets.only(top: 40),
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
                      child: Text("Next", style: TextStyle(
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
      ),
      )
       
    );
  }
}
