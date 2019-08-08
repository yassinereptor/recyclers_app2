import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:recyclers/config/config.dart';
import 'package:recyclers/home.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:recyclers/models/product.dart';
import 'package:shared_preferences/shared_preferences.dart';


class AddBayerScreen extends StatefulWidget {
  var data;
  AddBayerScreen({Key key, this.data}) : super(key: key);

  @override
  _AddBayerScreenState createState() => _AddBayerScreenState();
}

class _AddBayerScreenState extends State<AddBayerScreen> {
  int userOption;
  OfferData offerData;

@override
  void initState() {
    _dropDownMenuItems = getDropDownMenuItems();
    _dropDownMenuCats = getDropDownMenuCats();
    _currentUnit = _dropDownMenuItems[0].value;
    _currentCat = _dropDownMenuCats[0].value;

      userOption = 0;
      offerData = new OfferData();
      offerData.unit = 1;
      offerData.cat = 1;
    super.initState();

  }

  final _formKey = GlobalKey<FormState>();

  List<String> images =  new List();
  List<Widget> widg =  new List();

  List units =
  ["Unit", "Gram", "Ounce", "Kg", "Ton", "Lb", "liter", "meter"];

  List cats =
  ["Bottles", "Paper", "Oil", "Wood", "Organic", "Other"];

  List<DropdownMenuItem<String>> _dropDownMenuItems;
  List<DropdownMenuItem<String>> _dropDownMenuCats;
  String _currentUnit;
  String _currentCat;

  TextEditingController title_controller = new TextEditingController();
  TextEditingController desc_controller = new TextEditingController();
  TextEditingController min_price_controller = new TextEditingController();
  TextEditingController max_price_controller = new TextEditingController();
  TextEditingController qua_controller = new TextEditingController();
  TextEditingController limit_controller = new TextEditingController();

  List<DropdownMenuItem<String>> getDropDownMenuItems() {
    List<DropdownMenuItem<String>> items = new List();
    for (String item in units) {
      items.add(new DropdownMenuItem(
          value: item,
          child: new Text(item)
      ));
    }
    return items;
  }

  List<DropdownMenuItem<String>> getDropDownMenuCats() {
    List<DropdownMenuItem<String>> items = new List();
    for (String item in cats) {
      items.add(new DropdownMenuItem(
          value: item,
          child: new Text(item)
      ));
    }
    return items;
  }

