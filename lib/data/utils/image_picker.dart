import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';

class ImageHelper {
  File? image;

  Future<File?> getFromGallery() async {
    try {
      final FilePickerResult? image = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );
      if(image == null) return null;
      return File(image.files.single.path!);
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
    return null;
  }

  Future<File?> getFile() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['epub'],
      );
      if(result == null) return null;
      return File(result.files.single.path!);
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
    return null;
  }
}
