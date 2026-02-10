class Detection {
  final String id;
  final String label;
  final double confidence;
  final double x; // normalized center x
  final double y; // normalized center y
  final double width; // normalized
  final double height; // normalized

  Detection({
    required this.id,
    required this.label,
    required this.confidence,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  factory Detection.fromJson(Map<String, dynamic> json) {
    final bboxRaw = json['bbox'] ?? json['box'] ?? json['bounding_box'];
    final bbox = bboxRaw is Map ? Map<String, dynamic>.from(bboxRaw) : null;

    final x = bbox != null
        ? _toDouble(bbox['x'] ?? bbox['cx'] ?? bbox['x_center'])
        : _toDouble(json['x'] ?? json['cx'] ?? json['x_center']);
    final y = bbox != null
        ? _toDouble(bbox['y'] ?? bbox['cy'] ?? bbox['y_center'])
        : _toDouble(json['y'] ?? json['cy'] ?? json['y_center']);
    final width = bbox != null
        ? _toDouble(bbox['width'] ?? bbox['w'])
        : _toDouble(json['width'] ?? json['w']);
    final height = bbox != null
        ? _toDouble(bbox['height'] ?? bbox['h'])
        : _toDouble(json['height'] ?? json['h']);

    return Detection(
      id: (json['id'] ?? '').toString(),
      label: (json['label'] ?? json['class'] ?? json['name'] ?? '').toString(),
      confidence: _toDouble(
        json['confidence'] ?? json['score'] ?? json['probability'],
      ),
      x: x,
      y: y,
      width: width,
      height: height,
    );
  }
}
