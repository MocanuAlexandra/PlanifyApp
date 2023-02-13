import 'dart:async';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';

import 'notification_service.dart';
import '../helpers/location_helper.dart';
import '../providers/task_provider.dart';

class LocationBasedNotificationService {
  LocationData? _currentLocation;
  List<dynamic>? _nearbyPlaces;
  StreamSubscription<LocationData>? _locationSubscription;

  void initialize(BuildContext context) async {
    //TODO add a setting page to enable/disable this feature
    await Location().requestPermission();
    Location().changeSettings(accuracy: LocationAccuracy.high);

    _locationSubscription = Location().onLocationChanged.listen((location) {
      _currentLocation = location;
      checkForLocations(context);
    });
  }

  void checkForLocations(BuildContext context) async {
    _nearbyPlaces = await LocationHelper.getNearbyPlacesWithType(
        latitude: _currentLocation!.latitude!,
        longitude: _currentLocation!.longitude!);

    //get the user tasks
    final tasks = Provider.of<TaskProvider>(context, listen: false).tasksList;

    //check if the user is near a place with a type of any of his tasks location type
    for (var task in tasks) {
      if (task.locationCategory != "No location category chosen") {
        for (var place in _nearbyPlaces!) {
          for (var type in place['types']) {
            if (type == task.locationCategory) {
              var notificationTime = DateTime.now();
              //check if the user has already been notified about this place 30 minutes ago
              if (NotificationService.checkIfUserWasNotifiedAboutPlaceType(
                  task.id!, type, notificationTime)) {
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

  void turnOff() {
    _locationSubscription?.cancel();
  }

  void turnOn(BuildContext context) {
    _locationSubscription = Location().onLocationChanged.listen((location) {
      _currentLocation = location;
      checkForLocations(context);
    });
  }
}
