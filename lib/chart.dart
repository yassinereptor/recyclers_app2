import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ChartScreen extends StatefulWidget {
  var user;

  ChartScreen({Key key, this.user}) : super(key: key);

  @override
  _ChartScreenState createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {

  List<Color> gradientColors = [
    Color(0xff00b661),
    Color(0xff02d39a),
  ];

  List<PieChartSectionData> pieChartRawSections;
  List<PieChartSectionData> showingSections;
  StreamController<PieTouchResponse> pieTouchedResultStreamController;

  int touchedIndex;


  final Color leftBarColor = Color(0xff00b661);
  final Color rightBarColor = Color(0xffff5182);
  final double width = 7;

  List<BarChartGroupData> rawBarGroups;
  List<BarChartGroupData> showingBarGroups;

  StreamController<BarTouchResponse> barTouchedResultStreamController;

  int touchedGroupIndex;

@override
  void initState() {
    super.initState();

    final section1 = PieChartSectionData(
      color: Color(0xff00b661).withOpacity(0.8),
      value: 25,
      title: "",
      radius: 80,
      titleStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xff00b661)),
      titlePositionPercentageOffset: 0.55,
    );

    final section2 = PieChartSectionData(
      color: Colors.blueAccent.withOpacity(0.8),
      value: 25,
      title: "",
      radius: 65,
      titleStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent),
      titlePositionPercentageOffset: 0.55,
    );

    final section3 = PieChartSectionData(
      color: Colors.red.withOpacity(0.8),
      value: 25,
      title: "",
      radius: 60,
      titleStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
      titlePositionPercentageOffset: 0.6,
    );

    final section4 = PieChartSectionData(
      color: Colors.amber.withOpacity(0.8),
      value: 25,
      title: "",
      radius: 70,
      titleStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.amber),
      titlePositionPercentageOffset: 0.55,
    );

    final items = [
      section1,
      section2,
      section3,
      section4,
    ];

    pieChartRawSections = items;

    showingSections = pieChartRawSections;

    pieTouchedResultStreamController = StreamController();
    pieTouchedResultStreamController.stream.distinct().listen((details) {
      if (details == null) {
        return;
      }

      touchedIndex = -1;
      if (details.sectionData != null) {
        touchedIndex = showingSections.indexOf(details.sectionData);
      }

      setState(() {
        if (details.touchInput is FlLongPressEnd) {
          touchedIndex = -1;
          showingSections = List.of(pieChartRawSections);
        } else {
          showingSections = List.of(pieChartRawSections);
          if (touchedIndex != -1) {
            showingSections[touchedIndex] = showingSections[touchedIndex].copyWith(
              color: showingSections[touchedIndex].color.withOpacity(1),
            );
          }
        }
      });
    });

    ///////////////////////////////////////////////////////////



    final barGroup1 = makeGroupData(0, 5, 12);
    final barGroup2 = makeGroupData(1, 16, 12);
    final barGroup3 = makeGroupData(2, 18, 5);
    final barGroup4 = makeGroupData(3, 20, 16);
    final barGroup5 = makeGroupData(4, 17, 6);
    final barGroup6 = makeGroupData(5, 19, 1.5);
    final barGroup7 = makeGroupData(6, 10, 1.5);
    final barGroup8 = makeGroupData(7, 10, 1.7);
    final barGroup9 = makeGroupData(8, 5, 2.5);
    final barGroup10 = makeGroupData(9, 20, 3.5);
    final barGroup11 = makeGroupData(10, 12, 1.5);
    final barGroup12 = makeGroupData(11, 13, 1.0);

    final items2 = [
      barGroup1,
      barGroup2,
      barGroup3,
      barGroup4,
      barGroup5,
      barGroup6,
      barGroup7,
      barGroup8,
      barGroup9,
      barGroup10,
      barGroup11,
      barGroup12,
    ];

    rawBarGroups = items2;

    showingBarGroups = rawBarGroups;

    barTouchedResultStreamController = StreamController();
    barTouchedResultStreamController.stream.distinct().listen((BarTouchResponse response) {
      if (response == null) {
        return;
      }

      if (response.spot == null) {
        setState(() {
          touchedGroupIndex = -1;
          showingBarGroups = List.of(rawBarGroups);
        });
        return;
      }

      touchedGroupIndex = showingBarGroups.indexOf(response.spot.touchedBarGroup);

      setState(() {
        if (response.touchInput is FlLongPressEnd) {
          touchedGroupIndex = -1;
          showingBarGroups = List.of(rawBarGroups);
        } else {
          showingBarGroups = List.of(rawBarGroups);
          if (touchedGroupIndex != -1) {
            double sum = 0;
            for (BarChartRodData rod in showingBarGroups[touchedGroupIndex].barRods) {
              sum += rod.y;
            }
            double avg = sum / showingBarGroups[touchedGroupIndex].barRods.length;

            showingBarGroups[touchedGroupIndex] = showingBarGroups[touchedGroupIndex].copyWith(
              barRods: showingBarGroups[touchedGroupIndex].barRods.map((rod) {
                return rod.copyWith(y: avg);
              }).toList(),
            );
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
       body: ListView(
         children: <Widget>[
           Container(
             decoration: BoxDecoration(
                 color: Colors.white
             ),
             padding: EdgeInsets.only(left: 20, right: 20, top: 20),
             child: AspectRatio(
               aspectRatio: 4/3,
               child: FlChart(
                 chart: LineChart(
                     LineChartData(
                       gridData: FlGridData(
                         show: true,
                         drawHorizontalGrid: true,
                         getDrawingVerticalGridLine: (value) {
                           return const FlLine(
                             color: Color(0x4437434d),
                             strokeWidth:  0.2,
                           );
                         },
                         getDrawingHorizontalGridLine: (value) {
                           return const FlLine(
                             color: Color(0x4437434d),
                             strokeWidth: 0.2,
                           );
                         },
                       ),
                       titlesData: FlTitlesData(
                         show: true,
                         bottomTitles: SideTitles(
                           showTitles: true,
                           reservedSize: 22,
                           textStyle: TextStyle(
                               color: const Color(0xff68737d),
                               fontSize: 10
                           ),
                           getTitles: (value) {
                             switch(value.toInt()) {
                               case 0: return 'Jan';
                               case 1: return 'Feb';
                               case 2: return 'Mar';
                               case 3: return 'Apr';
                               case 4: return 'May';
                               case 5: return 'Jun';
                               case 6: return 'Jul';
                               case 7: return 'Aug';
                               case 8: return 'Sep';
                               case 9: return 'Oct';
                               case 10: return 'Nov';
                               case 11: return 'Dec';
                             }

                             return '';
                           },
                           margin: 8,
                         ),
                         leftTitles: SideTitles(
                           showTitles: true,
                           textStyle: TextStyle(
                             color: const Color(0xff67727d),
                             fontWeight: FontWeight.bold,
                             fontSize: 12,
                           ),
                           getTitles: (value) {
                             switch(value.toInt()) {
                               case 1: return '10k';
                               case 3: return '30k';
                               case 5: return '50k';
                             }
                             return '';
                           },
                           reservedSize: 15,
                           margin: 8,
                         ),
                       ),
                       borderData: FlBorderData(
                           show: true,
                           border: Border.all(color: Color(0xff37434d), width: 1)
                       ),
                       minX: 0,
                       maxX: 11,
                       minY: 0,
                       maxY: 6,
                       lineBarsData: [
                         LineChartBarData(
                           spots: [
                             FlSpot(0, 3),
                             FlSpot(2.6, 2),
                             FlSpot(4.9, 5),
                             FlSpot(6.8, 3.1),
                             FlSpot(8, 4),
                             FlSpot(9.5, 3),
                             FlSpot(11, 4),
                           ],
                           isCurved: true,
                           colors: gradientColors,
                           barWidth: 5,
                           isStrokeCapRound: true,
                           dotData: FlDotData(
                             show: false,
                           ),
                           belowBarData: BelowBarData(
                             show: true,
                             colors: gradientColors.map((color) => color.withOpacity(0.3)).toList(),
                           ),
                         ),
                       ],
                     ),
                   ),
                 ),
                  ),
                 ),
           Divider(),
           Container(
             child: AspectRatio(
               aspectRatio: 1.3,
               child: Container(
                 color: Colors.white,
                 child: Column(
                   children: <Widget>[
                     SizedBox(
                       height: 28,
                     ),
                     Row(
                       mainAxisSize: MainAxisSize.max,
                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                       children: <Widget>[
                         Indicator(color: Color(0xff00b661), text: "One", isSquare: false,
                           size: touchedIndex == 0 ? 18 : 16,
                           textColor: touchedIndex == 0 ? Colors.black : Colors.grey,),
                         Indicator(color: Colors.blueAccent, text: "Two", isSquare: false,
                           size: touchedIndex == 1 ? 18 : 16,
                           textColor: touchedIndex == 1 ? Colors.black : Colors.grey,),
                         Indicator(color: Colors.red, text: "Three", isSquare: false,
                           size: touchedIndex == 2 ? 18 : 16,
                           textColor: touchedIndex == 2 ? Colors.black : Colors.grey,),
                         Indicator(color: Colors.amber, text: "Four", isSquare: false,
                           size: touchedIndex == 3 ? 18 : 16,
                           textColor: touchedIndex == 3 ? Colors.black : Colors.grey,),
                       ],
                     ),
                     SizedBox(
                       height: 18,
                     ),
                     Expanded(
                       child: AspectRatio(
                         aspectRatio: 1,
                         child: FlChart(
                           chart: PieChart(
                             PieChartData(
                                 pieTouchData: PieTouchData(
                                   touchResponseStreamSink: pieTouchedResultStreamController.sink,
                                 ),
                                 startDegreeOffset: 180,
                                 borderData: FlBorderData(
                                   show: false,
                                 ),
                                 sectionsSpace: 12,
                                 centerSpaceRadius: 0,
                                 sections: showingSections),
                           ),
                         ),
                       ),
                     ),
                   ],
                 ),
               ),
             ),
           ),
           Divider(),
           Container(
             child: AspectRatio(
               aspectRatio: 1,
               child: Container(
                 color: Colors.white,
                 child: Padding(
                   padding: const EdgeInsets.all(16),
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.stretch,
                     mainAxisAlignment: MainAxisAlignment.start,
                     mainAxisSize: MainAxisSize.max,
                     children: <Widget>[
                       Expanded(
                         child: Padding(
                           padding: const EdgeInsets.symmetric(horizontal: 8.0),
                           child: FlChart(
                             chart: BarChart(BarChartData(
                               maxY: 20,
                               barTouchData: BarTouchData(
                                 touchTooltipData: TouchTooltipData(
                                     tooltipBgColor: Colors.grey,
                                     getTooltipItems: (spots) {
                                       return spots.map((TouchedSpot spot) {
                                         return null;
                                       }).toList();
                                     }
                                 ),
                                 touchResponseSink: barTouchedResultStreamController.sink,
                               ),
                               titlesData: FlTitlesData(
                                 show: true,
                                 bottomTitles: SideTitles(
                                   showTitles: true,
                                   textStyle: TextStyle(
                                       color: const Color(0xff7589a2),
                                       fontWeight: FontWeight.bold,
                                       fontSize: 10),
                                   margin: 20,
                                   getTitles: (double value) {
                                     switch (value.toInt()) {
                                       case 0:
                                         return 'Jan';
                                       case 1:
                                         return 'Feb';
                                       case 2:
                                         return 'Mar';
                                       case 3:
                                         return 'Apr';
                                       case 4:
                                         return 'May';
                                       case 5:
                                         return 'Jun';
                                       case 6:
                                         return 'Jul';
                                       case 7:
                                         return 'Aug';
                                       case 8:
                                         return 'Sep';
                                       case 9:
                                         return 'Oct';
                                       case 10:
                                         return 'Nov';
                                       case 11:
                                         return 'Dec';
                                     }
                                   },
                                 ),
                                 leftTitles: SideTitles(
                                   showTitles: true,
                                   textStyle: TextStyle(
                                       color: const Color(0xff7589a2),
                                       fontWeight: FontWeight.bold,
                                       fontSize: 12),
                                   margin: 15,
                                   reservedSize: 8,
                                   getTitles: (value) {
                                     if (value == 0) {
                                       return '1K';
                                     } else if (value == 10) {
                                       return '5K';
                                     } else if (value == 19) {
                                       return '10K';
                                     } else {
                                       return '';
                                     }
                                   },
                                 ),
                               ),
                               borderData: FlBorderData(
                                 show: false,
                               ),
                               barGroups: showingBarGroups,
                             )),
                           ),
                         ),
                       ),
                       SizedBox(
                         height: 12,
                       ),
                     ],
                   ),
                 ),
               ),
             ),
           )
               ]
       ),
    );

  }



  BarChartGroupData makeGroupData(int x, double y1, double y2) {
    return BarChartGroupData(barsSpace: 4, x: x, barRods: [
      BarChartRodData(
        y: y1,
        color: leftBarColor,
        width: width,
        isRound: true,
      ),
      BarChartRodData(
        y: y2,
        color: rightBarColor,
        width: width,
        isRound: true,
      ),
    ]);
  }

}


class Indicator extends StatelessWidget {

  final Color color;
  final String text;
  final bool isSquare;
  final double size;
  final Color textColor;

  const Indicator({
    Key key,
    this.color,
    this.text,
    this.isSquare,
    this.size = 16,
    this.textColor = const Color(0xff505050),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
            color: color,
          ),
        ),
        SizedBox(
          width: 4,
        ),
        Text(
          text,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
        )
      ],
    );
  }

}
