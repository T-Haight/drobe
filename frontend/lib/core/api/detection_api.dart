import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import '../../shared/models/detection.dart';

class DetectionApi {
  final Dio dio;

  DetectionApi(this.dio);

  DateTime _lastInference = DateTime.now();

  Future<List<Detection>> detectFrame(XFile image) async {
    if (DateTime.now().difference(_lastInference).inMilliseconds < 400) {
      return [];
    }
    _lastInference = DateTime.now();

    final bytes = await image.readAsBytes();
    final response = await dio.post(
      '/detect/frame',
      data: FormData.fromMap({
        'image': MultipartFile.fromBytes(bytes, filename: 'frame.jpg'),
      }),
    );

    return (response.data['detections'] as List)
        .map<Detection>((d) => Detection.fromJson(d))
        .toList();
  }
}
