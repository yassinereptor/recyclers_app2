import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pagewise/flutter_pagewise.dart';
import 'package:recyclers/config/config.dart';
import 'package:recyclers/credit_method.dart';
import 'package:recyclers/home.dart';
import 'package:recyclers/credit_card.dart';
import 'package:recyclers/privacy_policy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:toast/toast.dart';


class DipositScreen extends StatefulWidget {
  var user;

  DipositScreen({Key key, this.user}) : super(key: key);

  @override
  _DipositScreenState createState() => _DipositScreenState();
}

class _DipositScreenState extends State<DipositScreen> {
  static var user;
  List<String> list;
  String dropdownValue;
  var index;
//  var publicKey = AppConfig.pk_paystack;
  TextEditingController m_controller = new TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    list = ["Loading", ""];
    user = widget.user;

    dropdownValue = 'Loading';
    getItems();
//    PaystackPlugin.initialize(
//        publicKey: publicKey);
    super.initState();


  }

   getItems()
   async{
     Dio dio = new Dio();
     SharedPreferences prefs = await SharedPreferences.getInstance();
     var obj = prefs.getString("user_data");
     if(obj != null)
     {
       Map<String, dynamic> tmp = jsonDecode(obj);
       dio.post("${AppConfig.ip}/api/credit/load",
         options: Options(headers: {
           "authorization": "Token ${tmp['user']['token']}",
         }), data: {
         "id": tmp["user"]["_id"],
         "skip": 0,
         "limit": 10
       }).then((data){
         if(data.statusCode == 200)
         {
             List tab = data.data;
             list.clear();
             tab.forEach((item){
               String name = item["type"] + " (";

               switch(item["type"])
               {
                 case "Visa":
                 case "MasterCard":
                   list.add(name + item["card_number"].toString().substring(0, 4) + "...)");
                   break;
                 case "Paypal":
                   list.add(name + item["paypal_email"].toString() + ")");
                   break;
                 case "Bitcoin":
                   list.add(name + item["wallet"].toString().substring(0, 6) + ")");
                   break;
               }
             setState(() {

             });
           });
         }
       });
     }


   }


  @override
  Widget build(BuildContext context) {

  
    return Scaffold(
      appBar: AppBar(
        // actions: <Widget>[
        //   FlatButton(
        //     textColor: Colors.white,
        //     onPressed: (){},
        //     child: Text("Save", style: TextStyle(fontSize: 18),),
        //     shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
        //   ),
        // ],
        leading: IconButton(icon: Icon(Icons.arrow_back_ios, color: Colors.white,),
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
         child: NestedScrollView(
         headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
           return <Widget>[
           SliverToBoxAdapter(
             child: Container(
               child: Column(
                 children: <Widget>[
                   Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.only(left: 20, right: 20,bottom: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
              Text("Deposit to your Account", style: TextStyle(
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
                Container(
                child: Center(
                  child: InkWell(
                  onTap: (){
                      Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => PrivacyPolicyScreen()),
                          );
                  },
                  child: Text("( Privacy Policy )", style: TextStyle(
              fontFamily: "Oswald",
              decoration: TextDecoration.underline,
              fontSize: 15,
              color: Colors.red
            ),),
                ),
                )
              ),
              ],
            ),


              ],
            ),
            ),

                 ],
               ),
             ),
           )
           ];
         },
         body: Container(
           padding: EdgeInsets.only(left: 20, right: 20),
           child: Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: <Widget>[
               FlatButton(
                 padding: EdgeInsets.symmetric(vertical: 10, horizontal: 45),
                 onPressed: () async {
                   if(list.length > 0)
                   {
                     index = await showDialog(context: context,builder: (context) => CardsDialog(list: list,));
                     if(index != null)
                     {
                       setState(() {
                       });
                     }
                   }
                   else
                     Toast.show("Add a payment method first", context, textColor: Colors.black, duration: Toast.LENGTH_SHORT, gravity:  Toast.BOTTOM, backgroundColor: Colors.amber);
                 },
                 color: Color(0xff00b661),
                 shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                 child: Container(
                     alignment: Alignment.center,
                     child: Text("Select a payment method", style: TextStyle(
                         color: Colors.white,
                     ),
                     )),
               ),
                (index != null)? Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(left: 5, right: 5, top: 20, bottom: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text("Selected method: ", style: TextStyle(fontWeight: FontWeight.bold),),
                            Padding(padding: EdgeInsets.only(top: 5),),
                            Text(list[index])
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 5, right: 5, bottom: 10),
                        child: new TextFormField(
                          controller: m_controller,
                          decoration: new InputDecoration(
                            labelText: "Enter an amount",
                            labelStyle: TextStyle(
                              // color: Color(0xff137547)
                            ),
                            fillColor: Colors.white,
                            //fillColor: Colors.green
                          ),
                          validator: (val) {
                            if(double.parse(val.toString()) <= 0) {
                              return "Enter a valid amount > 0";
                            }else{
                              return null;
                            }
                          },
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      FlatButton(
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 45),
                        onPressed: () async {
                          if(_formKey.currentState.validate())
                          {
                            showDialog(context: context,builder: (context) => DespoitDialog(index: index, amount: m_controller.text));
                          }
                        },
                        color: Color(0xff00b661),
                        shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                        child: Container(
                            alignment: Alignment.center,
                            child: Text("Deposit", style: TextStyle(
                              color: Colors.white,
                            ),
                            )),
                      ),
                    ],
                  ),
                ): Container()
             ],
           ),
         )
        ),
       )
      ),
       
    );
  }

  
}





