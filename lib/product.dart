import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:recase/recase.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pagewise/flutter_pagewise.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:recyclers/config/config.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:recyclers/home.dart';
import 'package:recyclers/models/product.dart';
import 'package:photo_view/photo_view.dart';
import 'package:recyclers/models/user.dart';
import 'package:recyclers/profile_view.dart';
import 'package:recyclers/store.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;


class ProductScreen extends StatefulWidget {

  var entry;
ProductScreen({@required this.entry});

  @override
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {

  List<int> list;
  int _current = 0;

  static String id;
  var cart;
  var bid;

  Future getItems()
  async {
    Dio dio = new Dio();
    cart.clear();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var obj = prefs.getString("user_data");
    if(obj != null)
    {
      Map<String, dynamic> tmp = jsonDecode(obj);
      dio.post("${AppConfig.ip}/api/cart/load",
          options: Options(headers: {
            "authorization": "Token ${tmp['user']['token']}",
          }), data: {
            "id": tmp["user"]["_id"]
          }).then((data){
        cart = data.data;


        dio.post("${AppConfig.ip}/api/bid/load",
            options: Options(headers: {
              "authorization": "Token ${tmp['user']['token']}",
            }), data: {
              "id": tmp["user"]["_id"]
            }).then((item){
          bid = item.data;
          setState(() {});
        });

      });
    }
  }

  @override
    void initState() {
      // list = new List(widget.entry.image.length);
    print("------------------");
    cart = new List();
    bid = new List();
    print(widget.entry);
    int i = 0;
      list = new List();

      addView();

    if(widget.entry.image.length != 0)
    {
      while(i < widget.entry.image.length)
        list.add(i++);
    }
    id = widget.entry.id;
    rate = 0;
    getItems();
    getUser();
    super.initState();
    }

  checkCart(id)
  {
    bool flag = false;

    if(cart.length > 0)
    {

      cart.forEach((it){

        if(it["_id"] == id)
        {
          flag = true;
        }
      });
    }

    if(bid.length > 0)
    {

      bid.forEach((it){

        if(it["_id"] == id)
        {
          flag = true;
        }
      });
    }

    return (flag);
  }

    addView()
    async {
        Dio dio = new Dio();
        SharedPreferences prefs = await SharedPreferences.getInstance();
        var obj = prefs.getString("user_data");
        if(obj != null)
        {

          Map<String, dynamic> tmp = jsonDecode(obj);

          if(tmp["user"]["_id"] != widget.entry.user_id)
          {
            dio.post("${AppConfig.ip}/api/product/view/add",
                options: Options(headers: {
                  "authorization": "Token ${tmp['user']['token']}",
                }),
                data: {
              "id": tmp["user"]["_id"],
              "prod_id": widget.entry.id
            });
          }
        }
    }

  var user;

  getUser()
  async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var obj = prefs.getString("user_data");
    if(obj != null) {
      Map<String, dynamic> tmp = jsonDecode(obj);
      setState(() {
        user = tmp["user"];

      });
    }
  }


