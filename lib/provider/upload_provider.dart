import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:image/image.dart' as img;
import '../data/api/api_service.dart';
import '../data/response/upload_response.dart';

class UploadProvider extends ChangeNotifier {
  final ApiService apiService;

  UploadProvider(this.apiService);

  String? imagePath;
  XFile? imageFile;
  LatLng? _currLatLon;

  bool isUploading = false;
  String message = "";
  UploadResponse? uploadResponse;

  LatLng? get currLatLon => _currLatLon;

  void setImagePath(String? value) {
    imagePath = value;
    notifyListeners();
  }


  void setImageFile(XFile? value) {
    imageFile = value;
    notifyListeners();
  }


  Future<void> upload(
      List<int> bytes,
      String fileName,
      String description,
      {double lat = 0.0,
        double lon = 0.0,}
      )
  async {
    try {
      message = "";
      uploadResponse = null;
      isUploading = true;
      notifyListeners();

      uploadResponse = await apiService.uploadDocument(bytes, fileName, description, lat, lon);
      message = uploadResponse?.message ?? "success";
      isUploading = false;
      notifyListeners();
    } catch (e) {
      isUploading = false;
      message = e.toString();
      notifyListeners();
    }
  }

  Future<List<int>> compressImage(List<int> bytes) async {
    int imageLength = bytes.length;
    if (imageLength < 1000000) return bytes;

    final img.Image image = img.decodeImage(bytes)!;
    int compressQuality = 100;
    int length = imageLength;
    List<int> newByte = [];

    do {
      ///
      compressQuality -= 10;

      newByte = img.encodeJpg(
        image,
        quality: compressQuality,
      );

      length = newByte.length;
    } while (length > 1000000);

    return newByte;
  }

  Future<List<int>> resizeImage(List<int> bytes) async {
    int imageLength = bytes.length;
    if (imageLength < 1000000) return bytes;

    final img.Image image = img.decodeImage(bytes)!;
    bool isWidthMoreTaller = image.width > image.height;
    int imageTall = isWidthMoreTaller ? image.width : image.height;
    double compressTall = 1;
    int length = imageLength;
    List<int> newByte = bytes;

    do {
      ///
      compressTall -= 0.1;

      final newImage = img.copyResize(
        image,
        width: isWidthMoreTaller ? (imageTall * compressTall).toInt() : null,
        height: !isWidthMoreTaller ? (imageTall * compressTall).toInt() : null,
      );

      length = newImage.length;
      if (length < 1000000) {
        newByte = img.encodeJpg(newImage);
      }
    } while (length > 1000000);

    return newByte;
  }
}