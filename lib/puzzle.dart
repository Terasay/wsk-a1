
import 'dart:math' as math;
import 'package:flutter/material.dart';

class PuzzleCaptcha extends StatefulWidget {
  final ValueChanged<bool> onVerified;

  const PuzzleCaptcha({
    super.key,
    required this.onVerified,
  });

  @override
  State<PuzzleCaptcha> createState() => _PuzzleCaptchaState();
}

class _PuzzleCaptchaState extends State<PuzzleCaptcha> {
  static const String _imagePath = 'assets/images/landscape.jpg';

  static const double _imageHeight = 175;
  static const double _pieceSize = 58;
  static const double _pieceTop = 55;

  double _position = 0;
  bool _isVerified = false;

  // Случайная позиция слота при создании капчи
  late final double _targetRatio =
      0.30 + math.Random().nextDouble() * 0.58;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final maxX = math.max(0.0, width - _pieceSize);
          final targetX = maxX * _targetRatio;

          return Stack(
            children: [
              // 1. Основная фотография
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                height: _imageHeight,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    _imagePath,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              // 2. Место, куда нужно поставить фрагмент
              Positioned(
                left: targetX,
                top: _pieceTop,
                child: CustomPaint(
                  size: const Size(_pieceSize, _pieceSize),
                  painter: _SlotPainter(),
                ),
              ),

              // 3. Подвижный фрагмент фотографии
              Positioned(
                left: _position,
                top: _pieceTop,
                child: ClipPath(
                  clipper: _PuzzleClipper(),
                  child: SizedBox(
                    width: _pieceSize,
                    height: _pieceSize,
                    child: Stack(
                      clipBehavior: Clip.hardEdge,
                      children: [
                        Positioned(
                          left: -targetX,
                          top: -_pieceTop,
                          width: width,
                          height: _imageHeight,
                          child: Image.asset(
                            _imagePath,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 4. Дорожка ползунка
              Positioned(
                left: 0,
                right: 0,
                top: 190,
                height: 50,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),

              // 5. Управление ползунком
              Positioned(
                left: _position,
                top: 190,
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    if (_isVerified) return;

                    setState(() {
                      _position =
                          (_position + details.delta.dx)
                              .clamp(0.0, maxX);
                    });
                  },
                  onHorizontalDragEnd: (_) {
                    final success =
                        (_position - targetX).abs() <= 10;

                    setState(() {
                      _isVerified = success;

                      if (!success) {
                        _position = 0;
                      }
                    });

                    widget.onVerified(success);
                  },
                  child: Container(
                    width: _pieceSize,
                    height: 50,
                    decoration: BoxDecoration(
                      color: _isVerified
                          ? Colors.green
                          : Colors.black,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _isVerified
                          ? Icons.check
                          : Icons.arrow_forward,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// Создаём форму фрагмента пазла
Path _createPuzzlePath(Size size) {
  final w = size.width;
  final h = size.height;

  return Path()
    ..moveTo(w * 0.12, h * 0.12)
    ..lineTo(w * 0.35, h * 0.12)
    ..cubicTo(w * 0.28, 0, w * 0.72, 0, w * 0.65, h * 0.12)
    ..lineTo(w * 0.88, h * 0.12)
    ..lineTo(w * 0.88, h * 0.37)
    ..cubicTo(w, h * 0.30, w, h * 0.70, w * 0.88, h * 0.63)
    ..lineTo(w * 0.88, h * 0.88)
    ..lineTo(w * 0.12, h * 0.88)
    ..lineTo(w * 0.12, h * 0.63)
    ..cubicTo(0, h * 0.70, 0, h * 0.30, w * 0.12, h * 0.37)
    ..close();
}

// Обрезает фотографию по форме пазла
class _PuzzleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) => _createPuzzlePath(size);

  @override
  bool shouldReclip(covariant _PuzzleClipper oldClipper) => false;
}

// Рисует контур места для фрагмента
class _SlotPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = _createPuzzlePath(size);

    canvas.drawPath(
      path,
      Paint()..color = const Color(0x66000000),
    );

    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant _SlotPainter oldDelegate) => false;
}
