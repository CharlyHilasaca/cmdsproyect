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

    final shadowPaint =
        Paint()
          ..color = Colors.black.withOpacity(0.1)
          ..style = PaintingStyle.fill;

    // Sombra base para realismo
    final shadowPath = Path();
    shadowPath.addOval(
      Rect.fromCenter(center: const Offset(5, 110), width: 180, height: 40),
    );
    canvas.drawPath(shadowPath, shadowPaint);

    // Cuerpo de la camiseta con forma más realista
    final bodyPath = Path();
    bodyPath.moveTo(-65, -85); // Hombro izquierdo
    bodyPath.quadraticBezierTo(-70, -90, -60, -95); // Cuello izquierdo
    bodyPath.lineTo(60, -95); // Cuello derecho
    bodyPath.quadraticBezierTo(70, -90, 65, -85); // Hombro derecho
    bodyPath.lineTo(85, -65); // Axila derecha
    bodyPath.lineTo(85, 100); // Cintura derecha
    bodyPath.quadraticBezierTo(80, 105, 75, 105); // Borde inferior derecho
    bodyPath.lineTo(-75, 105); // Borde inferior izquierdo
    bodyPath.quadraticBezierTo(-80, 105, -85, 100); // Borde inferior izquierdo
    bodyPath.lineTo(-85, -65); // Axila izquierda
    bodyPath.close();

    canvas.drawPath(bodyPath, paint);
    canvas.drawPath(bodyPath, outlinePaint);

    // Mangas con mejor forma
    final sleevePaint = Paint()..color = _getGarmentColor().withOpacity(0.85);

    // Manga izquierda con forma más natural
    final leftSleeve = Path();
    leftSleeve.moveTo(-85, -65);
    leftSleeve.quadraticBezierTo(-125, -45, -130, -10);
    leftSleeve.quadraticBezierTo(-125, 25, -115, 35);
    leftSleeve.quadraticBezierTo(-95, 40, -85, 35);
    leftSleeve.close();

    canvas.drawPath(leftSleeve, sleevePaint);
    canvas.drawPath(leftSleeve, outlinePaint);

    // Manga derecha
    final rightSleeve = Path();
    rightSleeve.moveTo(85, -65);
    rightSleeve.quadraticBezierTo(125, -45, 130, -10);
    rightSleeve.quadraticBezierTo(125, 25, 115, 35);
    rightSleeve.quadraticBezierTo(95, 40, 85, 35);
    rightSleeve.close();

    canvas.drawPath(rightSleeve, sleevePaint);
    canvas.drawPath(rightSleeve, outlinePaint);

    // Cuello más detallado
    final neckPaint = Paint()..color = _getGarmentColor().withOpacity(0.9);
    final neckPath = Path();
    neckPath.addOval(const Rect.fromLTWH(-30, -100, 60, 30));
    canvas.drawPath(neckPath, neckPaint);
    canvas.drawPath(neckPath, outlinePaint);

    // Costuras decorativas
    final seamPaint =
        Paint()
          ..color = Colors.black.withOpacity(0.2)
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke;

    // Costuras de los hombros
    canvas.drawLine(const Offset(-65, -85), const Offset(-85, -65), seamPaint);
    canvas.drawLine(const Offset(65, -85), const Offset(85, -65), seamPaint);

    // Etiqueta pequeña
    final labelPaint = Paint()..color = Colors.white.withOpacity(0.8);
    canvas.drawRect(const Rect.fromLTWH(-15, 80, 30, 15), labelPaint);
    canvas.drawRect(const Rect.fromLTWH(-15, 80, 30, 15), outlinePaint);

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

    final shadowPaint =
        Paint()
          ..color = Colors.black.withOpacity(0.1)
          ..style = PaintingStyle.fill;

    // Sombra base
    final shadowPath = Path();
    shadowPath.addOval(
      Rect.fromCenter(center: const Offset(5, 160), width: 140, height: 30),
    );
    canvas.drawPath(shadowPath, shadowPaint);

    // Cintura con forma más realista
    final waistPath = Path();
    waistPath.moveTo(-65, -55);
    waistPath.quadraticBezierTo(-70, -60, -65, -65); // Cintura izquierda
    waistPath.lineTo(65, -65); // Cintura derecha
    waistPath.quadraticBezierTo(70, -60, 65, -55); // Cintura derecha
    waistPath.lineTo(65, -20); // Cadera derecha
    waistPath.lineTo(-65, -20); // Cadera izquierda
    waistPath.close();

    canvas.drawPath(waistPath, paint);
    canvas.drawPath(waistPath, outlinePaint);

    // Pierna izquierda con forma más natural
    final leftLeg = Path();
    leftLeg.moveTo(-65, -20);
    leftLeg.lineTo(-30, -20);
    leftLeg.quadraticBezierTo(-25, 50, -30, 100); // Muslo
    leftLeg.quadraticBezierTo(-28, 130, -32, 150); // Pantorrilla
    leftLeg.lineTo(-58, 150); // Tobillo izquierdo
    leftLeg.quadraticBezierTo(-62, 130, -60, 100); // Pantorrilla exterior
    leftLeg.quadraticBezierTo(-65, 50, -65, -20); // Muslo exterior
    leftLeg.close();

    canvas.drawPath(leftLeg, paint);
    canvas.drawPath(leftLeg, outlinePaint);

    // Pierna derecha
    final rightLeg = Path();
    rightLeg.moveTo(30, -20);
    rightLeg.lineTo(65, -20);
    rightLeg.quadraticBezierTo(65, 50, 60, 100);
    rightLeg.quadraticBezierTo(62, 130, 58, 150);
    rightLeg.lineTo(32, 150);
    rightLeg.quadraticBezierTo(28, 130, 30, 100);
    rightLeg.quadraticBezierTo(25, 50, 30, -20);
    rightLeg.close();

    canvas.drawPath(rightLeg, paint);
    canvas.drawPath(rightLeg, outlinePaint);

    // Costuras decorativas
    final seamPaint =
        Paint()
          ..color = Colors.black.withOpacity(0.2)
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke;

    // Costura interna piernas
    canvas.drawLine(const Offset(-30, -20), const Offset(-32, 150), seamPaint);
    canvas.drawLine(const Offset(30, -20), const Offset(32, 150), seamPaint);

    // Bolsillos frontales
    final pocketPaint = Paint()..color = _getGarmentColor().withOpacity(0.8);

    // Bolsillo izquierdo
    final leftPocket = Path();
    leftPocket.addRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-55, -10, 15, 20),
        const Radius.circular(3),
      ),
    );
    canvas.drawPath(leftPocket, pocketPaint);
    canvas.drawPath(leftPocket, outlinePaint);

    // Bolsillo derecho
    final rightPocket = Path();
    rightPocket.addRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(40, -10, 15, 20),
        const Radius.circular(3),
      ),
    );
    canvas.drawPath(rightPocket, pocketPaint);
    canvas.drawPath(rightPocket, outlinePaint);

    // Cremallera o botón
    final zipperPaint =
        Paint()
          ..color = Colors.grey[600]!
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

    canvas.drawLine(const Offset(0, -50), const Offset(0, -25), zipperPaint);

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

    final shadowPaint =
        Paint()
          ..color = Colors.black.withOpacity(0.1)
          ..style = PaintingStyle.fill;

    // Sombra base
    final shadowPath = Path();
    shadowPath.addOval(
      Rect.fromCenter(center: const Offset(5, 150), width: 220, height: 40),
    );
    canvas.drawPath(shadowPath, shadowPaint);

    // Parte superior del vestido con forma más elegante
    final topPath = Path();
    topPath.moveTo(-45, -85); // Hombro izquierdo
    topPath.quadraticBezierTo(-50, -90, -40, -95); // Cuello izquierdo
    topPath.lineTo(40, -95); // Cuello derecho
    topPath.quadraticBezierTo(50, -90, 45, -85); // Hombro derecho
    topPath.lineTo(55, -65); // Axila derecha
    topPath.quadraticBezierTo(60, 0, 65, 25); // Cintura derecha
    topPath.lineTo(-65, 25); // Cintura izquierda
    topPath.quadraticBezierTo(-60, 0, -55, -65); // Axila izquierda
    topPath.close();

    canvas.drawPath(topPath, paint);
    canvas.drawPath(topPath, outlinePaint);

    // Falda del vestido con forma más fluida y elegante
    final skirtPath = Path();
    skirtPath.moveTo(-65, 25);
    skirtPath.lineTo(65, 25);
    skirtPath.quadraticBezierTo(90, 60, 105, 100); // Lado derecho con curva
    skirtPath.quadraticBezierTo(110, 120, 105, 145); // Borde inferior derecho
    skirtPath.lineTo(-105, 145); // Borde inferior izquierdo
    skirtPath.quadraticBezierTo(
      -110,
      120,
      -105,
      100,
    ); // Borde inferior izquierdo con curva
    skirtPath.quadraticBezierTo(-90, 60, -65, 25); // Lado izquierdo con curva
    skirtPath.close();

    canvas.drawPath(skirtPath, paint);
    canvas.drawPath(skirtPath, outlinePaint);

    // Tirantes más delicados
    final strapPaint =
        Paint()
          ..color = _getGarmentColor().withOpacity(0.9)
          ..strokeWidth = 6
          ..style = PaintingStyle.stroke;

    canvas.drawLine(const Offset(-35, -85), const Offset(-35, -65), strapPaint);
    canvas.drawLine(const Offset(35, -85), const Offset(35, -65), strapPaint);

    // Detalles decorativos del vestido
    final decorPaint =
        Paint()
          ..color = Colors.white.withOpacity(0.6)
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke;

    // Línea decorativa en la cintura
    canvas.drawLine(const Offset(-65, 25), const Offset(65, 25), decorPaint);

    // Pequeños detalles florales o de encaje
    for (int i = 0; i < 5; i++) {
      final x = -40 + (i * 20.0);
      canvas.drawCircle(Offset(x, 30 + (i % 2) * 5), 2, decorPaint);
    }

    // Cuello más detallado
    final neckPaint = Paint()..color = _getGarmentColor().withOpacity(0.9);

    final neckPath = Path();
    neckPath.addOval(const Rect.fromLTWH(-25, -100, 50, 25));
    canvas.drawPath(neckPath, neckPaint);
    canvas.drawPath(neckPath, outlinePaint);

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

    final shadowPaint =
        Paint()
          ..color = Colors.black.withOpacity(0.15)
          ..style = PaintingStyle.fill;

    // Sombras de los zapatos
    canvas.drawOval(const Rect.fromLTWH(-85, 60, 70, 15), shadowPaint);
    canvas.drawOval(const Rect.fromLTWH(15, 60, 70, 15), shadowPaint);

    // Zapato izquierdo con forma más realista
    final leftShoe = Path();
    leftShoe.moveTo(-85, 35); // Talón
    leftShoe.quadraticBezierTo(-90, 30, -85, 25); // Parte superior del talón
    leftShoe.quadraticBezierTo(-75, 20, -50, 18); // Empeine
    leftShoe.quadraticBezierTo(-25, 20, -15, 25); // Punta
    leftShoe.quadraticBezierTo(-10, 30, -15, 35); // Borde inferior punta
    leftShoe.quadraticBezierTo(-25, 45, -50, 48); // Suela central
    leftShoe.quadraticBezierTo(-75, 45, -85, 35); // Suela talón
    leftShoe.close();

    canvas.drawPath(leftShoe, paint);
    canvas.drawPath(leftShoe, outlinePaint);

    // Zapato derecho
    final rightShoe = Path();
    rightShoe.moveTo(85, 35);
    rightShoe.quadraticBezierTo(90, 30, 85, 25);
    rightShoe.quadraticBezierTo(75, 20, 50, 18);
    rightShoe.quadraticBezierTo(25, 20, 15, 25);
    rightShoe.quadraticBezierTo(10, 30, 15, 35);
    rightShoe.quadraticBezierTo(25, 45, 50, 48);
    rightShoe.quadraticBezierTo(75, 45, 85, 35);
    rightShoe.close();

    canvas.drawPath(rightShoe, paint);
    canvas.drawPath(rightShoe, outlinePaint);

    // Suelas con color diferente
    final solePaint = Paint()..color = Colors.brown.withOpacity(0.8);

    // Suela izquierda
    final leftSole = Path();
    leftSole.addOval(const Rect.fromLTWH(-85, 40, 70, 20));
    canvas.drawPath(leftSole, solePaint);
    canvas.drawPath(leftSole, outlinePaint);

    // Suela derecha
    final rightSole = Path();
    rightSole.addOval(const Rect.fromLTWH(15, 40, 70, 20));
    canvas.drawPath(rightSole, solePaint);
    canvas.drawPath(rightSole, outlinePaint);

    // Cordones más detallados
    final lacePaint =
        Paint()
          ..color = Colors.white
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke;

    // Ojales y cordones zapato izquierdo
    for (int i = 0; i < 4; i++) {
      final y = 25.0 + (i * 3);
      // Ojales
      canvas.drawCircle(
        Offset(-65 + (i * 5), y),
        1.5,
        Paint()..color = Colors.black87,
      );
      canvas.drawCircle(
        Offset(-45 + (i * 5), y),
        1.5,
        Paint()..color = Colors.black87,
      );

      // Cordones cruzados
      canvas.drawLine(
        Offset(-65 + (i * 5), y),
        Offset(-45 + ((i + 1) * 5), y + 3),
        lacePaint,
      );
    }

    // Cordones zapato derecho
    for (int i = 0; i < 4; i++) {
      final y = 25.0 + (i * 3);
      canvas.drawCircle(
        Offset(35 + (i * 5), y),
        1.5,
        Paint()..color = Colors.black87,
      );
      canvas.drawCircle(
        Offset(55 + (i * 5), y),
        1.5,
        Paint()..color = Colors.black87,
      );

      canvas.drawLine(
        Offset(35 + (i * 5), y),
        Offset(55 + ((i + 1) * 5), y + 3),
        lacePaint,
      );
    }

    // Logo o marca en el zapato
    final logoPaint = Paint()..color = Colors.white.withOpacity(0.7);

    canvas.drawOval(const Rect.fromLTWH(-70, 28, 8, 4), logoPaint);
    canvas.drawOval(const Rect.fromLTWH(40, 28, 8, 4), logoPaint);
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
