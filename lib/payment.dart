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


class PaymentScreen extends StatefulWidget {
  var user;

  PaymentScreen({Key key, this.user}) : super(key: key);

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  static var user;

@override
  void initState() {
    user = widget.user;
    super.initState();

  
  }

    static const int PAGE_SIZE = 10;

    final _pageLoadController = PagewiseLoadController(
      pageSize: PAGE_SIZE,
      pageFuture: (pageIndex) =>
                BackendService.getCredit(user.id, pageIndex * PAGE_SIZE, PAGE_SIZE),
    );

  // getItems()
  // async{
  //   Dio dio = new Dio();
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   var obj = prefs.getString("user_data");
  //   if(obj != null)
  //   {
  //     Map<String, dynamic> tmp = jsonDecode(obj);
  //     dio.post("${AppConfig.ip}/api/credit/load",
  //       options: Options(headers: {
  //         "authorization": "Token ${tmp['user']['token']}",
  //       }), data: {
  //       "id": tmp["user"]["_id"],
  //     }).then((data){
  //       print(data.data);
  //       setState(() {
                
  //             });
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
            showDialog(context: context,builder: (context) => CardsDialog(reloadList: _pageLoadController.reset,));
        },
        backgroundColor: Color(0xff00b661),
      ),
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
              Text("Add a Payment Method", style: TextStyle(
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
            )
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
           margin: EdgeInsets.only(top: 10),
          child: RefreshIndicator(
          onRefresh: () async {
            this._pageLoadController.reset();
            // getItems();
            await Future.value({});
          },
          child: ScrollConfiguration(
            behavior: ScrollBehaviorCos(),
            child: PagewiseListView(
                              itemBuilder: this._itemBuilder,
                              pageLoadController: this._pageLoadController,
                              loadingBuilder: (context) {
                                return Text('Loading...');
                              },
                              noItemsFoundBuilder: (context) {
                                return Text('No Items Found');
                              },
                            ),
          )
        )
        )
        ),
       )
      ),
       
    );
  }


 Widget _itemBuilder(context, CreditModel entry, _) {
   return (entry.type == "MasterCard" || entry.type == "Visa")? Container(
     margin: EdgeInsets.only(left: 5, right: 5, bottom: 5),
     padding: EdgeInsets.only(top: 10, bottom: 10, left: 5, right: 5),
     decoration: BoxDecoration(
       borderRadius: BorderRadius.all(Radius.circular(3)),
        color: Colors.white,
        boxShadow: [
                      BoxShadow(color: Colors.black26, offset: Offset.zero, blurRadius: 2, spreadRadius: 0),
                    ],
     ),
     child: Row(
       crossAxisAlignment: CrossAxisAlignment.start,
       children: <Widget>[
         Expanded(
           child: Row(
       crossAxisAlignment: CrossAxisAlignment.start,
       children: <Widget>[
         Container(
          margin: EdgeInsets.only(left: 10, right: 15),
          height: 50,
          width: 50,
           decoration: BoxDecoration(
             image: DecorationImage(
               image: AssetImage("assets/images/credit-cards_${entry.type.toLowerCase()}.png")
             )
           ),
         ),
        Expanded(
          child:  Container(
            margin: EdgeInsets.only(top: 5, bottom: 5),
            child: Column(
       crossAxisAlignment: CrossAxisAlignment.start,
       children: <Widget>[
        Container(
          margin: EdgeInsets.only(bottom: 5),
          child:  Row(
            children: <Widget>[
              Text(entry.type, style: TextStyle(
           fontWeight: FontWeight.bold
         ),),
         Text(" (${timeago.format(DateTime.parse(entry.card_time))})", style: TextStyle(
           fontSize: 11
         ),)
            ],
          )
        ),
         Text(entry.card_number),
         Text(entry.card_holder),
         Text(entry.card_exp),
         Text(entry.card_cvc),
       ],
     ),
          )
        ),
        
       ],
     ),
         ),
         Container(
           padding: EdgeInsets.all(5),
           margin: EdgeInsets.only(right: 3),
          child: GestureDetector(
            onTap: () async {
              Dio dio = new Dio();
              SharedPreferences prefs = await SharedPreferences.getInstance();
              var obj = prefs.getString("user_data");
              if(obj != null)
              {
                Map<String, dynamic> tmp = jsonDecode(obj);
                dio.post("${AppConfig.ip}/api/credit/delete",
                  options: Options(headers: {
                    "authorization": "Token ${tmp['user']['token']}",
                  }), data: {
                  "id": tmp["user"]["_id"],
                  "card_id": entry.card_id,
                }).then((data){
                  print(data.data);
                  setState(() {
                          _pageLoadController.reset();
                        });
                });
              }
            },
            child: Icon(Icons.delete, color: Colors.red,),
          )
        )
       ],
     )
   ): Container(
      margin: EdgeInsets.only(left: 5, right: 5, bottom: 5),
     padding: EdgeInsets.only(top: 10, bottom: 10, left: 5, right: 5),
     decoration: BoxDecoration(
       borderRadius: BorderRadius.all(Radius.circular(3)),
        color: Colors.white,
        boxShadow: [
                      BoxShadow(color: Colors.black26, offset: Offset.zero, blurRadius: 2, spreadRadius: 0),
                    ],
     ),
     child: Row(
       crossAxisAlignment: CrossAxisAlignment.start,
       children: <Widget>[
         Expanded(
           child: Row(
       crossAxisAlignment: CrossAxisAlignment.start,
       children: <Widget>[
         Container(
          margin: EdgeInsets.only(left: 10, right: 15),
          height: 50,
          width: 50,
           decoration: BoxDecoration(
             image: DecorationImage(
               image: AssetImage("assets/images/credit-cards_${entry.type.toLowerCase()}.png")
             )
           ),
         ),
        Expanded(
          child:  Container(
            margin: EdgeInsets.only(top: 5, bottom: 5),
            child: Column(
       crossAxisAlignment: CrossAxisAlignment.start,
       children: <Widget>[
        Container(
          margin: EdgeInsets.only(bottom: 5),
          child:  Row(
            children: <Widget>[
              Text(entry.type, style: TextStyle(
           fontWeight: FontWeight.bold
         ),),
         Text(" (${timeago.format(DateTime.parse(entry.card_time))})", style: TextStyle(
           fontSize: 11
         ),)
            ],
          )
        ),
         Text((entry.type == "Paypal")? entry.paypal_email : "${entry.wallet.substring(0, 20)}..."),
        
       ],
     ),
          )
        ),
        
       ],
     ),
         ),
         Container(
           padding: EdgeInsets.all(5),
           margin: EdgeInsets.only(right: 3),
          child: GestureDetector(
            onTap: () async {
              Dio dio = new Dio();
              SharedPreferences prefs = await SharedPreferences.getInstance();
              var obj = prefs.getString("user_data");
              if(obj != null)
              {
                Map<String, dynamic> tmp = jsonDecode(obj);
                dio.post("${AppConfig.ip}/api/credit/delete",
                  options: Options(headers: {
                    "authorization": "Token ${tmp['user']['token']}",
                  }), data: {
                  "id": tmp["user"]["_id"],
                  "card_id": entry.card_id,
                }).then((data){
                  print(data.data);
                  setState(() {
                          _pageLoadController.reset();
                        });
                });
              }
            },
            child: Icon(Icons.delete, color: Colors.red,),
          )
        )
       ],
     )
   );
 }
  
}

  class CardsDialog extends StatefulWidget {
    Function reloadList;
      CardsDialog({Key key, this.reloadList}) : super(key: key);
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
                margin: EdgeInsets.all(20.0),
                  padding: EdgeInsets.only(left: 5, right: 5, top: 15, bottom: 15),
                  decoration: BoxDecoration(
                    //  gradient: LinearGradient(
                    //   colors: [
                    //     Color(0xff00b661).withOpacity(0.8),
                    //     Color(0Xff054A29).withOpacity(0.8)
                    //   ],
                    //   begin: Alignment.topLeft,
                    //   end: Alignment.bottomRight,
                    // ),
                    color: Colors.white,
                     borderRadius: BorderRadius.circular(15.0)),
                  child: Column(
                    children: <Widget>[
                     
                        Container(
              margin: EdgeInsets.only(left: 10, right: 10, bottom: 10),
              child: InkWell(
                onTap: (){
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CreditCardScreen(reload: widget.reloadList ,service: "MasterCard", logo: "assets/images/mastercard_logo.png", colors: [
                         Color(0xff00b661).withOpacity(0.8),
                        Color(0Xff054A29).withOpacity(0.8)
                      ],)),
                      );
                },
                child: Container(
                  padding: EdgeInsets.only(left: 10, right: 10),
              decoration: BoxDecoration(
                
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(right: 10),
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/images/credit-cards_mastercard.png")
                      )
                    ),
                  ),
                  Text(
                    "Mastercard",
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 18
                    ),
                  )
                    ]
                  ),
                  Icon(Icons.keyboard_arrow_right, color: Colors.white,)                  
                ],
              ),
              )
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 20, right: 20),
              child: Divider(
                color: Color(0xff137547),
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 10, right: 10, bottom: 10),
              child: InkWell(
                onTap: (){
                    Navigator.pop(context);

                  Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CreditCardScreen(reload: widget.reloadList ,service: "Visa", logo: "assets/images/visa_logo.png", colors: [
                        // Colors.blue[900],
                        // Colors.blue[100],
                        Color(0xff00b661),
                        Color(0Xff265463),
                      ])),
                      ).then((_){
                        print("Added");
                      });
                },
                child: Container(
                  padding: EdgeInsets.only(left: 10, right: 10),
              decoration: BoxDecoration(
                
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(right: 10),
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/images/credit-cards_visa.png")
                      )
                    ),
                  ),
                  Text(
                    "Visa",
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 18
                    ),
                  )
                    ]
                  ),
                  Icon(Icons.keyboard_arrow_right, color: Colors.white,)                  
                ],
              ),
              )
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 20, right: 20),
              child: Divider(
                color: Color(0xff137547),
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 10, right: 10, bottom: 10),
              child: InkWell(
                onTap: (){
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CreditMethodScreen(reload: widget.reloadList ,service: "Paypal", logo: "assets/images/mastercard_logo.png", colors: [
                         Color(0xff00b661).withOpacity(0.8),
                        Color(0Xff054A29).withOpacity(0.8)
                      ],)),
                      );

                },
                child: Container(
                  padding: EdgeInsets.only(left: 10, right: 10),
              decoration: BoxDecoration(
                
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(right: 10),
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/images/credit-cards_paypal.png")
                      )
                    ),
                  ),
                  Text(
                    "Paypal",
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 18
                    ),
                  )
                    ]
                  ),
                  Icon(Icons.keyboard_arrow_right, color: Colors.white,)                  
                ],
              ),
              )
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 20, right: 20),
              child: Divider(
                color: Color(0xff137547),
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 10, right: 10),
              child: InkWell(
                onTap: (){
                   Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CreditMethodScreen(reload: widget.reloadList ,service: "Bitcoin", logo: "assets/images/mastercard_logo.png", colors: [
                         Color(0xff00b661).withOpacity(0.8),
                        Color(0Xff054A29).withOpacity(0.8)
                      ],)),
                      );

                },
                child: Container(
                  padding: EdgeInsets.only(left: 10, right: 10),
              decoration: BoxDecoration(
                
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(right: 10),
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/images/credit-cards_bitcoin.png")
                      )
                    ),
                  ),
                  Text(
                    "Bitcoin",
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 18
                    ),
                  )
                    ]
                  ),
                  Icon(Icons.keyboard_arrow_right, color: Colors.white,)                  
                ],
              ),
              )
              ),
            ),
                    ],
                  )),
                ],
              )
            ),
          ),
        );
  }

}


