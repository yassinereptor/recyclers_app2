import 'dart:async';
import 'dart:convert';
import 'package:timeago/timeago.dart' as timeago;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pagewise/flutter_pagewise.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:photo_view/photo_view.dart';
import 'package:recase/recase.dart';
import 'package:recyclers/config/config.dart';
import 'package:recyclers/home.dart';
import 'package:recyclers/models/product.dart';
import 'package:recyclers/models/user.dart';
import 'package:recyclers/product.dart';
import 'package:recyclers/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ProfileViewScreen extends StatefulWidget {
  var user;
  ProfileViewScreen({Key key, this.user}) : super(key: key);

  @override
  _ProfileViewScreenState createState() => _ProfileViewScreenState();
}

class _ProfileViewScreenState extends State<ProfileViewScreen> {

  static var id;
  @override
  void initState() {
    _pageLoadController.addListener(() {
      if (!_pageLoadController.hasMoreItems) {
        Scaffold.of(context).showSnackBar(
            SnackBar(
                content: Text('No More Items!')
            )
        );
      }
    });
    super.initState();
    id  = widget.user.id;
    user = widget.user;
  }

  static const int PAGE_SIZE = 10;

  final _pageLoadController = PagewiseLoadController(
    pageSize: PAGE_SIZE,
    pageFuture: (pageIndex) =>
        BackendService.getProduct(id, pageIndex * PAGE_SIZE, PAGE_SIZE),
  );


  UserData user;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(icon: Icon(Icons.arrow_back_ios, color: Colors.white,), onPressed: ()=> Navigator.pop(context)),
      ),
      body: ScrollConfiguration(
        behavior: ScrollBehaviorCos(),
        child: NestedScrollView(
          headerSliverBuilder: (context, inn){
            return <Widget>[
            SliverToBoxAdapter(
              child: Column(
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
                            .copyWith(color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        (this.user != null)? this.user.email : "",
                        style: Theme.of(context)
                            .textTheme
                            .subtitle
                            .copyWith(color: Colors.black.withAlpha(200)),
                      )
                    ],
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 20, right: 20, top: 20),

                    child:  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          child: Text("Details", style: TextStyle(
                              fontSize: 20,
                              fontFamily: "Oswald",
                              color: Colors.black
                          ),),
                        ),
                        IconButton(
                          onPressed: (){
                            Navigator.of(context).push(MaterialPageRoute<void>(
                                builder: (BuildContext context)=> MapScreen(latlng: this.user.latLng, title: this.user.name,)
                            ));
                          },
                          icon: Icon(Icons.map, color: Color(0xff00b661),),
                        )
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        (this.user.company_name.isNotEmpty)?
                        Row(
                          children: <Widget>[
                            Text("Company Name ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),),
                            Text(this.user.company_name),
                          ],
                        ): Container(),
                        (this.user.company_name.isNotEmpty && this.user.company_id.isNotEmpty)?
                        Row(
                          children: <Widget>[
                            Text("Company Serie ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),),
                            Text(this.user.company_id),
                          ],
                        ): Container(),
                        Row(
                          children: <Widget>[
                            Text("Phone ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),),
                            Text(this.user.phone),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Text("Country ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),),
                            Text(this.user.country),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Divider(),
                  Container(
                    margin: EdgeInsets.only(left: 20),
                    alignment: Alignment.centerLeft,
                    child: Text("Products", style: TextStyle(
                        fontSize: 20,
                        fontFamily: "Oswald",
                        color: Colors.black
                    ),),
                  ),
                ],
              ),
            ),
            ];
            },
          body: Container(
            padding: EdgeInsets.only(top: 20),
              child: RefreshIndicator(
                  onRefresh: () async {
                    this._pageLoadController.reset();
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
          ),
        )
      )
    );
  }





  Widget _itemBuilder(context, ProductModel entry, _) {

    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.25,
      secondaryActions: <Widget>[
        Container(
          child: Container(
            padding: EdgeInsets.only(
              right: 15,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(top: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Container(
                        alignment: Alignment.centerLeft,
                        child: Icon(Icons.timelapse, color: Color(0xff00b661), size: 18,),
                      ),
                      Text("${timeago.format(DateTime.parse(entry.time), locale: 'en_short')}", style: TextStyle(
                          color: Color(0xff00b661), fontSize: 15
                      ),),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(bottom: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Container(
                        alignment: Alignment.centerLeft,
                        child: Icon(Icons.star, color: Colors.yellow[800], size: 20,),
                      ),
                      Text("${entry.quality}/5", style: TextStyle(color: Colors.yellow[800], fontSize: 15),)
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ],
      child: GestureDetector(
        onTap: (){
          Navigator.of(context).push(MaterialPageRoute<void>(
              builder: (BuildContext context)=> ProductScreen(entry: entry,)
          ));
        },
        child: Container(
            padding: EdgeInsets.only(left: 0, right: 5, top: 0, bottom: 0),
            margin: EdgeInsets.only(left: 5, right: 5, top: 6, bottom: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(3)),
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black26, offset: Offset.zero, blurRadius: 2, spreadRadius: 0),
              ],
            ),
            child:
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                GestureDetector(
                    onTap: (){
                      if((entry.image.length != 0))
                      {
                        Navigator.of(context).push(MaterialPageRoute<void>(
                            builder: (BuildContext context)=> PhotoHero(entry: entry,)
                        ));
                      }
                    },
                    child:  Hero(
                      tag: entry.id,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(3)),

                        ),
                        margin: EdgeInsets.only(right: 10),
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: 130,
                          height: 110,
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(3), topLeft: Radius.circular(3)),
                                // boxShadow: [
                                //   BoxShadow(color: Colors.black26, offset: Offset.zero, blurRadius: 2, spreadRadius: 0),
                                // ],
                                color: Colors.black,
                                image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: (entry.image.length != 0)? CachedNetworkImageProvider(
                                        entry.image[0],
                                        errorListener: (){

                                        }
                                    ) : AssetImage("assets/images/placeholder.png")
                                )

                              // image: DecorationImage(
                              //   image:  AssetImage("assets/images/profile.png"),
                              //   fit: BoxFit.fill
                              // )
                            ),
                          ),
                        ),
                      ),
                    )
                ),
                Expanded(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                          maxHeight: 110,
                          maxWidth: 200
                      ),
                      child: Container(
                        padding: EdgeInsets.only(top: 10, bottom: 5),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Expanded(
                                    child: Container(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(entry.title, style: TextStyle(
                                                fontSize: 18
                                            ),),
                                            Text("by ${entry.user_name}", style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey
                                            ),),
                                          ],
                                        )

                                    )
                                ),
                                Icon(Icons.keyboard_return, color: Colors.grey[200], size: 15)
                              ],
                            ),

                            Container(
                              padding: EdgeInsets.only(top: 0, bottom: 0),
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    flex: 2,
                                    child: Container(
                                        child: entry.fix? Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: <Widget>[
                                                Flexible(
                                                  child: Text("${double.parse(entry.price)} ", style: TextStyle(
                                                      color: Color(0xff00b661),
                                                      fontSize: 16
                                                  ),),
                                                ),
                                                Flexible(
                                                  child: Text("Dh / ${ProductUnit.getUnit(entry.unit)}", style: TextStyle(
                                                    color: Color(0xff00b661),
                                                    fontSize: 12,
                                                  ),),
                                                )
                                              ],
                                            ),
                                            Text("In Stock: ${entry.quantity}", style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey
                                            ),)
                                          ],
                                        ) : Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,

                                          children: <Widget>[
                                            Row(
                                              children: <Widget>[
                                                Container(
                                                  padding: EdgeInsets.only(right: 5),
                                                  child: Icon(Icons.timer, size: 15, color: Colors.grey,),
                                                ),
                                                Text("∞", style: TextStyle(
                                                    color: Color(0xff00b661)
                                                ),),
                                                Container(
                                                  padding: EdgeInsets.only(left: 2, right: 2),
                                                  child: Text("|", style: TextStyle(
                                                      color: Colors.grey
                                                  ),),
                                                ),
                                                Container(
                                                  padding: EdgeInsets.only(right: 5),
                                                  child: Icon(Icons.person_outline, size: 16, color: Colors.grey,),
                                                ),
                                                Text("6 bid", style: TextStyle(
                                                    color: Color(0xff00b661)
                                                ),),
                                              ],
                                            ),
                                            Row(
                                              children: <Widget>[
                                                Container(
                                                  padding: EdgeInsets.only(right: 5),
                                                  child: Icon(Icons.shopping_basket, size: 15, color: Colors.grey,),
                                                ),
                                                Text("${entry.quantity} ${ProductUnit.getUnit(entry.unit)}", style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey
                                                ),)
                                              ],
                                            )
                                          ],
                                        )
                                    ),
                                  ),

                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    )
                )
              ],
            )
        ),
      ),
    );
  }
}


