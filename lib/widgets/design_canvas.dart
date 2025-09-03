import 'package:flutter/material.dart';
import 'dart:math' as math;

class DesignCanvas extends StatefulWidget {
  final String garmentType;
  final Map<String, dynamic> design;
  final VoidCallback? onDesignChange;

  const DesignCanvas({
    super.key,
    required this.garmentType,
    required this.design,
    this.onDesignChange,
  });

  @override
  State<DesignCanvas> createState() => _DesignCanvasState();
}

class _DesignCanvasState extends State<DesignCanvas>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;
  double _rotationY = 0.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          // Fondo con gradiente
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.grey.shade100, Colors.grey.shade200],
              ),
            ),
          ),

          // Canvas principal con el diseño 3D
          Center(
            child: AnimatedBuilder(
              animation: _rotationAnimation,
              builder: (context, child) {
                return Transform(
                  alignment: Alignment.center,
                  transform:
                      Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateY(_rotationY + _rotationAnimation.value * 0.1),
                  child: CustomPaint(
                    size: const Size(300, 400),
                    painter: GarmentPainter(
                      garmentType: widget.garmentType,
                      design: widget.design,
                    ),
                  ),
                );
              },
            ),
          ),

          // Controles de rotación
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton.small(
                  onPressed: () {
                    setState(() {
                      _rotationY -= 0.2;
                    });
                  },
                  heroTag: "rotate_left",
                  child: const Icon(Icons.rotate_left),
                ),
                const SizedBox(width: 16),
                FloatingActionButton.small(
                  onPressed: () {
                    setState(() {
                      _rotationY += 0.2;
                    });
                  },
                  heroTag: "rotate_right",
                  child: const Icon(Icons.rotate_right),
                ),
              ],
            ),
          ),

          // Información del diseño
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.design['name'] ?? 'Diseño sin nombre',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GarmentPainter extends CustomPainter {
  final String garmentType;
  final Map<String, dynamic> design;

  GarmentPainter({required this.garmentType, required this.design});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..style = PaintingStyle.fill
          ..strokeWidth = 2.0;

    // Obtener colores del diseño
    final primaryColor = Color(
      design['colors']?['primary'] ?? Colors.blue.value,
    );
    final secondaryColor = Color(
      design['colors']?['secondary'] ?? Colors.white.value,
    );

    // Dibujar según el tipo de prenda
    switch (garmentType) {
      case 'tshirt':
        _drawTShirt(canvas, size, paint, primaryColor, secondaryColor);
        break;
      case 'hoodie':
        _drawHoodie(canvas, size, paint, primaryColor, secondaryColor);
        break;
      case 'pants':
        _drawPants(canvas, size, paint, primaryColor, secondaryColor);
        break;
      case 'dress':
        _drawDress(canvas, size, paint, primaryColor, secondaryColor);
        break;
      case 'jacket':
        _drawJacket(canvas, size, paint, primaryColor, secondaryColor);
        break;
      case 'shoes':
        _drawShoes(canvas, size, paint, primaryColor, secondaryColor);
        break;
      default:
        _drawTShirt(canvas, size, paint, primaryColor, secondaryColor);
    }

    // Dibujar patrón si no es sólido
    if (design['pattern'] != 'solid') {
      _drawPattern(canvas, size, design['pattern'], secondaryColor);
    }
  }

  void _drawTShirt(
    Canvas canvas,
    Size size,
    Paint paint,
    Color primary,
    Color secondary,
  ) {
    paint.color = primary;

    // Cuerpo de la camiseta
    final bodyPath = Path();
    bodyPath.moveTo(size.width * 0.3, size.height * 0.3);
    bodyPath.lineTo(size.width * 0.7, size.height * 0.3);
    bodyPath.lineTo(size.width * 0.75, size.height * 0.8);
    bodyPath.lineTo(size.width * 0.25, size.height * 0.8);
    bodyPath.close();

    canvas.drawPath(bodyPath, paint);

    // Mangas
    final leftSleeve = Path();
    leftSleeve.moveTo(size.width * 0.2, size.height * 0.25);
    leftSleeve.lineTo(size.width * 0.35, size.height * 0.3);
    leftSleeve.lineTo(size.width * 0.32, size.height * 0.45);
    leftSleeve.lineTo(size.width * 0.15, size.height * 0.4);
    leftSleeve.close();

    final rightSleeve = Path();
    rightSleeve.moveTo(size.width * 0.8, size.height * 0.25);
    rightSleeve.lineTo(size.width * 0.65, size.height * 0.3);
    rightSleeve.lineTo(size.width * 0.68, size.height * 0.45);
    rightSleeve.lineTo(size.width * 0.85, size.height * 0.4);
    rightSleeve.close();

    canvas.drawPath(leftSleeve, paint);
    canvas.drawPath(rightSleeve, paint);

    // Cuello
    paint.color = secondary;
    final neckRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.45,
        size.height * 0.2,
        size.width * 0.1,
        size.height * 0.15,
      ),
      const Radius.circular(8),
    );
    canvas.drawRRect(neckRect, paint);

    // Bordes
    paint.color = Colors.black;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2;
    canvas.drawPath(bodyPath, paint);
    canvas.drawPath(leftSleeve, paint);
    canvas.drawPath(rightSleeve, paint);
    canvas.drawRRect(neckRect, paint);
  }

  void _drawHoodie(
    Canvas canvas,
    Size size,
    Paint paint,
    Color primary,
    Color secondary,
  ) {
    paint.color = primary;
    paint.style = PaintingStyle.fill;

    // Cuerpo del hoodie (más amplio que camiseta)
    final bodyPath = Path();
    bodyPath.moveTo(size.width * 0.25, size.height * 0.3);
    bodyPath.lineTo(size.width * 0.75, size.height * 0.3);
    bodyPath.lineTo(size.width * 0.8, size.height * 0.85);
    bodyPath.lineTo(size.width * 0.2, size.height * 0.85);
    bodyPath.close();

    canvas.drawPath(bodyPath, paint);

    // Capucha
    final hoodPath = Path();
    hoodPath.moveTo(size.width * 0.3, size.height * 0.1);
    hoodPath.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.05,
      size.width * 0.7,
      size.height * 0.1,
    );
    hoodPath.lineTo(size.width * 0.65, size.height * 0.3);
    hoodPath.lineTo(size.width * 0.35, size.height * 0.3);
    hoodPath.close();

    canvas.drawPath(hoodPath, paint);

    // Mangas largas
    final leftSleeve = Path();
    leftSleeve.moveTo(size.width * 0.15, size.height * 0.25);
    leftSleeve.lineTo(size.width * 0.3, size.height * 0.3);
    leftSleeve.lineTo(size.width * 0.28, size.height * 0.75);
    leftSleeve.lineTo(size.width * 0.1, size.height * 0.7);
    leftSleeve.close();

    final rightSleeve = Path();
    rightSleeve.moveTo(size.width * 0.85, size.height * 0.25);
    rightSleeve.lineTo(size.width * 0.7, size.height * 0.3);
    rightSleeve.lineTo(size.width * 0.72, size.height * 0.75);
    rightSleeve.lineTo(size.width * 0.9, size.height * 0.7);
    rightSleeve.close();

    canvas.drawPath(leftSleeve, paint);
    canvas.drawPath(rightSleeve, paint);

    // Bolsillo frontal
    paint.color = secondary;
    final pocketRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.35,
        size.height * 0.45,
        size.width * 0.3,
        size.height * 0.2,
      ),
      const Radius.circular(8),
    );
    canvas.drawRRect(pocketRect, paint);

    // Bordes
    paint.color = Colors.black;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2;
    canvas.drawPath(bodyPath, paint);
    canvas.drawPath(hoodPath, paint);
    canvas.drawPath(leftSleeve, paint);
    canvas.drawPath(rightSleeve, paint);
    canvas.drawRRect(pocketRect, paint);
  }

  void _drawPants(
    Canvas canvas,
    Size size,
    Paint paint,
    Color primary,
    Color secondary,
  ) {
    paint.color = primary;
    paint.style = PaintingStyle.fill;

    // Cintura
    final waistRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.3,
        size.height * 0.2,
        size.width * 0.4,
        size.height * 0.1,
      ),
      const Radius.circular(4),
    );
    canvas.drawRRect(waistRect, paint);

    // Pierna izquierda
    final leftLeg = Path();
    leftLeg.moveTo(size.width * 0.32, size.height * 0.3);
    leftLeg.lineTo(size.width * 0.48, size.height * 0.3);
    leftLeg.lineTo(size.width * 0.45, size.height * 0.85);
    leftLeg.lineTo(size.width * 0.35, size.height * 0.85);
    leftLeg.close();

    // Pierna derecha
    final rightLeg = Path();
    rightLeg.moveTo(size.width * 0.52, size.height * 0.3);
    rightLeg.lineTo(size.width * 0.68, size.height * 0.3);
    rightLeg.lineTo(size.width * 0.65, size.height * 0.85);
    rightLeg.lineTo(size.width * 0.55, size.height * 0.85);
    rightLeg.close();

    canvas.drawPath(leftLeg, paint);
    canvas.drawPath(rightLeg, paint);

    // Bolsillos
    paint.color = secondary;
    final leftPocketRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.34,
        size.height * 0.35,
        size.width * 0.08,
        size.height * 0.08,
      ),
      const Radius.circular(4),
    );
    final rightPocketRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.58,
        size.height * 0.35,
        size.width * 0.08,
        size.height * 0.08,
      ),
      const Radius.circular(4),
    );

    canvas.drawRRect(leftPocketRect, paint);
    canvas.drawRRect(rightPocketRect, paint);

    // Bordes
    paint.color = Colors.black;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2;
    canvas.drawRRect(waistRect, paint);
    canvas.drawPath(leftLeg, paint);
    canvas.drawPath(rightLeg, paint);
    canvas.drawRRect(leftPocketRect, paint);
    canvas.drawRRect(rightPocketRect, paint);
  }

  void _drawDress(
    Canvas canvas,
    Size size,
    Paint paint,
    Color primary,
    Color secondary,
  ) {
    paint.color = primary;
    paint.style = PaintingStyle.fill;

    // Cuerpo del vestido (forma A)
    final dressPath = Path();
    dressPath.moveTo(size.width * 0.35, size.height * 0.3);
    dressPath.lineTo(size.width * 0.65, size.height * 0.3);
    dressPath.lineTo(size.width * 0.8, size.height * 0.8);
    dressPath.lineTo(size.width * 0.2, size.height * 0.8);
    dressPath.close();

    canvas.drawPath(dressPath, paint);

    // Mangas cortas
    final leftSleeve = Path();
    leftSleeve.moveTo(size.width * 0.25, size.height * 0.25);
    leftSleeve.lineTo(size.width * 0.4, size.height * 0.3);
    leftSleeve.lineTo(size.width * 0.38, size.height * 0.4);
    leftSleeve.lineTo(size.width * 0.2, size.height * 0.35);
    leftSleeve.close();

    final rightSleeve = Path();
    rightSleeve.moveTo(size.width * 0.75, size.height * 0.25);
    rightSleeve.lineTo(size.width * 0.6, size.height * 0.3);
    rightSleeve.lineTo(size.width * 0.62, size.height * 0.4);
    rightSleeve.lineTo(size.width * 0.8, size.height * 0.35);
    rightSleeve.close();

    canvas.drawPath(leftSleeve, paint);
    canvas.drawPath(rightSleeve, paint);

    // Cuello
    paint.color = secondary;
    final neckPath = Path();
    neckPath.moveTo(size.width * 0.42, size.height * 0.2);
    neckPath.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.15,
      size.width * 0.58,
      size.height * 0.2,
    );
    neckPath.lineTo(size.width * 0.55, size.height * 0.3);
    neckPath.lineTo(size.width * 0.45, size.height * 0.3);
    neckPath.close();

    canvas.drawPath(neckPath, paint);

    // Bordes decorativos
    paint.color = Colors.black;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2;
    canvas.drawPath(dressPath, paint);
    canvas.drawPath(leftSleeve, paint);
    canvas.drawPath(rightSleeve, paint);
    canvas.drawPath(neckPath, paint);

    // Detalles decorativos
    paint.strokeWidth = 1;
    for (int i = 0; i < 3; i++) {
      final y = size.height * (0.5 + i * 0.08);
      canvas.drawLine(
        Offset(size.width * 0.25, y),
        Offset(size.width * 0.75, y),
        paint,
      );
    }
  }

  void _drawJacket(
    Canvas canvas,
    Size size,
    Paint paint,
    Color primary,
    Color secondary,
  ) {
    // Similar a hoodie pero con detalles de chaqueta
    _drawHoodie(canvas, size, paint, primary, secondary);

    // Agregar zipper
    paint.color = Colors.grey;
    paint.style = PaintingStyle.fill;
    final zipperRect = Rect.fromLTWH(
      size.width * 0.48,
      size.height * 0.3,
      size.width * 0.04,
      size.height * 0.5,
    );
    canvas.drawRect(zipperRect, paint);

    // Bordes del zipper
    paint.color = Colors.black;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1;
    canvas.drawRect(zipperRect, paint);
  }

  void _drawShoes(
    Canvas canvas,
    Size size,
    Paint paint,
    Color primary,
    Color secondary,
  ) {
    paint.color = primary;
    paint.style = PaintingStyle.fill;

    // Zapato izquierdo
    final leftShoe = Path();
    leftShoe.moveTo(size.width * 0.2, size.height * 0.5);
    leftShoe.quadraticBezierTo(
      size.width * 0.1,
      size.height * 0.6,
      size.width * 0.15,
      size.height * 0.7,
    );
    leftShoe.lineTo(size.width * 0.4, size.height * 0.7);
    leftShoe.quadraticBezierTo(
      size.width * 0.45,
      size.height * 0.6,
      size.width * 0.4,
      size.height * 0.5,
    );
    leftShoe.close();

    // Zapato derecho
    final rightShoe = Path();
    rightShoe.moveTo(size.width * 0.6, size.height * 0.5);
    rightShoe.quadraticBezierTo(
      size.width * 0.55,
      size.height * 0.6,
      size.width * 0.6,
      size.height * 0.7,
    );
    rightShoe.lineTo(size.width * 0.85, size.height * 0.7);
    rightShoe.quadraticBezierTo(
      size.width * 0.9,
      size.height * 0.6,
      size.width * 0.8,
      size.height * 0.5,
    );
    rightShoe.close();

    canvas.drawPath(leftShoe, paint);
    canvas.drawPath(rightShoe, paint);

    // Suelas
    paint.color = secondary;
    final leftSole = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.12,
        size.height * 0.68,
        size.width * 0.32,
        size.height * 0.08,
      ),
      const Radius.circular(4),
    );
    final rightSole = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.56,
        size.height * 0.68,
        size.width * 0.32,
        size.height * 0.08,
      ),
      const Radius.circular(4),
    );

    canvas.drawRRect(leftSole, paint);
    canvas.drawRRect(rightSole, paint);

    // Bordes
    paint.color = Colors.black;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2;
    canvas.drawPath(leftShoe, paint);
    canvas.drawPath(rightShoe, paint);
    canvas.drawRRect(leftSole, paint);
    canvas.drawRRect(rightSole, paint);
  }

  void _drawPattern(Canvas canvas, Size size, String pattern, Color color) {
    final paint =
        Paint()
          ..color = color.withOpacity(0.3)
          ..style = PaintingStyle.fill;

    switch (pattern) {
      case 'stripes':
        for (int i = 0; i < 10; i++) {
          final y = size.height * 0.3 + (size.height * 0.5 / 10) * i;
          canvas.drawRect(
            Rect.fromLTWH(
              size.width * 0.3,
              y,
              size.width * 0.4,
              size.height * 0.02,
            ),
            paint,
          );
        }
        break;
      case 'dots':
        for (int i = 0; i < 5; i++) {
          for (int j = 0; j < 4; j++) {
            final x = size.width * 0.35 + (size.width * 0.3 / 5) * i;
            final y = size.height * 0.35 + (size.height * 0.4 / 4) * j;
            canvas.drawCircle(Offset(x, y), 4, paint);
          }
        }
        break;
      case 'checkered':
        for (int i = 0; i < 8; i++) {
          for (int j = 0; j < 6; j++) {
            if ((i + j) % 2 == 0) {
              final x = size.width * 0.3 + (size.width * 0.4 / 8) * i;
              final y = size.height * 0.3 + (size.height * 0.5 / 6) * j;
              canvas.drawRect(
                Rect.fromLTWH(
                  x,
                  y,
                  size.width * 0.4 / 8,
                  size.height * 0.5 / 6,
                ),
                paint,
              );
            }
          }
        }
        break;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
