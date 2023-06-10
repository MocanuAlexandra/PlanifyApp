import 'dart:async';

import 'package:flutter/material.dart';
import 'package:location/location.dart';
import '../database_helper_service.dart';

import '../../helpers/utility.dart';
import '../location_helper_service.dart';
import 'local_notification_service.dart';

class LocationBasedNotificationService {
  static LocationData? _currentLocation;
  static List<dynamic>? _nearbyPlaces;
  static StreamSubscription<LocationData>? _locationSubscription;
  static Timer? _timer;
  static bool existTasksWithLocationCategprySelected = false;
  static final Set<String> _processedTaskIds = {};

  static Future<List<dynamic>> getListOfNearbyPlaces() async {
    print("get list of neabry places");
    await LocationHelper.getNearbyPlaces(
      latitude: _currentLocation!.latitude!,
      longitude: _currentLocation!.longitude!,
    ).then((value) => _nearbyPlaces = value);
    return _nearbyPlaces!;
  }

  static Future<void> checkForLocations(int interval) async {
    print("check for locations");

    // Reset the set of processed task IDs
    _processedTaskIds.clear();

    // Get the tasks from the DB
    final tasks = await DBHelper.getListOfTasks();

    for (final task in tasks) {
      // Skip tasks that have already been processed
      if (_processedTaskIds.contains(task.id!)) {
        continue;
      }

      // If the task is done, deleted, or doesn't have a location category, move on to the next task
      if (task.isDeleted ||
          task.isDone ||
          task.locationCategory == 'No location category chosen') {
        continue;
      }

      final dueDate = task.dueDate;
      final dueTime = task.dueTime;

      if ((dueDate != null &&
              dueTime != null &&
              dueDate.isAfter(DateTime.now()) &&
              DateTime(
                DateTime.now().year,
                DateTime.now().month,
                DateTime.now().day,
                dueTime.hour,
                dueTime.minute,
              ).isAfter(DateTime.now())) ||
          (dueDate != null &&
              dueTime == null &&
              dueDate.isAfter(DateTime.now())) ||
          (dueDate == null && dueTime == null)) {
        bool notificationSent =
            false; // Variable to track if a notification has been sent for this task

        for (final place in _nearbyPlaces!) {
          for (final type in place['types']) {
            if (type == task.locationCategory) {
              if (!notificationSent) {
                print("incomming location based notification..");
                LocalNotificationService.createLocationBasedNotification(
                  task.id!,
                  task.title!,
                  place['name'],
                  type,
                  DateTime.now(),
                );
                notificationSent =
                    true; // Set the flag to true to indicate that a notification has been sent for this task
              }
            }
          }
        }

        if (notificationSent) {
          _processedTaskIds.add(task.id!);
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

  static Future<void> turnOn(int interval) async {
    print("turned on location based notification");

    _locationSubscription ??=
        Location().onLocationChanged.listen((location) async {
      if (_currentLocation == null) {
        // Set the new current location
        _currentLocation = location;

        // Check if there is at least one task with a location category selected
        if (await Utility.existsTaskWithLocationCategpoySelected()) {
          print("first time check for location based notification");

          // Set the nearby locations
          _nearbyPlaces = await getListOfNearbyPlaces();

          // Check those nearby locations according to tasks
          await checkForLocations(interval);
        }
      } else if (_currentLocation!.latitude != location.latitude ||
          _currentLocation!.longitude != location.longitude) {
        // Set the new current location
        _currentLocation = location;
      }

      if (_timer == null || !_timer!.isActive) {
        _timer = Timer.periodic(Duration(minutes: interval), (timer) async {
          print("interval check for location based notification");
          // Check if there is at least one task with a location category selected
          if (await Utility.existsTaskWithLocationCategpoySelected()) {
            // Set the nearby locations
            _nearbyPlaces = await getListOfNearbyPlaces();

            // Check those nearby locations according to tasks
            await checkForLocations(interval);
          }
        });
      }
    });
  }

  static void turnOff() {
    print("turned off location based notification");
    _locationSubscription?.cancel();
    _locationSubscription = null;
    _timer?.cancel();
    _timer = null;
    _processedTaskIds.clear();
  }
}
