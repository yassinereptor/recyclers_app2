import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pagewise/flutter_pagewise.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:recyclers/config/config.dart';
import 'package:recyclers/home.dart';
import 'package:recyclers/models/product.dart';
import 'package:recyclers/product.dart';
import 'package:recyclers/store.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'models/user.dart';


class CartScreen extends StatefulWidget {
  UserData user;

  CartScreen({Key key, this.user}) : super(key: key);

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {

  static UserData user;
  double total;

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
    total = 0;

    user = this.widget.user;
    getTotal();
    super.initState();

  }

  static const int PAGE_SIZE = 10;

  final _pageLoadController = PagewiseLoadController(
    pageSize: PAGE_SIZE,
    pageFuture: (pageIndex) =>
              BackendCartService.getProduct(user.id, pageIndex * PAGE_SIZE, PAGE_SIZE),
  );

Future removeItemsAll()
      async {
        Dio dio = new Dio();
        SharedPreferences prefs = await SharedPreferences.getInstance();
        var obj = prefs.getString("user_data");
        if(obj != null)
        {
          Map<String, dynamic> tmp = jsonDecode(obj);
          dio.post("${AppConfig.ip}/api/cart/removeall",
            options: Options(headers: {
              "authorization": "Token ${tmp['user']['token']}",
            }), data: {
            "id": tmp["user"]["_id"],
          }).then((data){

            print(data.data);
            setState(() {
                    getTotal();
                    _pageLoadController.reset();
                  });
          });
        }
      }

  Future removeItem(id)
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
                    getTotal();
                    _pageLoadController.reset();
                  });
          });
        }
      }

  Future getTotal()
      async {
        Dio dio = new Dio();
        SharedPreferences prefs = await SharedPreferences.getInstance();
        var obj = prefs.getString("user_data");
        if(obj != null)
        {
          Map<String, dynamic> tmp = jsonDecode(obj);
          dio.post("${AppConfig.ip}/api/cart/total",
            options: Options(headers: {
              "authorization": "Token ${tmp['user']['token']}",
            }), data: {
            "id": tmp["user"]["_id"],
          }).then((data){
            print(data.data);
            setState(() {
               total = double.parse(data.data.toString());
              });
          });
        }
      }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    child: Text("Price:"),
                  ),
                  Container(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Text("${total}", style: TextStyle(
                          color: Color(0xff00b661),
                          fontSize: 20
                        ),),
                        Text(" Dh", style: TextStyle(
                          color: Color(0xff00b661)
                          ),
                        ),
                      ],
                    )
                  )
                ],
              ),
              // Container(
              //   child: FlatButton(
              //       onPressed: (){},
              //       color: Color(0xff00b661),
              //       shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(50.0)),
              //       child: Container(
              //         height: 25,
              //         alignment: Alignment.center,
              //         child: Text("CheckOut", style: TextStyle(
              //         color: Colors.white,
              //       ),
              //       )),
              //     ),
              // )
            ],
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: NestedScrollView(
        headerSliverBuilder: (context, inn){
          return <Widget>[
            SliverToBoxAdapter(
              child: Container(
              margin: EdgeInsets.only(bottom: 10),
              child: Padding(
                    padding: EdgeInsets.only(top: 10, left: 10, right: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text("Cart", style: TextStyle(
                          fontFamily: "Oswald",
                          fontSize: 20,
                          color: Colors.black
                        ),),
                        OutlineButton(
                          highlightedBorderColor: Color(0xff00b661),
                          borderSide: BorderSide(
                            color: Color(0xff00b661)
                          ),
                          onPressed: removeItemsAll,
                          color: Colors.white,
                          shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                          child: Container(
                            alignment: Alignment.center,
                            child: Text("Clear all", style: TextStyle(
                            color: Color(0xff00b661),
                          fontSize: 12
                          ),
                          )),
                        ),
                      ],
                    )
                  )
            ),
            ),
          ];
        },
        body: Container(
          child: RefreshIndicator(
    onRefresh: () async {
      getTotal();
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
     
    );
  }


  Widget _itemBuilder(context, ProductModel entry, _) {
      print("++++++++++++++++++++++++++++++++++++++++++++++++++");
      print("${entry.id}");
      print("++++++++++++++++++++++++++++++++++++++++++++++++++");
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Flexible(
                          child: Text("${double.parse(entry.price) * entry.order} ", style: TextStyle(
                          color: Color(0xff00b661),
                          fontSize: 16
                        ),),
                        ),
                        Flexible(
                          child: Text("Dh", style: TextStyle(
                          color: Color(0xff00b661),
                          fontSize: 12,
                        ),),
                        )
                      ],
                    ),
                    Text("Quantite: ${entry.order} ${ProductUnit.getUnit(entry.unit)}", style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey
                    ),)
                  ],
                )
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                margin: EdgeInsets.only(right: 5),
                child: FlatButton(
                    onPressed: (){
                      if(entry.fix)
                      {
                        removeItem(entry.id);
                      }
                      else
                      {

                      }
                    },
                    color: Color(0xff00b661),
                    shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                    child: Container(
                      alignment: Alignment.center,
                      child: Text("Remove", style: TextStyle(
                      color: Colors.white,
                    fontSize: 9.5
                    ),
                    )),
                  ),
              ),
            )
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



class BackendCartService {
  
  static Future<List<ProductModel>> getProduct(id, offset, limit) async {
    Dio dio = new Dio();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var obj = prefs.getString("user_data");
    if(obj != null)
    {
      Map<String, dynamic> tmp = jsonDecode(obj);
      final responseBody = (await dio.post("${AppConfig.ip}/api/cart/load",
      options: Options(headers: {
        "authorization": "Token ${tmp['user']['token']}",
      }), data: {
            "id": id,
            "skip": offset,
            "limit": limit
          }
      )).data;
      print(responseBody);
      return ProductModel.fromJsonList(responseBody);
    }
  }
}