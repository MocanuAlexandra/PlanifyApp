import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '/models/task_adress.dart';

class MapScreen extends StatefulWidget {
  const MapScreen(
      {super.key,
      this.initialAdress = const TaskAdress(
        latitude: 37.422,
        longitude: -122.084,
      ),
      this.isSelecting = false});
  final TaskAdress initialAdress;
  final bool isSelecting;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? _pickedLocation;

  void _selectLocation(LatLng position) {
    setState(() {
      _pickedLocation = position;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Map'),
        actions: [
          if (widget.isSelecting)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _pickedLocation == null
                  ? null
                  : () {
                      Navigator.of(context).pop(_pickedLocation);
                    },
            ),
        ],
      ),
      body: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(widget.initialAdress.latitude!,
                widget.initialAdress.longitude!),
            zoom: 16,
          ),
          onTap: widget.isSelecting ? _selectLocation : null,
          markers: (_pickedLocation == null && widget.isSelecting == true)
              ? {}
              : {
                  Marker(
                    markerId: const MarkerId('m1'),
                    position: _pickedLocation ??
                        LatLng(widget.initialAdress.latitude!,
                            widget.initialAdress.longitude!),
                  ),
                }),
    );
  }
}
