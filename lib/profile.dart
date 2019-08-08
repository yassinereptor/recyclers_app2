import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';
import 'package:recase/recase.dart';
import 'package:recyclers/config/config.dart';
import 'package:recyclers/diposit.dart';
import 'package:recyclers/history.dart';
import 'package:recyclers/home.dart';
import 'package:recyclers/main.dart';
import 'package:recyclers/models/user.dart';
import 'package:recyclers/offers.dart';
import 'package:recyclers/payment.dart';
import 'package:recyclers/privacy_policy.dart';
import 'package:recyclers/qr.dart';
import 'package:recyclers/transactions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:fast_qr_reader_view/fast_qr_reader_view.dart' as Qr;


class ProfileScreen extends StatefulWidget {
  UserData user;
  Function callback;

  ProfileScreen({Key key, this.user, this.callback}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState(this.user);
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserData user;

_ProfileScreenState(this.user);

@override
  void initState() {
    super.initState();

    getData();

  }

  getData()
  async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var obj = prefs.getString("user_data");
    if(obj != null)
    {
      Map<String, dynamic> tmp = jsonDecode(obj);
      Response response;
      Dio dio = new Dio();
      response = await dio.get("${AppConfig.ip}/api/current?id=${tmp['user']['_id']}",
          options: Options(headers: {
            "authorization": "Token ${tmp['user']['token']}",
          }));
      if(response.statusCode == 200)
      {
        UserData user;
        user = new UserData();
        user.id = response.data["user"]["_id"];
        user.email = response.data["user"]["email"];
        user.name = response.data["user"]["name"];
        user.company_name = response.data["user"]["company_name"];
        user.company_id = response.data["user"]["company_id"];
        user.cin = response.data["user"]["cin"];
        user.phone = response.data["user"]["phone"];
        user.country = response.data["user"]["country"];
        user.pos = response.data["user"]["pos"];
        user.seller = response.data["user"]["seller"];
        user.bayer = response.data["user"]["bayer"];
        user.latLng = new LatLng(double.parse(response.data["user"]["lat"]), double.parse(response.data["user"]["lng"]));
        user.profile = response.data["user"]["profile"];
        user.amount = response.data["user"]["amount"];
        user.onhold = response.data["user"]["onhold"];

        setState(() {
          this.user = user;
        });
      }
    }
    return ;
  }


