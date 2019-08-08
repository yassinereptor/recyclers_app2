import 'package:country_pickers/country.dart';
import 'package:flutter/material.dart';
import 'package:country_pickers/country_pickers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:recyclers/maps.dart';
import 'package:geocoder/geocoder.dart';
import 'package:recyclers/signup4.dart';
import 'models/user.dart';


class Signup3Screen extends StatefulWidget {
  final UserData user;
  Signup3Screen({Key key, @required this.user}) : super(key: key);


  @override
  _Signup3ScreenState createState() => _Signup3ScreenState(user);
}

class _Signup3ScreenState extends State<Signup3Screen> {

  int userOption;

@override
  void initState() {
    super.initState();

    setState(() {
      
      userOption = 0;
      user.country = "MAR";
    });
  
  }

  UserData user;
  LatLng result;
  Country ctry;

  TextEditingController phone_controller = TextEditingController();
  TextEditingController pos_controller = TextEditingController();

  final _formKey = GlobalKey<FormState>();


  _Signup3ScreenState(UserData user)
  {
    this.user = user;
  }


  onSellerSet(int val)
  {
    setState(() => userOption = val);
  }

  onBayerSet(int val)
  {
    setState(() => userOption = val);
  }

  onCountryPick(Country country) {
           user.country = country.iso3Code;
  }

  onMapPress()
  {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MapScreen()),
    ).then((val){
      print("----------------------------------------------------");
      print(val);
      print("----------------------------------------------------");

      if(val != null)
      {
        result = val;
        final coordinates = new Coordinates(result.latitude, result.longitude);
        Geocoder.local.findAddressesFromCoordinates(coordinates).then((addresses){
          setState(() {
            print("-------------------|${addresses.first.addressLine}|------------------------");
            pos_controller.text = addresses.first.addressLine;
          });
        });
      }

    });
  }

  Widget _buildDropdownItem(Country country) => Container(
    child: Row(
      children: <Widget>[
        CountryPickerUtils.getDefaultFlagImage(country),
        SizedBox(
          width: 8.0,
        ),
        Text("+${country.phoneCode} (${country.isoCode})"),
      ],
    ),
  );

  onSignupPress()
  {
      
       if(_formKey.currentState.validate())
      {
        user.latLng = (result != null)? result : new LatLng(0, 0);
        user.phone = phone_controller.text;
        user.seller = userOption == 0 ? true : false;
        user.bayer = userOption == 1 ? true : false;
        user.pos = pos_controller.text;

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Signup4Screen(user: this.user,))
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
              margin: EdgeInsets.only(bottom: 40),
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

                child: new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            new Radio(
                          activeColor: Color(0xff00b661),
                          value: 0,
                          groupValue: userOption,
                          onChanged: onSellerSet,
                        ),
                        new Text(
                          'Seller',
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
                          onChanged: onBayerSet,
                        ),
                        new Text(
                          'Bayer',
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
                padding: EdgeInsets.only(bottom: 20),
                child: CountryPickerDropdown(
                  initialValue: 'ma',
                  itemBuilder: _buildDropdownItem,
                  onValuePicked: onCountryPick
                ),
              ),
     Container(
                padding: EdgeInsets.only(bottom: 20),

                child: new TextFormField(
                  controller: phone_controller,
                      decoration: new InputDecoration(
                        labelText: "Enter Phone Number (+212 ...) *",
                        labelStyle: TextStyle(
              // color: Color(0xff137547)
            ),
                        fillColor: Colors.white,
                        //fillColor: Colors.green
                      ),
                      validator: (val) {
                        if(val.length==0) {
                          return "Phone Number cannot be empty";
                        }else{
                          return null;
                        }
                      },
                      keyboardType: TextInputType.phone,
              ),
              ),
                    
          
              
              Container(
                padding: EdgeInsets.only(bottom: 20),

                child: Row(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(right: 5),
                   child: IconButton(icon: Icon(Icons.map), iconSize: 36, color: Color(0xff00b661), onPressed: onMapPress, alignment: Alignment.center),
                    ),
                    Expanded(
                      child: Container(
                      child: new TextFormField(
                        controller: pos_controller,
                      decoration: new InputDecoration(
                        labelText: "Enter your position",
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