  Future removeItems(id)
  async {
    Dio dio = new Dio();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var obj = prefs.getString("user_data");
    if(obj != null)
    {
      Map<String, dynamic> tmp = jsonDecode(obj);
      dio.post("${AppConfig.ip}/api/cart/add",
          options: Options(headers: {
            "authorization": "Token ${tmp['user']['token']}",
          }), data: {
            "id": tmp["user"]["_id"],
            "prod_id": id,
          }).then((data){

        print(data.data);
        setState(() {
          getItems();
        });
      });
    }
  }
  Future removeBid(id)
  async {
    Dio dio = new Dio();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var obj = prefs.getString("user_data");
    if(obj != null)
    {
      Map<String, dynamic> tmp = jsonDecode(obj);
      dio.post("${AppConfig.ip}/api/bid/add",
          options: Options(headers: {
            "authorization": "Token ${tmp['user']['token']}",
          }), data: {
            "id": tmp["user"]["_id"],
            "prod_id": id,
          }).then((data){

        print(data.data);
        getItems();
        setState(() {

        });
      });
    }
  }


onSendReviewPress()
async {
  
  if(rev_controller.text.isNotEmpty)
  {
    Dio dio = new Dio();
    SharedPreferences prefs = await SharedPreferences.getInstance();
      var obj = prefs.getString("user_data");
      if(obj != null)
      {
          
        Map<String, dynamic> tmp = jsonDecode(obj);

        dio.post("${AppConfig.ip}/api/info", data: {
          "id": tmp["user"]["_id"]
        }).then((user){
          if(user.statusCode == 200)
          {
            print("------------------------------------------------");
            print("${rate} ${rev_controller.text}");
            print("------------------------------------------------");

            dio.post("${AppConfig.ip}/api/product/review", data: {
              "post_user_id": widget.entry.user_id,
              "user_id": tmp["user"]["_id"],
              "post_id": widget.entry.id,
              "text": rev_controller.text,
              "rate": rate,
              "profile": user.data["user"]["profile"],
              "time": new DateTime.now().toString()
            }).then((data){
              this._pageLoadController.reset();
               setState(() {
                rev_controller.text = "";
                rate = 0.0;
              });
            });
          }
        });
      }
   
  }
}


static const int PAGE_SIZE = 10;

