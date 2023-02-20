import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:planify_app/helpers/utility.dart';
import '../providers/task_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/task.dart';

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
    final url =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$latitude,$longitude&radius=50&key=$GOOGLE_API_KEY';
    final response = await http.get(Uri.parse(url));
    return json.decode(response.body)['results'];
  }

  static void launchMaps(
      List<dynamic> taskList, double currentLat, double currentLng) async {
    String url = 'https://www.google.com/maps/dir/$currentLat,$currentLng/';

    // Sort the tasks list by due time in ascending order
    Utility.sortTaskListByDueTime(taskList);

    // Iterate through the tasks list and get the lat and long of each task
    for (int i = 0; i < taskList.length; i++) {
      Task task = taskList[i];
      if (task.address!.latitude != 0 && task.address!.longitude != 0) {
        url += '${task.address!.latitude},${task.address!.longitude}/';
      }
    }

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch Google Maps with URL: $url';
    }
  }
}
