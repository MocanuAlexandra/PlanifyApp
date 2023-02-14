import 'dart:async';

import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';

import '../helpers/location_helper.dart';
import '../providers/task_provider.dart';
import 'notification_service.dart';

class LocationBasedNotificationService {
  static LocationData? _currentLocation;
  static List<dynamic>? _nearbyPlaces;
  static StreamSubscription<LocationData>? _locationSubscription;
  static BuildContext? _context;

  static Future<List<dynamic>> getListOfNearbyPlaces() async {
    await LocationHelper.getNearbyPlacesWithType(
            latitude: _currentLocation!.latitude!,
            longitude: _currentLocation!.longitude!)
        .then((value) => _nearbyPlaces = value);
    return _nearbyPlaces!;
  }

  static Future<void> checkForLocations(
      BuildContext context, int interval) async {
    //get the nearby places
    var nearbyPlaces = await getListOfNearbyPlaces();

    //get the user tasks
    final tasks = Provider.of<TaskProvider>(_context!, listen: false).tasksList;

    //check if the user is near a place with a type of any of his tasks location type
    for (var task in tasks) {
      if (task.locationCategory != "No location category chosen") {
        for (var place in nearbyPlaces) {
          for (var type in place['types']) {
            if (type == task.locationCategory) {
              var notificationTime = DateTime.now();
              //check if the user has already been notified about this location type 'interval' ago
              if (NotificationService
                  .checkIfUserWasNotifiedAboutPlaceTypeInLastInterval(
                      task.id!, type, notificationTime, interval)) {
                return;
              } else {
                NotificationService.createLocationBasedNotification(
                    task.id!, place['name'], type, notificationTime);
              }
            }
          }
        }
      }
    }
  }

  static Future<bool> checkLocationPermission(BuildContext context) async {
    _context = context;
    bool isPermissionGranted = false;
    final locPermission = await Location().hasPermission();

    // if the user has already granted the location permission
    if (locPermission == PermissionStatus.granted ||
        locPermission == PermissionStatus.grantedLimited) {
      isPermissionGranted = true;
    } else {
      // if not, ask for it
      final locPermission = await Location().requestPermission();

      if (locPermission == PermissionStatus.granted ||
          locPermission == PermissionStatus.grantedLimited) {
        isPermissionGranted = true;
      } else {
        isPermissionGranted = false;
      }
    }

    return isPermissionGranted;
  }

  // turn on the location service
  static void turnOn(BuildContext context, int interval) {
    Location().changeSettings(accuracy: LocationAccuracy.high);
    _locationSubscription =
        Location().onLocationChanged.listen((location) async {
      _currentLocation = location;
      await checkForLocations(context, interval);
    });
  }

  // turn off the location service
  static void turnOff() async {
    await _locationSubscription?.cancel();
  }
}