  TextEditingController rev_controller = new TextEditingController();
  final _formKey = GlobalKey<FormState>();
  var rate;


final _pageLoadController = PagewiseLoadController(
  pageSize: PAGE_SIZE,
  pageFuture: (pageIndex) =>
            BackendReviewService.getReview(id, pageIndex * PAGE_SIZE, PAGE_SIZE),
);

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.entry.title, style: TextStyle(color: Colors.white),),
        centerTitle: true,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios, color: Colors.white,), onPressed: ()=> Navigator.pop(context)),
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 25,
        child: Container(
          height: 75,
          padding: EdgeInsets.only(left: 20, right: 20, top: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    alignment: Alignment.topLeft,
                    child: Text(widget.entry.bid? "Starting price:" : "Price:"),
                  ),
                  Container(
                    child: widget.entry.bid? Container(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Text("${widget.entry.price}", style: TextStyle(
                          color: Color(0xff00b661),
                          fontSize: 20
                        ),),
                        Text(" Dh for ${widget.entry.quantity} ${ProductUnit.getUnit(widget.entry.unit)}", style: TextStyle(
                          color: Color(0xff00b661)
                          ),
                        ),
                      ],
                    )
                  ) : Container(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Text("${widget.entry.price}", style: TextStyle(
                          color: Color(0xff00b661),
                          fontSize: 20
                        ),),
                        Text(" Dh / ${ProductUnit.getUnit(widget.entry.unit)}", style: TextStyle(
                          color: Color(0xff00b661)
                          ),
                        ),
                      ],
                    )
                  ),
                  )
                ],
              ),
              Container(
                  margin: EdgeInsets.only(right: 5),
                  child: FlatButton(

                    onPressed: (){
                      if(user != null && user["_id"] == widget.entry.user_id)
                      {

                      }
                      else if(widget.entry.fix)
                      {
                        if(checkCart(widget.entry.id))
                          removeItems(widget.entry.id);
                        else
                          showDialog(context: context,builder: (context) => QuanOverlay(entry: widget.entry, getItems: getItems));
                      }
                      else
                      {
                        if(checkCart(widget.entry.id))
                        {
                          removeBid(widget.entry.id);
                        }
                        else
                          showDialog(context: context,builder: (context) => BidOverlay(entry: widget.entry, getItems: getItems));
                      }
                    },
                    color: Color(0xff00b661),
                    shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                    child:
                    (user != null && user["_id"] == widget.entry.user_id)?
                    Container(
                      height: 25,
                        alignment: Alignment.center,
                        child: Text("Edit", style: TextStyle(
                            color: Colors.white,
                            fontSize: 12
                        ),
                        )):
                    (!checkCart(widget.entry.id))? Container(
                        height: 25,

                        alignment: Alignment.center,
                        child: Text(widget.entry.fix? "Add" : "Bid", style: TextStyle(
                            color: Colors.white,
                            fontSize: 12
                        ),
                        )): Container(
                      height: 25,

                      child: Icon(Icons.check, color: Colors.white,),
                    ),
                  )
              ),
            ],
          ),
        ),
      ),
      body: NestedScrollView(
         headerSliverBuilder: (context, inn){
          return <Widget>[
              SliverToBoxAdapter(
                child: Column(
        children: <Widget>[
          Container(
            //This
            color: Colors.white,
            padding: (list.isNotEmpty)? EdgeInsets.only(top: 10, bottom: 10) : EdgeInsets.only(),
            margin: EdgeInsets.only(bottom: 10),
            child: Stack(
            children: <Widget>[
              Container(
                child: (list.isNotEmpty)? CarouselSlider(
        initialPage: 0,
        enableInfiniteScroll: false,
        enlargeCenterPage: true,
        onPageChanged: (index) {
            setState(() {
              _current = index;
            });
          },
        items: (list.isNotEmpty)? list.map((i) {
          return Builder(
            builder: (BuildContext context) {
              return Container(
                decoration: BoxDecoration(
                ),
                child: Container(
                    // The blue background emphasizes that it's a new route.
                    alignment: Alignment.center,
                      child: InkWell(
                        onTap: (){
                            Navigator.push(context, MaterialPageRoute( builder: (context) => PhotoHeroProduct(entry: widget.entry.image[i], id: widget.entry.id),));
                        },
                        child: Container(
                        decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(5)),                          
                          image: DecorationImage(
                            image: CachedNetworkImageProvider(widget.entry.image[i]),
                            fit: BoxFit.cover,
                          )
                        ),
                      )
                      
                    ),
                )
              );
            },
          );
        }).toList() : null,
      ) : Container(),
              ),
      Positioned(
          bottom: 0.0,
          left: 0.0,
          right: 0.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: list.map((i) {
              return Container(
                width: _current == i? 16.0 : 8.0,
                height: 8.0,
                margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(50)),
                  color: _current == i ? Color.fromRGBO(255, 255, 255, 0.9) : Color.fromRGBO(255, 255, 255, 0.4)
                ),
              );
            }).toList(),
          )
        )
            ],
          )
          ),
         Container(
           padding: EdgeInsets.only(left: 20, right: 20, bottom: 10),
           child: Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: <Widget>[
               Row(
                 children: <Widget>[
                   Text("by ", style: TextStyle(
                       fontSize: 12
                   ),),
                   GestureDetector(
                     child: Text(ReCase(widget.entry.user_name.toString()).titleCase, style: TextStyle(
                         fontSize: 14
                     ),),
                     onTap: ()async{


                         SharedPreferences prefs = await SharedPreferences.getInstance();
                         var obj = prefs.getString("user_data");
                         if(obj != null)
                         {
                           Map<String, dynamic> tmp = jsonDecode(obj);
                           Response response;
                           Dio dio = new Dio();
                           response = await dio.get("${AppConfig.ip}/api/current?id=${widget.entry.user_id}",
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
                               Navigator.push(
                                 context,
                                 MaterialPageRoute(builder: (context) => ProfileViewScreen(user: user,)),
                               );
                             });
                           }
                         }




                     },
                   )
                 ],
               ),
               Text("${timeago.format(DateTime.parse(widget.entry.time))}", style: TextStyle(
                   fontSize: 14
               ),)
             ],
           ),
         ),
         Container(
           padding: EdgeInsets.only(left: 20, right: 20),
           child: Column(
             children: <Widget>[
                Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
                Text("Details", style: TextStyle(
                    fontSize: 20,
                    fontFamily: "Oswald",
                    color: Colors.black
                  ),),
                  Row(
                    children: <Widget>[
                      Icon(Icons.star, color: Colors.yellow[800]),
                  Text("${widget.entry.quality}/5", style: TextStyle(color: Colors.yellow[800], fontSize: 18),)
                    ],
                  ),
            ],
          ),

             Container(
          margin: EdgeInsets.only(top: 10, bottom: 10),
          child: (widget.entry.desc.toString().length > 0)? DescriptionTextWidget(text: widget.entry.desc,):
               Container(
                 alignment: Alignment.center,
                 child: Text("No Description"),
               ),
        ),
        Container(
          child: Column(
            children: <Widget>[

              Padding(padding: EdgeInsets.only(top: 10)),
              Row(
                children: <Widget>[
                  Text("Quantity:  ", style: TextStyle(
                    fontWeight: FontWeight.bold,
fontSize: 15
                  ),),
                  Text(widget.entry.quantity.toString(), style: TextStyle(
                    fontSize: 15
                  ),)
                ],
              ),
              Padding(padding: EdgeInsets.only(top: 10)),
              
              Row(
                children: <Widget>[
                  Text("Category:  ", style: TextStyle(
                    fontWeight: FontWeight.bold,
fontSize: 15
                  ),),
                  Text(ProductCat.getCat(widget.entry.cat), style: TextStyle(
                    fontSize: 15
                  ),)
                ],
              ),

              Padding(padding: EdgeInsets.only(bottom: 15)),

            ],
          ),
        ),
        Divider(),
        Container(
          alignment: Alignment.centerLeft,
          child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
              Text("Reviews", style: TextStyle(
                    fontFamily: "Oswald",
                    fontSize: 20,
                    color: Colors.black
                  ),),
            Text("Write your review", style: TextStyle(
              fontFamily: "Oswald",
              fontSize: 12,
              color: Color(0xff00b661)
            ),),
              ],
            ),
        ),
        Container(
          margin: EdgeInsets.only(bottom: 20),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                Container(
            padding: EdgeInsets.only(top: 15),
            child: FlutterRatingBar(
            itemSize: 30,
                  initialRating: double.parse(rate.toString()),
                  fillColor: Color(0xff00b661),
                  borderColor: Color(0xff00b661).withAlpha(60),
                  allowHalfRating: true,
                  onRatingUpdate: (rating){
                    rate = rating;
                  },
                ),
          ),
                Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
                Expanded(
                  child: Container(

                child: new TextFormField(
                  controller: rev_controller,
                      decoration: new InputDecoration(
                        labelText: "...",
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
                ),
                Container(
                  margin: EdgeInsets.only(left: 5),
              child: FlatButton(
                    onPressed: onSendReviewPress,
                    shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(50.0)),
                    child: Container(
                      alignment: Alignment.center,
                      child: Text("Send", style: TextStyle(
                      color: Color(0xff00b661),
                    ),
                    )),
                  ),
            )
            ],
          ),
          
              ],
            )
          )
        ),
         Divider(),
             ],
           ),
         )
        ],
      ),
              )
             
          ];
          } ,
          body: Container(
            margin: EdgeInsets.only(top: 20),
        child: Container(
          child: ScrollConfiguration(
      behavior: ScrollBehaviorCos(),
      child: PagewiseListView(
                        itemBuilder: this._itemBuilder,
                        pageLoadController: this._pageLoadController,
                        loadingBuilder: (context) {
                          return Text('Loading...');
                        },
                        noItemsFoundBuilder: (context) {
                          return Text('No Review Found');
                        },
                      ),
    ),
        )
      ),
      )
      
                );
  }

  Widget _itemBuilder(context, ReviewModel entry, _) {

    return Container(
      padding: EdgeInsets.only(left: 15),
      margin: EdgeInsets.only(bottom: 10),
      child: Row(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(5),
            child: Container(
              height: 35,
              width: 35,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.black26, offset: Offset.zero, blurRadius: 2, spreadRadius: 0),
                ],
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: (entry.profile == "non")? AssetImage("assets/images/profile.png") : CachedNetworkImageProvider(entry.profile)
                )
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.only(left: 10, right: 20, top: 5, bottom: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(entry.user_name, style: TextStyle(fontWeight: FontWeight.bold),),
                      Container(
                        child: Row(
                          children: <Widget>[
                              Icon(Icons.star, color: Colors.yellow[800], size: 15,),
                              Text("${entry.rate}/5", style: TextStyle(color: Colors.yellow[800], fontSize: 13),)
                            ],
                          ),
                      )
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(top: 5),
                  child: Text(entry.text),
                )
              ],
            ),
          ),
          )
        ],
      ),
    );
  }
}




