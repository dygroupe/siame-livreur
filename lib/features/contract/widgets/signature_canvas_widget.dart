import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/styles.dart';

class ExclusivePanGestureRecognizer extends PanGestureRecognizer {
  @override
  void addAllowedPointer(PointerDownEvent event) {
    super.addAllowedPointer(event);
    resolve(GestureDisposition.accepted);
  }
}

class ExclusiveGestureFactory extends GestureRecognizerFactory<ExclusivePanGestureRecognizer> {
  final GestureRecognizerFactoryConstructor<ExclusivePanGestureRecognizer> _constructor;
  final GestureRecognizerFactoryInitializer<ExclusivePanGestureRecognizer> _initializer;

  ExclusiveGestureFactory(this._constructor, this._initializer);

  @override
  ExclusivePanGestureRecognizer constructor() => _constructor();

  @override
  void initializer(ExclusivePanGestureRecognizer instance) => _initializer(instance);
}

class SignatureCanvasWidget extends StatefulWidget {
  final Function(String base64Image) onSigned;
  const SignatureCanvasWidget({super.key, required this.onSigned});

  @override
  State<SignatureCanvasWidget> createState() => _SignatureCanvasWidgetState();
}

class _SignatureCanvasWidgetState extends State<SignatureCanvasWidget> {
  final GlobalKey _canvasKey = GlobalKey();
  final ValueNotifier<List<Offset?>> _pointsNotifier = ValueNotifier<List<Offset?>>([]);
  bool _isSigned = false;
  RenderBox? _cachedRenderBox;

  void _clearCanvas() {
    _pointsNotifier.value = [];
    setState(() {
      _isSigned = false;
    });
  }

