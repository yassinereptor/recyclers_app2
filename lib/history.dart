import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:recyclers/config/config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeline_list/timeline.dart';
import 'package:timeline_list/timeline_model.dart';
import 'package:timeago/timeago.dart' as timeago;

class HistoryScreen extends StatefulWidget {
  var user;

  HistoryScreen({Key key, this.user}) : super(key: key);

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {

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
        setState(() {
          list.forEach((item){
            items.add(TimelineModel(
                Container(
                  margin: EdgeInsets.only(top: 10, bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text("Baying ${item["quantity"]} Product${int.parse(item["quantity"].toString()) > 1 ? "s": ""}"),
                      Text("Total Price: ${item["price"]}"),
                      Text("Transaction: ${item["done"] == true? "Done" : "Not done yet"}"),
                      Text("Time: ${timeago.format(DateTime.fromMillisecondsSinceEpoch(int.parse(item["time"].toString())))}")
                    ],
                  ),
                ),
                position: TimelineItemPosition.random,
                iconBackground: Color(0xff00b661),
                icon: Icon(Icons.history, color: Colors.white,))
            );
          });
        });
      }
    }
  }

  createTimelineModel()
  {

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("History order"),
        leading: IconButton(icon: Icon(Icons.arrow_back_ios, color: Colors.white,), onPressed: (){
          Navigator.pop(context);
        }),
      ),
      body: Container(
        padding: EdgeInsets.only(left: 10, right: 10, top: 0, bottom: 20),
        child: Timeline(
            children: items,
            position: TimelinePosition.Left
        ),
      )
    );
  }
}
