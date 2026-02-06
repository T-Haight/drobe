import 'package:drobe_application/core/api/api_client.dart';
import 'package:drobe_application/shared/models/clothing_item.dart';
import 'package:camera/camera.dart';
import 'dart:io' if (dart.library.html) 'dart:html';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http_parser/http_parser.dart';

class VideoCaptureRepository {
  final ApiClient apiClient;

  VideoCaptureRepository(this.apiClient);

  Future<List<ClothingItem>> uploadVideo(String videoPath) async {
    MultipartFile multipartFile;

    if (kIsWeb) {
      // For web, we need to handle the video differently
      // The videoPath will be a blob URL, so we'll need to fetch and convert it
      // For now, we'll throw an error as web upload needs special handling
      throw UnsupportedError(
        'Web upload not yet implemented. Please use mobile/desktop app for uploads.',
      );
    } else {
      // For mobile/desktop, use the file path
      multipartFile = await MultipartFile.fromFile(
        videoPath,
        filename: 'wardrobe.mp4',
        contentType: MediaType('video', 'mp4'),
      );
    }

    final response = await apiClient.postMultipart(
      '/capture/upload',
      fields: {},
      files: [multipartFile],
    );

    return (response.data as List)
        .map((json) => ClothingItem.fromJson(json))
        .toList();
  }

  // New method to send frames to the ML model for detection
  Future<List<ClothingItem>> detectClothingItems(CameraImage image) async {
    // Convert image to the format required by the ML model
    final bytes = image.planes.map((plane) => plane.bytes).toList();
    
    // Send the image to the ML model for detection
    

    // Return the list of detected clothing items
    return [];
  }

  // New method to add clothing items to the virtual closet asynchronously
  Future<void> addToVirtualCloset(ClothingItem item) async {
    // Prepare data for the database
    // Use apiClient to send data to the cloud database
  }
}
