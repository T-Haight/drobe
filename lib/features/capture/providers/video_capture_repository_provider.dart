import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../video_capture_repository.dart';
import '../../../core/providers/api_client_provider.dart';

final videoCaptureRepositoryProvider = Provider<VideoCaptureRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return VideoCaptureRepository(apiClient);
});
