import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:recyclers/welcome.dart';



class IntroScreen extends StatefulWidget {
  IntroScreen({Key key}) : super(key: key);

  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  List<Slide> slides = new List();

@override
  void initState() {
    super.initState();

    slides.add(
      new Slide(
        title: "Title",
        description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Duis non sollicitudin nisi.",
        icon: IconData(0xe96d, fontFamily: "iconmoon"),
        backgroundColor: Color(0xff5bba6f),
      ),
    );

    slides.add(
      new Slide(
        title: "PENCIL",
        description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Duis non sollicitudin nisi.",
        icon: IconData(0xe96e, fontFamily: "iconmoon"),
        backgroundColor: Color(0xff137547),
      ),
    );

    slides.add(
      new Slide(
        title: "RULER",
        description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Duis non sollicitudin nisi.",
        icon: IconData(0xe98d, fontFamily: "iconmoon"),
        backgroundColor: Color(0xff054a29),
      ),
    );
  }

  void onDonePress() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => WelcomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new IntroSlider(
      slides: this.slides,
      onDonePress: this.onDonePress,
    );
  }
}
