import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';

class SignatureCanvasWidget extends StatefulWidget {
  final Function(String base64Image) onSigned;
  const SignatureCanvasWidget({super.key, required this.onSigned});

  @override
  State<SignatureCanvasWidget> createState() => _SignatureCanvasWidgetState();
}

class _SignatureCanvasWidgetState extends State<SignatureCanvasWidget> {
  final List<Offset?> _points = [];

  void _clearCanvas() {
    setState(() {
      _points.clear();
    });
  }

  Future<void> _captureSignature() async {
    if (_points.isEmpty) {
      Get.snackbar('Attention', 'Veuillez apposer votre signature dans le cadre', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromPoints(const Offset(0, 0), const Offset(400, 200)));

    final paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.5;

    // Background white
    canvas.drawRect(const Rect.fromLTWH(0, 0, 400, 200), Paint()..color = Colors.white);

    for (int i = 0; i < _points.length - 1; i++) {
      if (_points[i] != null && _points[i + 1] != null) {
        canvas.drawLine(_points[i]!, _points[i + 1]!, paint);
      }
    }

    final picture = recorder.endRecording();
    final img = await picture.toImage(400, 200);
    final pngBytes = await img.toByteData(format: ui.ImageByteFormat.png);

    if (pngBytes != null) {
      final base64String = base64Encode(pngBytes.buffer.asUint8List());
      final fullDataUrl = 'data:image/png;base64,$base64String';
      widget.onSigned(fullDataUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Signature Électronique',
          style: TextStyle(fontSize: Dimensions.fontSizeLarge, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
        ),
        const SizedBox(height: 8),
        Text(
          'Veuillez signer avec votre doigt dans la zone ci-dessous :',
          style: TextStyle(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor),
        ),
        const SizedBox(height: 12),
        Container(
          height: 180,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            border: Border.all(color: Theme.of(context).primaryColor, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                blurRadius: 5,
                spreadRadius: 2,
              )
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            child: GestureDetector(
              onPanUpdate: (DragUpdateDetails details) {
                RenderBox object = context.findRenderObject() as RenderBox;
                Offset localPosition = object.globalToLocal(details.globalPosition);
                setState(() {
                  _points.add(localPosition);
                });
              },
              onPanEnd: (DragEndDetails details) {
                _points.add(null);
              },
              child: CustomPaint(
                painter: SignaturePainter(points: _points),
                size: Size.infinite,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton.icon(
              onPressed: _clearCanvas,
              icon: const Icon(Icons.refresh, color: Colors.red),
              label: const Text('Effacer', style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton.icon(
              onPressed: _captureSignature,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
              ),
              icon: const Icon(Icons.check_circle, color: Colors.white),
              label: const Text('Valider la Signature', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ],
    );
  }
}

class SignaturePainter extends CustomPainter {
  final List<Offset?> points;
  SignaturePainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.0;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(SignaturePainter oldDelegate) => oldDelegate.points != points;
}
