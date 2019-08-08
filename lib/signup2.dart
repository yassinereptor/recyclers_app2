import 'package:flutter/material.dart';
import 'package:recyclers/models/user.dart';
import 'package:recyclers/signup3.dart';



class Signup2Screen extends StatefulWidget {
  final UserData user;
  Signup2Screen({Key key, @required this.user}) : super(key: key);

  @override
  _Signup2ScreenState createState() => _Signup2ScreenState(this.user);
}

class _Signup2ScreenState extends State<Signup2Screen> {

@override
  void initState() {
    super.initState();

  
  }

  UserData user;

  _Signup2ScreenState(this.user);


  final _formKey = GlobalKey<FormState>();

  
  final TextEditingController com_name_controller = TextEditingController(); 
  final TextEditingController com_id_controller = TextEditingController(); 
  final TextEditingController cin_controller = TextEditingController();

  onSignupPress()
  {
    if(_formKey.currentState.validate())
    {

      this.user.company_name = com_name_controller.text;
      this.user.company_id = com_id_controller.text;
      this.user.cin = cin_controller.text;

      Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Signup3Screen(user: this.user,)),
    );
    }
  }

  onBackPress()
  {
    Navigator.of(context).pop();
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
              margin: EdgeInsets.only(bottom: 35),
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
              child: IconButton(icon: Icon(Icons.keyboard_arrow_left), iconSize: 60, color: Color(0xff00b661), onPressed: onBackPress, alignment: Alignment.center),
            )
              ],
            ),
            ),
              Container(
                padding: EdgeInsets.only(bottom: 20),
                child: new TextFormField(
                      decoration: new InputDecoration(
                        labelText: "Enter Company Name",
                        labelStyle: TextStyle(
              // color: Color(0xff137547)
            ),
                        fillColor: Colors.white,
                        //fillColor: Colors.green
                      ),
                      validator: (val) {
                          return null;
                      },
                      keyboardType: TextInputType.emailAddress,
              ),
              ),
              Container(
                padding: EdgeInsets.only(bottom: 20),

                child: new TextFormField(
                      decoration: new InputDecoration(
                        labelText: "Enter Company ID",
                        labelStyle: TextStyle(
              // color: Color(0xff137547)
            ),
                        fillColor: Colors.white,
                        //fillColor: Colors.green
                      ),
                      validator: (val) {
                          return null;
                      },
                      keyboardType: TextInputType.text,
              ),
              ),
              Container(
                padding: EdgeInsets.only(bottom: 20),

                child: new TextFormField(
                  controller: cin_controller,
                      decoration: new InputDecoration(
                        labelText: "Enter CIN *",
                        labelStyle: TextStyle(
              // color: Color(0xff137547)
            ),
                        fillColor: Colors.white,
                        //fillColor: Colors.green
                      ),
                      validator: (val) {
                        if(val.length==0) {
                          return "CIN cannot be empty";
                        }else{
                          return null;
                        }
                      },
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
