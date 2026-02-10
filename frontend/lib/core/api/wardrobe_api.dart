import 'package:dio/dio.dart';

class WardrobeApi {
  final Dio dio;

  WardrobeApi(this.dio);

  Future<void> saveWardrobeItem({
    required String detectionId,
    required Map<String, double> bbox,
    required String label,
  }) async {
    await dio.post(
      '/wardrobe/items',
      data: {'detection_id': detectionId, 'bbox': bbox, 'label': label},
    );
  }
}