  Future<void> _captureSignature() async {
    final points = _pointsNotifier.value;
    if (points.isEmpty) {
      Get.snackbar(
        'Attention',
        'Veuillez apposer votre signature dans le cadre avant de valider',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    final RenderBox? renderBox = _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    final double width = renderBox != null && renderBox.size.width > 0 ? renderBox.size.width : 400.0;
    final double height = renderBox != null && renderBox.size.height > 0 ? renderBox.size.height : 200.0;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, width, height));

    // Fill white background
    canvas.drawRect(Rect.fromLTWH(0, 0, width, height), Paint()..color = Colors.white);

    final paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke;

    Path path = Path();
    bool isPathStarted = false;

    for (int i = 0; i < points.length; i++) {
      if (points[i] != null) {
        if (!isPathStarted) {
          path.moveTo(points[i]!.dx, points[i]!.dy);
          isPathStarted = true;
        } else if (i > 0 && points[i - 1] != null) {
          final p1 = points[i - 1]!;
          final p2 = points[i]!;
          final midX = (p1.dx + p2.dx) / 2;
          final midY = (p1.dy + p2.dy) / 2;
          path.quadraticBezierTo(p1.dx, p1.dy, midX, midY);
        }
      } else {
        isPathStarted = false;
      }
    }
    canvas.drawPath(path, paint);

    final picture = recorder.endRecording();
    final img = await picture.toImage(width.toInt(), height.toInt());
    final pngBytes = await img.toByteData(format: ui.ImageByteFormat.png);

    if (pngBytes != null) {
      final base64String = base64Encode(pngBytes.buffer.asUint8List());
      final fullDataUrl = 'data:image/png;base64,$base64String';
      setState(() {
        _isSigned = true;
      });
      widget.onSigned(fullDataUrl);
      Get.snackbar(
        'Succès',
        'Signature enregistrée avec succès',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    }
  }

  void _onPanStart(Offset globalPosition) {
    _cachedRenderBox = _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    if (_cachedRenderBox != null) {
      final localPosition = _cachedRenderBox!.globalToLocal(globalPosition);
      _pointsNotifier.value = List.from(_pointsNotifier.value)..add(localPosition);
    }
  }

  void _onPanUpdate(Offset globalPosition) {
    if (_cachedRenderBox != null) {
      final localPosition = _cachedRenderBox!.globalToLocal(globalPosition);
      if (localPosition.dx >= 0 &&
          localPosition.dx <= _cachedRenderBox!.size.width &&
          localPosition.dy >= 0 &&
          localPosition.dy <= _cachedRenderBox!.size.height) {
        _pointsNotifier.value = List.from(_pointsNotifier.value)..add(localPosition);
      }
    }
  }

  void _onPanEnd() {
    _pointsNotifier.value = List.from(_pointsNotifier.value)..add(null);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Signature Manuscrite',
              style: robotoBold.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color: Theme.of(context).primaryColor,
              ),
            ),
            if (_isSigned)
              Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    'Signature enregistrée',
                    style: robotoMedium.copyWith(color: Colors.green, fontSize: Dimensions.fontSizeSmall),
                  ),
                ],
              ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Signez avec votre doigt dans le cadre ci-dessous :',
          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).hintColor),
        ),
        const SizedBox(height: 10),

        // Signature Canvas Container
        Container(
          key: _canvasKey,
          height: 180,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            border: Border.all(
              color: _isSigned ? Colors.green : Theme.of(context).primaryColor,
              width: _isSigned ? 2.0 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 5,
                spreadRadius: 1,
              )
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            child: Stack(
              children: [
                // Line Guide
                Positioned(
                  bottom: 30,
                  left: 30,
                  right: 30,
                  child: Container(
                    height: 1,
                    color: Colors.grey[300],
                  ),
                ),
                Positioned(
                  bottom: 35,
                  left: 35,
                  child: Text(
                    'X',
                    style: robotoBold.copyWith(color: Colors.grey[400], fontSize: Dimensions.fontSizeLarge),
                  ),
                ),

                // ExclusivePanGestureRecognizer locks page scrolling completely while drawing!
                RawGestureDetector(
                  behavior: HitTestBehavior.opaque,
                  gestures: <Type, GestureRecognizerFactory>{
                    ExclusivePanGestureRecognizer: ExclusiveGestureFactory(
                      () => ExclusivePanGestureRecognizer(),
                      (ExclusivePanGestureRecognizer instance) {
                        instance.onStart = (details) => _onPanStart(details.globalPosition);
                        instance.onUpdate = (details) => _onPanUpdate(details.globalPosition);
                        instance.onEnd = (details) => _onPanEnd();
                      },
                    ),
                  },
                  child: CustomPaint(
                    painter: SmoothSignaturePainter(pointsNotifier: _pointsNotifier),
                    size: Size.infinite,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Action Buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            OutlinedButton.icon(
              onPressed: _clearCanvas,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
              ),
              icon: const Icon(Icons.cleaning_services, size: 18),
              label: Text('Effacer', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall)),
            ),
            ElevatedButton.icon(
              onPressed: _captureSignature,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
              ),
              icon: const Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
              label: Text(
                'Valider la Signature',
                style: robotoBold.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeSmall),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class SmoothSignaturePainter extends CustomPainter {
  final ValueNotifier<List<Offset?>> pointsNotifier;
  SmoothSignaturePainter({required this.pointsNotifier}) : super(repaint: pointsNotifier);

  @override
  void paint(Canvas canvas, Size size) {
    final points = pointsNotifier.value;
    if (points.isEmpty) return;

    final paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke;

    Path path = Path();
    bool isPathStarted = false;

    for (int i = 0; i < points.length; i++) {
      if (points[i] != null) {
        if (!isPathStarted) {
          path.moveTo(points[i]!.dx, points[i]!.dy);
          isPathStarted = true;
        } else if (i > 0 && points[i - 1] != null) {
          final p1 = points[i - 1]!;
          final p2 = points[i]!;
          final midX = (p1.dx + p2.dx) / 2;
          final midY = (p1.dy + p2.dy) / 2;
          path.quadraticBezierTo(p1.dx, p1.dy, midX, midY);
        }
      } else {
        isPathStarted = false;
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(SmoothSignaturePainter oldDelegate) => true;
}
