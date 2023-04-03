import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'image_preview.dart';

class UserImagePicker extends StatefulWidget {
  final String? previousImageUrl;
  final Function(File? pickedImage, bool isDeleted) imagePickFn;
  const UserImagePicker({
    super.key,
    required this.imagePickFn,
    required this.previousImageUrl,
  });

  @override
  State<UserImagePicker> createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  File? _pickedImage;
  String? _previewImageUrl;
  bool isDeleted = false;

  @override
  void initState() {
    if (widget.previousImageUrl != null) {
      _previewImageUrl = widget.previousImageUrl;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: SizedBox(
            width: 120,
            height: 120,
            child: _pickedImage == null
                ? _previewImageUrl != null
                    ? ImagePreview(
                        imageUrl: _previewImageUrl!,
                        isUrl: true,
                        isDefaultImage: false,
                      )
                    : const ImagePreview(
                        imageUrl: 'assets/images/noimage.jpg',
                        isUrl: false,
                        isDefaultImage: true,
                      )
                : ImagePreview(
                    imageUrl: _pickedImage!.path,
                    isUrl: false,
                    isDefaultImage: false,
                  ),
          ),
        ),
        TextButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.photo_camera),
            label: const Text('Add image    '),
            style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.secondary,
                iconColor: Theme.of(context).colorScheme.primary)),
        IconButton(onPressed: _deleteImage, icon: const Icon(Icons.delete)),
      ],
    );
  }

  void _deleteImage() {
    setState(() {
      _pickedImage = null;
      _previewImageUrl = null;
      isDeleted = true;
    });
    widget.imagePickFn(_pickedImage, isDeleted);
  }

  void _pickImage() async {
    final pickedImageFile = await ImagePicker()
        .pickImage(source: ImageSource.camera, imageQuality: 50);
    setState(() {
      _pickedImage = File(pickedImageFile!.path);
    });
    widget.imagePickFn(_pickedImage, isDeleted);
  }
}
