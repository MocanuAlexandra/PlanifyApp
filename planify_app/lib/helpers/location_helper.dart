import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:location/location.dart';

const GOOGLE_API_KEY = 'AIzaSyBCtWNcI4lD7pMey-ZghzlfRvFjQ2FfLhM';

class LocationHelper {
  // function that generates a preview image of a certain location
  static String generateLocPreviewImg({double? latitude, double? longitude}) {
    return 'https://maps.googleapis.com/maps/api/staticmap?center=&$latitude,$longitude&zoom=15&size=600x300&maptype=roadmap&markers=color:red%7Alabel:A%7C$latitude,$longitude&key=$GOOGLE_API_KEY';
  }

  // function that gets the address of a certain location based on lat and long
  static Future<String> getPlaceAddress(double lat, double lng) async {
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$GOOGLE_API_KEY';
    final response = await http.get(Uri.parse(url));
    return json.decode(response.body)['results'][0]['formatted_address'];
  }

  static getApiKey() {
    return GOOGLE_API_KEY;
  }

  static getCurrentLocation() {
    return Location().getLocation();
  }

  // function that gets the nearby places of a certain location based on lat and long
  static Future<List<dynamic>> getNearbyPlacesWithType(
      {double? latitude, double? longitude}) async {
    //TODO modify this radius
    final url =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$latitude,$longitude&radius=400&key=$GOOGLE_API_KEY';
    final response = await http.get(Uri.parse(url));
    return json.decode(response.body)['results'];
  }
}
