import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:recyclers/config/config.dart';
import 'package:recyclers/home.dart';
import 'package:flutter_flip_view/flutter_flip_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CreditCardScreen extends StatefulWidget {
      Function reload;
      String service;
      String logo;
      var colors;
      CreditCardScreen({Key key, this.reload, this.service, this.logo, this.colors}) : super(key: key);
      @override
      State<StatefulWidget> createState() => CreditCardScreenState();
    }

    class CreditCardScreenState extends State<CreditCardScreen> with SingleTickerProviderStateMixin {
 

AnimationController _animationController;
  Animation<double> _curvedAnimation;

      @override
      void initState() {
        c_number_controller.addListener((){
          setState(() {
                      
                    });
        });
        c_name_controller.addListener((){
          setState(() {
                      
                    });
        });
        c_exper_controller.addListener((){
          setState(() {
                      
                    });
        });
        c_cvc_controller.addListener((){
          setState(() {
                      
                    });
        });
        super.initState();
   
    _animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 1000));
    _curvedAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
      }

      @override
  void dispose() {
    _animationController.dispose();
    c_number_controller.dispose();
    c_name_controller.dispose();
    c_exper_controller.dispose();
    c_cvc_controller.dispose();
    super.dispose();
  }


  onSavePress()async {
        if(c_number_controller.text.isNotEmpty && c_name_controller.text.isNotEmpty && c_exper_controller.text.isNotEmpty && c_cvc_controller.text.isNotEmpty)
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
              }), data: widget.service == "MasterCard" || widget.service == "Visa" ? {
              "id": tmp["user"]["_id"],
              "card_id": tmp["user"]["_id"] + DateTime.now().toString(),
              "type": widget.service,
              "card_number": c_number_controller.text,
              "card_holder": c_name_controller.text,
              "card_exp": c_exper_controller.text,
              "card_cvc": c_cvc_controller.text,
              "card_time": DateTime.now().toString()
            }: {}).then((data){
              print(data.data);
              setState(() {
                      widget.reload();
                    });
            });
          }
          Navigator.pop(context);
        }
        else{
          Fluttertoast.showToast(
            msg: "Fill the card",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIos: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0
        );
        }
  }

  void _flip(bool reverse) {
    if (_animationController.isAnimating) return;
    if (reverse) {
      _animationController.forward();
    } else {
      _animationController.reverse();
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
              margin: EdgeInsets.only(bottom: 10, left: 20),
              child: Text("Touch the top of the card to flip it ", style: TextStyle(
              fontSize: 15,
            ),),
            ),
            Container(
              padding: EdgeInsets.all(10),
              child: FlipView(
                    animationController: _curvedAnimation,
                    front: _buildCard(true, () => _flip(true)),
                    back: _buildCard(false, () => _flip(false)),
                )
            ),

            Container(
              padding: EdgeInsets.all(20),
              child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text("Crad Number: ", style: TextStyle(
                      fontWeight: FontWeight.bold
                    ),),
                    Text(c_number_controller.text)
                  ],
                ),
                Row(
                  children: <Widget>[
                    Text("Holder Name: ", style: TextStyle(
                      fontWeight: FontWeight.bold
                    ),),
                    Text(c_name_controller.text)
                  ],
                ),
                Row(
                  children: <Widget>[
                    Text("Experation: ", style: TextStyle(
                      fontWeight: FontWeight.bold
                    ),),
                    Text(c_exper_controller.text)
                  ],
                ),
                Row(
                  children: <Widget>[
                    Text("CVC: ", style: TextStyle(
                      fontWeight: FontWeight.bold
                    ),),
                    Text(c_cvc_controller.text)
                  ],
                )
              ],
            ),
            )
          ],
        ),
       )
      ),
       
    );
      }

      TextEditingController c_number_controller = TextEditingController();
      TextEditingController c_name_controller = TextEditingController();
      TextEditingController c_exper_controller = TextEditingController();
      TextEditingController c_cvc_controller = TextEditingController();
      final _formKey1 = GlobalKey<FormState>();
      final _formKey2 = GlobalKey<FormState>();


      Widget _buildCard(bool front, GestureTapCallback onTap) {
    return AspectRatio(
      aspectRatio: 1.586,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            gradient: LinearGradient(
              colors: widget.colors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              splashColor: Colors.white.withOpacity(0.1),
              highlightColor: Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              onTap: onTap,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  front? Container(
                    margin: EdgeInsets.only(top: 10, right: 10),
                    alignment: Alignment.centerRight,
                    width: 90,
                    height: 40,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(widget.logo)
                      )
                    ),
                  ) :
                  Container(
                    margin: EdgeInsets.only(top: 20),
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.black
                    ),
                  ),
                  (front)?
                    Form(
                    key: _formKey1,

                    child: Container(
                      padding: EdgeInsets.only(left: 10, right: 10),
                      child: Column(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.only(bottom: 10),
                          child: new TextFormField(
                            style: TextStyle(
                              color: Colors.white
                            ),
                            cursorColor: Colors.white,
                            controller: c_number_controller,
                                decoration: new InputDecoration(
                                  labelText: "Card Number",
                                  labelStyle: TextStyle(
                      ),
                                  fillColor: Colors.white,
                                ),
                                validator: (val) {
                                  if(val.length==0) {
                                    return "Title cannot be empty";
                                  }else{
                                    return null;
                                  }
                                },
                                inputFormatters: [
                                  MaskedTextInputFormatter(
                                    mask: 'xxxx-xxxx-xxxx-xxxx',
                                    separator: '-',
                                  ),
                                ],
                                keyboardType: TextInputType.number,
                        ),
                        ),
                        Row(
                          children: <Widget>[
                            
                        //--------------------------------------
                          Expanded(
                            flex: 2,
                            child: Container(
                          padding: EdgeInsets.only(bottom: 10, right: 10),
                          child: new TextFormField(
                            controller: c_name_controller,
                            style: TextStyle(
                              color: Colors.white
                            ),
                            cursorColor: Colors.white,
                                decoration: new InputDecoration(
                                  labelText: "Holder Name",
                                  labelStyle: TextStyle(
                      ),
                                  fillColor: Colors.white,
                                ),
                                validator: (val) {
                                  if(val.length==0) {
                                    return "Title cannot be empty";
                                  }else{
                                    return null;
                                  }
                                },
                                inputFormatters: [
                                  // MaskedTextInputFormatter(
                                  //   mask: 'xxx',
                                  //   separator: '',
                                  // ),
                                ],
                                keyboardType: TextInputType.text,
                        ),
                        ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Container(
                          padding: EdgeInsets.only(bottom: 10, right: 10),
                          child: new TextFormField(
                            controller: c_exper_controller,
                            style: TextStyle(
                              color: Colors.white
                            ),
                            cursorColor: Colors.white,
                                decoration: new InputDecoration(
                                  labelText: "Expiration",
                                  labelStyle: TextStyle(
                      ),
                                  fillColor: Colors.white,
                                ),
                                validator: (val) {
                                  if(val.length==0) {
                                    return "Title cannot be empty";
                                  }else{
                                    return null;
                                  }
                                },
                                inputFormatters: [
                                  MaskedTextInputFormatter(
                                    mask: 'xx/xx',
                                    separator: '/',
                                  ),
                                ],
                                keyboardType: TextInputType.number,
                        ),
                        ),
                           
                          ),
                        
                          ],
                        )
                      ],
                    ),
                    )
                  )

                  :


                  Form(
                    key: _formKey2,
                    child: Container(
                      padding: EdgeInsets.only(left: 10, right: 10),
                      child: Column(
                      children: <Widget>[
                        
                        Row(
                          children: <Widget>[
                            
                        //--------------------------------------
                   
                          Expanded(
                            flex: 1,

                            child: Container(
                          padding: EdgeInsets.only(bottom: 10, right: 10),
                          child: new TextFormField(
                            controller: c_cvc_controller,

                            style: TextStyle(
                              
                              color: Colors.white
                            ),
                            cursorColor: Colors.white,
                                decoration: new InputDecoration(
                                  labelText: "CVC",
                                  labelStyle: TextStyle(
                      ),
                                  fillColor: Colors.white,
                                ),
                                validator: (val) {
                                  if(val.length==0) {
                                    return "Title cannot be empty";
                                  }else{
                                    return null;
                                  }
                                },
                                inputFormatters: [
                                  MaskedTextInputFormatter(
                                    mask: 'xxx',
                                    separator: '',
                                  ),
                                ],
                                keyboardType: TextInputType.number,
                        ),
                        ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Container(),
                          ),
                          Expanded(
                            flex: 1,
                            child: Container(),
                          )
                          ],
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 10, right: 10),
                          alignment: Alignment.bottomRight,
                          width: 90,
                          height: 40,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(widget.logo)
                            )
                          ),
                        )
                      ],
                    ),
                    )
                  )
                ],
              )
            ),
          ),
        ),
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