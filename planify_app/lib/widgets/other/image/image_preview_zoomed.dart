import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ImagePreviewZoomed extends StatefulWidget {
  final String imageUrl;

  const ImagePreviewZoomed({super.key, required this.imageUrl});

  @override
  State<ImagePreviewZoomed> createState() => _ImagePreviewZoomedState();
}

class _ImagePreviewZoomedState extends State<ImagePreviewZoomed> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                color: Colors.black.withOpacity(0.5),
              ),
            ),
            Center(
              child: GestureDetector(
                onScaleUpdate: (ScaleUpdateDetails details) {
                  setState(() {
                    _scale = details.scale.clamp(1.0, 3.0);
                  });
                },
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: PhotoView(
                    imageProvider: NetworkImage(widget.imageUrl),
                    initialScale: PhotoViewComputedScale.contained,
                    minScale: PhotoViewComputedScale.contained,
                    maxScale: 3.0,
                    scaleStateController: PhotoViewScaleStateController(),
                    filterQuality: FilterQuality.high,
                    backgroundDecoration: const BoxDecoration(
                      color: Colors.transparent,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 40.0,
              right: 20.0,
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 30.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