class BackendService {

  static Future<List<ProductModel>> getProduct(id, offset, limit) async {

    Dio dio = new Dio();
    final responseBody = (await dio.post("${AppConfig.ip}/api/product/load/user", data: {
      "id": id,
      "cats": [],
      "filter": "time",
      "skip": offset,
      "limit": limit
    }
    )).data;

    print(responseBody);
    return ProductModel.fromJsonList(responseBody);
  }
}

class ProductModel {
  String id;
  String title;
  String user_id;
  String user_name;
  String desc;
  String price;
  String quality;
  String time;
  bool fix;
  bool bid;
  int quantity;
  int unit;
  int cat;
  int order;
  var image;
  var bid_list;


  ProductModel.fromJson(obj) {

    this.id = obj["_id"];
    this.order = obj["order"];
    this.bid_list = obj["bid_list"];
    this.title = obj["title"];
    this.desc = obj["desc"];
    this.user_id = obj["user_id"];
    this.user_name = obj["user_name"];
    this.price = obj["price"].toString();
    this.quality = obj["quality"].toString();
    this.quantity = obj["quantity"];
    this.unit = obj["unit"];
    this.image = obj["images"];
    this.fix = obj["fix"];
    this.bid = obj["bid"];
    this.time = obj["time"];
    this.cat = obj["cat"];

  }

  static List<ProductModel> fromJsonList(jsonList) {
    return jsonList.map<ProductModel>((obj) => ProductModel.fromJson(obj)).toList();
  }
}



class PhotoHero extends StatefulWidget {

  var entry;
  PhotoHero({@required this.entry});

  @override
  _PhotoHeroState createState() => _PhotoHeroState();
}

class _PhotoHeroState extends State<PhotoHero> {

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
                tag: widget.entry.id,
                child: PhotoView(
                  imageProvider: CachedNetworkImageProvider(widget.entry.image[0]),
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

  MapScreen({this.latlng, this.title});

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

  @override
  Widget build(BuildContext context) {
    return new Scaffold(

      appBar: AppBar(
        leading: IconButton(icon: Icon(Icons.arrow_back_ios, color: Colors.white,), onPressed: ()=>Navigator.pop(context)),
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
        initialCameraPosition: _kGooglePlex,
        onMapCreated: (GoogleMapController controller) async {
          _controller.complete(controller);
        },
      ),
    );
  }

}