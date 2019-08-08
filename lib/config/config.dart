import 'dart:io';

import 'package:flutter/material.dart';
import 'package:toast/toast.dart';

class AppConfig
{
  // static String ip = "https://recyclers.herokuapp.com";
  static String ip = "http://142.93.233.231";
  // static String ip = "http://10.12.4.14:1337";
  // static String ip = "http://192.168.1.107:1337";
  // static String ip = "http://10.30.244.215:1337";
  static String pk_paystack = 'pk_test_af05445033461b044234113eb4cc3d5dcd2eec8e';


  static checkCon(context)
  async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } on SocketException catch (_) {
      Toast.show("You have no connection internet!", context, textColor: Colors.white, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM, backgroundColor: Colors.red);
      return false;
    }
  }
}