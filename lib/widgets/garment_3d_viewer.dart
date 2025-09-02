import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:model_viewer_plus/model_viewer_plus.dart';

/// Widget especializado para mostrar prendas en 3D
class Garment3DViewer extends StatefulWidget {
  final String garmentType;
  final Map<String, dynamic> designData;
  final Color primaryColor;
  final Color secondaryColor;
  final String? texture;
  final double width;
  final double height;
  final VoidCallback? onTap;

  const Garment3DViewer({
    Key? key,
    required this.garmentType,
    required this.designData,
    this.primaryColor = Colors.blue,
    this.secondaryColor = Colors.white,
    this.texture,
    this.width = 300,
    this.height = 300,
    this.onTap,
  }) : super(key: key);

  @override
  State<Garment3DViewer> createState() => _Garment3DViewerState();
}

class _Garment3DViewerState extends State<Garment3DViewer>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late Animation<double> _rotationAnimation;
  bool _isLoading = false;
  bool _use3DModel = false; // Toggle entre modelo 3D real y representación

  @override
  void initState() {
    super.initState();
    _setupAnimation();
  }

  void _setupAnimation() {
    _rotationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(begin: 0, end: 360).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );

    _rotationController.repeat();
  }

  bool _hasRealModel() {
    // Verificar si existe un modelo 3D real para este tipo de prenda
    const availableModels = ['camiseta', 'pantalon', 'vestido', 'chaqueta'];
    return availableModels.contains(widget.garmentType.toLowerCase());
  }

  bool _canUseModelViewer() {
    // ModelViewer funciona mejor en web y móviles
    if (kIsWeb) return true;

    try {
      if (Platform.isAndroid || Platform.isIOS) return true;
      // En desktop, solo usar si WebView está disponible
      return false;
    } catch (e) {
      // Si hay error detectando plataforma, usar modo simple
      return false;
    }
  }

  String _getModelPath() {
    // Rutas a modelos 3D reales según el tipo de prenda
    switch (widget.garmentType.toLowerCase()) {
      case 'camiseta':
        return 'https://modelviewer.dev/shared-assets/models/Astronaut.glb';
      case 'pantalon':
        return 'https://modelviewer.dev/shared-assets/models/RobotExpressive.glb';
      case 'vestido':
        return 'https://modelviewer.dev/shared-assets/models/Astronaut.glb';
      case 'chaqueta':
        return 'https://modelviewer.dev/shared-assets/models/RobotExpressive.glb';
      default:
        return 'https://modelviewer.dev/shared-assets/models/Astronaut.glb';
    }
  }

  Widget _buildSimple3DView() {
    return AnimatedBuilder(
      animation: _rotationAnimation,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.width, widget.height),
          painter: Garment3DPainter(
            garmentType: widget.garmentType,
            primaryColor: widget.primaryColor,
            secondaryColor: widget.secondaryColor,
            rotationAngle: _rotationAnimation.value,
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // Fondo degradado
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.grey[100]!, Colors.grey[200]!],
                ),
              ),
            ),

            // Visor 3D
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_use3DModel && _hasRealModel() && _canUseModelViewer())
              // Modelo 3D real usando ModelViewer
              ModelViewer(
                src: _getModelPath(),
                alt: 'Modelo 3D de ${widget.garmentType}',
                ar: false,
                autoRotate: true,
                cameraControls: true,
                backgroundColor: const Color(0x00000000),
                shadowIntensity: 0.3,
                cameraOrbit: '0deg 75deg 2.5m',
              )
            else
              // Representación 3D simple personalizada
              _buildSimple3DView(),

            // Controles superpuestos
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        _use3DModel ? Icons.view_in_ar : Icons.threed_rotation,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _use3DModel = !_use3DModel;
                        });
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        _rotationController.isAnimating
                            ? Icons.pause
                            : Icons.play_arrow,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () {
                        if (_rotationController.isAnimating) {
                          _rotationController.stop();
                        } else {
                          _rotationController.repeat();
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.info_outline,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () {
                        _showPlatformInfo();
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Información de la prenda
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.garmentType.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: widget.primaryColor,
                            borderRadius: BorderRadius.circular(2),
                            border: Border.all(color: Colors.white, width: 1),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: widget.secondaryColor,
                            borderRadius: BorderRadius.circular(2),
                            border: Border.all(color: Colors.white, width: 1),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _getPlatformDisplayText(),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Overlay para detectar taps
            if (widget.onTap != null)
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(onTap: widget.onTap, child: Container()),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getPlatformDisplayText() {
    if (!_use3DModel) return 'SIMPLE';

    if (kIsWeb) return 'WEB 3D';

    try {
      if (Platform.isAndroid) return 'ANDROID 3D';
      if (Platform.isIOS) return 'iOS 3D';
      if (Platform.isWindows) return 'WIN 3D';
      if (Platform.isMacOS) return 'MAC 3D';
      if (Platform.isLinux) return 'LINUX 3D';
    } catch (e) {
      // Error detectando plataforma
    }

    return '3D';
  }

  String _getPlatformCapabilities() {
    List<String> capabilities = [];

    capabilities.add('✅ Renderizado Simple');

    if (kIsWeb) {
      capabilities.add('✅ ModelViewer (WebGL)');
      capabilities.add('✅ Animaciones fluidas');
      capabilities.add('✅ Controles de cámara');
    } else {
      try {
        if (Platform.isAndroid || Platform.isIOS) {
          capabilities.add('✅ ModelViewer (Nativo)');
          capabilities.add('✅ Soporte AR');
          capabilities.add('✅ Controles táctiles');
        } else {
          capabilities.add('⚠️ ModelViewer (Limitado)');
          capabilities.add('✅ Controles básicos');
        }
      } catch (e) {
        capabilities.add('⚠️ Detección de plataforma falló');
      }
    }

    return capabilities.join('\n');
  }

  void _showPlatformInfo() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.info, color: widget.primaryColor),
              const SizedBox(width: 8),
              const Text('Información de Plataforma'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Plataforma Actual:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: widget.primaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(_getCurrentPlatformName()),
                const SizedBox(height: 16),
                Text(
                  'Capacidades 3D:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: widget.primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(_getPlatformCapabilities()),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '💡 Consejos:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '• En Web/móviles: Usa modelos 3D avanzados\n'
                        '• En Desktop: Usa renderizado simple\n'
                        '• Toca el botón 3D para cambiar de modo\n'
                        '• Usa pausa/play para controlar animación',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cerrar',
                style: TextStyle(color: widget.primaryColor),
              ),
            ),
          ],
        );
      },
    );
  }

  String _getCurrentPlatformName() {
    if (kIsWeb) return '🌐 Web Browser';

    try {
      if (Platform.isAndroid) return '📱 Android';
      if (Platform.isIOS) return '📱 iOS';
      if (Platform.isWindows) return '💻 Windows';
      if (Platform.isMacOS) return '💻 macOS';
      if (Platform.isLinux) return '💻 Linux';
    } catch (e) {
      return '❓ Plataforma desconocida';
    }

    return '❓ No detectada';
  }
}

