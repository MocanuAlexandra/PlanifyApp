import 'package:flutter/material.dart';

import '../helpers/utility.dart';
import '../services/location_based_notification_service.dart';
import '../widgets/drawer.dart';

class SettingsScreen extends StatefulWidget {
  static const routeName = '/settings';
  final Function(Map<String, dynamic>, BuildContext context)? saveFilters;
  final Map<String, dynamic> currentFilters;
  const SettingsScreen(
      {super.key, required this.saveFilters, required this.currentFilters});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  //filters
  var _locationBasedNotification = false;
  int? _intervalOfNotification;
  var _selfEmptyingTrash = false;
  int? _intervalOfSelfEmptyingTrash;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              final selectedFilters = {
                'locationBasedNotification': _locationBasedNotification,
                'intervalOfNotification': _intervalOfNotification,
                'selfEmptyingTrash': _selfEmptyingTrash,
                'intervalOfSelfEmptyingTrash': _intervalOfSelfEmptyingTrash,
              };
              saveFilters(context, selectedFilters);
            },
          ),
        ],
      ),
      drawer: const MainDrawer(),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              children: [
                // location based notification
                SwitchListTile(
                  title: const Text('Location based notification',
                      style: TextStyle(fontSize: 17)),
                  value: _locationBasedNotification,
                  subtitle: const Text(
                    """Turn on to receive notifications based on your location.
Make sure the app is running in the background.""",
                    softWrap: true,
                  ),
                  onChanged: (newValue) async {
                    bool updatedFilterValue;
                    bool permissionStatus;

                    //check if the user wants to enable or disable these notifications
                    if (newValue) {
                      // if the user wants to enable these notifications, check if user has granted permission
                      permissionStatus = await LocationBasedNotificationService
                          .checkLocationPermission(context);

                      // if yes, update the filter value with true,
                      // otherwise update the filter value with false
                      if (permissionStatus) {
                        updatedFilterValue = true;
                      } else {
                        updatedFilterValue = false;
                      }
                      // if the user wants to disable these notifications, update the filter value
                    } else {
                      updatedFilterValue = false;
                      _intervalOfNotification = null;
                    }

                    // update _locationBasedNotification with the updated filter value
                    setState(() {
                      _locationBasedNotification = updatedFilterValue;
                    });
                  },
                ),
                //user can select the interval of notifications only if location based notification is enabled
                if (_locationBasedNotification)
                  DropdownButtonFormField<int>(
                    icon: const Icon(Icons.arrow_drop_down),
                    value: _intervalOfNotification,
                    items: const [
                      DropdownMenuItem(
                        value: 2,
                        child: Text(
                          'Every 2 minutes',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 10,
                        child: Text(
                          'Every 10 minutes',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 30,
                        child: Text(
                          'Every 30 minutes',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 60,
                        child: Text(
                          'Every 1 hour',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 1440,
                        child: Text(
                          'Once a day',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _intervalOfNotification = value!;
                      });
                    },
                    hint: const Text(
                      'Select interval of notifications',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                const SizedBox(
                  height: 20,
                ),
                // trash self emptying
                SwitchListTile(
                  title: const Text('Self emptying trash',
                      style: TextStyle(fontSize: 17)),
                  value: _selfEmptyingTrash,
                  subtitle: const Text(
                    """Turn on to empty the trash automatically.""",
                    softWrap: true,
                  ),
                  onChanged: (newValue) async {
                    bool updatedFilterValue;

                    //check if the user wants to enable or disable this functionality
                    if (newValue) {
                      // if the user wants to enable this functionality, update the filter value with true,
                      updatedFilterValue = true;
                    } else {
                      updatedFilterValue = false;
                      _intervalOfSelfEmptyingTrash = null;
                    }

                    // update _selfEmptyingTrash with the updated filter value
                    setState(() {
                      _selfEmptyingTrash = updatedFilterValue;
                    });
                  },
                ),
                //user can select the interval of self emptying only if self emptying is enabled
                if (_selfEmptyingTrash)
                  DropdownButtonFormField<int>(
                    icon: const Icon(Icons.arrow_drop_down),
                    value: _intervalOfSelfEmptyingTrash,
                    items: const [
                      DropdownMenuItem(
                        value: 1,
                        child: Text(
                          'Every 1 minute',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 5,
                        child: Text(
                          'Every 5 minute',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 15,
                        child: Text(
                          'Every 15 minute',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 30,
                        child: Text(
                          'Every 30 minute',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _intervalOfSelfEmptyingTrash = value!;
                      });
                    },
                    hint: const Text(
                      'Select interval of self emptying',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    _locationBasedNotification =
        widget.currentFilters['locationBasedNotification']!;
    _intervalOfNotification = widget.currentFilters['intervalOfNotification'];
    _selfEmptyingTrash = widget.currentFilters['selfEmptyingTrash']!;
    _intervalOfSelfEmptyingTrash =
        widget.currentFilters['intervalOfSelfEmptyingTrash'];
    super.initState();
  }

  void saveFilters(BuildContext context, Map<String, dynamic> selectedFilters) {
    if (_intervalOfNotification == null && _locationBasedNotification) {
      Utility.displayInformationalDialog(context,
          'You must select an interval at which you want to receive location-based notifications');
    } else {
      widget.saveFilters!(selectedFilters, context);
    }

    if (_intervalOfSelfEmptyingTrash == null && _selfEmptyingTrash) {
      Utility.displayInformationalDialog(context,
          'You must select an interval at which you want to empty the trash');
    } else {
      widget.saveFilters!(selectedFilters, context);
    }
  }
}