  @override
  Widget build(BuildContext context) {

    print("-----------------------------------");
    print(this.user.id);
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              Expanded(
                flex: 2,
                child: Container(
                decoration: BoxDecoration(
                  color: Color(0xff137547)
                ),
              ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                decoration: BoxDecoration(
                  color: Colors.white
                ),
              ),
              )
            ],
          ),
          ScrollConfiguration(
            behavior: ScrollBehaviorCos(),
            child: ListView(
              padding: EdgeInsets.only(bottom: 50, top: 50),
            children: <Widget>[
              Column(
            children: <Widget>[
              Container(
              margin: EdgeInsets.only(top: 20, bottom: 15),
              alignment: Alignment.center,
              child: SizedBox(
                width: 150,
                height: 150,
                child: InkWell(
                  onTap: (){
                    if((this.user != null && this.user.profile != "non"))
                    {                   
                      Navigator.of(context).push(MaterialPageRoute<void>(
                        builder: (BuildContext context)=> PhotoProfileHero(link: this.user.profile)
                      ));
                    }
                  },
                  child: Hero(
                    tag: "profile",
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(color: Colors.black26, offset: Offset.zero, blurRadius: 5, spreadRadius: 1),
                        ],
                        color: Colors.black,
                        shape: BoxShape.circle,
                        image: new DecorationImage(
                            fit: BoxFit.cover,
                            image: (this.user == null || this.user.profile == "non")? AssetImage("assets/images/profile.png") : CachedNetworkImageProvider(this.user.profile)
                            //image: (this.user == null || this.user.profile == "non")? AssetImage("assets/images/profile.png") : CachedNetworkImageProvider("691")
                        )
                      ),
                    ),
                  )
                )
              ),
            ),
            Column(
                    children: <Widget>[
                      Text(
                        (this.user != null)? ReCase(this.user.name).titleCase : "",
                        style: Theme.of(context)
                            .textTheme
                            .subhead
                            .copyWith(color: Colors.white),
                      ),
                      Text(
                        (this.user != null)? this.user.email : "",
                        style: Theme.of(context)
                            .textTheme
                            .subtitle
                            .copyWith(color: Colors.white.withAlpha(200)),
                      )
                    ],
                  ),
            Container(
              padding: EdgeInsets.only(top: 20, bottom: 5),
              child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Row(
                    children: <Widget>[
                      Text(
                        "Solde: ",
                        style: Theme.of(context)
                            .textTheme
                            .subhead
                            .copyWith(color: Colors.white),
                      ),
                      Text(
                        this.user.amount.toString() + " DH",
                        style: Theme.of(context)
                            .textTheme
                            .subtitle
                            .copyWith(color: Colors.white.withAlpha(200)),
                      )
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Text(
                        "In hold: ",
                        style: Theme.of(context)
                            .textTheme
                            .subhead
                            .copyWith(color: Colors.white),
                      ),
                      Text(
                        this.user.onhold.toString() + " DH",
                        style: Theme.of(context)
                            .textTheme
                            .subtitle
                            .copyWith(color: Colors.white.withAlpha(200)),
                      )
                    ],
                  ),
              ],
            ),
            ),
            Container(
              padding: EdgeInsets.only(top: 10, bottom: 10),
              margin: EdgeInsets.only(right: 20, left: 20, top: 20),
              decoration: BoxDecoration(
                boxShadow: [
                          BoxShadow(color: Colors.black26, offset: Offset.zero, blurRadius: 5, spreadRadius: 1),
                ],
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(10))
              ),
              child: Column(
                children: <Widget>[
                  InkWell(
                    onTap: ()
                    {

                    },
                    child: Container(
                    decoration: BoxDecoration(
                      
                    ),
                    padding: EdgeInsets.only(top: 12, bottom: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(right: 20, left: 20),
                          child: Icon(Icons.edit, color: Color(0xff00b661),),
                        ),
                        Text("Edit Profile", style: TextStyle(color: Color(0xff054A29)),),
                      ],
                    )
                  ),
                  ),
                   Padding(
                    padding: EdgeInsets.only(left: 20, right: 20),
                    child: Divider(color: Color(0xff00b661),),
                  ),
                  InkWell(
                    onTap: ()
                    {
                      Navigator.of(context).push(MaterialPageRoute<void>(
                        builder: (BuildContext context)=> OffersScreen()
                      ));
                    },
                    child: Container(
                    decoration: BoxDecoration(
                      
                    ),
                    padding: EdgeInsets.only(top: 12, bottom: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(right: 20, left: 20),
                          child: Icon(Icons.store, color: Color(0xff00b661),),
                        ),
                        Text("My Offers", style: TextStyle(color: Color(0xff054A29)),),
                      ],
                    )
                  ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 20, right: 20),
                    child: Divider(color: Color(0xff00b661),),
                  ),
                  InkWell(
                    onTap: ()
                    async {
                      if(user.seller)
                      {

                          List<Qr.CameraDescription> cameras = await Qr.availableCameras();

                          if(cameras.length > 0)
                          {

                            PermissionHandler().requestPermissions([PermissionGroup.camera]).then((res){
                              res.forEach((g, s) async {
                                // ignore: ambiguous_import
                                if(g == PermissionGroup.camera && s == PermissionStatus.granted)
                                {
                                  SharedPreferences prefs = await SharedPreferences.getInstance();
                                  var obj = prefs.getString("user_data");
                                  if(obj != null)
                                  {
                                    Map<String, dynamic> tmp = jsonDecode(obj);
                                    var data = await Navigator.of(context).push(new MaterialPageRoute(builder: (context) => new QrScreen(cameras: cameras)));
                                    print(data);
                                    Response res = await new Dio().post(
                                        "${AppConfig.ip}/api/scan",
                                        options: Options(headers: {
                                          "authorization": "Token ${tmp['user']['token']}",
                                        }),
                                        data: {
                                          "code": data
                                        });

                                    if(res.statusCode == 200)
                                    {

                                      setState(() {
                                          getData();
                                      });
                                    }
                                    else
                                      Toast.show("QR invalide", context, textColor: Colors.white, duration: Toast.LENGTH_SHORT, gravity:  Toast.BOTTOM, backgroundColor: Colors.red);

                                  }

                                }
                              });
                            });

                          }
                          else
                            Toast.show("Camera error", context, textColor: Colors.white, duration: Toast.LENGTH_SHORT, gravity:  Toast.BOTTOM, backgroundColor: Colors.red);

                      }else
                        Toast.show("You should change the mod", context, textColor: Colors.black, duration: Toast.LENGTH_SHORT, gravity:  Toast.BOTTOM, backgroundColor: Colors.amber);
                    },
                    child: Container(
                        decoration: BoxDecoration(

                        ),
                        padding: EdgeInsets.only(top: 12, bottom: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(right: 20, left: 20),
                              child: Icon(Icons.center_focus_weak, color: Color(0xff00b661),),
                            ),
                            Text("Scan to get paid", style: TextStyle(color: Color(0xff054A29)),),
                          ],
                        )
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 20, right: 20),
                    child: Divider(color: Color(0xff00b661),),
                  ),
                  InkWell(
                    onTap: ()
                    async {
                      final latLng = await Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context)=> MapScreen(latlng: user.latLng, title: user.name, reset: getData,)));

                      setState(() {
//                        getData();
                        if(latLng != null)
                          user.latLng = latLng;
                      });
                    },
                    child: Container(
                    decoration: BoxDecoration(
                      
                    ),
                    padding: EdgeInsets.only(top: 12, bottom: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(right: 20, left: 20),
                          child: Icon(Icons.map, color: Color(0xff00b661),),
                        ),
                        Text("Shipping Address", style: TextStyle(color: Color(0xff054A29)),),
                      ],
                    )
                  ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 20, right: 20),
                    child: Divider(color: Color(0xff00b661),),
                  ),
                  InkWell(
                    onTap: ()
                    {
                      Navigator.of(context).push(MaterialPageRoute<void>(
                          builder: (BuildContext context)=> TransactionScreen(user: this.user,)
                      ));
                    },
                    child: Container(
                        decoration: BoxDecoration(

                        ),
                        padding: EdgeInsets.only(top: 12, bottom: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(right: 20, left: 20),
                              child: Icon(Icons.priority_high, color: Color(0xff00b661),),
                            ),
                            Text("Incomplete Transactions", style: TextStyle(color: Color(0xff054A29)),),
                          ],
                        )
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 20, right: 20),
                    child: Divider(color: Color(0xff00b661),),
                  ),
                  InkWell(
                    onTap: ()
                    {
                      Navigator.of(context).push(MaterialPageRoute<void>(
                        builder: (BuildContext context)=> PaymentScreen(user: this.user,)
                      ));
                    },
                    child: Container(
                    decoration: BoxDecoration(
                      
                    ),
                    padding: EdgeInsets.only(top: 12, bottom: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(right: 20, left: 20),
                          child: Icon(Icons.payment, color: Color(0xff00b661),),
                        ),
                        Text("Payment Method", style: TextStyle(color: Color(0xff054A29)),),
                      ],
                    )
                  ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 20, right: 20),
                    child: Divider(color: Color(0xff00b661),),
                  ),
                  InkWell(
                    onTap: ()
                    {
                      Navigator.of(context).push(MaterialPageRoute<void>(
                        builder: (BuildContext context)=> DipositScreen(user: this.user,)
                      ));
                    },
                    child: Container(
                    decoration: BoxDecoration(
                      
                    ),
                    padding: EdgeInsets.only(top: 12, bottom: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(right: 20, left: 20),
                          child: Icon(Icons.monetization_on, color: Color(0xff00b661),),
                        ),

                        Text("Deposit", style: TextStyle(color: Color(0xff054A29)),),
                      ],
                    )
                  ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 20, right: 20),
                    child: Divider(color: Color(0xff00b661),),
                  ),
                  InkWell(
                    onTap: ()
                    {
                      Navigator.of(context).push(MaterialPageRoute<void>(
                          builder: (BuildContext context)=> HistoryScreen(user: this.user,)
                      ));
                    },
                    child: Container(
                    decoration: BoxDecoration(
                      
                    ),
                    padding: EdgeInsets.only(top: 12, bottom: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(right: 20, left: 20),
                          child: Icon(Icons.history, color: Color(0xff00b661),),
                        ),
                        Text("Order History", style: TextStyle(color: Color(0xff054A29)),),
                      ],
                    )
                  ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 20, right: 20),
                    child: Divider(color: Color(0xff00b661),),
                  ),
                  InkWell(
                    onTap: ()
                    async {
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      var obj = prefs.getString("user_data");
                      if(obj != null)
                      {
                          user.seller = !user.seller;
                          user.bayer = !user.bayer;

                          Map<String, dynamic> tmp = jsonDecode(obj);
                          new Dio().post("${AppConfig.ip}/api/profile/mode", data: {
                            "id": tmp['user']["_id"],
                            "seller": user.seller,
                            "bayer": user.bayer
                          }, options: Options(headers: {
                            "authorization": "Token ${tmp['user']['token']}",
                          })).then((val){
                            setState(() {
                              this.widget.callback();
                            });
                          });
                      }
                    },
                    child: Container(
                    decoration: BoxDecoration(
                      
                    ),
                    padding: EdgeInsets.only(top: 12, bottom: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                         Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(right: 20, left: 20),
                          child: Icon(Icons.mode_edit, color: Color(0xff00b661),),
                        ),
                        Text("Mode", style: TextStyle(color: Color(0xff054A29)),),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.only(right: 20),
                      child: Text(user.seller? "Seller" : "Bayer", style: TextStyle(color: Colors.grey),)
                    )
                      ],
                    )
                  ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 20, right: 20),
                    child: Divider(color: Color(0xff00b661),),
                  ),
                  InkWell(
                    onTap: ()
                    {

                    },
                    child: Container(
                    decoration: BoxDecoration(
                      
                    ),
                    padding: EdgeInsets.only(top: 12, bottom: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                         Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(right: 20, left: 20),
                          child: Icon(Icons.language, color: Color(0xff00b661),),
                        ),
                        Text("Language", style: TextStyle(color: Color(0xff054A29)),),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.only(right: 20),
                      child: Text("English", style: TextStyle(color: Colors.grey),)
                    )
                      ],
                    )
                  ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 10, bottom: 10),
              margin: EdgeInsets.only(right: 20, left: 20, top: 20),
              decoration: BoxDecoration(
                boxShadow: [
                          BoxShadow(color: Colors.black26, offset: Offset.zero, blurRadius: 5, spreadRadius: 1),
                ],
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(10))
              ),
              child: Column(
                children: <Widget>[
                  InkWell(
                    onTap: ()
                    {

                    },
                    child: Container(
                    decoration: BoxDecoration(
                      
                    ),
                    padding: EdgeInsets.only(top: 12, bottom: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(right: 20, left: 20),
                          child: Icon(Icons.notifications_active, color: Color(0xff00b661),),
                        ),
                        Text("Notification Settings", style: TextStyle(color: Color(0xff054A29)),),
                      ],
                    )
                  ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 20, right: 20),
                    child: Divider(color: Color(0xff00b661),),
                  ),
                  InkWell(
                    onTap: ()
                    {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PrivacyPolicyScreen()),
                      );
                    },
                    child: Container(
                    decoration: BoxDecoration(
                      
                    ),
                    padding: EdgeInsets.only(top: 12, bottom: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(right: 20, left: 20),
                          child: Icon(Icons.note, color: Color(0xff00b661),),
                        ),
                        Text("Privacy Policy", style: TextStyle(color: Color(0xff054A29)),),
                      ],
                    )
                  ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 20, right: 20),
                    child: Divider(color: Color(0xff00b661),),
                  ),
                  InkWell(
                    onTap: ()
                    {

                    },
                    child: Container(
                    decoration: BoxDecoration(
                      
                    ),
                    padding: EdgeInsets.only(top: 12, bottom: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(right: 20, left: 20),
                          child: Icon(Icons.question_answer, color: Color(0xff00b661),),
                        ),
                        Text("FAQ", style: TextStyle(color: Color(0xff054A29)),),
                      ],
                    )
                  ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 20, right: 20),
                    child: Divider(color: Color(0xff00b661),),
                  ),
                  InkWell(
                    onTap: ()
                    {

                    },
                    child: Container(
                    decoration: BoxDecoration(
                      
                    ),
                    padding: EdgeInsets.only(top: 12, bottom: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(right: 20, left: 20),
                          child: Icon(Icons.rate_review, color: Color(0xff00b661),),
                        ),
                        Text("Rate us", style: TextStyle(color: Color(0xff054A29)),),
                      ],
                    )
                  ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 10, bottom: 10),
              margin: EdgeInsets.only(right: 20, left: 20, top: 20),
              decoration: BoxDecoration(
                boxShadow: [
                          BoxShadow(color: Colors.black26, offset: Offset.zero, blurRadius: 5, spreadRadius: 1),
                ],
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(10))
              ),
              child: InkWell(
                    onTap: ()
                    async {
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      prefs.remove("user_data");
                      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
                          SplashScreen()), (Route<dynamic> route) => false);
                    },
                    child: Container(
                    decoration: BoxDecoration(
                      
                    ),
                    padding: EdgeInsets.only(top: 12, bottom: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(right: 20, left: 20),
                          child: Icon(Icons.exit_to_app, color: Colors.red,),
                        ),
                        Text("Log out", style: TextStyle(color: Colors.red),),
                      ],
                    )
                  ),
                  ),
              )
            ],
          )
            ],
          ),
          )
        ],
      ),
    );
  }
}



