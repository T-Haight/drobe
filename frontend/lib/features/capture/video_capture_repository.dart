import 'dart:io';

import '../../core/api/detection_api.dart';
import '../../shared/models/clothing_item.dart';
import 'package:camera/camera.dart';

class VideoCaptureRepository {
  final DetectionApi detectionApi;

  VideoCaptureRepository(this.detectionApi);

  // New method to send frames to the ML model for detection
  Future<List<ClothingItem>> detectClothingItems(CameraImage image) async {
    // Convert image to the format required by the ML model
    final bytes = image.planes.map((plane) => plane.bytes).toList();

    // Send the image to the ML model for detection
    final detections = await detectionApi.detectFrame(File('temp.jpg'));

    // Return the list of detected clothing items
    return [];
  }

  // New method to add clothing items to the virtual closet asynchronously
  Future<void> addToVirtualCloset(ClothingItem item) async {
    // Prepare data for the database
    // Use apiClient to send data to the cloud database
  }
}
