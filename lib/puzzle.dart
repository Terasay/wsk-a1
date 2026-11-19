
import 'dart:math';
import 'package:flutter/material.dart';

class PuzzleCaptcha extends StatefulWidget {
  final ValueChanged<bool> onVerified;

  const PuzzleCaptcha({super.key, required this.onVerified});

  @override
  State<PuzzleCaptcha> createState() => _PuzzleCaptchaState();
}

class _PuzzleCaptchaState extends State<PuzzleCaptcha> {
  static const double pieceSize = 48;

  double _position = 0;
  bool _isVerified = false;
  late double _targetRatio;

  @override
  void initState() {
    super.initState();

    // Случайное положение цели (35–85% пути)
    _targetRatio = 0.35 + Random().nextDouble() * 0.5;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxX = max(0.0, constraints.maxWidth - pieceSize);
        final targetX = maxX * _targetRatio;

        return SizedBox(
          height: 155,
          child: Stack(
            children: [
              // Место, куда нужно переместить пазл
              Positioned(
                left: targetX,
                top: 8,
                child: Container(
                  width: pieceSize,
                  height: pieceSize,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.green, width: 3),
                  ),
                ),
              ),

              // Движущийся фрагмент
              Positioned(
                left: _position,
                top: 8,
                child: Container(
                  width: pieceSize,
                  height: pieceSize,
                  color: Colors.blue,
                ),
              ),

              // Дорожка ползунка
              Positioned(
                top: 94,
                left: 0,
                right: 0,
                child: Container(
                  height: 50,
                  color: Colors.black12,
                ),
              ),

              // Ползунок, которым управляет пользователь
              Positioned(
                left: _position,
                top: 95,
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    if (_isVerified) return;

                    setState(() {
                      _position = (_position + details.delta.dx)
                          .clamp(0.0, maxX);
                    });
                  },

                  onHorizontalDragEnd: (_) {
                    final success = (_position - targetX).abs() <= 12;

                    setState(() {
                      _isVerified = success;
                      if (!success) _position = 0;
                    });

                    widget.onVerified(success);
                  },

                  child: Container(
                    width: pieceSize,
                    height: pieceSize,
                    color: _isVerified ? Colors.green : Colors.black,
                    alignment: Alignment.center,
                    child: Icon(
                      _isVerified ? Icons.check : Icons.arrow_forward,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