class PhotoProfileHero extends StatefulWidget {

  String link;
PhotoProfileHero({@required this.link});

  @override
  _PhotoProfileHeroState createState() => _PhotoProfileHeroState();
}

class _PhotoProfileHeroState extends State<PhotoProfileHero> {

  @override
    void initState() {
      // TODO: implement initState
      super.initState();
  //       print("()()()()()(()((()()()(");
  // print(widget.entry.image);
    }

  @override
  Widget build(BuildContext context){

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(
          color: Colors.white
        ),
      ),
                  body: Container(
                    color: Colors.black,
                    child: Container(
                    // The blue background emphasizes that it's a new route.
                    alignment: Alignment.center,
                    child: Hero(
                      tag: "profile",
                      child: PhotoView(
                        imageProvider: CachedNetworkImageProvider(widget.link),
                      ),
                    )
                  ),
                  )
                );
  }
}







class MapScreen extends StatefulWidget {
  LatLng latlng;
  String title;
  Function reset;

  MapScreen({this.latlng, this.title, this.reset});

  @override
  State<MapScreen> createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> {

  Completer<GoogleMapController> _controller = Completer();
  static LatLng latlngPop;

  CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  @override
  void initState() {

    print(widget.latlng);
    super.initState();
    latlngPop = widget.latlng;
    flag = false;
    setState(() {
      getPos();
      _kGooglePlex = CameraPosition(
        target: widget.latlng,
        zoom: 14.4746,
      );
    });
  }

  getPos()async
  {

    String name = widget.title;

    _markers.add(Marker(
      markerId: MarkerId(name),
      position: widget.latlng,
    ));
    final CameraPosition _pos = CameraPosition(
        bearing: 192.8334901395799,
        target: widget.latlng,
//        tilt: 59.440717697143555,
        zoom: 19.151926040649414);
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_pos));
    setState(() {
    });
  }

  final Set<Marker> _markers = Set();
  bool flag;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(

      appBar: AppBar(
        leading: IconButton(icon: Icon(Icons.arrow_back_ios, color: Colors.white,), onPressed: ()=>Navigator.pop(context)),
        actions: <Widget>[
          flag?
          FlatButton(
//            color: Color(0xff00b661),
            onPressed: () async {

              SharedPreferences prefs = await SharedPreferences.getInstance();
              var obj = prefs.getString("user_data");
              if(obj != null) {
                Map<String, dynamic> tmp = jsonDecode(obj);
                Dio().post("${AppConfig.ip}/api/update/map",
                    data: {
                      "id": tmp['user']['_id'],
                      "lat": latlngPop.latitude.toString(),
                      "lng": latlngPop.longitude.toString()
                    },
                    options: Options(headers: {
                      "authorization": "Token ${tmp['user']['token']}",
                    }));
//                widget.reset().then((_){
                  Navigator.pop(context, latlngPop);
//                });
              }

            },
            child: Container(
              padding: EdgeInsets.only(top: 10, bottom: 10, left: 15, right: 15),
//          decoration: BoxDecoration(
//              borderRadius: BorderRadius.all(Radius.circular(50)),
//              color: Color(0xff00b661)
//          ),
              child: Text("Save", style: TextStyle(color: Colors.white, fontSize: 18),),
              //child: Text("Set", style: TextStyle(color: Colors.white, fontSize: 20),),
            ),
          ): Container(),
        ],
      ),
      body: GoogleMap(
        mapType: MapType.hybrid,
        myLocationButtonEnabled: true,
        myLocationEnabled: true,
        rotateGesturesEnabled: true,
        scrollGesturesEnabled: true,
        zoomGesturesEnabled: true,
        tiltGesturesEnabled: true,
        markers: _markers,
        onLongPress: (LatLng latlng){
          flag = true;
          latlngPop = latlng;
          setState(() {
            _markers.clear();
            _markers.add(Marker(
              markerId: MarkerId('My Location'),
              position: latlng,
            ));
          });
          setState(() async{
            final CameraPosition _pos = CameraPosition(
//                bearing: 192.8334901395799,
                target: latlng,
//                tilt: 59.440717697143555,
                zoom: 19.151926040649414
            );
            final GoogleMapController controller = await _controller.future;
            controller.animateCamera(CameraUpdate.newCameraPosition(_pos));

          });
        },
        initialCameraPosition: _kGooglePlex,
        onMapCreated: (GoogleMapController controller) async {
          _controller.complete(controller);
        },
      ),
    );
  }

}