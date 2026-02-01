import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_client.dart';
import 'dio_provider.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  final dio = ref.watch(dioProvider);
  return ApiClient(dio);
});