/// Widget simplificado para vista previa rápida
class QuickGarment3DPreview extends StatelessWidget {
  final String garmentType;
  final Color primaryColor;
  final double size;

  const QuickGarment3DPreview({
    Key? key,
    required this.garmentType,
    required this.primaryColor,
    this.size = 80,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.grey[100]!, Colors.grey[200]!],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Center(
            child: Icon(
              _getGarmentIcon(),
              size: size * 0.5,
              color: primaryColor,
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(
                Icons.threed_rotation,
                color: Colors.white,
                size: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getGarmentIcon() {
    switch (garmentType.toLowerCase()) {
      case 'camiseta':
        return Icons.dry_cleaning;
      case 'pantalon':
        return Icons.directions_walk;
      case 'vestido':
        return Icons.woman;
      case 'chaqueta':
        return Icons.outdoor_grill;
      default:
        return Icons.checkroom;
    }
  }
}

/// Painter personalizado para renderizar prendas en 3D simple
class Garment3DPainter extends CustomPainter {
  final String garmentType;
  final Color primaryColor;
  final Color secondaryColor;
  final double rotationAngle;

  Garment3DPainter({
    required this.garmentType,
    required this.primaryColor,
    required this.secondaryColor,
    required this.rotationAngle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = primaryColor
          ..style = PaintingStyle.fill;

    final paintStroke =
        Paint()
          ..color = Colors.black26
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

    final center = Offset(size.width / 2, size.height / 2);

    // Aplicar rotación
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotationAngle * 3.14159 / 180);
    canvas.translate(-center.dx, -center.dy);

    switch (garmentType.toLowerCase()) {
      case 'camiseta':
        _drawTShirt(canvas, size, paint, paintStroke);
        break;
      case 'pantalon':
        _drawPants(canvas, size, paint, paintStroke);
        break;
      case 'vestido':
        _drawDress(canvas, size, paint, paintStroke);
        break;
      case 'chaqueta':
        _drawJacket(canvas, size, paint, paintStroke);
        break;
      default:
        _drawGenericGarment(canvas, size, paint, paintStroke);
    }

    canvas.restore();
  }

  void _drawTShirt(Canvas canvas, Size size, Paint paint, Paint paintStroke) {
    final path = Path();
    final center = Offset(size.width / 2, size.height / 2);

    // Cuerpo de la camiseta con perspectiva 3D
    path.moveTo(center.dx - 60, center.dy - 40);
    path.lineTo(center.dx + 60, center.dy - 40);
    path.lineTo(center.dx + 50, center.dy + 60);
    path.lineTo(center.dx - 50, center.dy + 60);
    path.close();

    // Sombra 3D
    final shadowPaint =
        Paint()
          ..color = primaryColor.withOpacity(0.3)
          ..style = PaintingStyle.fill;

    final shadowPath = Path();
    shadowPath.moveTo(center.dx - 55, center.dy - 35);
    shadowPath.lineTo(center.dx + 65, center.dy - 35);
    shadowPath.lineTo(center.dx + 55, center.dy + 65);
    shadowPath.lineTo(center.dx - 45, center.dy + 65);
    shadowPath.close();

    canvas.drawPath(shadowPath, shadowPaint);
    canvas.drawPath(path, paint);
    canvas.drawPath(path, paintStroke);

    // Mangas
    final sleevePath = Path();
    sleevePath.addOval(
      Rect.fromCenter(
        center: Offset(center.dx - 80, center.dy - 20),
        width: 35,
        height: 60,
      ),
    );
    sleevePath.addOval(
      Rect.fromCenter(
        center: Offset(center.dx + 80, center.dy - 20),
        width: 35,
        height: 60,
      ),
    );

    canvas.drawPath(sleevePath, paint);
    canvas.drawPath(sleevePath, paintStroke);
  }

  void _drawPants(Canvas canvas, Size size, Paint paint, Paint paintStroke) {
    final center = Offset(size.width / 2, size.height / 2);

    // Parte superior (cintura)
    final waistRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy - 60),
        width: 80,
        height: 25,
      ),
      const Radius.circular(5),
    );

    // Piernas con perspectiva
    final leftLeg = Path();
    leftLeg.moveTo(center.dx - 40, center.dy - 45);
    leftLeg.lineTo(center.dx - 10, center.dy - 45);
    leftLeg.lineTo(center.dx - 15, center.dy + 80);
    leftLeg.lineTo(center.dx - 45, center.dy + 80);
    leftLeg.close();

    final rightLeg = Path();
    rightLeg.moveTo(center.dx + 10, center.dy - 45);
    rightLeg.lineTo(center.dx + 40, center.dy - 45);
    rightLeg.lineTo(center.dx + 45, center.dy + 80);
    rightLeg.lineTo(center.dx + 15, center.dy + 80);
    rightLeg.close();

    // Sombras
    final shadowPaint =
        Paint()
          ..color = primaryColor.withOpacity(0.3)
          ..style = PaintingStyle.fill;

    canvas.drawRRect(waistRect.shift(const Offset(3, 3)), shadowPaint);
    canvas.drawPath(leftLeg.shift(const Offset(3, 3)), shadowPaint);
    canvas.drawPath(rightLeg.shift(const Offset(3, 3)), shadowPaint);

    // Dibujar prendas principales
    canvas.drawRRect(waistRect, paint);
    canvas.drawPath(leftLeg, paint);
    canvas.drawPath(rightLeg, paint);

    canvas.drawRRect(waistRect, paintStroke);
    canvas.drawPath(leftLeg, paintStroke);
    canvas.drawPath(rightLeg, paintStroke);
  }

  void _drawDress(Canvas canvas, Size size, Paint paint, Paint paintStroke) {
    final center = Offset(size.width / 2, size.height / 2);

    // Parte superior (corpiño)
    final topPath = Path();
    topPath.moveTo(center.dx - 50, center.dy - 60);
    topPath.lineTo(center.dx + 50, center.dy - 60);
    topPath.lineTo(center.dx + 40, center.dy - 10);
    topPath.lineTo(center.dx - 40, center.dy - 10);
    topPath.close();

    // Falda con perspectiva
    final skirtPath = Path();
    skirtPath.moveTo(center.dx - 40, center.dy - 10);
    skirtPath.lineTo(center.dx + 40, center.dy - 10);
    skirtPath.lineTo(center.dx + 70, center.dy + 70);
    skirtPath.lineTo(center.dx - 70, center.dy + 70);
    skirtPath.close();

    // Sombras
    final shadowPaint =
        Paint()
          ..color = primaryColor.withOpacity(0.3)
          ..style = PaintingStyle.fill;

    canvas.drawPath(topPath.shift(const Offset(3, 3)), shadowPaint);
    canvas.drawPath(skirtPath.shift(const Offset(3, 3)), shadowPaint);

    // Dibujar vestido
    canvas.drawPath(topPath, paint);
    canvas.drawPath(skirtPath, paint);
    canvas.drawPath(topPath, paintStroke);
    canvas.drawPath(skirtPath, paintStroke);

    // Detalle de cintura
    final waistPaint =
        Paint()
          ..color = secondaryColor
          ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy - 10),
        width: 80,
        height: 8,
      ),
      waistPaint,
    );
  }

  void _drawJacket(Canvas canvas, Size size, Paint paint, Paint paintStroke) {
    final center = Offset(size.width / 2, size.height / 2);

    // Cuerpo principal
    final bodyPath = Path();
    bodyPath.moveTo(center.dx - 65, center.dy - 50);
    bodyPath.lineTo(center.dx + 65, center.dy - 50);
    bodyPath.lineTo(center.dx + 55, center.dy + 60);
    bodyPath.lineTo(center.dx - 55, center.dy + 60);
    bodyPath.close();

    // Mangas más anchas para chaqueta
    final sleevePath = Path();
    sleevePath.addOval(
      Rect.fromCenter(
        center: Offset(center.dx - 90, center.dy - 10),
        width: 45,
        height: 80,
      ),
    );
    sleevePath.addOval(
      Rect.fromCenter(
        center: Offset(center.dx + 90, center.dy - 10),
        width: 45,
        height: 80,
      ),
    );

    // Sombras
    final shadowPaint =
        Paint()
          ..color = primaryColor.withOpacity(0.3)
          ..style = PaintingStyle.fill;

    canvas.drawPath(bodyPath.shift(const Offset(3, 3)), shadowPaint);
    canvas.drawPath(sleevePath.shift(const Offset(3, 3)), shadowPaint);

    // Dibujar chaqueta
    canvas.drawPath(bodyPath, paint);
    canvas.drawPath(sleevePath, paint);
    canvas.drawPath(bodyPath, paintStroke);
    canvas.drawPath(sleevePath, paintStroke);

    // Detalles de la chaqueta (botones)
    final buttonPaint =
        Paint()
          ..color = secondaryColor
          ..style = PaintingStyle.fill;

    for (int i = 0; i < 4; i++) {
      canvas.drawCircle(
        Offset(center.dx, center.dy - 30 + (i * 20)),
        4,
        buttonPaint,
      );
    }
  }

  void _drawGenericGarment(
    Canvas canvas,
    Size size,
    Paint paint,
    Paint paintStroke,
  ) {
    final center = Offset(size.width / 2, size.height / 2);

    // Forma genérica rectangular con perspectiva
    final path = Path();
    path.moveTo(center.dx - 50, center.dy - 50);
    path.lineTo(center.dx + 50, center.dy - 50);
    path.lineTo(center.dx + 45, center.dy + 50);
    path.lineTo(center.dx - 45, center.dy + 50);
    path.close();

    // Sombra
    final shadowPaint =
        Paint()
          ..color = primaryColor.withOpacity(0.3)
          ..style = PaintingStyle.fill;

    canvas.drawPath(path.shift(const Offset(3, 3)), shadowPaint);
    canvas.drawPath(path, paint);
    canvas.drawPath(path, paintStroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is Garment3DPainter &&
        (oldDelegate.rotationAngle != rotationAngle ||
            oldDelegate.primaryColor != primaryColor ||
            oldDelegate.secondaryColor != secondaryColor ||
            oldDelegate.garmentType != garmentType);
  }
}
