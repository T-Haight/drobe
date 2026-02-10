import 'package:flutter/material.dart';

class DetectionOverlay extends StatelessWidget {
  final List<dynamic> detections;
  final Size previewSize;
  final Function(dynamic) onTapDetection;

  const DetectionOverlay({
    super.key,
    required this.detections,
    required this.previewSize,
    required this.onTapDetection,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scaleX = constraints.maxWidth / previewSize.height;
        final scaleY = constraints.maxHeight / previewSize.width;

        return Stack(
          children: detections.map((det) {
            final boxWidth = det.width * previewSize.height * scaleX;
            final boxHeight = det.height * previewSize.width * scaleY;

            final left = (det.x * previewSize.height * scaleX) - boxWidth / 2;
            final top = (det.y * previewSize.width * scaleY) - boxHeight / 2;

            return Positioned(
              left: left,
              top: top,
              width: boxWidth,
              height: boxHeight,
              child: GestureDetector(
                onTap: () => onTapDetection(det),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.greenAccent, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      color: Colors.black.withValues(alpha: 0.6),
                      child: Text(
                        det.label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