class CardsDialog extends StatefulWidget {
  List list;
  CardsDialog({Key key, this.list}) : super(key: key);
  @override
  State<StatefulWidget> createState() => CardsDialogState();
}

class CardsDialogState extends State<CardsDialog>
    with SingleTickerProviderStateMixin{
  AnimationController controller;
  Animation<double> scaleAnimation;
  @override
  void initState() {
    super.initState();

    controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 450));
    scaleAnimation =
        CurvedAnimation(parent: controller, curve: Curves.elasticInOut);

    controller.addListener(() {
      setState(() {});
    });

    controller.forward();
  }


  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: ScaleTransition(
            scale: scaleAnimation,
            child: Wrap(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(left: 20, right: 20, bottom: 10),
                  padding: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15.0)),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: widget.list.length,
                    itemBuilder: (context, index){
                      return GestureDetector(
                        onTap: (){
                          Navigator.pop(context, index);
                        },
                        child: Column(
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.only(top: 10, bottom: 10),
                              child: Text(widget.list[index]),
                            ),
                            (index  != widget.list.length - 1)? Divider():  Container()
                          ],
                        )
                      );
                    },
                  ),
                )
              ],
            )
        ),
      ),
    );
  }

}




class DespoitDialog extends StatefulWidget {
  int index;
  String amount;

  DespoitDialog({Key key, this.index, this.amount}) : super(key: key);
  @override
  State<StatefulWidget> createState() => DespoitDialogState();
}

class DespoitDialogState extends State<DespoitDialog>
    with SingleTickerProviderStateMixin{
  AnimationController controller;
  Animation<double> scaleAnimation;
  TextEditingController m_controller = new TextEditingController();

  @override
  void initState() {
    super.initState();
    m_controller.text = "0";
    controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 450));
    scaleAnimation =
        CurvedAnimation(parent: controller, curve: Curves.elasticInOut);

    controller.addListener(() {
      setState(() {});
    });

    controller.forward();
  }

  final _formKey = GlobalKey<FormState>();


  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: ScaleTransition(
            scale: scaleAnimation,
            child: Wrap(
              children: <Widget>[
                Form(
                    key: _formKey,
                    child: Container(
                    margin: EdgeInsets.only(left: 20, right: 20, bottom: 10),
                    padding: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15.0)),
                    child: Column(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.only(left: 5, right: 5, bottom: 10),
                          child: new TextFormField(
                            controller: m_controller,
                            decoration: new InputDecoration(
                              labelText: "Enter the secret code",
                              labelStyle: TextStyle(
                                // color: Color(0xff137547)
                              ),
                              fillColor: Colors.white,
                              //fillColor: Colors.green
                            ),
                            validator: (val) {
                              if(double.parse(val.toString()) <= 0) {
                                return "Enter a valid code";
                              }else{
                                return null;
                              }
                            },
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        FlatButton(
                          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 45),
                          onPressed: () async {
                            if(_formKey.currentState.validate())
                            {
                              SharedPreferences prefs = await SharedPreferences.getInstance();
                              var obj = prefs.getString("user_data");
                            if(obj != null) {
                                Map<String, dynamic> tmp = jsonDecode(obj);

                                Response response = await new Dio().post("${AppConfig.ip}/api/credit/charge",  options: Options(headers: {
                                  "authorization": "Token ${tmp['user']['token']}",
                                }),data: {
                                  "amount": double.parse(widget.amount),
                                  "code": m_controller.text,
                                  "index": widget.index,
                                  "id": tmp["user"]["_id"],
                                });
                                if(response.statusCode == 200)
                                {
                                  Toast.show("You added ${widget.amount} to your account", context, textColor: Colors.white, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM, backgroundColor: Colors.blueAccent);
                                }
                                else if(response.statusCode == 422)
                                  Toast.show("Can't login try again!", context, textColor: Colors.white, duration: Toast.LENGTH_SHORT, gravity:  Toast.BOTTOM, backgroundColor: Colors.red);
                                Navigator.pop(context);
                            }
                            }
                          },
                          color: Color(0xff00b661),
                          shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                          child: Container(
                              alignment: Alignment.center,
                              child: Text("Deposit", style: TextStyle(
                                color: Colors.white,
                              ),
                              )),
                        ),
                      ],
                    )
                ))
              ],
            )
        ),
      ),
    );
  }

}
