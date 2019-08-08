import 'dart:async';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';

class MapScreen extends StatefulWidget {
  @override
  State<MapScreen> createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> {
  Completer<GoogleMapController> _controller = Completer();

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  LatLng latlngPop;
  
  final Set<Marker> _markers = Set();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
//      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
//      floatingActionButton: FloatingActionButton(
//        backgroundColor: Color(0xff00b661),
//        onPressed: onOKPress,
//        child: Container(
//          padding: EdgeInsets.only(top: 10, bottom: 10, left: 15, right: 15),
////          decoration: BoxDecoration(
////              borderRadius: BorderRadius.all(Radius.circular(50)),
////              color: Color(0xff00b661)
////          ),
//          child: Icon(Icons.add),
//          //child: Text("Set", style: TextStyle(color: Colors.white, fontSize: 20),),
//        ),
//      ),
      appBar: AppBar(
       leading: IconButton(icon: Icon(Icons.arrow_back_ios, color: Colors.white,), onPressed: ()=>Navigator.pop(context)),
        actions: <Widget>[
          FlatButton(
//            color: Color(0xff00b661),
            onPressed: onOKPress,
            child: Container(
              padding: EdgeInsets.only(top: 10, bottom: 10, left: 15, right: 15),
//          decoration: BoxDecoration(
//              borderRadius: BorderRadius.all(Radius.circular(50)),
//              color: Color(0xff00b661)
//          ),
              child: Text("Set position", style: TextStyle(color: Colors.white, fontSize: 18),),
              //child: Text("Set", style: TextStyle(color: Colors.white, fontSize: 20),),
            ),
          ),
        ],
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
        onLongPress: (LatLng latlng){
          latlngPop = latlng;
          setState(() {
            _markers.clear();
            _markers.add(Marker(
              markerId: MarkerId('My Location'),
              position: latlng,
            ));
          });
          setState(() async{
            final CameraPosition _pos = CameraPosition(
                bearing: 192.8334901395799,
                target: latlng,
                tilt: 59.440717697143555,
                zoom: 19.151926040649414);
            final GoogleMapController controller = await _controller.future;
            controller.animateCamera(CameraUpdate.newCameraPosition(_pos));

          });
        },
        initialCameraPosition: _kGooglePlex,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
    );
  }

  Future<void> onOKPress() async {
    Navigator.of(context).pop(latlngPop);
  }
}