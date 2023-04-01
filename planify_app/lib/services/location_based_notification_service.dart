import 'dart:async';

import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';

import 'location_helper_service.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import 'notification_service.dart';

class LocationBasedNotificationService {
  static LocationData? _currentLocation;
  static List<dynamic>? _nearbyPlaces;
  static StreamSubscription<LocationData>? _locationSubscription;
  static BuildContext? _context;
  static BuildContext? _contextt;
  static DateTime lastNotifiedTime = DateTime.now();
  static bool isFirstTime = true;

  static Future<List<dynamic>> getListOfNearbyPlaces() async {
    await LocationHelper.getNearbyPlacesWithType(
            latitude: _currentLocation!.latitude!,
            longitude: _currentLocation!.longitude!)
        .then((value) => _nearbyPlaces = value);
    return _nearbyPlaces!;
  }

  static void checkForLocations(
      BuildContext context, int interval, bool isFirstTime) async {
    _context = context;
    var tasks = <Task>[];

    //check if enough time has passed since the last notification
    var difference = DateTime.now().difference(lastNotifiedTime);
    if (difference.inMinutes < interval && !isFirstTime) {
      return;
    } else {
      // set the last notified time to now
      lastNotifiedTime = DateTime.now();

      //get the user tasks
      tasks = Provider.of<TaskProvider>(_context!, listen: false).tasksList;

      //iterate through the tasks that are not deleted and not done
      //and have a location category
      for (var task in tasks) {
        if (task.locationCategory != "No location category chosen" &&
            task.isDeleted == false &&
            task.isDone == false) {
          //check if the due time and due date have passed
          //meaning dueDate/time is not null and dueDate/time is before now
          if (task.dueDate != null &&
              task.dueTime != null &&
              task.dueDate!.isBefore(DateTime.now()) &&
              DateTime(
                      DateTime.now().year,
                      DateTime.now().month,
                      DateTime.now().day,
                      task.dueTime!.hour,
                      task.dueTime!.minute)
                  .isAfter(DateTime.now())) {
            //get the nearby places
            await getListOfNearbyPlaces().then((nearbyPlaces) => {
                  for (var place in nearbyPlaces)
                    {
                      for (var type in place['types'])
                        {
                          if (type == task.locationCategory)
                            {
                              //notify the user
                              NotificationService
                                  .createLocationBasedNotification(task.id!,
                                      place['name'], type, DateTime.now()),
                            }
                        }
                    }
                });
            //check if the due date have passed
            //meaning dueDate is not null and dueTime it is
          } else if (task.dueDate != null &&
              task.dueTime == null &&
              task.dueDate!.day != DateTime.now().day &&
              task.dueDate!.month != DateTime.now().month &&
              task.dueDate!.year != DateTime.now().year) {
            //get the nearby places
            await getListOfNearbyPlaces().then((nearbyPlaces) => {
                  for (var place in nearbyPlaces)
                    {
                      for (var type in place['types'])
                        {
                          if (type == task.locationCategory)
                            {
                              //notify the user
                              NotificationService
                                  .createLocationBasedNotification(task.id!,
                                      place['name'], type, DateTime.now()),
                            }
                        }
                    }
                });
            //last case is when the due date/time are both null
          } else if (task.dueDate == null && task.dueTime == null) {
            //get the nearby places
            await getListOfNearbyPlaces().then((nearbyPlaces) => {
                  for (var place in nearbyPlaces)
                    {
                      for (var type in place['types'])
                        {
                          if (type == task.locationCategory)
                            {
                              //notify the user
                              NotificationService
                                  .createLocationBasedNotification(task.id!,
                                      place['name'], type, DateTime.now()),
                            }
                        }
                    }
                });
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
  static Future<void> turnOn(BuildContext context, int interval) async {
    _contextt = context;

    _locationSubscription = Location().onLocationChanged.listen((location) {
      //at first, the current location is null so we need to initialize it
      //and we will check for the first time for nearby places
      if (_currentLocation == null) {
        _currentLocation = location;
        checkForLocations(_contextt!, interval, isFirstTime);
        isFirstTime = false;
      }

      //TODO uncomment this in production because it is for testing purposes
      // //then check if the current location is different from the new location
      // //so that the user doesn't get notified for the same location
      // if (_currentLocation!.latitude!.toStringAsFixed(4) ==
      //         location.latitude!.toStringAsFixed(4) &&
      //     _currentLocation!.longitude!.toStringAsFixed(4) ==
      //         location.longitude!.toStringAsFixed(4)) {
      //   return;
      // }
      //update the current location
      _currentLocation = location;

      // check for nearby places
      checkForLocations(_contextt!, interval, isFirstTime);
    });
  }

  // turn off the location service
  static Future<void> turnOff() async {
    await _locationSubscription?.cancel();
  }
}
