import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

import '../../models/task_address.dart';
import '../../screens/location/map_screen.dart';
import '../../services/location_helper_service.dart';
import 'location_category.dart';

class LocationInput extends StatefulWidget {
  final Function onSelectPlace;
  final Function onSelectCategory;
  final TaskAddress? previousAddress;
  final String? previousLocationCategory;
  const LocationInput(
      {super.key,
      required this.onSelectPlace,
      this.previousAddress,
      required this.onSelectCategory,
      this.previousLocationCategory});

  @override
  State<LocationInput> createState() => _LocationInputState();
}

class _LocationInputState extends State<LocationInput> {
  String? _previewImageUrl;
  TaskAddress? _initialAddress;
  String? _selectedLocationCategory;

  @override
  void initState() {
    if (widget.previousAddress != null &&
        widget.previousAddress!.latitude != 0.0 &&
        widget.previousAddress!.longitude != 0.0) {
      _previewImageUrl = LocationHelper.generateLocPreviewImg(
          latitude: widget.previousAddress!.latitude,
          longitude: widget.previousAddress!.longitude);
      _selectedLocationCategory = 'No location category chosen';
    } else if (widget.previousLocationCategory != null ||
        widget.previousLocationCategory != 'No location category chosen') {
      _selectedLocationCategory = widget.previousLocationCategory;
      _previewImageUrl = null;
    }
    super.initState();
  }

  // add the map in preview
  void _showPreview(double lat, double long) {
    final staticMapUrl =
        LocationHelper.generateLocPreviewImg(latitude: lat, longitude: long);
    setState(() {
      _previewImageUrl = staticMapUrl;
    });
  }

  // select the location on the map
  Future<void> _selectOnMap() async {
    double zoom = 16;

    //check if the user has granted the permission
    final locPermission = await Location().hasPermission();
    if (locPermission == PermissionStatus.granted) {
      final locData = await Location().getLocation();
      _initialAddress = TaskAddress(
          latitude: locData.latitude!, longitude: locData.longitude!);
    } else {
      // if not, ask for it
      final locPermission = await Location().requestPermission();

      if (locPermission == PermissionStatus.granted ||
          locPermission == PermissionStatus.grantedLimited) {
        final locData = await Location().getLocation();
        _initialAddress = TaskAddress(
            latitude: locData.latitude!, longitude: locData.longitude!);
        zoom = 16;
      }
      // if the user refuses, display the map with the default location and zoomed out
      else if (locPermission == PermissionStatus.denied ||
          locPermission == PermissionStatus.deniedForever) {
        _initialAddress = const TaskAddress(latitude: 0.0, longitude: 0.0);
        zoom = 2;
      }
    }

    // ignore: use_build_context_synchronously
    final selectedLocation = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (ctx) => MapScreen(
          initialAddress: _initialAddress!,
          isSelecting: true,
          zoom: zoom,
        ),
      ),
    );

    if (selectedLocation == null) {
      return;
    }
    _showPreview(selectedLocation.latitude, selectedLocation.longitude);
    widget.onSelectPlace(selectedLocation.latitude, selectedLocation.longitude);
    _selectedLocationCategory = 'No location category chosen';
  }

  void _deleteLocation() {
    setState(() {
      _previewImageUrl = null;
      _selectedLocationCategory = 'No location category chosen';
    });
    widget.onSelectPlace(null, null);
    widget.onSelectCategory(null);
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
          child: _previewImageUrl == null &&
                  (_selectedLocationCategory != 'No location category chosen' &&
                      _selectedLocationCategory != null)
              ? displayLocationCategoryChosen()
              : _previewImageUrl != null &&
                      _selectedLocationCategory == 'No location category chosen'
                  ? displayLocationPreview()
                  : _previewImageUrl == null &&
                          (_selectedLocationCategory ==
                                  'No location category chosen' ||
                              _selectedLocationCategory == null)
                      ? const Text(
                          'No location or location category chosen',
                          style: TextStyle(fontSize: 15),
                          textAlign: TextAlign.center,
                        )
                      : null,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton.icon(
                onPressed: () => {
                      selectLocationCategory(context),
                    },
                icon: const Icon(Icons.share_location_sharp),
                label: const Text(
                  'Category',
                  style: TextStyle(fontSize: 15),
                ),
                style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.secondary,
                    iconColor: Theme.of(context).colorScheme.primary)),
            TextButton.icon(
                onPressed: _selectOnMap,
                icon: const Icon(Icons.map),
                label: const Text(
                  'Search',
                  style: TextStyle(fontSize: 15),
                ),
                style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.secondary,
                    iconColor: Theme.of(context).colorScheme.primary)),
            TextButton.icon(
                onPressed: _deleteLocation,
                icon: const Icon(Icons.delete),
                label: const Text(
                  'Delete',
                  style: TextStyle(fontSize: 15),
                ),
                style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.secondary,
                    iconColor: Theme.of(context).colorScheme.primary)),
          ],
        ),
      ],
    );
  }

  Image displayLocationPreview() {
    return Image.network(
      _previewImageUrl!,
      fit: BoxFit.fitHeight,
      width: double.infinity,
      loadingBuilder: (context, child, loadingProgress) =>
          loadingProgress == null
              ? child
              : const Center(
                  child: CircularProgressIndicator(),
                ),
    );
  }

  Column displayLocationCategoryChosen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Location category chosen: ',
          style: TextStyle(
            fontSize: 17,
          ),
          softWrap: true,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text(
          _selectedLocationCategory!,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
          softWrap: true,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Future<dynamic> selectLocationCategory(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) => LocationCategory(
              onSelectLocationCategory: _selectLocationCategory,
              previousLocationCategory: widget.previousLocationCategory,
            ));
  }

// set the selected location category
  void _selectLocationCategory(String category) {
    setState(() {
      _selectedLocationCategory = category;
      _previewImageUrl = null;
    });
    widget.onSelectPlace(null, null);
    widget.onSelectCategory(category);
  }
}
