import '../../shared/models/detection.dart';

enum VideoCaptureStatus {
  idle,
  detecting,
  error,
}

class VideoCaptureState {
  final VideoCaptureStatus status;
  final String? error;
  final List<Detection> detections;

  VideoCaptureState({
    required this.status,
    this.error,
    this.detections = const [],
  });

  VideoCaptureState copyWith({
    VideoCaptureStatus? status,
    String? error,
    List<Detection>? detections,
  }) {
    return VideoCaptureState(
      status: status ?? this.status,
      error: error,
      detections: detections ?? this.detections,
    );
  }
}
