class ApiClient {
  final Dio dio;

  ApiClient(this.dio);

  Future<List<ClothingItem>> uploadVideo(File video);
}