  productsImage()
  {
    
    setState(() {
      widg.clear();
      images.forEach((item){
      widg.add(
        Container(
          margin: EdgeInsets.only(right: 10),
          alignment: Alignment.center,
          child: SizedBox(
            width: 120,
            height: 120,
            child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(color: Colors.black26, offset: Offset.zero, blurRadius: 3, spreadRadius: 1),
                    ],
                    color: Colors.black,
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    image: DecorationImage(
                      image:  MemoryImage(base64.decode(item)),
                      fit: BoxFit.fill
                    )
                  ),
                ),
          ),
        ),
      );
    });
    });
  }

  void changedDropDownItem(String selectedCity) {
    setState(() {
      _currentUnit = selectedCity;
      offerData.unit = units.indexOf(selectedCity) + 1;
    });
  }

  void changedDropDownCat(String cat) {
    setState(() {
      _currentCat = cat;
      offerData.cat = cats.indexOf(cat) + 1;
    });
  }

  onBidSet(int val)
  {
    setState(() => userOption = val);
  }

  onFixSet(int val)
  {
    setState(() => userOption = val);
  }

  capPicPress() async
  {
    File image = await ImagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      if(image != null)
      {
        images.add(base64Encode(image.readAsBytesSync()));
       productsImage();
      }
    });
  }

  addPicPress() async
  {
    File image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      if(image != null)
      {
        images.add(base64Encode(image.readAsBytesSync()));
       productsImage();
      }
    });
  }

  onCancelImagePress()
  {
    setState(() {
      images.clear();
      widg.clear();
    });
  }

  onSavePress() async
  {
    if(_formKey.currentState.validate())
    {
      offerData.title = title_controller.text;
      offerData.description = desc_controller.text;
      offerData.min_price = double.parse(min_price_controller.text);
      offerData.max_price = double.parse(max_price_controller.text);
      offerData.quantity = int.parse(qua_controller.text);

      Response response;
      Dio dio = new Dio();

      SharedPreferences prefs = await SharedPreferences.getInstance();
      var obj = prefs.getString("user_data");
      if(obj != null)
      {
          
        Map<String, dynamic> tmp = jsonDecode(obj);
        response = await dio.post("${AppConfig.ip}/api/offer/add", data: {
            "user_id": tmp['user']['_id'],
            "user_name": widget.data.name,
            "title": offerData.title,
            "desc": offerData.description,
            "min_price": offerData.min_price,
            "max_price": offerData.max_price,
            "min_quality": offerData.min_quality,
            "max_quality": offerData.max_quality,
            "quantity": offerData.quantity,
            "unit": offerData.unit,
            "cat": offerData.cat,
            "time": new DateTime.now().toString(),
          },
          options: Options(headers: {
            "authorization": "Token ${tmp['user']['token']}",
          }));
 
          if(response.statusCode == 200)
          {
            Navigator.pop(context);
          }
      }
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
      body: Form(
        key: _formKey,
        child: Container(
        padding: EdgeInsets.only(left: 20, right: 20, top: 30),
       child: ScrollConfiguration(
         behavior: ScrollBehaviorCos(),
         child: ListView(
         
          children: <Widget>[
            Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.only(bottom: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
              Text("Add an Offer", style: TextStyle(
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
                  controller: title_controller,
                      decoration: new InputDecoration(
                        labelText: "Product Title *",
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
                      keyboardType: TextInputType.emailAddress,
              ),
              ),
              Container(
                padding: EdgeInsets.only(bottom: 20),
                child: new TextFormField(
                  controller: desc_controller,
                      decoration: new InputDecoration(
                        labelText: "Description",
                        labelStyle: TextStyle(
            ),
                        fillColor: Colors.white,
                      ),
                      validator: (val) {
                          return null;
                      },
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
              ),
              ),
            
              Text("Product Quality", style: TextStyle(color: Colors.grey.shade900, fontSize: 16),),
              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.only(top: 15, bottom: 10),
                child: Row(
                  children: <Widget>[
                 Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: <Widget>[
                     Text("Min quality"),
                        FlutterRatingBar(
                  initialRating: 0,
                  itemSize: 25,
                  fillColor: Color(0xff00b661),
                  borderColor: Color(0xff00b661).withAlpha(60),
                  allowHalfRating: true,
                  onRatingUpdate: (rating){
                    offerData.min_quality = rating;
                  },
                  ),
                   ],
                 ),
                 Expanded(
                   child: Center(
                     child: VerticalDivider(),
                   ),
                 ),
        Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: <Widget>[
                     Text("Max quality"),
                        FlutterRatingBar(
                  initialRating: 0,
                  itemSize: 25,
                  fillColor: Color(0xff00b661),
                  borderColor: Color(0xff00b661).withAlpha(60),
                  allowHalfRating: true,
                  onRatingUpdate: (rating){
                    offerData.max_quality = rating;
                  },
                  ),
                   ],
                 ),               
                  ],
                )
              ),
              DropdownButton(
                value: _currentCat,
                items: _dropDownMenuCats,
                onChanged: changedDropDownCat,
              ),
              Container(
                child: Row(
                children: <Widget>[
                  Expanded(
                    child: Container(
                padding: EdgeInsets.only(bottom: 10),
                child: new TextFormField(
                  controller: min_price_controller,
                      decoration: new InputDecoration(
                        labelText: "Min Price *",
                        labelStyle: TextStyle(
              // color: Color(0xff137547)
                          ),
                          fillColor: Colors.white,
                          //fillColor: Colors.green
                        ),
                        validator: (val) {
                          if(val.length==0) {
                            return "Price cannot be empty";
                          }else{
                            return null;
                          }
                        },
                        keyboardType: TextInputType.number,
                ),
              ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 10, right: 10),
                    child: Text(" For "),
                  ),
                  new DropdownButton(
                    value: _currentUnit,
                    items: _dropDownMenuItems,
                    onChanged: changedDropDownItem,
                  )
                ],
              ),
              ),
              Container(
                child: Container(
                padding: EdgeInsets.only(bottom: 10),
                child: new TextFormField(
                  controller: max_price_controller,
                      decoration: new InputDecoration(
                        labelText: "Max Price *",
                        labelStyle: TextStyle(
              // color: Color(0xff137547)
                          ),
                          fillColor: Colors.white,
                          //fillColor: Colors.green
                        ),
                        validator: (val) {
                          if(val.length==0) {
                            return "Price cannot be empty";
                          }else{
                            return null;
                          }
                        },
                        keyboardType: TextInputType.number,
                ),
              ),
              ),
              Container(

                padding: EdgeInsets.only(bottom: 50),
                child: new TextFormField(
                  controller: qua_controller,
                      decoration: new InputDecoration(
                        suffixText: _currentUnit,
                        labelText: "Quantity",
                        labelStyle: TextStyle(
              // color: Color(0xff137547)
            ),
                        fillColor: Colors.white,
                        //fillColor: Colors.green
                      ),
                      validator: (val){
                        return null;
                      },
                      keyboardType: TextInputType.number,
              ),
              ),
          ],
        ),
       )
      ),
      )
       
    );
  }
}
