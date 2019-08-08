 import 'dart:convert';
import 'dart:typed_data';
 import 'dart:convert';
 import 'package:convert/convert.dart';
 import 'package:crypto/crypto.dart' as crypto;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:bubble_bottom_bar/bubble_bottom_bar.dart';
import 'package:hidden_drawer_menu/hidden_drawer/hidden_drawer_menu.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:localstorage/localstorage.dart';
import 'package:recyclers/add_bayer.dart';
import 'package:recyclers/add_seller.dart';
import 'package:recyclers/cart.dart';
import 'package:recyclers/chart.dart';
import 'package:recyclers/config/config.dart';
import 'package:recyclers/models/user.dart';
import 'package:recyclers/nearby.dart';
import 'package:recyclers/notification.dart';
import 'package:recyclers/profile.dart';
import 'package:recyclers/profile_view.dart';
import 'package:recyclers/search.dart';
import 'package:recyclers/store.dart';
import 'package:dio/dio.dart';
import 'package:recyclers/welcome.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

import 'main.dart';


class HomeScreen extends StatefulWidget {
  var data;
  HomeScreen({Key key, @required  this.data}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState(this.data);
}

class _HomeScreenState extends State<HomeScreen> {


@override
  void initState() {
    super.initState();
    getDataState();      
  }

  var data;
  UserData user;


  Future getDataState() async
  {
      this.user = await getData();   
      setState(() {
        
      });
  }

  Future getData()
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
        print("****************************************************");
        print(response.data["user"]["_id"]);
        print("****************************************************");
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

        print("------------------------------------------------------------------");
        print(user.id);
        print(user.email);
        print(user.name);
        print(user.company_name);
        print(user.company_id);
        print(user.cin);
        print(user.phone);
        print(user.country);
        print(user.pos);
        print(user.seller);
        print(user.bayer);
        print(user.latLng);
        print(user.profile);
        print("------------------------------------------------------------------");

        return user;
      }
    }
    return null;
  }


  _HomeScreenState(this.data);



  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  

  Widget headerView(BuildContext context) { 

    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(
            children: <Widget>[
              new Container(
                  width: 48.0,
                  height: 48.0,
                  decoration: new BoxDecoration(
                      shape: BoxShape.circle,
                      image: new DecorationImage(
                            fit: BoxFit.cover,
                            image: (this.user == null || this.user.profile == "non")? AssetImage("assets/images/profile.png") : CachedNetworkImageProvider(this.user.profile)
                        )
                      ),
                    ),
              Container(
                  margin: EdgeInsets.only(left: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        (this.user != null)? this.user.name : "",
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
                  ))
            ],
          ),
        ),
        Divider(
          color: Colors.white.withAlpha(200),
          height: 16,
        )
      ],
    );
  }



  @override
  Widget build(BuildContext context) {
    return SimpleHiddenDrawer(
      menu: Menu(headerView: headerView, user: user,),
        screenSelectedBuilder: (position,controller) {
          
          Widget screenCurrent;
          print(position);
          
          switch(position){
            case 0 :
              print("Home");
              break;
            case 1 :
              print("Near by");

              break;
            case 2 :
              print("Settings");
              break;
            case 3 :
              print("Logout");
              break;
          }
          
          return HomeInsiderScreen();
        }
    );
  }

}


class ScrollBehaviorCos extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}




class HomeInsiderScreen extends StatefulWidget {
  UserData data;

  HomeInsiderScreen({Key key}) : super(key: key);

  @override
  _HomeInsiderScreenState createState() => _HomeInsiderScreenState();
}

class _HomeInsiderScreenState extends State<HomeInsiderScreen> {

  UserData user;

  void callback() {
    setState(() {
      getDataState();
    });
  }

