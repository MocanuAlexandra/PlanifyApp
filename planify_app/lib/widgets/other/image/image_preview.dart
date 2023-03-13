import 'dart:io';

import 'package:flutter/material.dart';

import 'image_preview_zoomed.dart';

class ImagePreview extends StatefulWidget {
  final String imageUrl;
  final bool isUrl;
  final bool isDefaultImage;

  const ImagePreview(
      {super.key,
      required this.imageUrl,
      required this.isUrl,
      required this.isDefaultImage});

  @override
  State<ImagePreview> createState() => _ImagePreviewState();
}

class _ImagePreviewState extends State<ImagePreview> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isUrl
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ImagePreviewZoomed(imageUrl: widget.imageUrl),
                ),
              );
            }
          : () {},
      child: SizedBox(
        width: 120,
        height: 120,
        child: widget.isDefaultImage
            ? Image.asset(widget.imageUrl,
                frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                if (wasSynchronouslyLoaded) {
                  return child;
                }
                return AnimatedOpacity(
                  opacity: frame == null ? 0 : 1,
                  duration: const Duration(seconds: 1),
                  curve: Curves.easeOut,
                  child: child,
                );
              })
            : widget.isUrl
                ? Image.network(widget.imageUrl,
                    loadingBuilder: (context, child, loadingProgress) =>
                        loadingProgress == null
                            ? child
                            : const Center(
                                child: CircularProgressIndicator(),
                              ))
                : Image.file(File(widget.imageUrl), frameBuilder:
                    (context, child, frame, wasSynchronouslyLoaded) {
                    if (wasSynchronouslyLoaded) {
                      return child;
                    }
                    return AnimatedOpacity(
                      opacity: frame == null ? 0 : 1,
                      duration: const Duration(seconds: 1),
                      curve: Curves.easeOut,
                      child: child,
                    );
                  }),
      ),
    );
  }
}
