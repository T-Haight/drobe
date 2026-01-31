import 'package:drobe_application/core/api/api_client.dart';
import 'package:drobe_application/shared/models/clothing_item.dart';
import 'dart:io';
import 'package:dio/dio.dart';

class CaptureRepository {
  final ApiClient apiClient;

  CaptureRepository(this.apiClient);

  Future<List<ClothingItem>> uploadVideo(File video) async {
    final response = await apiClient.postMultipart(
      '/capture/upload',
      fields: {},
      files: [
        await MultipartFile.fromFile(video.path, filename: 'wardrobe.mp4'),
      ],
    );

    return (response.data as List)
        .map((json) => ClothingItem.fromJson(json))
        .toList();
  }
}
