import 'dart:convert';
import 'package:crypto/crypto.dart' as crypto;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:recyclers/config/config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeline_list/timeline.dart';
import 'package:timeline_list/timeline_model.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:convert/convert.dart';

class TransactionScreen extends StatefulWidget {
  var user;

  TransactionScreen({Key key, this.user}) : super(key: key);

  @override
  _TransactionScreenState createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {

  List list;

  List<TimelineModel> items = [];


  @override
  void initState() {
    list = new List();
    getTans();


    super.initState();
  }


  getTans()
  async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var obj = prefs.getString("user_data");
    if(obj != null) {
      Map<String, dynamic> tmp = jsonDecode(obj);
      Response response;
      Dio dio = new Dio();
      response =
      await dio.get("${AppConfig.ip}/api/trans/load?id=${tmp['user']['_id']}",
          options: Options(headers: {
            "authorization": "Token ${tmp['user']['token']}",
          }));
      if (response.statusCode == 200) {
        print(response.data);
        list = response.data;
        list = list.where((item)=> item["done"] == false).toList();
        list.forEach((item){
          
        });
        setState(() {
          list.forEach((item){
            items.add(TimelineModel(
                GestureDetector(
                  onTap: (){
//                    String str = item["_id"] + item["time"] + item["bayer_id"] + item["prod_id"] + "1337";
                    showDialog(context: context,builder: (context) => QrDialog(text: item["hash"]));
                  },
                  child: Container(
                    margin: EdgeInsets.only(top: 10, bottom: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text("Baying ${item["quantity"]} Product${int.parse(item["quantity"].toString()) > 1 ? "s": ""}"),
                        Text("Total Price: ${item["price"]}"),
                        Text("Time: ${timeago.format(DateTime.fromMillisecondsSinceEpoch(int.parse(item["time"].toString())))}")
                      ],
                    ),
                  ),
                ),
                position: TimelineItemPosition.random,
                iconBackground: Colors.amber,
                icon: Icon(Icons.priority_high, color: Colors.black,))
            );
          });
        });
      }
    }
  }

//  generateMd5(String data) {
//    var content = new Utf8Encoder().convert(data);
//    var md5 = crypto.md5;
//    var digest = md5.convert(content);
//    return hex.encode(digest.bytes);
//  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Incomplete Transactions"),
        leading: IconButton(icon: Icon(Icons.arrow_back_ios, color: Colors.white,), onPressed: (){
          Navigator.pop(context);
        }),
      ),
      body: Container(
        padding: EdgeInsets.only(left: 10, right: 10, top: 0, bottom: 20),
        child: list.length > 0? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: 20, left: 10, right: 10),
              child: Text("Click in a transaction to generate QR"),
            ),
            Container(
              margin: EdgeInsets.only(left: 10, right: 10, bottom: 20),
              child: Text("Qr used for seller to scan it and get payed!"),
            ),
            Expanded(child: Timeline(
                children: items,
                position: TimelinePosition.Left
            ),)
          ],
        ): Container(
          margin: EdgeInsets.only(top: 20, left: 10, right: 10),
          child: Text("No Transaction right now"),
        ),
      )
    );
  }
}





class QrDialog extends StatefulWidget {
  String text;

  QrDialog({Key key, this.text}) : super(key: key);
  @override
  State<StatefulWidget> createState() => QrDialogState();
}

class QrDialogState extends State<QrDialog>
    with SingleTickerProviderStateMixin{
  AnimationController controller;
  Animation<double> scaleAnimation;
  TextEditingController m_controller = new TextEditingController();

  @override
  void initState() {
    super.initState();
    m_controller.text = "0";
    controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 450));
    scaleAnimation =
        CurvedAnimation(parent: controller, curve: Curves.elasticInOut);

    controller.addListener(() {
      setState(() {});
    });

    controller.forward();
  }

  final _formKey = GlobalKey<FormState>();


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
                            new QrImage(
                              data: widget.text,
                              size: 200.0,
                            )
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
