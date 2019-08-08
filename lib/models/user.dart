import 'package:country_pickers/country.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class UserData
{
  String id, email, password, name, company_name, company_id, cin, phone, country, pos, profile;
  bool seller, bayer;
  LatLng latLng;
  var amount, onhold;
}