class BackendService {
  
  static Future<List<CreditModel>> getCredit(id, offset, limit) async {
    Dio dio = new Dio();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var obj = prefs.getString("user_data");
    Map<String, dynamic> tmp = jsonDecode(obj);
    final responseBody = (await dio.post("${AppConfig.ip}/api/credit/load",
        options: Options(headers: {
          "authorization": "Token ${tmp['user']['token']}",
        }), 
    data: {
            "id": id,
            "skip": offset,
            "limit": limit
          }
    )).data;
   
    print(responseBody);
    return CreditModel.fromJsonList(responseBody);
  }
}

class CreditModel {
    String type;
    String card_id;
    String card_number;
    String card_holder;
    String card_exp;
    String card_cvc;
    String card_time;
    String paypal_email;
    String wallet;



  CreditModel.fromJson(obj) {
    this.type = obj["type"];
    this.card_id = obj["card_id"];
    this.card_number = obj["card_number"];
    this.card_holder = obj["card_holder"];
    this.card_exp = obj["card_exp"];
    this.card_cvc = obj["card_cvc"];
    this.paypal_email = obj["paypal_email"];
    this.card_time = obj["card_time"];
    this.wallet = obj["wallet"];
  }

  static List<CreditModel> fromJsonList(jsonList) {
    return jsonList.map<CreditModel>((obj) => CreditModel.fromJson(obj)).toList();
  }
}

