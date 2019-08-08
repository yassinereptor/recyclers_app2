import 'package:flutter/material.dart';


class NotificationScreen extends StatefulWidget {
  var user;
  NotificationScreen({Key key, this.user}) : super(key: key);

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {

@override
  void initState() {
    super.initState();

  
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
       body: Text("Notification"),
    );
  }
}