  @override
  void initState() {
    super.initState();
    hideBar = 0; 
    currentIndex = 0;
    getDataState();
    items =  [
                  BubbleBottomBarItem(backgroundColor: Color(0xff00b661), icon: Icon(Icons.dashboard, color: Color(0xff054a29),), activeIcon: Icon(Icons.dashboard, color: Color(0xff00b661),), title: Text("Store")),
                  BubbleBottomBarItem(backgroundColor: Color(0xff00b661), icon: Icon(Icons.shopping_cart, color: Color(0xff054a29),), activeIcon: Icon(Icons.shopping_cart, color: Color(0xff00b661),), title: Text("Cart")),
                  BubbleBottomBarItem(backgroundColor: Color(0xff00b661), icon: Icon(Icons.notifications, color: Color(0xff054a29),), activeIcon: Icon(Icons.notifications, color: Color(0xff00b661),), title: Text("News")),
                  BubbleBottomBarItem(backgroundColor: Color(0xff00b661), icon: Icon(Icons.person, color: Color(0xff054a29),), activeIcon: Icon(Icons.person, color: Color(0xff00b661),), title: Text("Profile"))
              ];

  }
    Future getDataState() async
  {
      this.user = await getData();   
      setState(() {
         items = (this.user == null)?
              [
                  BubbleBottomBarItem(backgroundColor: Color(0xff00b661), icon: Icon(Icons.dashboard, color: Color(0xff054a29),), activeIcon: Icon(Icons.dashboard, color: Color(0xff00b661),), title: Text("Store")),
                  BubbleBottomBarItem(backgroundColor: Color(0xff00b661), icon: Icon(Icons.shopping_cart, color: Color(0xff054a29),), activeIcon: Icon(Icons.shopping_cart, color: Color(0xff00b661),), title: Text("Cart")),
                  BubbleBottomBarItem(backgroundColor: Color(0xff00b661), icon: Icon(Icons.notifications, color: Color(0xff054a29),), activeIcon: Icon(Icons.notifications, color: Color(0xff00b661),), title: Text("News")),
                  BubbleBottomBarItem(backgroundColor: Color(0xff00b661), icon: Icon(Icons.person, color: Color(0xff054a29),), activeIcon: Icon(Icons.person, color: Color(0xff00b661),), title: Text("Profile"))
              ]:
              [
                  BubbleBottomBarItem(backgroundColor: Color(0xff00b661), icon: Icon(Icons.dashboard, color: Color(0xff054a29),), activeIcon: Icon(Icons.dashboard, color: Color(0xff00b661),), title: Text("Store")),
                  (this.user.seller == true && this.user.bayer == false)?
                    BubbleBottomBarItem(backgroundColor: Color(0xff00b661), icon: Icon(Icons.bubble_chart, color: Color(0xff054a29),), activeIcon: Icon(Icons.bubble_chart, color: Color(0xff00b661),), title: Text("Chart"))
                  :  BubbleBottomBarItem(backgroundColor: Color(0xff00b661), icon: Icon(Icons.shopping_cart, color: Color(0xff054a29),), activeIcon: Icon(Icons.shopping_cart, color: Color(0xff00b661),), title: Text("Cart")),
                  BubbleBottomBarItem(backgroundColor: Color(0xff00b661), icon: Icon(Icons.notifications, color: Color(0xff054a29),), activeIcon: Icon(Icons.notifications, color: Color(0xff00b661),), title: Text("News")),
                  BubbleBottomBarItem(backgroundColor: Color(0xff00b661), icon: Icon(Icons.person, color: Color(0xff054a29),), activeIcon: Icon(Icons.person, color: Color(0xff00b661),), title: Text("Profile"))
              ];
      });
  }

  Future getData()
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
        return user;
      }
    }
    return null;
  }
  

  _HomeInsiderScreenState();

  int currentIndex;
  int hideBar;
  
  changePage(i)
  {
    setState(() {
      if(i == 3)
        hideBar = 1;
      else
        hideBar = 0;
      currentIndex = i;
    });
  }

  TextEditingController searchController = TextEditingController();

  onSearchPress()
  {
    print(searchController.text);
    if(searchController.text.isNotEmpty)
    {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SearchScreen(text: searchController.text)),
      );
    }

  }