class DescriptionTextWidget extends StatefulWidget {
  final String text;

  DescriptionTextWidget({@required this.text});

  @override
  _DescriptionTextWidgetState createState() => new _DescriptionTextWidgetState();
}

class _DescriptionTextWidgetState extends State<DescriptionTextWidget> {
  String firstHalf;
  String secondHalf;

  bool flag = true;

  @override
  void initState() {
    super.initState();

    if (widget.text.length > 50) {
      firstHalf = widget.text.substring(0, 50);
      secondHalf = widget.text.substring(50, widget.text.length);
    } else {
      firstHalf = widget.text;
      secondHalf = "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      padding: new EdgeInsets.symmetric(vertical: 10.0),
      child: secondHalf.isEmpty
          ? new Text(firstHalf)
          : new Column(
              children: <Widget>[
                new Text(flag ? (firstHalf + "...") : (firstHalf + secondHalf)),
                Container(

                  child: new InkWell(
                  child: Container(
                    margin: EdgeInsets.only(top: 10),
                    child: new Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: Divider(),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 5, right: 5),
                        child: new Text(
                        flag ? "show more" : "show less",
                        style: new TextStyle(color: Color(0xff00b661)),
                      ),
                      ),
                       Expanded(
                        child: Divider(),
                      ),
                    ],
                  ),
                  ),
                  onTap: () {
                    setState(() {
                      flag = !flag;
                    });
                  },
                ),
                ),
                
              ],
            ),
    );
  }
}


