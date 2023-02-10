import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_maps_webservice_ex/places.dart';

import '../../helpers/location_helper.dart';
import '../../models/task_address.dart';

class MapScreen extends StatefulWidget {
  const MapScreen(
      {super.key,
      this.initialAddress = const TaskAddress(
        latitude: 0,
        longitude: 0,
      ),
      this.isSelecting = false,
      required this.zoom});
  final TaskAddress initialAddress;
  final bool isSelecting;
  final double zoom;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  late final _placesService =
      GoogleMapsPlaces(apiKey: LocationHelper.getApiKey());
  final TextEditingController _searchController = TextEditingController();
  String? _searchAddr;
  LatLng? _searchCoords;
  LatLng? _pickedLocation;
  bool _isMapLoading = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select a location"),
        actions: <Widget>[
          if (widget.isSelecting)
            IconButton(
              icon: const Icon(Icons.check),
              // Disable the button if no location is selected
              onPressed: _pickedLocation == null
                  ? null
                  : () {
                      Navigator.of(context).pop(_pickedLocation);
                    },
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getCurrentLocation,
        child: const Icon(Icons.my_location),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      body: Column(
        children: [
          // This is the search bar
          Container(
            padding: const EdgeInsets.all(8.0),
            child: TypeAheadField(
              textFieldConfiguration: TextFieldConfiguration(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search for a location',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: _handleSearch,
                  ),
                ),
              ),
              // These are the suggestions that will be shown
              suggestionsCallback: (pattern) async {
                PlacesAutocompleteResponse response =
                    await _placesService.autocomplete(pattern);
                return response.predictions;
              },
              itemBuilder: (context, suggestion) {
                // Each suggestion will be displayed using this builder
                return ListTile(
                  leading: const Icon(Icons.location_on),
                  title: Text(suggestion.description!),
                );
              },
              // This is the function that will be called when a suggestion is selected
              onSuggestionSelected: (suggestion) async {
                // Get the details of the selected place
                PlacesDetailsResponse place = await _placesService
                    .getDetailsByPlaceId(suggestion.placeId!);

                // Get the coordinates of the selected place
                _searchCoords = LatLng(place.result!.geometry!.location.lat,
                    place.result!.geometry!.location.lng);

                // Set the picked suggested address as the picked location
                _selectLocation(_searchCoords!, place);
              },
            ),
          ),
          // This is the map
          Expanded(
            child: Stack(children: [
              GoogleMap(
                onMapCreated: _onMapCreated,
                onTap: _selectLocation,
                markers: (_pickedLocation == null && widget.isSelecting == true)
                    ? {
                        // Add a marker to initial location
                        Marker(
                          markerId: const MarkerId('m1'),
                          position: LatLng(widget.initialAddress.latitude!,
                              widget.initialAddress.longitude!),
                          infoWindow:
                              const InfoWindow(title: 'Your selected location'),
                        ),
                      }
                    : {
                        // Add a marker to the picked location
                        Marker(
                          markerId: const MarkerId('m1'),
                          position: _pickedLocation ??
                              LatLng(widget.initialAddress.latitude!,
                                  widget.initialAddress.longitude!),
                          infoWindow:
                              const InfoWindow(title: 'Your selected location'),
                        ),
                      },
                // Set the initial camera position to the initial address (the current location of the user)
                initialCameraPosition: CameraPosition(
                  target: LatLng(widget.initialAddress.latitude!,
                      widget.initialAddress.longitude!),
                  zoom: widget.zoom,
                ),
              ),
              if (_isMapLoading)
                const Center(
                  child: CircularProgressIndicator(),
                ),
            ]),
          ),
        ],
      ),
    );
  }

  // get the current location
  Future<void> _getCurrentLocation() async {
    try {
      final locData = await LocationHelper.getCurrentLocation();
      mapController.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(locData.latitude!, locData.longitude!),
          16,
        ),
      );
      setState(() {
        _pickedLocation = LatLng(locData.latitude!, locData.longitude!);
      });
    } catch (error) {
      return;
    }
  }

  // This is called when the map is created
  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;
      _isMapLoading = false;
    });
  }

  // This is called when the search button is pressed
  void _handleSearch() async {
    // Get the search text
    _searchAddr = _searchController.text;

    // Get the address of the search text
    PlacesSearchResponse searchResponse = await _placesService.searchByText(
      _searchAddr!,
    );
    // Get the coordinates of the search address
    _searchCoords = LatLng(
      searchResponse.results[0].geometry!.location.lat,
      searchResponse.results[0].geometry!.location.lng,
    );

    // Set the search address as the picked location
    _selectLocation(_searchCoords!, null, searchResponse.results[0].name);
  }

  void _selectLocation(LatLng position,
      [PlacesDetailsResponse? place, String? searchAddress]) {
    // Move the camera to the search coordinates and add marker
    mapController.animateCamera(
      CameraUpdate.newLatLngZoom(position, 16),
    );

    // If the user selected a place from the search results, set the search text to the place name
    if (place != null) {
      _searchController.text = place.result!.name;
    } else {
      _searchController.text = '';
    }

    // If the user searched for a place, set the search text to the search address
    if (searchAddress != null) {
      _searchController.text = searchAddress;
    }

    // Set the picked location
    setState(() {
      _pickedLocation = position;
    });
  }
}
