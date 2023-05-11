import 'dart:async';

import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:planify_app/services/database_helper_service.dart';

import '../helpers/utility.dart';
import 'location_helper_service.dart';
import 'notification_service.dart';

class LocationBasedNotificationService {
  static LocationData? _currentLocation;
  static List<dynamic>? _nearbyPlaces;
  static StreamSubscription<LocationData>? _locationSubscription;
  static Timer? _timer;
  static bool existTasksWithLocationCategprySelected = false;
  static final Set<String> _processedTaskIds = {};

  static Future<List<dynamic>> getListOfNearbyPlaces() async {
    await LocationHelper.getNearbyPlaces(
      latitude: _currentLocation!.latitude!,
      longitude: _currentLocation!.longitude!,
    ).then((value) => _nearbyPlaces = value);
    return _nearbyPlaces!;
  }

  static Future<void> checkForLocations(int interval) async {
    // reset the set of processed task IDs
    _processedTaskIds.clear();

    //get the task from DB
    final tasks = await DBHelper.fetchListOfTasks();

    for (final task in tasks) {
      //add task IDs into set, in order to be ckecked only once
      if (_processedTaskIds.contains(task.id!)) {
        continue;
      }

      //if task is done, deleted or doesn't have a location category, get over it
      if (task.isDeleted ||
          task.isDone ||
          task.locationCategory == 'No location category chosen') {
        continue;
      }

      final dueDate = task.dueDate;
      final dueTime = task.dueTime;

      if ((dueDate != null &&
              dueTime != null &&
              dueDate.isBefore(DateTime.now()) &&
              DateTime(
                DateTime.now().year,
                DateTime.now().month,
                DateTime.now().day,
                dueTime.hour,
                dueTime.minute,
              ).isAfter(DateTime.now())) ||
          (dueDate != null &&
              dueTime == null &&
              dueDate.isBefore(DateTime.now()) &&
              dueDate.day != DateTime.now().day &&
              dueDate.month != DateTime.now().month &&
              dueDate.year != DateTime.now().year) ||
          (dueDate == null && dueTime == null)) {
        //check if any nearby location has type the same as location category from task
        for (final place in _nearbyPlaces!) {
          for (final type in place['types']) {
            if (type == task.locationCategory) {
              NotificationService.createLocationBasedNotification(
                task.id!,
                task.title!,
                place['name'],
                type,
                DateTime.now(),
              );
              _processedTaskIds.add(task.id!);
              break;
            }
          }
        }
      }
    }
  }

  static Future<bool> checkLocationPermission(BuildContext context) async {
    bool isPermissionGranted = false;
    final locPermission = await Location().hasPermission();

    if (locPermission == PermissionStatus.granted ||
        locPermission == PermissionStatus.grantedLimited) {
      isPermissionGranted = true;
    } else {
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

  static Future<void> turnOn(BuildContext context, int interval) async {
    _locationSubscription ??=
        Location().onLocationChanged.listen((location) async {
      if (_currentLocation == null) {
        //set the new current location
        _currentLocation = location;
      } else if (_currentLocation!.latitude != location.latitude ||
          _currentLocation!.longitude != location.longitude) {
        //set the new current location
        _currentLocation = location;
      }

      if (_timer == null || !_timer!.isActive) {
        _timer = Timer.periodic(Duration(minutes: interval), (timer) async {
          //check if exists at least one lasts with location category selected
          if (await Utility.existsTaskWithLocationCategpoySelected()) {
            //set the nearby locations
            _nearbyPlaces = await getListOfNearbyPlaces();

            //check those nearby locations according to tasks
            await checkForLocations(interval);
          }
        });
      }
    });
  }

  static void turnOff() {
    _locationSubscription?.cancel();
    _locationSubscription = null;
    _timer?.cancel();
    _timer = null;
    _processedTaskIds.clear();
  }
}
