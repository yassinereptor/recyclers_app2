import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geocoder/model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:recase/recase.dart';
import 'package:recyclers/config/config.dart';
import 'package:recyclers/home.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:recyclers/maps.dart';
import 'package:recyclers/models/product.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';


class AddSellerScreen extends StatefulWidget {
  var data;
  AddSellerScreen({Key key, this.data}) : super(key: key);

  @override
  _AddSellerScreenState createState() => _AddSellerScreenState();
}

class _AddSellerScreenState extends State<AddSellerScreen> {
  int userOption;
  ProductData productData;

@override
  void initState() {
    _dropDownMenuItems = getDropDownMenuItems();
    _dropDownMenuCats = getDropDownMenuCats();
    _currentUnit = _dropDownMenuItems[0].value;
    _currentCat = _dropDownMenuCats[0].value;

      userOption = 0;
      productData = new ProductData();
      productData.unit = 1;
      productData.cat = 1;
    super.initState();

  }

  final _formKey = GlobalKey<FormState>();

  List<dynamic> images =  new List();
  List<Widget> widg =  new List();

  List units =
  ["Unit", "Gram", "Ounce", "Kg", "Ton", "Lb", "liter", "meter"];

  List cats =
  ["Bottles", "Paper", "Oil", "Wood", "Organic", "Other"];

  List<DropdownMenuItem<String>> _dropDownMenuItems;
  List<DropdownMenuItem<String>> _dropDownMenuCats;
  String _currentUnit;
  String _currentCat;
  LatLng result;
  TextEditingController title_controller = new TextEditingController();
  TextEditingController desc_controller = new TextEditingController();
  TextEditingController price_controller = new TextEditingController();
  TextEditingController qua_controller = new TextEditingController();
  TextEditingController limit_controller = new TextEditingController();
  TextEditingController pos_controller = TextEditingController();

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

