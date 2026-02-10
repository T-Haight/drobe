class ClothingItem {
  final String id;
  final ClothingType type;
  final ClothingColor color;
  final List<String> tags;
  final String imageUrl;
  final DateTime createdAt;

  const ClothingItem({
    required this.id,
    required this.type,
    required this.color,
    required this.tags,
    required this.imageUrl,
    required this.createdAt,
  });

  factory ClothingItem.fromJson(Map<String, dynamic> json) {
    return ClothingItem(
      id: json['id'],
      type: ClothingType.values.firstWhere((e) => e.name == json['type']),
      color: ClothingColor.values.firstWhere((e) => e.name == json['color']),
      tags: List<String>.from(json['tags']),
      imageUrl: json['image_url'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

enum ClothingType { shirt, pants, jacket, shoes }

enum ClothingColor { black, white, blue, red, green }