class PhotoHeroProduct extends StatefulWidget {

  String entry;
  String id;
PhotoHeroProduct({@required this.entry, @required this.id});

  @override
  _PhotoHeroProductState createState() => _PhotoHeroProductState();
}

class _PhotoHeroProductState extends State<PhotoHeroProduct> {

  @override
    void initState() {
      super.initState();
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
                    alignment: Alignment.center,
                    child: Hero(
                      tag: widget.id,
                      child: PhotoView(
                        imageProvider: CachedNetworkImageProvider(widget.entry),
                      ),
                     
                    )
                  ),
                  )
                );
  }
}



class BackendReviewService {

  static Future<List<ReviewModel>> getReview(id, offset, limit) async {
    Dio dio = new Dio();
    final responseBody = (await dio.post("${AppConfig.ip}/api/product/review/load", data: {
            "post_user_id": id,
            "limit": limit,
            "skip": offset
          }
    )).data;
   
    print(responseBody);
    return ReviewModel.fromJsonList(responseBody);
  }
}

class ReviewModel {
  String _id;
  String profile;
  String post_user_id;
  String user_id;
  String post_id;
  String text;
  double rate;
  String user_name;



  ReviewModel.fromJson(obj)  {

    print("------------------------------------");
    print(obj);
    print("------------------------------------");

    this._id = obj["_id"];
    this.profile = obj["profile"];
    this.post_user_id = obj["post_user_id"];
    this.user_id = obj["user_id"];
    this.post_id = obj["post_id"];
    this.text = obj["text"];
    this.rate = double.parse(obj["rate"].toString());
    this.user_name = obj["user_name"];

   
    
  }

  static List<ReviewModel> fromJsonList(jsonList) {
    return jsonList.map<ReviewModel>((obj) => ReviewModel.fromJson(obj)).toList();
  }
}
