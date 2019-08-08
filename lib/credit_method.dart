import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:recyclers/config/config.dart';
import 'package:recyclers/home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CreditMethodScreen extends StatefulWidget {
      Function reload;
      String service;
      String logo;
      var colors;
      CreditMethodScreen({Key key, this.reload, this.service, this.logo, this.colors}) : super(key: key);
      @override
      State<StatefulWidget> createState() => CreditMethodScreenState();
    }

    class CreditMethodScreenState extends State<CreditMethodScreen> with SingleTickerProviderStateMixin {
 

AnimationController _animationController;
  Animation<double> _curvedAnimation;

      @override
      void initState() {
        super.initState();
   
    _animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 1000));
    _curvedAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
      }

      @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

      TextEditingController email_controller = TextEditingController();
      final _formKey = GlobalKey<FormState>();

  onSavePress()async {
        if(_formKey.currentState.validate())
        {
          Dio dio = new Dio();
          SharedPreferences prefs = await SharedPreferences.getInstance();
          var obj = prefs.getString("user_data");
          if(obj != null)
          {
            Map<String, dynamic> tmp = jsonDecode(obj);
            dio.post("${AppConfig.ip}/api/credit/add",
              options: Options(headers: {
                "authorization": "Token ${tmp['user']['token']}",
              }), data: widget.service == "Paypal"? {
              "id": tmp["user"]["_id"],
              "card_id": tmp["user"]["_id"] + DateTime.now().toString(),
              "type": widget.service,
              "paypal_email": email_controller.text,
              "card_time": DateTime.now().toString()
            }: {
              "id": tmp["user"]["_id"],
              "card_id": tmp["user"]["_id"] + DateTime.now().toString(),
              "type": widget.service,
              "wallet": email_controller.text,
              "card_time": DateTime.now().toString()  
            }).then((data){
              print(data.data);
              setState(() {
                      widget.reload();
                    });
            });
          }
          Navigator.pop(context);
        }
  }


      @override
      Widget build(BuildContext context) {
        return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          FlatButton(
            textColor: Colors.white,
            onPressed: onSavePress,
            child: Text("Save", style: TextStyle(fontSize: 18),),
            shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
          ),
        ],
        leading: IconButton(icon: Icon(Icons.arrow_back, color: Colors.white,),
        tooltip: "Cancel and Return to List",
        onPressed: () {
          Navigator.pop(context, true);
        },
        )
      ),
      backgroundColor: Colors.white,
      body: Container(
        padding: EdgeInsets.only(top: 30),
       child: ScrollConfiguration(
         behavior: ScrollBehaviorCos(),
         child: ListView(
         
          children: <Widget>[
            Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.only(left: 20, right: 20,bottom: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
              Text("Enter your informations of ${widget.service}", style: TextStyle(
                    fontFamily: "Oswald",
                    fontSize: 23,
                    color: Colors.black
                  ),),
            Row(
              children: <Widget>[
                Text("to continue ", style: TextStyle(
              fontFamily: "Oswald",
              fontSize: 15,
              color: Color(0xff00b661)
            ),),
           
              ],
            )
              ],
            ),
            ),
            Container(
              height: 50,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/${widget.service.toLowerCase()}_logo.png")
                )
              ),
            ),
            Container(
              padding: EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Container(
                child: new TextFormField(
                  controller: email_controller,
                      decoration: new InputDecoration(
                        labelText: (widget.service == "Paypal")? "Enter Email *" : "Enter your Wallet *",
                        labelStyle: TextStyle(
              // color: Color(0xff137547)
            ),
                        fillColor: Colors.white,
                        //fillColor: Colors.green
                      ),
                      validator: (val) {
                        if(val.length==0) {
                          return (widget.service == "Paypal")? "Email cannot be empty" : "Wallet cannot be empty";
                        }else{
                          return null;
                        }
                      },
                      keyboardType: TextInputType.text,
              ),
              ),
              )
            ),

          ],
        ),
       )
      ),
       
    );
      }



    }



    class MaskedTextInputFormatter extends TextInputFormatter {
  final String mask;
  final String separator;

  MaskedTextInputFormatter({
    @required this.mask,
    @required this.separator,
  }) { assert(mask != null); assert (separator != null); }

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if(newValue.text.length > 0) {
      if(newValue.text.length > oldValue.text.length) {
        if(newValue.text.length > mask.length) return oldValue;
        if(newValue.text.length < mask.length && mask[newValue.text.length - 1] == separator) {
          return TextEditingValue(
            text: '${oldValue.text}$separator${newValue.text.substring(newValue.text.length-1)}',
            selection: TextSelection.collapsed(
              offset: newValue.selection.end + 1,
            ),
          );
        }
      }
    }
    return newValue;
  }
}