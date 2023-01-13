import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

import '../../helpers/location_helper.dart';
import '../../models/task_adress.dart';
import '../../screens/location/map_screen.dart';

class LocationInput extends StatefulWidget {
  final Function onSelectPlace;
  const LocationInput({super.key, required this.onSelectPlace});

  @override
  State<LocationInput> createState() => _LocationInputState();
}

class _LocationInputState extends State<LocationInput> {
  String? _previewImageUrl;
  TaskAdress? _initialAdress;

  // add the map in preview
  void _showPreview(double lat, double long) {
    final staticMapUrl =
        LocationHelper.generateLocPreviewImg(latitude: lat, longitude: long);
    setState(() {
      _previewImageUrl = staticMapUrl;
    });
  }

  // get the current location
  Future<void> _getCurrentUserLocation() async {
    try {
      final locData = await Location().getLocation();
      _showPreview(locData.latitude!, locData.longitude!);
      widget.onSelectPlace(locData.latitude, locData.longitude);
    } catch (error) {
      return;
    }
  }

  // select the location on the map
  Future<void> _selectOnMap() async {
    final locData = await Location().getLocation();

    _initialAdress =
        TaskAdress(latitude: locData.latitude!, longitude: locData.longitude!);

    // ignore: use_build_context_synchronously
    final selectedLocation = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (ctx) =>
            MapScreen(initialAdress: _initialAdress!, isSelecting: true),
      ),
    );

    if (selectedLocation == null) {
      return;
    }
    _showPreview(selectedLocation.latitude, selectedLocation.longitude);
    widget.onSelectPlace(selectedLocation.latitude, selectedLocation.longitude);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 170,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(width: 1, color: Colors.grey),
          ),
          child: _previewImageUrl == null
              ? const Text(
                  'No location chosen',
                  textAlign: TextAlign.center,
                )
              : Image.network(_previewImageUrl!,
                  fit: BoxFit.cover, width: double.infinity),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(
              onPressed: _getCurrentUserLocation,
              icon: const Icon(Icons.location_on),
              label: const Text('Current Location'),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).primaryColor,
              ),
            ),
            TextButton.icon(
              onPressed: _selectOnMap,
              icon: const Icon(Icons.map),
              label: const Text('Select on Map'),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