  onMapPress()
  {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MapScreen()),
    ).then((val){
      result = val;
       final coordinates = new Coordinates(result.latitude, result.longitude);
        Geocoder.local.findAddressesFromCoordinates(coordinates).then((addresses){
            setState(() {
              print("-------------------|${addresses.first.addressLine}|------------------------");
                pos_controller.text = addresses.first.addressLine;     
            });
        });
      
    });
  }

  productsImage()
  {
    
    setState(() {
      widg.clear();
      images.forEach((item){
      Uint8List image = Uint8List.fromList(item);
      widg.add(
        Container(
          margin: EdgeInsets.only(right: 10),
          alignment: Alignment.center,
          child: Container(
            width: 120,
            height: 120,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(color: Colors.black26, offset: Offset.zero, blurRadius: 3, spreadRadius: 1),
                    ],
                    color: Colors.black,
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    image: DecorationImage(
                      image:  MemoryImage(image),
                      fit: BoxFit.cover
                    )
                  ),
          ),
//          child: SizedBox(
//
//            child:
//          ),
        ),
      );
    });
    });
  }

  void changedDropDownItem(String selectedCity) {
    print("Selected city $units.indexOf(selectedCity), we are going to refresh the UI");
    setState(() {
      _currentUnit = selectedCity;
      productData.unit = units.indexOf(selectedCity) + 1;
    });
  }

  void changedDropDownCat(String cat) {
    print("Selected city $units.indexOf(cat), we are going to refresh the UI");
    setState(() {
      _currentCat = cat;
      productData.cat = cats.indexOf(cat) + 1;
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
    setState(() async {
      if(image != null)
      {
        var result = await FlutterImageCompress.compressWithFile(
          image.absolute.path,
          quality: 80,
        );
        images.add(result);
       productsImage();
      }
    });
  }

  scanPress()
  async {
    File image = await ImagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      if(image != null)
      {
        Toast.show("Wait for data!", context, textColor: Colors.white, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM, backgroundColor: Colors.blueAccent);
        String base64 = base64Encode(image.readAsBytesSync());
        print(base64);
        Dio().post("${AppConfig.ip}/api/ai", data: {
          "base64": base64
        }).then((res){
          if(res.statusCode == 200)
          {

            if(res.data != null)
            {
              setState(() {
                title_controller.text = ReCase((res.data["score"].toString().split(":")[0]).toString()).titleCase;
              });
            }
          }

        }, onError: (err){
          Toast.show("Error while processing data", context, textColor: Colors.white, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM, backgroundColor: Colors.red);
        });
      }
    });
  }

  addPicPress() async
  {
    File image = await ImagePicker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    setState(() async {
      if(image != null)
      {
        var result = await FlutterImageCompress.compressWithFile(
          image.absolute.path,
          quality: 80,
        );
        images.add(result);
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
      productData.title = title_controller.text;
      productData.description = desc_controller.text;
      productData.price = double.parse(price_controller.text);
      productData.quantity = int.parse(qua_controller.text);
      productData.fix = userOption == 0? true : false;
      productData.bid = userOption == 1? true : false;
      productData.latlng = (result != null)? result : new LatLng(0, 0);

      images.forEach((item){
        var base64 = base64Encode(item);
        productData.images.add(base64);
      });

      Response response;
      Dio dio = new Dio();

      SharedPreferences prefs = await SharedPreferences.getInstance();
      var obj = prefs.getString("user_data");
      if(obj != null)
      {
          
        Map<String, dynamic> tmp = jsonDecode(obj);
        response = await dio.post("${AppConfig.ip}/api/product/add", data: {
            "user_id": tmp['user']['_id'],
            "user_name": widget.data.name,
            "title": productData.title,
            "desc": productData.description,
            "price": productData.price,
            "quantity": productData.quantity,
            "quality": productData.quality,
            "fix": productData.fix,
            "bid": productData.bid,
            "images": productData.images,
            "unit": productData.unit,
            "cat": productData.cat,
            "lat": productData.latlng.latitude.toString(),
            "lng": productData.latlng.longitude.toString(),
            "pos": pos_controller.text,
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
              Text("Add a Product", style: TextStyle(
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
               margin: EdgeInsets.only(bottom: 10),
               child: Row(
               mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(right: 10),
                    child: IconButton(icon: Icon(Icons.blur_linear), iconSize: 30, color: Color(0xff00b661), onPressed: scanPress, alignment: Alignment.center),
                  ),
                  Container(
                    margin: EdgeInsets.only(right: 10),
                  child: IconButton(icon: Icon(Icons.add_a_photo), iconSize: 30, color: Color(0xff00b661), onPressed: capPicPress, alignment: Alignment.center),
                  ),
                  Container(
                    margin: EdgeInsets.only(right: 10),
                    child: IconButton(icon: Icon(Icons.library_add), iconSize: 30, color: Color(0xff00b661), onPressed: addPicPress, alignment: Alignment.center),
                  ),
                  (images.isNotEmpty == true)? 
                  Container(
                    child: IconButton(icon: Icon(Icons.cancel), iconSize: 30, color: Colors.red, onPressed: onCancelImagePress, alignment: Alignment.center),
                  ):
                  Container(),
                ],
              ),
             ),
            (images.isNotEmpty == true)?
            Container(
               margin: EdgeInsets.only(bottom: 10),
              alignment: Alignment.center,
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                children: <Widget>[
                  Row(
                    children: widg
                  ),
                ],
              )
            ):
            Container(),
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
              Text("Product Sell mode", style: TextStyle(color: Colors.grey.shade600, fontSize: 16),),
              Container(
                padding: EdgeInsets.only(bottom: 10),
                child: new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            new Radio(
                          activeColor: Color(0xff00b661),
                          value: 0,
                          groupValue: userOption,
                          onChanged: onFixSet,
                        ),
                        new Text(
                          'Fix Price',
                          style: new TextStyle(fontSize: 16.0),
                        ),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            new Radio(
                          activeColor: Color(0xff00b661),
                          value: 1,
                          groupValue: userOption,
                          onChanged: onBidSet,
                        ),
                        new Text(
                          'Bid',
                          style: new TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                          ],
                        )
                      ],
                    ),
              ),
              Container(
                child: userOption == 1? Container(
                  child: Container(
                    padding: EdgeInsets.only(top: 10, bottom: 25),
                    child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                       Container(
                         padding: EdgeInsets.only(),
                         child: Text("Bidding Options", style: TextStyle(color: Colors.grey.shade900, fontSize: 16),),
                       ),
                       TextFormField(
                  controller: limit_controller,
                      decoration: new InputDecoration(
                        labelText: "Limited Days",
                        labelStyle: TextStyle(
                          ),
                          fillColor: Colors.white,
                        ),
                        validator: (val) {
                            return null;
                        },
                        keyboardType: TextInputType.number,
                ),
                    ],
                  ),
                  )
                  
                ): Container(),
              ),
              Text("Product Quality", style: TextStyle(color: Colors.grey.shade900, fontSize: 16),),
              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.only(top: 10, bottom: 5),
                child: FlutterRatingBar(
                  itemSize: 30,
                  initialRating: 0,
                  fillColor: Color(0xff00b661),
                  borderColor: Color(0xff00b661).withAlpha(60),
                  allowHalfRating: true,
                  onRatingUpdate: (rating){
                    productData.quality = rating;
                  },
                ),
              ),
              Container(
                padding: EdgeInsets.only(bottom: 20, top: 5),

                child: Row(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(right: 5),
                   child: IconButton(icon: Icon(Icons.map), iconSize: 30, color: Color(0xff00b661), onPressed: onMapPress, alignment: Alignment.center),
                    ),
                    Expanded(
                      child: Container(
                      child: new TextFormField(
                        controller: pos_controller,
                      decoration: new InputDecoration(
                        labelText: "Enter Product position",
                        labelStyle: TextStyle(
              // color: Color(0xff137547)
            ),
                        fillColor: Colors.white,
                        //fillColor: Colors.green
                      ),
                      validator: (val) {
                        if(val.length==0) {
                          return "Position cannot be empty";
                        }else{
                          return null;
                        }
                      },
                      keyboardType: TextInputType.text,
              ),
                    ),
                    )
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
                  controller: price_controller,
                      decoration: new InputDecoration(
                        labelText: userOption == 1? "Starting price *" : "Price *",
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
                    child: Text(userOption == 1? " For " : " Per "),
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
