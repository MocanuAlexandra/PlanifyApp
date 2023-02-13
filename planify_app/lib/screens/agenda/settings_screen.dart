import 'package:flutter/material.dart';

import '../../services/location_based_notification_service.dart';
import '../../widgets/drawer.dart';

class SettingsScreen extends StatefulWidget {
  static const routeName = '/settings';
  final Function(Map<String, bool>)? saveFilters;
  final Map<String, bool> currentFilters;

  const SettingsScreen(
      {super.key, required this.saveFilters, required this.currentFilters});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  //filters
  var _locationBasedNotification = false;

  @override
  void initState() {
    _locationBasedNotification =
        widget.currentFilters['locationBasedNotification']!;
    super.initState();
  }

  // Widget _buildSwitchListTile(String title, String description,
  //     bool currentValue, Function updateValue) {
  //   return SwitchListTile(
  //     title: Text(title),
  //     value: currentValue,
  //     subtitle: Text(description),
  //     onChanged: (newValue) {
  //       setState(() async {
  //         await updateValue(newValue);
  //       });
  //     },
  //   );
  // }

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
              };
              widget.saveFilters!(selectedFilters);
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
                      style: TextStyle(fontSize: 17 )),
                  value: _locationBasedNotification,
                  subtitle: const Text(
                      'Turn on to receive notifications based on your location.'),
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
                    }

                    // update _locationBasedNotification with the updated filter value
                    setState(() {
                      _locationBasedNotification = updatedFilterValue;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