//  generateMd5(String data) {
//    var content = new Utf8Encoder().convert(data);
//    var md5 = crypto.md5;
//    var digest = md5.convert(content);
//    return hex.encode(digest.bytes);
//  }

  onAddPress()
  async {
    if(currentIndex == 1 && this.user.bayer)
    {
      var flag = await showDialog(context: context,builder: (context) => CheckoutDialog());
      if(flag != null && flag)
      {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        var obj = prefs.getString("user_data");
        if(obj != null) {
          Map<String, dynamic> tmp = jsonDecode(obj);

//          String str = tmp["_id"] + tmp["time"] + tmp["bayer_id"] + tmp["prod_id"] + "1337";

          Response response = await new Dio().post("${AppConfig.ip}/api/cart/checkout",  options: Options(headers: {
            "authorization": "Token ${tmp['user']['token']}",
          }),data: {
            "id": tmp["user"]["_id"],
          });
          if(response.statusCode == 200)
          {
            setState(() {
              currentIndex = 0;
              getData();
            });
            Toast.show("Checkout comfirmed for more informations go to your profile", context, textColor: Colors.white, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM, backgroundColor: Colors.blueAccent);
          }
          else if(response.statusCode == 430)
            Toast.show("You don't have enough credit", context, textColor: Colors.white, duration: Toast.LENGTH_SHORT, gravity:  Toast.BOTTOM, backgroundColor: Colors.red);
        }
      }
    }
    else if(this.user.seller == true && this.user.bayer == false)
    {
      Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddSellerScreen(data: this.user,)),
          );
    }
    else
    {
        Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddBayerScreen(data: this.user,)),
          );
    }
  }

  getScreen()
  {
    switch(currentIndex)
    {
      case 0:
        return StoreScreen();
        break;
      case 1:
        if(this.user == null)
        {
          if(mounted)
            Navigator.of(context).pop();
        }
        else if(this.user.bayer)
        {
          return CartScreen(user: this.user,);
        }
        else
        {
          return ChartScreen(user: this.user,);
        }
        break;
      case 2:
        if(this.user == null) {
          if(mounted)
            Navigator.pop(context);
        }
        else
          return NotificationScreen();
        break;
      case 3:
        if(this.user == null) {
          if(mounted)
            Navigator.pop(context);
        }
        else
          return ProfileScreen(user: this.user, callback: this.callback,);
        break;
    }

  }

  var items;
  
  @override
  Widget build(BuildContext context) {
    if (this.user == null)
    {
      return Scaffold(
        bottomNavigationBar: BubbleBottomBar(
                opacity: .2,
                currentIndex: currentIndex,
                onTap: changePage,
                borderRadius: BorderRadius.zero,
                elevation: 12,
                hasNotch: false,
                hasInk: true,
                inkColor: Colors.black12,
                items: items
                
              ),
          appBar: AppBar(
              leading: Container(),
                  bottom: PreferredSize(child: Container(), preferredSize: Size.fromHeight(30)),
                  flexibleSpace: FlexibleSpaceBar.createSettings(
                    currentExtent: 20,
                    child: FlexibleSpaceBar(
                      centerTitle: true,
                      title: Container(
                      height: 50,
                      margin: EdgeInsets.only(right: 10, left: 10),
                      decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.all(Radius.circular(50))
                              ),
                      child: Container(
                              child: Form(
                                child:
                                TextFormField(
                                  controller: searchController,
                                  cursorColor: Color(0xff00b661),
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    prefixIcon: Container(
                                      padding: EdgeInsets.only(left: 10, right: 5),
                                      child: Icon(Icons.search, color: Color(0xff054a29),),
                                    ),
                                    suffixIcon: Container(
                                      margin: EdgeInsets.only(top: 5, bottom: 5, left: 3),
                                      decoration: BoxDecoration(
                                          color: Color(0xff00b661),
                                          shape: BoxShape.circle
                                      ),
                                      child: IconButton(icon: Icon(Icons.keyboard_arrow_right), iconSize: 25, color: Colors.white, onPressed: onSearchPress, alignment: Alignment.center),
                                    ),
                                  ),
                              ),
                              )
                            ),
                    ),
                    )
                  ),
                ),
          body: Container(
              child:  getScreen(),
            )
      );
    }
    else if(hideBar == 1)
    {
      return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: onAddPress,
          child: Icon(Icons.add),
          backgroundColor: Color(0xff00b661),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        bottomNavigationBar: BubbleBottomBar(
                opacity: .2,
                currentIndex: currentIndex,
                onTap: changePage,
                borderRadius: BorderRadius.zero,
                elevation: 12,
                fabLocation: BubbleBottomBarFabLocation.end,
                hasNotch: false,
                hasInk: true,
                inkColor: Colors.black12,
                items: items
                
              ),
          body: Container(
              child:  getScreen(),
            )
      );
    }
    else
    {
      return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: onAddPress,
          child: currentIndex == 1 && this.user.bayer? Icon(Icons.monetization_on) : Icon(Icons.add),
          backgroundColor: Color(0xff00b661),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        bottomNavigationBar: BubbleBottomBar(
                opacity: .2,
                currentIndex: currentIndex,
                onTap: changePage,
                borderRadius: BorderRadius.zero,
                elevation: 12,
                fabLocation: BubbleBottomBarFabLocation.end,
                hasNotch: false,
                hasInk: true,
                inkColor: Colors.black12,
                items: items
                
              ),
          appBar: AppBar(
              leading: Container(),
                  bottom: PreferredSize(child: Container(), preferredSize: Size.fromHeight(30)),
                  flexibleSpace: FlexibleSpaceBar.createSettings(
                    currentExtent: 20,
                    child: FlexibleSpaceBar(
                      centerTitle: true,
                      title: Container(
                      height: 50,
                      margin: EdgeInsets.only(right: 10, left: 10),
                      decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.all(Radius.circular(50))
                              ),
                      child: Container(
                              child: TextField(
                                controller: searchController,
                                cursorColor: Color(0xff00b661),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  prefixIcon: Container(
                                    padding: EdgeInsets.only(left: 10, right: 5),
                                    child: Icon(Icons.search, color: Color(0xff054a29),),
                                  ),
                                  suffixIcon: Container(
                              margin: EdgeInsets.only(top: 5, bottom: 5, left: 3),
                              decoration: BoxDecoration(
                                color: Color(0xff00b661),
                                shape: BoxShape.circle
                              ),
                              child: IconButton(icon: Icon(Icons.keyboard_arrow_right), iconSize: 25, color: Colors.white, onPressed: onSearchPress, alignment: Alignment.center),
                            ),
                                ),
                              ),
                            ),
                    ),
                    )
                  ),
                ),
          body: Container(
              child:  getScreen(),
            )
      );
    }
  }

}



 class CheckoutDialog extends StatefulWidget {

   CheckoutDialog({Key key}) : super(key: key);
   @override
   State<StatefulWidget> createState() => CheckoutDialogState();
 }

 class CheckoutDialogState extends State<CheckoutDialog>
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
                         child: Column(
                           children: <Widget>[
                             FlatButton(
                               padding: EdgeInsets.symmetric(vertical: 10, horizontal: 45),
                               onPressed: () async {
                                 Navigator.pop(context, true);
                               },
                               color: Color(0xff00b661),
                               shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                               child: Container(
                                   alignment: Alignment.center,
                                   child: Text("Confirm", style: TextStyle(
                                     color: Colors.white,
                                   ),
                                   )),
                             ),
                             FlatButton(
                               padding: EdgeInsets.symmetric(vertical: 10, horizontal: 45),
                               onPressed: () async {
                                 Navigator.pop(context, false);
                               },
                               shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                               child: Container(
                                   alignment: Alignment.center,
                                   child: Text("Cancel", style: TextStyle(
                                     color: Colors.red,
                                   ),
                                   )),
                             ),
                           ],
                         )
                     )
               ],
             )
         ),
       ),
     );
   }

 }



 class Menu extends StatefulWidget {
  Function headerView;
  var user;

  Menu({Key key, this.headerView, this.user}) : super(key: key);
   @override
   _MenuState createState() => _MenuState();
 }

 class _MenuState extends State<Menu> {
   @override
   Widget build(BuildContext context) {
     return Container(
                width: double.maxFinite,
                height: double.maxFinite,
                color: Color(0xff00b661),
                padding: const EdgeInsets.only(left: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(top: 50),
                      child: GestureDetector(
                        onTap: () async {

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
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => ProfileViewScreen(user: user,)),
                                );
                              });
                            }
                          }

                        },
                        child: widget.headerView(context),
                      )
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          FlatButton(
                            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 45),
                            onPressed: (){
                              SimpleHiddenDrawerProvider.of(context).setSelectedMenuPosition(0);
                            },
                            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                            child: Row(
                              children: <Widget>[
                                Icon(Icons.home, color: Colors.white,),
                                Container(
                                    margin: EdgeInsets.only(left: 10),
                                    width: 100,
                                    child: Text("Home", style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18
                                    ),
                                    ))
                              ],
                            ),
                          ),
                          Divider(color: Colors.white54),
                          FlatButton(
                            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 45),
                            onPressed: (){
                              //SimpleHiddenDrawerProvider.of(context).setSelectedMenuPosition(1);
                              Navigator.of(context).push(
                                  new MaterialPageRoute(builder: (context) => new NearbyScreen()));
                            },
                            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                            child: Row(
                              children: <Widget>[
                                Icon(Icons.home, color: Colors.white,),
                                Container(
                                    margin: EdgeInsets.only(left: 10),
                                    width: 100,
                                    child: Text("Near by", style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18
                                    ),
                                    ))
                              ],
                            ),
                          ),
                          Divider(color: Colors.white54),

                          (widget.user != null) ? FlatButton(
                            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 45),
                            onPressed: (){
                              SimpleHiddenDrawerProvider.of(context).setSelectedMenuPosition(2);
                            },
                            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                            child: Row(
                              children: <Widget>[
                                Icon(Icons.settings, color: Colors.white,),
                                Container(
                                    margin: EdgeInsets.only(left: 10),
                                    width: 100,
                                    child: Text("Settings", style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18
                                    ),
                                    ))
                              ],
                            ),
                          ) : Container(),
                          (widget.user != null) ?  Divider(color: Colors.white54) : Container(),

                          (widget.user != null) ? FlatButton(
                            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 45),
                            onPressed: () async {
                              SharedPreferences prefs = await SharedPreferences.getInstance();
                              prefs.remove("user_data");
                              Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
                                  SplashScreen()), (Route<dynamic> route) => false);
                            },
                            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                            child: Row(
                              children: <Widget>[
                                Icon(Icons.exit_to_app, color: Colors.white,),
                                Container(
                                    margin: EdgeInsets.only(left: 10),
                                    width: 100,
                                    child: Text("Logout", style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18
                                    ),
                                    ))
                              ],
                            ),
                          ):
                          FlatButton(
                            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 45),
                            onPressed: () async {
                              Navigator.of(context).pop();
                            },
                            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                            child: Row(
                              children: <Widget>[
                                Icon(Icons.exit_to_app, color: Colors.white,),
                                Container(
                                    margin: EdgeInsets.only(left: 10),
                                    width: 100,
                                    child: Text("Go Back", style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18
                                    ),
                                    ))
                              ],
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                )
              );

   }
 }