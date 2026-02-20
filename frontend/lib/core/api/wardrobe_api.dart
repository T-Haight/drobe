import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:dio/dio.dart';

class WardrobeApi {
  final Dio dio;

  WardrobeApi(this.dio);

  Future<Map<String, dynamic>> saveWardrobeItem({
    required XFile image,
    required Map<String, double> bbox,
    required String label,
  }) async {
    final bytes = await image.readAsBytes();
    final formData = FormData.fromMap({
      'image': MultipartFile.fromBytes(bytes, filename: 'frame.jpg'),
      'bbox': jsonEncode(bbox),
      'label': label,
    });

    final response = await dio.post('/wardrobe/items', data: formData);
    return response.data as Map<String, dynamic>;
  }
}
