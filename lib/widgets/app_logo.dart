import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool showText;

  const AppLogo({
    super.key,
    this.size = 72,
    this.showText = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomPaint(
          size: Size(size * 1.55, size * 0.92),
          painter: const _AppLogoPainter(),
        ),
        if (showText) ...[
          SizedBox(height: size * 0.08),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'CHILL ',
                  style: TextStyle(
                    color: const Color(0xFFFF7A00),
                    fontSize: size * 0.20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: size * 0.045,
                    height: 1,
                  ),
                ),
                TextSpan(
                  text: 'BITES',
                  style: TextStyle(
                    color: const Color(0xFF231F20),
                    fontSize: size * 0.20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: size * 0.045,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _AppLogoPainter extends CustomPainter {
  const _AppLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.14)
      ..maskFilter = MaskFilter.blur(
        BlurStyle.normal,
        w * 0.018,
      );

    final white = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final barHeight = h * 0.18;
    final radius = barHeight / 2;

    // =========================
    // SHADOW
    // =========================
    final shadowPath = Path()
      ..moveTo(w * 0.18, h * 0.20)
      ..lineTo(w * 0.62, h * 0.20)
      ..quadraticBezierTo(w * 0.82, h * 0.20, w * 0.82, h * 0.40)
      ..quadraticBezierTo(w * 0.82, h * 0.50, w * 0.72, h * 0.55)
      ..quadraticBezierTo(w * 0.84, h * 0.59, w * 0.84, h * 0.73)
      ..quadraticBezierTo(w * 0.84, h * 0.92, w * 0.62, h * 0.92)
      ..lineTo(w * 0.42, h * 0.92)
      ..lineTo(w * 0.42, h * 0.75)
      ..lineTo(w * 0.60, h * 0.75)
      ..quadraticBezierTo(w * 0.68, h * 0.75, w * 0.68, h * 0.68)
      ..quadraticBezierTo(w * 0.68, h * 0.61, w * 0.60, h * 0.61)
      ..lineTo(w * 0.35, h * 0.61)
      ..lineTo(w * 0.35, h * 0.92)
      ..lineTo(w * 0.18, h * 0.92)
      ..lineTo(w * 0.18, h * 0.50)
      ..lineTo(w * 0.44, h * 0.50)
      ..lineTo(w * 0.52, h * 0.34)
      ..lineTo(w * 0.28, h * 0.34)
      ..close();

    canvas.save();
    canvas.translate(w * 0.015, h * 0.02);
    canvas.drawPath(shadowPath, shadowPaint);
    canvas.restore();

    // =========================
    // PAINT HELPERS
    // =========================
    Paint metallicPaint({
      required Rect rect,
      required List<Color> colors,
    }) {
      return Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
          stops: const [0.0, 0.42, 0.72, 1.0],
        ).createShader(rect)
        ..style = PaintingStyle.fill;
    }

    void drawGloss(Path path, Rect rect, {double opacity = 0.25}) {
      final glossPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(opacity),
            Colors.white.withOpacity(opacity * 0.35),
            Colors.transparent,
          ],
        ).createShader(rect)
        ..style = PaintingStyle.fill;

      canvas.drawPath(path, glossPaint);
    }

    // =========================
    // F - FULL PATH BORDER
    // =========================
    final fFullPath = Path()
      ..moveTo(w * 0.18, h * 0.18)
      ..lineTo(w * 0.58, h * 0.18)
      ..lineTo(w * 0.48, h * 0.36)
      ..lineTo(w * 0.28, h * 0.36)
      ..lineTo(w * 0.28, h * 0.48)
      ..lineTo(w * 0.46, h * 0.48)
      ..lineTo(w * 0.37, h * 0.64)
      ..lineTo(w * 0.28, h * 0.64)
      ..lineTo(w * 0.28, h * 0.92)
      ..lineTo(w * 0.18, h * 0.92)
      ..lineTo(w * 0.18, h * 0.48)
      ..lineTo(w * 0.28, h * 0.48)
      ..lineTo(w * 0.28, h * 0.36)
      ..lineTo(w * 0.18, h * 0.36)
      ..close();

    final fOutlinePaint = Paint()
      ..color = const Color(0xFF231F20).withOpacity(0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.012
      ..strokeJoin = StrokeJoin.round;

    // =========================
    // F TẦNG 1 - CAM
    // =========================
    final topPath = Path()
      ..moveTo(w * 0.18, h * 0.18)
      ..lineTo(w * 0.58, h * 0.18)
      ..lineTo(w * 0.48, h * 0.36)
      ..lineTo(w * 0.28, h * 0.36)
      ..lineTo(w * 0.18, h * 0.36)
      ..close();

    final topRect = Rect.fromLTWH(w * 0.18, h * 0.18, w * 0.40, h * 0.18);

    canvas.drawPath(
      topPath,
      metallicPaint(
        rect: topRect,
        colors: const [
          Color(0xFFFFD08A),
          Color(0xFFFF8A00),
          Color(0xFFFF6A00),
          Color(0xFFC94C00),
        ],
      ),
    );

    // =========================
    // F TẦNG 2 - BẠC
    // =========================
    final silverPath = Path()
      ..moveTo(w * 0.18, h * 0.36)
      ..lineTo(w * 0.48, h * 0.36)
      ..lineTo(w * 0.41, h * 0.48)
      ..lineTo(w * 0.28, h * 0.48)
      ..lineTo(w * 0.18, h * 0.48)
      ..close();

    final silverRect = Rect.fromLTWH(w * 0.18, h * 0.36, w * 0.30, h * 0.12);

    canvas.drawPath(
      silverPath,
      metallicPaint(
        rect: silverRect,
        colors: const [
          Color(0xFFFFFFFF),
          Color(0xFFE5E7EB),
          Color(0xFFB7C0CC),
          Color(0xFF8E99A8),
        ],
      ),
    );

    // =========================
    // F TẦNG 3 - VÀNG
    // =========================
    final goldPath = Path()
      ..moveTo(w * 0.18, h * 0.48)
      ..lineTo(w * 0.46, h * 0.48)
      ..lineTo(w * 0.37, h * 0.64)
      ..lineTo(w * 0.28, h * 0.64)
      ..lineTo(w * 0.28, h * 0.70)
      ..lineTo(w * 0.18, h * 0.70)
      ..close();

    final goldRect = Rect.fromLTWH(w * 0.18, h * 0.48, w * 0.28, h * 0.22);

    canvas.drawPath(
      goldPath,
      metallicPaint(
        rect: goldRect,
        colors: const [
          Color(0xFFFFF4B0),
          Color(0xFFFFD54F),
          Color(0xFFFFB300),
          Color(0xFFC97A00),
        ],
      ),
    );

    // =========================
    // F TẦNG 4 - DIAMOND
    // =========================
    final diamondPath = Path()
      ..moveTo(w * 0.18, h * 0.70)
      ..lineTo(w * 0.28, h * 0.70)
      ..lineTo(w * 0.28, h * 0.92)
      ..lineTo(w * 0.18, h * 0.92)
      ..close();

    final diamondRect = Rect.fromLTWH(w * 0.18, h * 0.70, w * 0.10, h * 0.22);

    canvas.drawPath(
      diamondPath,
      metallicPaint(
        rect: diamondRect,
        colors: const [
          Color(0xFFD8F7FF),
          Color(0xFF7DD3FC),
          Color(0xFF38BDF8),
          Color(0xFF0369A1),
        ],
      ),
    );

    // =========================
    // F GLOSS
    // =========================
    drawGloss(
      Path()
        ..moveTo(w * 0.20, h * 0.205)
        ..lineTo(w * 0.50, h * 0.205)
        ..lineTo(w * 0.46, h * 0.265)
        ..lineTo(w * 0.22, h * 0.265)
        ..close(),
      topRect,
      opacity: 0.32,
    );

    drawGloss(
      Path()
        ..moveTo(w * 0.20, h * 0.505)
        ..lineTo(w * 0.39, h * 0.505)
        ..lineTo(w * 0.35, h * 0.565)
        ..lineTo(w * 0.20, h * 0.565)
        ..close(),
      goldRect,
      opacity: 0.22,
    );

    // Sparkle nhỏ ở tầng kim cương
    final sparklePaint = Paint()
      ..color = Colors.white.withOpacity(0.78)
      ..style = PaintingStyle.fill;

    final sparkle = Path()
      ..moveTo(w * 0.235, h * 0.775)
      ..lineTo(w * 0.252, h * 0.805)
      ..lineTo(w * 0.235, h * 0.835)
      ..lineTo(w * 0.218, h * 0.805)
      ..close();

    canvas.drawPath(sparkle, sparklePaint);

    canvas.drawPath(fFullPath, fOutlinePaint);

    // =========================
    // B - DARK METALLIC
    // =========================
    final bRect = Rect.fromLTWH(w * 0.43, h * 0.18, w * 0.48, h * 0.82);

    final bPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF3B3538),
          Color(0xFF231F20),
          Color(0xFF171415),
        ],
      ).createShader(bRect)
      ..style = PaintingStyle.fill;

    final bPath = Path()
      ..moveTo(w * 0.48, h * 0.18)
      ..lineTo(w * 0.64, h * 0.18)
      ..cubicTo(
        w * 0.80,
        h * 0.18,
        w * 0.88,
        h * 0.28,
        w * 0.88,
        h * 0.41,
      )
      ..cubicTo(
        w * 0.88,
        h * 0.50,
        w * 0.83,
        h * 0.56,
        w * 0.76,
        h * 0.59,
      )
      ..cubicTo(
        w * 0.86,
        h * 0.62,
        w * 0.91,
        h * 0.70,
        w * 0.91,
        h * 0.80,
      )
      ..cubicTo(
        w * 0.91,
        h * 0.93,
        w * 0.80,
        h * 1.00,
        w * 0.64,
        h * 1.00,
      )
      ..lineTo(w * 0.43, h * 1.00)
      ..lineTo(w * 0.53, h * 0.82)
      ..lineTo(w * 0.64, h * 0.82)
      ..cubicTo(
        w * 0.71,
        h * 0.82,
        w * 0.75,
        h * 0.78,
        w * 0.75,
        h * 0.72,
      )
      ..cubicTo(
        w * 0.75,
        h * 0.66,
        w * 0.71,
        h * 0.62,
        w * 0.64,
        h * 0.62,
      )
      ..lineTo(w * 0.50, h * 0.62)
      ..lineTo(w * 0.60, h * 0.44)
      ..lineTo(w * 0.64, h * 0.44)
      ..cubicTo(
        w * 0.71,
        h * 0.44,
        w * 0.75,
        h * 0.40,
        w * 0.75,
        h * 0.34,
      )
      ..cubicTo(
        w * 0.75,
        h * 0.28,
        w * 0.71,
        h * 0.25,
        w * 0.64,
        h * 0.25,
      )
      ..lineTo(w * 0.48, h * 0.25)
      ..close();

    canvas.drawPath(bPath, bPaint);

    // Gloss nhẹ cho B
    final bGlossPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.18),
          Colors.transparent,
        ],
      ).createShader(bRect)
      ..style = PaintingStyle.fill;

    final bGlossPath = Path()
      ..moveTo(w * 0.51, h * 0.205)
      ..lineTo(w * 0.69, h * 0.205)
      ..lineTo(w * 0.64, h * 0.275)
      ..lineTo(w * 0.51, h * 0.275)
      ..close();

    canvas.drawPath(bGlossPath, bGlossPaint);

    // White cuts inside B
    final topCut = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.40, h * 0.32, w * 0.34, barHeight),
      Radius.circular(radius),
    );

    final bottomCut = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.38, h * 0.63, w * 0.38, barHeight),
      Radius.circular(radius),
    );

    canvas.drawRRect(topCut, white);
    canvas.drawRRect(bottomCut, white);

    // Accent giữa dùng vàng kim nhẹ
    final accentPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFFFF4B0),
          Color(0xFFFFC93C),
          Color(0xFFE09A00),
        ],
      ).createShader(Rect.fromLTWH(w * 0.34, h * 0.50, w * 0.21, h * 0.16));

    final accentPath = Path()
      ..moveTo(w * 0.43, h * 0.50)
      ..lineTo(w * 0.55, h * 0.50)
      ..lineTo(w * 0.45, h * 0.66)
      ..lineTo(w * 0.34, h * 0.66)
      ..close();

    canvas.drawPath(accentPath, accentPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}