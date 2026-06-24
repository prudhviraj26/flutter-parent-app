import 'package:flutter/material.dart';

class VeyhoLogo extends StatelessWidget {
  final double fontSize;

  const VeyhoLogo({super.key, this.fontSize = 48.0});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: fontSize * 1.5,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                'vey',
                style: TextStyle(
                  color: const Color(0xFF0A1D6E),
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Inter',
                ),
              ),
              Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  Text(
                    'h',
                    style: TextStyle(
                      color: const Color(0xFF1D70B8),
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Inter',
                    ),
                  ),
                  // Curving swoosh arrow positioned above 'h'
                  Positioned(
                    top: -fontSize * 0.45,
                    left: fontSize * 0.05,
                    child: CustomPaint(
                      size: Size(fontSize * 0.7, fontSize * 0.7),
                      painter: SwooshPainter(),
                    ),
                  ),
                ],
              ),
              Text(
                'o',
                style: TextStyle(
                  color: const Color(0xFF1D70B8),
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SwooshPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // Draw dark fold shadow
    final Paint shadowPaint = Paint()
      ..color = const Color(0xFF0A8276)
      ..style = PaintingStyle.fill;
    final Path shadowPath = Path()
      ..moveTo(w * 0.1, h * 0.8)
      ..lineTo(w * 0.2, h * 0.8)
      ..lineTo(w * 0.1, h * 0.7)
      ..close();
    canvas.drawPath(shadowPath, shadowPaint);

    // Draw the main swoosh gradient
    final Paint swooshPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF3BE4C4), Color(0xFF1DBEE2)],
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.fill;

    final Path swooshPath = Path();
    swooshPath.moveTo(w * 0.1, h * 0.8);
    // Control points for the curve
    swooshPath.cubicTo(w * 0.25, h * 0.7, w * 0.48, h * 0.52, w * 0.7, h * 0.3);
    swooshPath.lineTo(w * 0.62, h * 0.22);
    swooshPath.lineTo(w * 0.92, h * 0.12); // Arrow tip
    swooshPath.lineTo(w * 0.82, h * 0.42);
    swooshPath.lineTo(w * 0.74, h * 0.34);
    swooshPath.cubicTo(w * 0.52, h * 0.56, w * 0.28, h * 0.72, w * 0.2, h * 0.8);
    swooshPath.close();

    canvas.drawPath(swooshPath, swooshPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
