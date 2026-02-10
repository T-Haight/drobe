import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/detection_api.dart';
import '../api/wardrobe_api.dart';
import 'dio_provider.dart';

final apiClientProvider = Provider<DetectionApi>((ref) {
  final dio = ref.watch(dioProvider);
  return DetectionApi(dio);
});

final wardrobeApiProvider = Provider<WardrobeApi>((ref) {
  final dio = ref.watch(dioProvider);
  return WardrobeApi(dio);
});
