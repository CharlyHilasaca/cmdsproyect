import 'package:flutter/material.dart';
import 'dart:math' as math;

class Advanced3DViewer extends StatefulWidget {
  final Map<String, dynamic> design;
  final Function(Map<String, dynamic>)? onDesignChanged;

  const Advanced3DViewer({
    super.key,
    required this.design,
    this.onDesignChanged,
  });

  @override
  State<Advanced3DViewer> createState() => _Advanced3DViewerState();
}

class _Advanced3DViewerState extends State<Advanced3DViewer>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  double _rotationX = 0.0;
  double _rotationY = 0.0;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF5F5F5), Color(0xFFE0E0E0)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            _rotationY += details.delta.dx * 0.01;
            _rotationX -= details.delta.dy * 0.01;
            _rotationX = _rotationX.clamp(-math.pi / 4, math.pi / 4);
          });
        },
        child: CustomPaint(
          painter: _GarmentPainter(
            design: widget.design,
            rotationX: _rotationX,
            rotationY: _rotationY,
            animation: _rotationController,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _GarmentPainter extends CustomPainter {
  final Map<String, dynamic> design;
  final double rotationX;
  final double rotationY;
  final Animation<double> animation;

  _GarmentPainter({
    required this.design,
    required this.rotationX,
    required this.rotationY,
    required this.animation,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Configurar matriz de transformación 3D
    canvas.save();
    canvas.translate(center.dx, center.dy);

    // Aplicar rotaciones
    final rotY = rotationY + (animation.value * 2 * math.pi);

    // Obtener tipo de prenda
    final garmentType = design['garment_type'] ?? 'camiseta';

    // Dibujar según el tipo
    switch (garmentType.toLowerCase()) {
      case 'camiseta':
      case 'shirt':
        _drawShirt3D(canvas, size, rotY);
        break;
      case 'pantalón':
      case 'pants':
        _drawPants3D(canvas, size, rotY);
        break;
      case 'vestido':
      case 'dress':
        _drawDress3D(canvas, size, rotY);
        break;
      case 'chaqueta':
      case 'jacket':
        _drawJacket3D(canvas, size, rotY);
        break;
      case 'falda':
      case 'skirt':
        _drawSkirt3D(canvas, size, rotY);
        break;
      case 'zapatos':
      case 'shoes':
        _drawShoes3D(canvas, size, rotY);
        break;
      default:
        _drawShirt3D(canvas, size, rotY);
    }

    canvas.restore();
  }

  void _drawShirt3D(Canvas canvas, Size size, double rotation) {
    final paint =
        Paint()
          ..color = _getGarmentColor()
          ..style = PaintingStyle.fill;

    final outlinePaint =
        Paint()
          ..color = Colors.black.withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

    // Cuerpo de la camiseta con efecto 3D
    final bodyPath = Path();

    // Frente de la camiseta
    bodyPath.moveTo(-60, -80);
    bodyPath.lineTo(60, -80);
    bodyPath.lineTo(80, -60);
    bodyPath.lineTo(80, 100);
    bodyPath.lineTo(-80, 100);
    bodyPath.lineTo(-80, -60);
    bodyPath.close();

    canvas.drawPath(bodyPath, paint);
    canvas.drawPath(bodyPath, outlinePaint);

    // Mangas
    final sleevePaint = Paint()..color = _getGarmentColor().withOpacity(0.8);

    // Manga izquierda
    final leftSleeve = Path();
    leftSleeve.moveTo(-80, -60);
    leftSleeve.lineTo(-120, -40);
    leftSleeve.lineTo(-110, 20);
    leftSleeve.lineTo(-80, 30);
    leftSleeve.close();

    canvas.drawPath(leftSleeve, sleevePaint);
    canvas.drawPath(leftSleeve, outlinePaint);

    // Manga derecha
    final rightSleeve = Path();
    rightSleeve.moveTo(80, -60);
    rightSleeve.lineTo(120, -40);
    rightSleeve.lineTo(110, 20);
    rightSleeve.lineTo(80, 30);
    rightSleeve.close();

    canvas.drawPath(rightSleeve, sleevePaint);
    canvas.drawPath(rightSleeve, outlinePaint);

    // Cuello
    final neckPaint = Paint()..color = _getGarmentColor().withOpacity(0.9);

    canvas.drawOval(const Rect.fromLTWH(-25, -85, 50, 25), neckPaint);
    canvas.drawOval(const Rect.fromLTWH(-25, -85, 50, 25), outlinePaint);

    // Detalles decorativos
    _drawPattern(canvas, bodyPath);
  }

  void _drawPants3D(Canvas canvas, Size size, double rotation) {
    final paint =
        Paint()
          ..color = _getGarmentColor()
          ..style = PaintingStyle.fill;

    final outlinePaint =
        Paint()
          ..color = Colors.black.withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

    // Cintura
    final waistPath = Path();
    waistPath.addRect(const Rect.fromLTWH(-60, -50, 120, 30));
    canvas.drawPath(waistPath, paint);
    canvas.drawPath(waistPath, outlinePaint);

    // Pierna izquierda
    final leftLeg = Path();
    leftLeg.moveTo(-60, -20);
    leftLeg.lineTo(-30, -20);
    leftLeg.lineTo(-25, 150);
    leftLeg.lineTo(-55, 150);
    leftLeg.close();

    canvas.drawPath(leftLeg, paint);
    canvas.drawPath(leftLeg, outlinePaint);

    // Pierna derecha
    final rightLeg = Path();
    rightLeg.moveTo(30, -20);
    rightLeg.lineTo(60, -20);
    rightLeg.lineTo(55, 150);
    rightLeg.lineTo(25, 150);
    rightLeg.close();

    canvas.drawPath(rightLeg, paint);
    canvas.drawPath(rightLeg, outlinePaint);

    _drawPattern(canvas, leftLeg);
  }

  void _drawDress3D(Canvas canvas, Size size, double rotation) {
    final paint =
        Paint()
          ..color = _getGarmentColor()
          ..style = PaintingStyle.fill;

    final outlinePaint =
        Paint()
          ..color = Colors.black.withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

    // Parte superior del vestido
    final topPath = Path();
    topPath.moveTo(-50, -80);
    topPath.lineTo(50, -80);
    topPath.lineTo(60, -60);
    topPath.lineTo(60, 20);
    topPath.lineTo(-60, 20);
    topPath.lineTo(-60, -60);
    topPath.close();

    canvas.drawPath(topPath, paint);
    canvas.drawPath(topPath, outlinePaint);

    // Falda del vestido (más amplia)
    final skirtPath = Path();
    skirtPath.moveTo(-60, 20);
    skirtPath.lineTo(60, 20);
    skirtPath.lineTo(100, 140);
    skirtPath.lineTo(-100, 140);
    skirtPath.close();

    canvas.drawPath(skirtPath, paint);
    canvas.drawPath(skirtPath, outlinePaint);

    // Tirantes
    final strapPaint =
        Paint()
          ..color = _getGarmentColor().withOpacity(0.9)
          ..strokeWidth = 8
          ..style = PaintingStyle.stroke;

    canvas.drawLine(const Offset(-40, -80), const Offset(-40, -60), strapPaint);
    canvas.drawLine(const Offset(40, -80), const Offset(40, -60), strapPaint);

    _drawPattern(canvas, skirtPath);
  }

  void _drawJacket3D(Canvas canvas, Size size, double rotation) {
    final paint =
        Paint()
          ..color = _getGarmentColor()
          ..style = PaintingStyle.fill;

    final outlinePaint =
        Paint()
          ..color = Colors.black.withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

    // Cuerpo de la chaqueta
    final bodyPath = Path();
    bodyPath.moveTo(-70, -90);
    bodyPath.lineTo(70, -90);
    bodyPath.lineTo(90, -70);
    bodyPath.lineTo(90, 80);
    bodyPath.lineTo(-90, 80);
    bodyPath.lineTo(-90, -70);
    bodyPath.close();

    canvas.drawPath(bodyPath, paint);
    canvas.drawPath(bodyPath, outlinePaint);

    // Solapas
    final lapalPaint = Paint()..color = _getGarmentColor().withOpacity(0.8);

    final leftLapal = Path();
    leftLapal.moveTo(-70, -70);
    leftLapal.lineTo(-30, -70);
    leftLapal.lineTo(-40, 20);
    leftLapal.lineTo(-70, 20);
    leftLapal.close();

    canvas.drawPath(leftLapal, lapalPaint);
    canvas.drawPath(leftLapal, outlinePaint);

    // Mangas largas
    final leftSleeve = Path();
    leftSleeve.moveTo(-90, -70);
    leftSleeve.lineTo(-140, -50);
    leftSleeve.lineTo(-130, 60);
    leftSleeve.lineTo(-90, 50);
    leftSleeve.close();

    canvas.drawPath(leftSleeve, paint);
    canvas.drawPath(leftSleeve, outlinePaint);

    final rightSleeve = Path();
    rightSleeve.moveTo(90, -70);
    rightSleeve.lineTo(140, -50);
    rightSleeve.lineTo(130, 60);
    rightSleeve.lineTo(90, 50);
    rightSleeve.close();

    canvas.drawPath(rightSleeve, paint);
    canvas.drawPath(rightSleeve, outlinePaint);

    // Botones
    final buttonPaint =
        Paint()
          ..color = Colors.black87
          ..style = PaintingStyle.fill;

    for (int i = 0; i < 4; i++) {
      canvas.drawCircle(Offset(0, -40 + (i * 25)), 4, buttonPaint);
    }

    _drawPattern(canvas, bodyPath);
  }

  void _drawSkirt3D(Canvas canvas, Size size, double rotation) {
    final paint =
        Paint()
          ..color = _getGarmentColor()
          ..style = PaintingStyle.fill;

    final outlinePaint =
        Paint()
          ..color = Colors.black.withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

    // Cintura
    final waistPath = Path();
    waistPath.addRect(const Rect.fromLTWH(-50, -30, 100, 20));
    canvas.drawPath(waistPath, paint);
    canvas.drawPath(waistPath, outlinePaint);

    // Falda
    final skirtPath = Path();
    skirtPath.moveTo(-50, -10);
    skirtPath.lineTo(50, -10);
    skirtPath.lineTo(80, 100);
    skirtPath.lineTo(-80, 100);
    skirtPath.close();

    canvas.drawPath(skirtPath, paint);
    canvas.drawPath(skirtPath, outlinePaint);

    _drawPattern(canvas, skirtPath);
  }

  void _drawShoes3D(Canvas canvas, Size size, double rotation) {
    final paint =
        Paint()
          ..color = _getGarmentColor()
          ..style = PaintingStyle.fill;

    final outlinePaint =
        Paint()
          ..color = Colors.black.withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

    // Zapato izquierdo
    final leftShoe = Path();
    leftShoe.addOval(const Rect.fromLTWH(-80, 20, 60, 40));
    canvas.drawPath(leftShoe, paint);
    canvas.drawPath(leftShoe, outlinePaint);

    // Zapato derecho
    final rightShoe = Path();
    rightShoe.addOval(const Rect.fromLTWH(20, 20, 60, 40));
    canvas.drawPath(rightShoe, paint);
    canvas.drawPath(rightShoe, outlinePaint);

    // Cordones o detalles
    final detailPaint =
        Paint()
          ..color = Colors.black54
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

    // Cordones zapato izquierdo
    for (int i = 0; i < 3; i++) {
      canvas.drawLine(
        Offset(-70 + (i * 8), 30),
        Offset(-65 + (i * 8), 40),
        detailPaint,
      );
    }

    // Cordones zapato derecho
    for (int i = 0; i < 3; i++) {
      canvas.drawLine(
        Offset(30 + (i * 8), 30),
        Offset(35 + (i * 8), 40),
        detailPaint,
      );
    }
  }

  void _drawPattern(Canvas canvas, Path basePath) {
    final pattern = design['pattern'] ?? 'solid';
    final patternColor = _getGarmentColor().withOpacity(0.3);

    switch (pattern) {
      case 'stripes':
        _drawStripes(canvas, patternColor);
        break;
      case 'dots':
        _drawDots(canvas, patternColor);
        break;
      case 'checks':
        _drawChecks(canvas, patternColor);
        break;
      case 'floral':
        _drawFloral(canvas, patternColor);
        break;
    }
  }

  void _drawStripes(Canvas canvas, Color color) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = 4
          ..style = PaintingStyle.stroke;

    for (int i = -10; i <= 10; i++) {
      canvas.drawLine(Offset(-100, i * 15.0), Offset(100, i * 15.0), paint);
    }
  }

  void _drawDots(Canvas canvas, Color color) {
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill;

    for (int x = -8; x <= 8; x++) {
      for (int y = -8; y <= 8; y++) {
        if ((x + y) % 2 == 0) {
          canvas.drawCircle(Offset(x * 15.0, y * 15.0), 3, paint);
        }
      }
    }
  }

  void _drawChecks(Canvas canvas, Color color) {
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill;

    for (int x = -6; x <= 6; x++) {
      for (int y = -6; y <= 6; y++) {
        if ((x + y) % 2 == 0) {
          canvas.drawRect(Rect.fromLTWH(x * 20.0, y * 20.0, 20, 20), paint);
        }
      }
    }
  }

  void _drawFloral(Canvas canvas, Color color) {
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill;

    for (int x = -4; x <= 4; x++) {
      for (int y = -4; y <= 4; y++) {
        final center = Offset(x * 30.0, y * 30.0);

        // Flor simple
        for (int i = 0; i < 6; i++) {
          final angle = (i * math.pi * 2) / 6;
          final petalEnd = Offset(
            center.dx + math.cos(angle) * 8,
            center.dy + math.sin(angle) * 8,
          );
          canvas.drawCircle(petalEnd, 4, paint);
        }

        // Centro de la flor
        canvas.drawCircle(center, 3, Paint()..color = Colors.yellow);
      }
    }
  }

  Color _getGarmentColor() {
    final colors = design['colors'] as List?;
    if (colors != null && colors.isNotEmpty) {
      final colorValue = colors[0];
      if (colorValue is Color) {
        return colorValue;
      } else if (colorValue is int) {
        return Color(colorValue);
      } else if (colorValue is String) {
        // Si es un string hexadecimal
        try {
          return Color(int.parse(colorValue.replaceFirst('#', '0xff')));
        } catch (e) {
          return Colors.blue;
        }
      }
    }
    return Colors.blue; // Color por defecto
  }

  @override
  bool shouldRepaint(_GarmentPainter oldDelegate) {
    return oldDelegate.design != design ||
        oldDelegate.rotationX != rotationX ||
        oldDelegate.rotationY != rotationY;
  }
}
