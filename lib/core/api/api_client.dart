import 'package:dio/dio.dart';

class ApiClient {
  final Dio dio;

  ApiClient(this.dio);

  Future<Response> postMultipart(
    String path, {
    required Map<String, dynamic> fields,
    required List<MultipartFile> files,
  }) {
    final formData = FormData.fromMap({...fields, 'files': files});

    return dio.post(path, data: formData);
  }
}
