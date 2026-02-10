import 'package:dio/dio.dart';
import '../../shared/models/detection.dart';
import 'dart:io';

class DetectionApi {
  final Dio dio;

  DetectionApi(this.dio);

  DateTime _lastInference = DateTime.now();

  Future<List<Detection>> detectFrame(File image) async {
    if (DateTime.now().difference(_lastInference).inMilliseconds < 400) {
      return [];
    }
    _lastInference = DateTime.now();

    final response = await dio.post(
      '/detect/frame',
      data: FormData.fromMap({
        'image': await MultipartFile.fromFile(image.path),
      }),
    );

    return response.data['detections']
        .map<Detection>((d) => Detection.fromJson(d))
        .toList();
  }
}
