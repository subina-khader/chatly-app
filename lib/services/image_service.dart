import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

final imageServiceProvider = Provider<ImageService>((ref) => ImageService());

class ImageService {
  final ImagePicker _picker = ImagePicker();

  // Pick image from gallery
  Future<String?> pickImageFromGallery() async {
    final status = await Permission.photos.request();
    if (!status.isGranted) return null;

    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (image == null) return null;
    return await _convertToBase64(image.path);
  }

  // Take photo with camera
  Future<String?> takePhoto() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) return null;

    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (image == null) return null;
    return await _convertToBase64(image.path);
  }

  // Convert image to base64
  Future<String> _convertToBase64(String imagePath) async {
    final bytes = await File(imagePath).readAsBytes();
    return base64Encode(bytes);
  }
}