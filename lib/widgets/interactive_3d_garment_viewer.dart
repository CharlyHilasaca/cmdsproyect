import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'dart:math' as math;

/// Widget avanzado para modelos 3D interactivos con personalización completa
class Interactive3DGarmentViewer extends StatefulWidget {
  final String garmentType;
  final Function(Map<String, dynamic>) onDesignChange;
  final double width;
  final double height;

  const Interactive3DGarmentViewer({
    Key? key,
    required this.garmentType,
    required this.onDesignChange,
    this.width = 350,
    this.height = 400,
  }) : super(key: key);

  @override
  State<Interactive3DGarmentViewer> createState() =>
      _Interactive3DGarmentViewerState();
}

class _Interactive3DGarmentViewerState extends State<Interactive3DGarmentViewer>
    with TickerProviderStateMixin {
  // Controladores de animación
  late AnimationController _rotationController;
  late AnimationController _colorTransitionController;
  late Animation<double> _rotationAnimation;

  // Estado del modelo 3D
  double _rotationX = 0.0;
  double _rotationY = 0.0;
  double _zoom = 1.0;
  bool _isAnimating = true;
  Offset? _lastFocalPoint;

  // Personalización actual
  late Map<String, dynamic> _currentDesign;

  // Estilos predeterminados por categoría
  static final Map<String, List<Map<String, dynamic>>> _categoryStyles = {
    'Camisetas': [
      {
        'name': 'Básica',
        'colors': [Colors.white, Colors.black, Colors.grey],
        'pattern': 'solid',
        'sleeves': 'short',
        'neckline': 'round',
        'fit': 'regular',
      },
      {
        'name': 'Deportiva',
        'colors': [Colors.blue, Colors.red, Colors.green],
        'pattern': 'stripes',
        'sleeves': 'short',
        'neckline': 'v',
        'fit': 'athletic',
      },
      {
        'name': 'Casual',
        'colors': [
          const Color(0xFF000080),
          const Color(0xFF800000),
          const Color(0xFF228B22),
        ],
        'pattern': 'solid',
        'sleeves': 'long',
        'neckline': 'round',
        'fit': 'relaxed',
      },
    ],
    'Hoodies': [
      {
        'name': 'Clásica',
        'colors': [Colors.grey, Colors.black, const Color(0xFF000080)],
        'pattern': 'solid',
        'hood': 'standard',
        'pockets': 'kangaroo',
        'fit': 'regular',
      },
      {
        'name': 'Streetwear',
        'colors': [Colors.orange, Colors.purple, Colors.cyan],
        'pattern': 'graphic',
        'hood': 'oversized',
        'pockets': 'side',
        'fit': 'oversized',
      },
    ],
    'Pantalones': [
      {
        'name': 'Jeans',
        'colors': [Colors.indigo, Colors.black, Colors.grey],
        'pattern': 'denim',
        'fit': 'slim',
        'length': 'full',
        'waist': 'mid',
      },
      {
        'name': 'Cargo',
        'colors': [
          const Color(0xFFF0E68C),
          const Color(0xFF808000),
          Colors.brown,
        ],
        'pattern': 'solid',
        'fit': 'regular',
        'length': 'full',
        'waist': 'low',
      },
    ],
    'Vestidos': [
      {
        'name': 'Casual',
        'colors': [Colors.pink, Colors.blue, Colors.white],
        'pattern': 'floral',
        'length': 'knee',
        'sleeves': 'sleeveless',
        'neckline': 'round',
      },
      {
        'name': 'Elegante',
        'colors': [
          Colors.black,
          const Color(0xFF000080),
          const Color(0xFF800020),
        ],
        'pattern': 'solid',
        'length': 'maxi',
        'sleeves': 'long',
        'neckline': 'v',
      },
    ],
    'Chaquetas': [
      {
        'name': 'Bomber',
        'colors': [Colors.black, Colors.green, Colors.brown],
        'pattern': 'solid',
        'style': 'bomber',
        'lining': 'quilted',
        'closure': 'zipper',
      },
      {
        'name': 'Blazer',
        'colors': [
          const Color(0xFF000080),
          const Color(0xFF36454F),
          Colors.brown,
        ],
        'pattern': 'solid',
        'style': 'blazer',
        'lining': 'satin',
        'closure': 'buttons',
      },
    ],
  };

  // Paleta de colores extendida
  static const List<Color> _colorPalette = [
    // Básicos
    Colors.white, Colors.black, Colors.grey,
    // Primarios
    Colors.red, Colors.blue, Colors.green,
    // Secundarios
    Colors.orange, Colors.purple, Colors.yellow,
    // Tonos tierra
    Color(0xFF8B4513), Color(0xFF654321), Color(0xFFA0522D),
    // Tonos pasteles
    Color(0xFFFFB6C1), Color(0xFFADD8E6), Color(0xFF98FB98),
    // Tonos oscuros
    Color(0xFF2F4F4F), Color(0xFF800000), Color(0xFF008080),
  ];

  // Patrones disponibles
  static const List<Map<String, dynamic>> _patterns = [
    {'name': 'Sólido', 'value': 'solid', 'icon': Icons.crop_square},
    {'name': 'Rayas', 'value': 'stripes', 'icon': Icons.view_stream},
    {'name': 'Puntos', 'value': 'dots', 'icon': Icons.blur_on},
    {'name': 'Cuadros', 'value': 'checkered', 'icon': Icons.grid_4x4},
    {'name': 'Floral', 'value': 'floral', 'icon': Icons.local_florist},
    {'name': 'Geométrico', 'value': 'geometric', 'icon': Icons.change_history},
  ];

  @override
  void initState() {
    super.initState();
    _initializeDesign();
    _setupAnimations();
  }

  void _initializeDesign() {
    // Inicializar con el primer estilo predeterminado
    final styles = _categoryStyles[widget.garmentType] ?? [];
    if (styles.isNotEmpty) {
      _currentDesign = Map<String, dynamic>.from(styles.first);
      _currentDesign['selectedColorIndex'] = 0;
      _currentDesign['selectedPatternIndex'] = 0;
    } else {
      _currentDesign = {
        'name': 'Personalizado',
        'colors': [Colors.blue],
        'pattern': 'solid',
        'selectedColorIndex': 0,
        'selectedPatternIndex': 0,
      };
    }

    // Notificar cambio inicial después del build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onDesignChange(_currentDesign);
    });
  }

  void _setupAnimations() {
    _rotationController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    );

    _colorTransitionController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(begin: 0, end: 360).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );

    if (_isAnimating) {
      _rotationController.repeat();
    }
  }

  void _updateDesign(String key, dynamic value) {
    setState(() {
      _currentDesign[key] = value;
    });

    // Notificar cambio después del build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onDesignChange(_currentDesign);
    });

    // Animación de transición
    _colorTransitionController.forward().then((_) {
      _colorTransitionController.reverse();
    });
  }

  void _applyPresetStyle(Map<String, dynamic> style) {
    setState(() {
      _currentDesign = Map<String, dynamic>.from(style);
      _currentDesign['selectedColorIndex'] = 0;
      _currentDesign['selectedPatternIndex'] = _patterns
          .indexWhere((p) => p['value'] == style['pattern'])
          .clamp(0, _patterns.length - 1);
    });

    // Notificar cambio después del build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onDesignChange(_currentDesign);
    });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _colorTransitionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Visor 3D principal
          Expanded(flex: 3, child: _build3DViewer()),

          // Panel de personalización
          Expanded(flex: 2, child: _buildCustomizationPanel()),
        ],
      ),
    );
  }

  Widget _build3DViewer() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.grey[100]!, Colors.grey[200]!],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Stack(
        children: [
          // Modelo 3D
          Center(
            child: GestureDetector(
              onScaleStart: (details) {
                _lastFocalPoint = details.focalPoint;
              },
              onScaleUpdate: (details) {
                setState(() {
                  // Manejar zoom
                  _zoom = (details.scale).clamp(0.5, 3.0);

                  // Manejar rotación usando la diferencia del punto focal
                  if (_lastFocalPoint != null) {
                    final delta = details.focalPoint - _lastFocalPoint!;
                    _rotationY += delta.dx * 0.01;
                    _rotationX += delta.dy * 0.01;
                    _rotationX = _rotationX.clamp(-math.pi / 4, math.pi / 4);
                  }
                  _lastFocalPoint = details.focalPoint;
                });
              },
              child: AnimatedBuilder(
                animation: _rotationAnimation,
                builder: (context, child) {
                  return Transform(
                    alignment: Alignment.center,
                    transform:
                        Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..scale(_zoom)
                          ..rotateY(
                            _isAnimating
                                ? _rotationAnimation.value * math.pi / 180
                                : _rotationY,
                          )
                          ..rotateX(_rotationX),
                    child: CustomPaint(
                      size: const Size(250, 300),
                      painter: Advanced3DGarmentPainter(
                        garmentType: widget.garmentType,
                        design: _currentDesign,
                        animationValue: _colorTransitionController.value,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Controles superpuestos
          Positioned(top: 16, right: 16, child: _buildControls()),

          // Información del modelo
          Positioned(bottom: 16, left: 16, right: 16, child: _buildModelInfo()),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Fila de controles principales
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Control de animación
              IconButton(
                icon: Icon(
                  _isAnimating ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    _isAnimating = !_isAnimating;
                    if (_isAnimating) {
                      _rotationController.repeat();
                    } else {
                      _rotationController.stop();
                    }
                  });
                },
              ),

              const SizedBox(width: 4),

              // Reset de rotación
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white, size: 20),
                onPressed: () {
                  setState(() {
                    _rotationX = 0.0;
                    _rotationY = 0.0;
                    _zoom = 1.0;
                  });
                },
              ),

              const SizedBox(width: 4),

              // Control de iluminación
              IconButton(
                icon: const Icon(
                  Icons.lightbulb_outline,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    _colorTransitionController.forward().then((_) {
                      _colorTransitionController.reverse();
                    });
                  });
                },
              ),

              const SizedBox(width: 4),

              // Control de pantalla completa
              IconButton(
                icon: const Icon(
                  Icons.fullscreen,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: _showFullscreenViewer,
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Control de zoom
          Container(
            width: 100,
            height: 20,
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 2,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                activeTrackColor: Colors.white,
                inactiveTrackColor: Colors.white.withOpacity(0.3),
                thumbColor: Colors.white,
              ),
              child: Slider(
                value: _zoom,
                min: 0.5,
                max: 3.0,
                onChanged: (value) {
                  setState(() {
                    _zoom = value;
                  });
                },
              ),
            ),
          ),

          // Etiqueta de zoom
          Text(
            'Zoom: ${(_zoom * 100).toInt()}%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModelInfo() {
    final currentColor = _getCurrentColor();
    final currentPattern = _getCurrentPattern();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Muestra de color
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: currentColor,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
          const SizedBox(width: 12),

          // Información
          Expanded(
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
                Text(
                  '${_currentDesign['name']} • ${currentPattern['name']}',
                  style: const TextStyle(color: Colors.white70, fontSize: 10),
                ),
              ],
            ),
          ),

          // Indicador de plataforma
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getPlatformColor(),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _getPlatformText(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 8,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomizationPanel() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      child: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            // Pestañas
            TabBar(
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.blue,
              tabs: const [
                Tab(icon: Icon(Icons.palette), text: 'Colores'),
                Tab(icon: Icon(Icons.pattern), text: 'Patrones'),
                Tab(icon: Icon(Icons.style), text: 'Estilos'),
              ],
            ),

            // Contenido de pestañas
            Expanded(
              child: TabBarView(
                children: [
                  _buildColorTab(),
                  _buildPatternTab(),
                  _buildStyleTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 6,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: _colorPalette.length,
        itemBuilder: (context, index) {
          final color = _colorPalette[index];
          final isSelected = _currentDesign['selectedColorIndex'] == index;

          return GestureDetector(
            onTap: () {
              _updateDesign('selectedColorIndex', index);
              _updateDesign('colors', [color]);
            },
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? Colors.blue : Colors.grey[300]!,
                  width: isSelected ? 3 : 1,
                ),
                boxShadow:
                    isSelected
                        ? [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.3),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ]
                        : null,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPatternTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.2,
        ),
        itemCount: _patterns.length,
        itemBuilder: (context, index) {
          final pattern = _patterns[index];
          final isSelected = _currentDesign['selectedPatternIndex'] == index;

          return GestureDetector(
            onTap: () {
              _updateDesign('selectedPatternIndex', index);
              _updateDesign('pattern', pattern['value']);
            },
            child: Container(
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue[50] : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? Colors.blue : Colors.grey[300]!,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    pattern['icon'],
                    size: 24,
                    color: isSelected ? Colors.blue : Colors.grey[600],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    pattern['name'],
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.blue : Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStyleTab() {
    final styles = _categoryStyles[widget.garmentType] ?? [];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView.builder(
        itemCount: styles.length,
        itemBuilder: (context, index) {
          final style = styles[index];
          final isSelected = _currentDesign['name'] == style['name'];

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: GestureDetector(
              onTap: () => _applyPresetStyle(style),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue[50] : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? Colors.blue : Colors.grey[300]!,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Muestra de colores del estilo
                    Row(
                      children:
                          (style['colors'] as List<Color>).take(3).map((color) {
                            return Container(
                              width: 20,
                              height: 20,
                              margin: const EdgeInsets.only(right: 4),
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 1,
                                ),
                              ),
                            );
                          }).toList(),
                    ),

                    const SizedBox(width: 12),

                    // Información del estilo
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            style['name'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.blue : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getStyleDescription(style),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Indicador de selección
                    if (isSelected)
                      const Icon(
                        Icons.check_circle,
                        color: Colors.blue,
                        size: 20,
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getCurrentColor() {
    final index = _currentDesign['selectedColorIndex'] ?? 0;
    return _colorPalette[index.clamp(0, _colorPalette.length - 1)];
  }

  Map<String, dynamic> _getCurrentPattern() {
    final index = _currentDesign['selectedPatternIndex'] ?? 0;
    return _patterns[index.clamp(0, _patterns.length - 1)];
  }

  String _getStyleDescription(Map<String, dynamic> style) {
    final parts = <String>[];

    if (style.containsKey('fit')) parts.add('Corte ${style['fit']}');
    if (style.containsKey('sleeves')) parts.add('Mangas ${style['sleeves']}');
    if (style.containsKey('pattern')) parts.add('Patrón ${style['pattern']}');

    return parts.join(' • ');
  }

  Color _getPlatformColor() {
    if (kIsWeb) return Colors.green;
    try {
      if (Platform.isAndroid || Platform.isIOS) return Colors.blue;
      return Colors.orange;
    } catch (e) {
      return Colors.grey;
    }
  }

  String _getPlatformText() {
    if (kIsWeb) return 'WEB';
    try {
      if (Platform.isAndroid) return 'AND';
      if (Platform.isIOS) return 'iOS';
      return 'DESK';
    } catch (e) {
      return '?';
    }
  }

  void _showFullscreenViewer() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => Scaffold(
              backgroundColor: Colors.black,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                title: Text(
                  '${widget.garmentType} - Vista 3D',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              body: Center(
                child: Interactive3DGarmentViewer(
                  garmentType: widget.garmentType,
                  onDesignChange: widget.onDesignChange,
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: MediaQuery.of(context).size.height * 0.8,
                ),
              ),
            ),
      ),
    );
  }
}

/// Painter avanzado para renderizar modelos 3D detallados
class Advanced3DGarmentPainter extends CustomPainter {
  final String garmentType;
  final Map<String, dynamic> design;
  final double animationValue;

  Advanced3DGarmentPainter({
    required this.garmentType,
    required this.design,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = _getMainColor()
          ..style = PaintingStyle.fill;

    final shadowPaint =
        Paint()
          ..color = _getMainColor().withOpacity(0.3)
          ..style = PaintingStyle.fill;

    final strokePaint =
        Paint()
          ..color = Colors.black26
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

    final center = Offset(size.width / 2, size.height / 2);

    // Aplicar efecto de transición de color
    if (animationValue > 0) {
      paint.color =
          Color.lerp(paint.color, Colors.white, animationValue * 0.3)!;
    }

    switch (garmentType.toLowerCase()) {
      case 'camisetas':
        _paintAdvancedTShirt(
          canvas,
          size,
          paint,
          shadowPaint,
          strokePaint,
          center,
        );
        break;
      case 'hoodies':
        _paintAdvancedHoodie(
          canvas,
          size,
          paint,
          shadowPaint,
          strokePaint,
          center,
        );
        break;
      case 'pantalones':
        _paintAdvancedPants(
          canvas,
          size,
          paint,
          shadowPaint,
          strokePaint,
          center,
        );
        break;
      case 'vestidos':
        _paintAdvancedDress(
          canvas,
          size,
          paint,
          shadowPaint,
          strokePaint,
          center,
        );
        break;
      case 'chaquetas':
        _paintAdvancedJacket(
          canvas,
          size,
          paint,
          shadowPaint,
          strokePaint,
          center,
        );
        break;
      default:
        _paintGenericGarment(
          canvas,
          size,
          paint,
          shadowPaint,
          strokePaint,
          center,
        );
    }

    // Agregar patrón si está seleccionado
    _addPattern(canvas, size, center);
  }

  Color _getMainColor() {
    if (design['colors'] != null && (design['colors'] as List).isNotEmpty) {
      return design['colors'][0] as Color;
    }
    return Colors.blue;
  }

  void _paintAdvancedTShirt(
    Canvas canvas,
    Size size,
    Paint paint,
    Paint shadowPaint,
    Paint strokePaint,
    Offset center,
  ) {
    // Sistema de iluminación volumétrica avanzada
    final lightPosition = Offset(center.dx - 40, center.dy - 60);

    // **PASO 1: Sombra volumétrica proyectada**
    _paintVolumetricShadow(canvas, center, lightPosition);

    // **PASO 2: Cuerpo principal con múltiples capas de profundidad**
    _paintLayeredTShirtBody(canvas, center, paint, lightPosition);

    // **PASO 3: Mangas con volumen realista**
    _paintVolumetricSleeves(canvas, center, paint, lightPosition);

    // **PASO 4: Cuello con profundidad**
    _paintVolumetricNeckline(canvas, center, paint, lightPosition);

    // **PASO 5: Costuras y detalles de construcción**
    _paintRealisticSeams(canvas, center);

    // **PASO 6: Efectos de material y textura**
    _paintFabricDetails(canvas, center, paint);

    // **PASO 7: Highlights y reflexiones**
    _paintVolumetricHighlights(canvas, center, lightPosition);
  }

  void _paintVolumetricShadow(Canvas canvas, Offset center, Offset lightPos) {
    // Sombra principal con múltiples gradientes para simular volumen
    final shadowLayers = [
      {'opacity': 0.4, 'blur': 12.0, 'offset': Offset(8, 10), 'scale': 1.1},
      {'opacity': 0.25, 'blur': 8.0, 'offset': Offset(5, 7), 'scale': 1.05},
      {'opacity': 0.15, 'blur': 4.0, 'offset': Offset(2, 3), 'scale': 1.02},
    ];

    for (final layer in shadowLayers) {
      final shadowPath = Path();
      final scale = layer['scale'] as double;
      final offset = layer['offset'] as Offset;

      // Forma de sombra con perspectiva
      shadowPath.moveTo(
        center.dx - (60 * scale) + offset.dx,
        center.dy - (35 * scale) + offset.dy,
      );
      shadowPath.lineTo(
        center.dx + (60 * scale) + offset.dx,
        center.dy - (35 * scale) + offset.dy,
      );
      shadowPath.quadraticBezierTo(
        center.dx + (65 * scale) + offset.dx,
        center.dy + offset.dy,
        center.dx + (55 * scale) + offset.dx,
        center.dy + (35 * scale) + offset.dy,
      );
      shadowPath.lineTo(
        center.dx + (50 * scale) + offset.dx,
        center.dy + (85 * scale) + offset.dy,
      );
      shadowPath.quadraticBezierTo(
        center.dx + offset.dx,
        center.dy + (90 * scale) + offset.dy,
        center.dx - (50 * scale) + offset.dx,
        center.dy + (85 * scale) + offset.dy,
      );
      shadowPath.lineTo(
        center.dx - (55 * scale) + offset.dx,
        center.dy + (35 * scale) + offset.dy,
      );
      shadowPath.quadraticBezierTo(
        center.dx - (65 * scale) + offset.dx,
        center.dy + offset.dy,
        center.dx - (60 * scale) + offset.dx,
        center.dy - (35 * scale) + offset.dy,
      );
      shadowPath.close();

      final shadowPaint =
          Paint()
            ..color = Colors.black.withOpacity(layer['opacity'] as double)
            ..maskFilter = MaskFilter.blur(
              BlurStyle.normal,
              layer['blur'] as double,
            );

      canvas.drawPath(shadowPath, shadowPaint);
    }
  }

  void _paintLayeredTShirtBody(
    Canvas canvas,
    Offset center,
    Paint basePaint,
    Offset lightPos,
  ) {
    // **Capa 1: Fondo oscuro para profundidad**
    final backLayerPath = Path();
    backLayerPath.moveTo(center.dx - 52, center.dy - 32);
    backLayerPath.lineTo(center.dx + 52, center.dy - 32);
    backLayerPath.quadraticBezierTo(
      center.dx + 58,
      center.dy + 2,
      center.dx + 52,
      center.dy + 32,
    );
    backLayerPath.lineTo(center.dx + 47, center.dy + 82);
    backLayerPath.quadraticBezierTo(
      center.dx,
      center.dy + 87,
      center.dx - 47,
      center.dy + 82,
    );
    backLayerPath.quadraticBezierTo(
      center.dx - 58,
      center.dy + 32,
      center.dx - 52,
      center.dy + 2,
    );
    backLayerPath.close();

    final backPaint =
        Paint()
          ..color = basePaint.color.withOpacity(0.3)
          ..style = PaintingStyle.fill;
    canvas.drawPath(backLayerPath, backPaint);

    // **Capa 2: Cuerpo principal con gradiente volumétrico**
    final mainBodyPath = Path();
    mainBodyPath.moveTo(center.dx - 50, center.dy - 30);
    mainBodyPath.lineTo(center.dx + 50, center.dy - 30);
    mainBodyPath.quadraticBezierTo(
      center.dx + 56,
      center.dy,
      center.dx + 50,
      center.dy + 30,
    );
    mainBodyPath.lineTo(center.dx + 45, center.dy + 80);
    mainBodyPath.quadraticBezierTo(
      center.dx,
      center.dy + 85,
      center.dx - 45,
      center.dy + 80,
    );
    mainBodyPath.quadraticBezierTo(
      center.dx - 56,
      center.dy + 30,
      center.dx - 50,
      center.dy,
    );
    mainBodyPath.close();

    // Gradiente volumétrico que simula curvatura
    final volumeGradient = RadialGradient(
      center: Alignment(-0.3, -0.4), // Posición de la luz
      radius: 1.2,
      colors: [
        // Parte más iluminada (convexa)
        Color.lerp(basePaint.color, Colors.white, 0.4)!,
        // Color base
        basePaint.color,
        // Parte en sombra (cóncava)
        Color.lerp(basePaint.color, Colors.black, 0.3)!,
        // Bordes en sombra profunda
        Color.lerp(basePaint.color, Colors.black, 0.5)!,
      ],
      stops: const [0.0, 0.4, 0.8, 1.0],
    );

    final volumePaint =
        Paint()
          ..shader = volumeGradient.createShader(
            Rect.fromCenter(center: center, width: 120, height: 130),
          );

    canvas.drawPath(mainBodyPath, volumePaint);

    // **Capa 3: Highlights especulares para simular material**
    final specularPath = Path();
    specularPath.moveTo(center.dx - 35, center.dy - 20);
    specularPath.quadraticBezierTo(
      center.dx - 10,
      center.dy - 25,
      center.dx + 15,
      center.dy - 15,
    );
    specularPath.quadraticBezierTo(
      center.dx + 25,
      center.dy + 5,
      center.dx + 20,
      center.dy + 20,
    );
    specularPath.quadraticBezierTo(
      center.dx,
      center.dy + 15,
      center.dx - 20,
      center.dy + 10,
    );
    specularPath.quadraticBezierTo(
      center.dx - 35,
      center.dy - 5,
      center.dx - 35,
      center.dy - 20,
    );
    specularPath.close();

    final specularPaint =
        Paint()
          ..color = Colors.white.withOpacity(0.2)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    canvas.drawPath(specularPath, specularPaint);

    // **Capa 4: Contorno con profundidad**
    final outlinePaint =
        Paint()
          ..color = Color.lerp(basePaint.color, Colors.black, 0.6)!
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5;

    canvas.drawPath(mainBodyPath, outlinePaint);
  }

  void _paintVolumetricSleeves(
    Canvas canvas,
    Offset center,
    Paint basePaint,
    Offset lightPos,
  ) {
    // **Manga Izquierda con volumen 3D**
    _paintSingleVolumetricSleeve(
      canvas,
      center,
      basePaint,
      lightPos,
      isLeft: true,
    );

    // **Manga Derecha con volumen 3D**
    _paintSingleVolumetricSleeve(
      canvas,
      center,
      basePaint,
      lightPos,
      isLeft: false,
    );
  }

  void _paintSingleVolumetricSleeve(
    Canvas canvas,
    Offset center,
    Paint basePaint,
    Offset lightPos, {
    required bool isLeft,
  }) {
    final multiplier = isLeft ? -1 : 1;
    final sleeveCenter = Offset(center.dx + (70 * multiplier), center.dy - 10);

    // **Capa 1: Sombra de la manga**
    final shadowPath = Path();
    shadowPath.addOval(
      Rect.fromCenter(
        center: Offset(sleeveCenter.dx + (3 * multiplier), sleeveCenter.dy + 3),
        width: 50,
        height: 80,
      ),
    );

    final shadowPaint =
        Paint()
          ..color = Colors.black.withOpacity(0.2)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawPath(shadowPath, shadowPaint);

    // **Capa 2: Manga posterior (profundidad)**
    final backSleevePath = Path();
    backSleevePath.addOval(
      Rect.fromCenter(
        center: Offset(sleeveCenter.dx + (2 * multiplier), sleeveCenter.dy + 1),
        width: 48,
        height: 78,
      ),
    );

    final backPaint =
        Paint()..color = Color.lerp(basePaint.color, Colors.black, 0.4)!;
    canvas.drawPath(backSleevePath, backPaint);

    // **Capa 3: Manga principal con gradiente volumétrico**
    final mainSleevePath = Path();
    mainSleevePath.addOval(
      Rect.fromCenter(center: sleeveCenter, width: 45, height: 75),
    );

    // Gradiente que simula cilindro con luz lateral
    final sleeveGradient = LinearGradient(
      begin: Alignment(isLeft ? 1.0 : -1.0, -0.5),
      end: Alignment(isLeft ? -1.0 : 1.0, 0.5),
      colors: [
        Color.lerp(basePaint.color, Colors.white, 0.3)!, // Highlight
        basePaint.color, // Color base
        Color.lerp(basePaint.color, Colors.black, 0.2)!, // Sombra media
        Color.lerp(basePaint.color, Colors.black, 0.4)!, // Sombra profunda
      ],
      stops: const [0.0, 0.3, 0.7, 1.0],
    );

    final sleevePaint =
        Paint()
          ..shader = sleeveGradient.createShader(
            Rect.fromCenter(center: sleeveCenter, width: 45, height: 75),
          );

    canvas.drawPath(mainSleevePath, sleevePaint);

    // **Capa 4: Highlight especular**
    final highlightPath = Path();
    highlightPath.addOval(
      Rect.fromCenter(
        center: Offset(
          sleeveCenter.dx + (8 * multiplier),
          sleeveCenter.dy - 15,
        ),
        width: 12,
        height: 30,
      ),
    );

    final highlightPaint =
        Paint()
          ..color = Colors.white.withOpacity(0.4)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    canvas.drawPath(highlightPath, highlightPaint);

    // **Capa 5: Contorno de manga**
    final outlinePaint =
        Paint()
          ..color = Color.lerp(basePaint.color, Colors.black, 0.7)!
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

    canvas.drawPath(mainSleevePath, outlinePaint);
  }

  void _paintVolumetricNeckline(
    Canvas canvas,
    Offset center,
    Paint basePaint,
    Offset lightPos,
  ) {
    final necklineType = design['neckline'] ?? 'round';

    switch (necklineType.toLowerCase()) {
      case 'v':
        _paintVolumetricVNeck(canvas, center, basePaint, lightPos);
        break;
      case 'round':
      default:
        _paintVolumetricRoundNeck(canvas, center, basePaint, lightPos);
        break;
    }
  }

  void _paintVolumetricRoundNeck(
    Canvas canvas,
    Offset center,
    Paint basePaint,
    Offset lightPos,
  ) {
    // **Capa 1: Abertura del cuello (profundidad)**
    final neckHolePath = Path();
    neckHolePath.addOval(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy - 25),
        width: 35,
        height: 20,
      ),
    );

    final neckHolePaint =
        Paint()..color = Color.lerp(basePaint.color, Colors.black, 0.8)!;
    canvas.drawPath(neckHolePath, neckHolePaint);

    // **Capa 2: Borde del cuello con volumen**
    final neckBorderPath = Path();
    neckBorderPath.addOval(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy - 28),
        width: 42,
        height: 26,
      ),
    );

    // Gradiente para simular doblez del cuello
    final neckGradient = RadialGradient(
      center: Alignment.topCenter,
      radius: 0.8,
      colors: [
        Color.lerp(basePaint.color, Colors.white, 0.2)!,
        basePaint.color,
        Color.lerp(basePaint.color, Colors.black, 0.3)!,
      ],
      stops: const [0.0, 0.5, 1.0],
    );

    final neckPaint =
        Paint()
          ..shader = neckGradient.createShader(
            Rect.fromCenter(
              center: Offset(center.dx, center.dy - 28),
              width: 42,
              height: 26,
            ),
          );

    canvas.drawPath(neckBorderPath, neckPaint);

    // **Capa 3: Highlight en el borde**
    final neckHighlightPaint =
        Paint()
          ..color = Colors.white.withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;

    canvas.drawPath(neckBorderPath, neckHighlightPaint);
  }

  void _paintVolumetricVNeck(
    Canvas canvas,
    Offset center,
    Paint basePaint,
    Offset lightPos,
  ) {
    // **Cuello en V con profundidad**
    final vNeckPath = Path();
    vNeckPath.moveTo(center.dx - 15, center.dy - 30);
    vNeckPath.lineTo(center.dx, center.dy - 10);
    vNeckPath.lineTo(center.dx + 15, center.dy - 30);
    vNeckPath.quadraticBezierTo(
      center.dx + 8,
      center.dy - 35,
      center.dx,
      center.dy - 32,
    );
    vNeckPath.quadraticBezierTo(
      center.dx - 8,
      center.dy - 35,
      center.dx - 15,
      center.dy - 30,
    );
    vNeckPath.close();

    final vNeckPaint =
        Paint()..color = Color.lerp(basePaint.color, Colors.black, 0.6)!;
    canvas.drawPath(vNeckPath, vNeckPaint);

    // Borde del cuello en V
    final vNeckBorderPaint =
        Paint()
          ..color = Color.lerp(basePaint.color, Colors.white, 0.2)!
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

    canvas.drawPath(vNeckPath, vNeckBorderPaint);
  }

  void _paintAdvancedHoodie(
    Canvas canvas,
    Size size,
    Paint paint,
    Paint shadowPaint,
    Paint strokePaint,
    Offset center,
  ) {
    // Similar a camiseta pero con capucha y bolsillo
    _paintAdvancedTShirt(canvas, size, paint, shadowPaint, strokePaint, center);

    // Capucha
    final hoodPath = Path();
    hoodPath.moveTo(center.dx - 40, center.dy - 30);
    hoodPath.quadraticBezierTo(
      center.dx,
      center.dy - 50,
      center.dx + 40,
      center.dy - 30,
    );
    hoodPath.quadraticBezierTo(
      center.dx + 35,
      center.dy - 20,
      center.dx + 30,
      center.dy - 15,
    );
    hoodPath.quadraticBezierTo(
      center.dx,
      center.dy - 35,
      center.dx - 30,
      center.dy - 15,
    );
    hoodPath.quadraticBezierTo(
      center.dx - 35,
      center.dy - 20,
      center.dx - 40,
      center.dy - 30,
    );

    canvas.drawPath(hoodPath, paint);
    canvas.drawPath(hoodPath, strokePaint);

    // Bolsillo canguro
    final pocketPath = Path();
    pocketPath.addRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center.dx, center.dy + 20),
          width: 60,
          height: 25,
        ),
        const Radius.circular(12),
      ),
    );
    canvas.drawPath(pocketPath, shadowPaint);
    canvas.drawPath(pocketPath, strokePaint);
  }

  void _paintAdvancedPants(
    Canvas canvas,
    Size size,
    Paint paint,
    Paint shadowPaint,
    Paint strokePaint,
    Offset center,
  ) {
    // Cintura
    final waistRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy - 80),
        width: 90,
        height: 20,
      ),
      const Radius.circular(10),
    );
    canvas.drawRRect(waistRect, paint);
    canvas.drawRRect(waistRect, strokePaint);

    // Piernas con perspectiva 3D mejorada
    final leftLegPath = Path();
    leftLegPath.moveTo(center.dx - 45, center.dy - 70);
    leftLegPath.lineTo(center.dx - 5, center.dy - 70);
    leftLegPath.quadraticBezierTo(
      center.dx - 10,
      center.dy,
      center.dx - 15,
      center.dy + 70,
    );
    leftLegPath.lineTo(center.dx - 50, center.dy + 70);
    leftLegPath.quadraticBezierTo(
      center.dx - 45,
      center.dy,
      center.dx - 45,
      center.dy - 70,
    );

    final rightLegPath = Path();
    rightLegPath.moveTo(center.dx + 5, center.dy - 70);
    rightLegPath.lineTo(center.dx + 45, center.dy - 70);
    rightLegPath.quadraticBezierTo(
      center.dx + 45,
      center.dy,
      center.dx + 50,
      center.dy + 70,
    );
    rightLegPath.lineTo(center.dx + 15, center.dy + 70);
    rightLegPath.quadraticBezierTo(
      center.dx + 10,
      center.dy,
      center.dx + 5,
      center.dy - 70,
    );

    // Sombras de las piernas
    canvas.drawPath(leftLegPath.shift(const Offset(3, 3)), shadowPaint);
    canvas.drawPath(rightLegPath.shift(const Offset(3, 3)), shadowPaint);

    canvas.drawPath(leftLegPath, paint);
    canvas.drawPath(rightLegPath, paint);
    canvas.drawPath(leftLegPath, strokePaint);
    canvas.drawPath(rightLegPath, strokePaint);
  }

  void _paintAdvancedDress(
    Canvas canvas,
    Size size,
    Paint paint,
    Paint shadowPaint,
    Paint strokePaint,
    Offset center,
  ) {
    // Corpiño más detallado
    final bodiceePath = Path();
    bodiceePath.moveTo(center.dx - 40, center.dy - 60);
    bodiceePath.quadraticBezierTo(
      center.dx - 45,
      center.dy - 40,
      center.dx - 35,
      center.dy - 10,
    );
    bodiceePath.lineTo(center.dx + 35, center.dy - 10);
    bodiceePath.quadraticBezierTo(
      center.dx + 45,
      center.dy - 40,
      center.dx + 40,
      center.dy - 60,
    );
    bodiceePath.quadraticBezierTo(
      center.dx,
      center.dy - 65,
      center.dx - 40,
      center.dy - 60,
    );

    canvas.drawPath(bodiceePath, paint);
    canvas.drawPath(bodiceePath, strokePaint);

    // Falda con volumen
    final skirtPath = Path();
    skirtPath.moveTo(center.dx - 35, center.dy - 10);
    skirtPath.lineTo(center.dx + 35, center.dy - 10);
    skirtPath.quadraticBezierTo(
      center.dx + 70,
      center.dy + 30,
      center.dx + 75,
      center.dy + 80,
    );
    skirtPath.quadraticBezierTo(
      center.dx,
      center.dy + 85,
      center.dx - 75,
      center.dy + 80,
    );
    skirtPath.quadraticBezierTo(
      center.dx - 70,
      center.dy + 30,
      center.dx - 35,
      center.dy - 10,
    );

    canvas.drawPath(skirtPath, shadowPaint);
    canvas.drawPath(skirtPath, paint);
    canvas.drawPath(skirtPath, strokePaint);

    // Mangas según el estilo
    _paintSleeves(
      canvas,
      center,
      paint,
      strokePaint,
      design['sleeves'] ?? 'sleeveless',
    );
  }

  void _paintAdvancedJacket(
    Canvas canvas,
    Size size,
    Paint paint,
    Paint shadowPaint,
    Paint strokePaint,
    Offset center,
  ) {
    // Similar a camiseta pero más estructurada
    _paintAdvancedTShirt(canvas, size, paint, shadowPaint, strokePaint, center);

    // Solapas
    final lapelPath = Path();
    lapelPath.moveTo(center.dx - 30, center.dy - 20);
    lapelPath.quadraticBezierTo(
      center.dx - 45,
      center.dy - 10,
      center.dx - 40,
      center.dy + 10,
    );
    lapelPath.lineTo(center.dx - 10, center.dy + 10);
    lapelPath.lineTo(center.dx - 30, center.dy - 20);

    canvas.drawPath(lapelPath, shadowPaint);
    canvas.drawPath(lapelPath, strokePaint);

    // Espejo para la otra solapa
    canvas.save();
    canvas.scale(-1, 1);
    canvas.translate(-size.width, 0);
    canvas.drawPath(lapelPath, shadowPaint);
    canvas.drawPath(lapelPath, strokePaint);
    canvas.restore();

    // Botones
    _paintButtons(canvas, center, design['closure'] ?? 'buttons');
  }

  void _paintGenericGarment(
    Canvas canvas,
    Size size,
    Paint paint,
    Paint shadowPaint,
    Paint strokePaint,
    Offset center,
  ) {
    final path = Path();
    path.addRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: 100, height: 120),
        const Radius.circular(10),
      ),
    );

    canvas.drawPath(path.shift(const Offset(3, 3)), shadowPaint);
    canvas.drawPath(path, paint);
    canvas.drawPath(path, strokePaint);
  }

  void _paintSleeves(
    Canvas canvas,
    Offset center,
    Paint paint,
    Paint strokePaint,
    String type,
  ) {
    switch (type) {
      case 'short':
        _paintShortSleeves(canvas, center, paint, strokePaint);
        break;
      case 'long':
        _paintLongSleeves(canvas, center, paint, strokePaint);
        break;
      case 'sleeveless':
        // Sin mangas
        break;
    }
  }

  void _paintShortSleeves(
    Canvas canvas,
    Offset center,
    Paint paint,
    Paint strokePaint,
  ) {
    final leftSleeve = Path();
    leftSleeve.addOval(
      Rect.fromCenter(
        center: Offset(center.dx - 75, center.dy - 10),
        width: 30,
        height: 50,
      ),
    );

    final rightSleeve = Path();
    rightSleeve.addOval(
      Rect.fromCenter(
        center: Offset(center.dx + 75, center.dy - 10),
        width: 30,
        height: 50,
      ),
    );

    canvas.drawPath(leftSleeve, paint);
    canvas.drawPath(rightSleeve, paint);
    canvas.drawPath(leftSleeve, strokePaint);
    canvas.drawPath(rightSleeve, strokePaint);
  }

  void _paintLongSleeves(
    Canvas canvas,
    Offset center,
    Paint paint,
    Paint strokePaint,
  ) {
    final leftSleeve = Path();
    leftSleeve.addRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center.dx - 75, center.dy + 10),
          width: 35,
          height: 90,
        ),
        const Radius.circular(15),
      ),
    );

    final rightSleeve = Path();
    rightSleeve.addRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center.dx + 75, center.dy + 10),
          width: 35,
          height: 90,
        ),
        const Radius.circular(15),
      ),
    );

    canvas.drawPath(leftSleeve, paint);
    canvas.drawPath(rightSleeve, paint);
    canvas.drawPath(leftSleeve, strokePaint);
    canvas.drawPath(rightSleeve, strokePaint);
  }

  void _paintRealisticSeams(Canvas canvas, Offset center) {
    // **Costuras principales con profundidad y sombreado**

    // Costura lateral izquierda
    _paintSingleSeam(
      canvas,
      Offset(center.dx - 45, center.dy - 20),
      Offset(center.dx - 42, center.dy + 70),
      isMainSeam: true,
    );

    // Costura lateral derecha
    _paintSingleSeam(
      canvas,
      Offset(center.dx + 45, center.dy - 20),
      Offset(center.dx + 42, center.dy + 70),
      isMainSeam: true,
    );

    // Costura de hombros
    _paintSingleSeam(
      canvas,
      Offset(center.dx - 50, center.dy - 30),
      Offset(center.dx - 65, center.dy - 15),
      isMainSeam: false,
    );

    _paintSingleSeam(
      canvas,
      Offset(center.dx + 50, center.dy - 30),
      Offset(center.dx + 65, center.dy - 15),
      isMainSeam: false,
    );

    // Costura del dobladillo
    _paintHemSeam(canvas, center);
  }

  void _paintSingleSeam(
    Canvas canvas,
    Offset start,
    Offset end, {
    required bool isMainSeam,
  }) {
    // **Capa 1: Sombra de la costura (profundidad)**
    final shadowPaint =
        Paint()
          ..color = Colors.black.withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = isMainSeam ? 3 : 2
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1);

    canvas.drawLine(
      Offset(start.dx + 1, start.dy + 1),
      Offset(end.dx + 1, end.dy + 1),
      shadowPaint,
    );

    // **Capa 2: Línea principal de costura**
    final seamPaint =
        Paint()
          ..color = Colors.black.withOpacity(0.6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = isMainSeam ? 2 : 1.5;

    canvas.drawLine(start, end, seamPaint);

    // **Capa 3: Puntadas individuales**
    if (isMainSeam) {
      _paintStitchDetails(canvas, start, end);
    }

    // **Capa 4: Highlight de costura**
    final highlightPaint =
        Paint()
          ..color = Colors.white.withOpacity(0.2)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8;

    canvas.drawLine(
      Offset(start.dx - 0.5, start.dy - 0.5),
      Offset(end.dx - 0.5, end.dy - 0.5),
      highlightPaint,
    );
  }

  void _paintStitchDetails(Canvas canvas, Offset start, Offset end) {
    final stitchCount = 15;
    final stitchPaint =
        Paint()
          ..color = Colors.black.withOpacity(0.4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8;

    for (int i = 0; i < stitchCount; i++) {
      final t = i / (stitchCount - 1);
      final stitchPos = Offset(
        start.dx + (end.dx - start.dx) * t,
        start.dy + (end.dy - start.dy) * t,
      );

      // Puntada cruzada
      canvas.drawLine(
        Offset(stitchPos.dx - 1.5, stitchPos.dy - 1),
        Offset(stitchPos.dx + 1.5, stitchPos.dy + 1),
        stitchPaint,
      );
      canvas.drawLine(
        Offset(stitchPos.dx + 1.5, stitchPos.dy - 1),
        Offset(stitchPos.dx - 1.5, stitchPos.dy + 1),
        stitchPaint,
      );
    }
  }

  void _paintHemSeam(Canvas canvas, Offset center) {
    // Dobladillo con efecto de doblado
    final hemPath = Path();
    hemPath.moveTo(center.dx - 45, center.dy + 75);
    hemPath.quadraticBezierTo(
      center.dx,
      center.dy + 80,
      center.dx + 45,
      center.dy + 75,
    );

    // Sombra del dobladillo
    final hemShadowPaint =
        Paint()
          ..color = Colors.black.withOpacity(0.4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    canvas.drawPath(hemPath, hemShadowPaint);

    // Línea principal del dobladillo
    final hemPaint =
        Paint()
          ..color = Colors.black.withOpacity(0.7)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5;

    canvas.drawPath(hemPath, hemPaint);

    // Highlight del dobladillo
    final hemHighlightPaint =
        Paint()
          ..color = Colors.white.withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1;

    final highlightPath = Path();
    highlightPath.moveTo(center.dx - 45, center.dy + 73);
    highlightPath.quadraticBezierTo(
      center.dx,
      center.dy + 78,
      center.dx + 45,
      center.dy + 73,
    );

    canvas.drawPath(highlightPath, hemHighlightPaint);
  }

  void _paintFabricDetails(Canvas canvas, Offset center, Paint basePaint) {
    // **Detalles de textura de tela para mayor realismo**

    // Textura sutil de tejido
    _paintFabricWeave(canvas, center, basePaint);

    // Variaciones de color para simular fibras
    _paintFiberVariations(canvas, center, basePaint);

    // Micro-wrinkles y pliegues
    _paintFabricWrinkles(canvas, center, basePaint);
  }

  void _paintFabricWeave(Canvas canvas, Offset center, Paint basePaint) {
    final weavePaint =
        Paint()
          ..color = basePaint.color.withOpacity(0.1)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.3;

    // Patrón de tejido muy sutil
    for (int i = 0; i < 25; i++) {
      final x = center.dx - 50 + (i * 4);
      for (int j = 0; j < 30; j++) {
        final y = center.dy - 40 + (j * 3);
        if ((i + j) % 3 == 0) {
          canvas.drawLine(Offset(x, y), Offset(x + 2, y + 1.5), weavePaint);
        }
      }
    }
  }

  void _paintFiberVariations(Canvas canvas, Offset center, Paint basePaint) {
    final random = math.Random(42); // Seed fijo para consistencia

    // Pequeñas variaciones de color aleatorias
    for (int i = 0; i < 100; i++) {
      final x = center.dx - 45 + (random.nextDouble() * 90);
      final y = center.dy - 35 + (random.nextDouble() * 110);

      if (_isPointInGarment(Offset(x, y), center)) {
        final variation = random.nextDouble() * 0.15;
        final fiberColor =
            Color.lerp(
              basePaint.color,
              random.nextBool() ? Colors.white : Colors.black,
              variation,
            )!;

        final fiberPaint =
            Paint()
              ..color = fiberColor.withOpacity(0.3)
              ..style = PaintingStyle.fill;

        canvas.drawCircle(Offset(x, y), 0.8, fiberPaint);
      }
    }
  }

  void _paintFabricWrinkles(Canvas canvas, Offset center, Paint basePaint) {
    // Pequeños pliegues y arrugas para realismo
    final wrinklePaint =
        Paint()
          ..color = Colors.black.withOpacity(0.1)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.5;

    // Pliegue sutil cerca del hombro izquierdo
    final wrinklePath1 = Path();
    wrinklePath1.moveTo(center.dx - 30, center.dy - 15);
    wrinklePath1.quadraticBezierTo(
      center.dx - 20,
      center.dy - 10,
      center.dx - 10,
      center.dy - 8,
    );
    canvas.drawPath(wrinklePath1, wrinklePaint);

    // Pliegue cerca del lado derecho
    final wrinklePath2 = Path();
    wrinklePath2.moveTo(center.dx + 35, center.dy + 20);
    wrinklePath2.quadraticBezierTo(
      center.dx + 30,
      center.dy + 25,
      center.dx + 25,
      center.dy + 30,
    );
    canvas.drawPath(wrinklePath2, wrinklePaint);
  }

  bool _isPointInGarment(Offset point, Offset center) {
    // Verificar si el punto está dentro de la forma general de la prenda
    final dx = (point.dx - center.dx).abs();
    final dy = (point.dy - center.dy).abs();

    // Forma aproximada de camiseta
    if (dy < 35) {
      return dx < 50; // Parte superior más ancha
    } else {
      return dx < 45; // Parte inferior
    }
  }

  void _paintVolumetricHighlights(
    Canvas canvas,
    Offset center,
    Offset lightPos,
  ) {
    // **Sistema de highlights volumétricos basado en posición de luz**

    // Highlight principal (luz directa)
    _paintPrimaryHighlight(canvas, center, lightPos);

    // Highlights secundarios (luz reflejada)
    _paintSecondaryHighlights(canvas, center, lightPos);

    // Highlights especulares (material brillante)
    _paintSpecularHighlights(canvas, center, lightPos);
  }

  void _paintPrimaryHighlight(Canvas canvas, Offset center, Offset lightPos) {
    // Calcular posición del highlight basado en la luz
    final highlightCenter = Offset(
      center.dx + (lightPos.dx - center.dx) * 0.3,
      center.dy + (lightPos.dy - center.dy) * 0.3,
    );

    final highlightGradient = RadialGradient(
      colors: [
        Colors.white.withOpacity(0.4),
        Colors.white.withOpacity(0.2),
        Colors.white.withOpacity(0.1),
        Colors.transparent,
      ],
      stops: const [0.0, 0.3, 0.6, 1.0],
    );

    final highlightPaint =
        Paint()
          ..shader = highlightGradient.createShader(
            Rect.fromCircle(center: highlightCenter, radius: 35),
          );

    canvas.drawCircle(highlightCenter, 35, highlightPaint);
  }

  void _paintSecondaryHighlights(
    Canvas canvas,
    Offset center,
    Offset lightPos,
  ) {
    // Múltiples highlights pequeños para simular reflexiones
    final highlights = [
      Offset(center.dx + 20, center.dy - 10),
      Offset(center.dx - 15, center.dy + 15),
      Offset(center.dx + 10, center.dy + 40),
    ];

    for (final highlight in highlights) {
      final highlightPaint =
          Paint()
            ..color = Colors.white.withOpacity(0.15)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

      canvas.drawCircle(highlight, 8, highlightPaint);
    }
  }

  void _paintSpecularHighlights(Canvas canvas, Offset center, Offset lightPos) {
    // Highlights especulares intensos en puntos específicos
    final specularPoints = [
      Offset(center.dx - 25, center.dy - 20), // Hombro izquierdo
      Offset(center.dx + 30, center.dy - 15), // Hombro derecho
      Offset(center.dx, center.dy + 10), // Centro del pecho
    ];

    for (final point in specularPoints) {
      final specularPaint =
          Paint()
            ..color = Colors.white.withOpacity(0.6)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1);

      canvas.drawCircle(point, 3, specularPaint);
    }
  }

  void _paintButtons(Canvas canvas, Offset center, String closureType) {
    if (closureType != 'buttons') return;

    final buttonPaint =
        Paint()
          ..color = const Color(0xFF8B7355)
          ..style = PaintingStyle.fill;

    final buttonStroke =
        Paint()
          ..color = Colors.black54
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1;

    for (int i = 0; i < 4; i++) {
      final buttonCenter = Offset(center.dx, center.dy - 20 + (i * 15));
      canvas.drawCircle(buttonCenter, 4, buttonPaint);
      canvas.drawCircle(buttonCenter, 4, buttonStroke);
    }
  }

  void _addPattern(Canvas canvas, Size size, Offset center) {
    final pattern = design['pattern'] ?? 'solid';

    switch (pattern) {
      case 'stripes':
        _addAdvancedStripePattern(canvas, size, center);
        break;
      case 'dots':
        _addAdvancedDotPattern(canvas, size, center);
        break;
      case 'checkered':
        _addAdvancedCheckeredPattern(canvas, size, center);
        break;
      case 'denim':
        _addDenimTexture(canvas, size, center);
        break;
      case 'graphic':
        _addGraphicPattern(canvas, size, center);
        break;
      case 'fabric':
        _addFabricTexture(canvas, size, center);
        break;
      // Otros patrones pueden agregarse aquí
    }
  }

  void _addAdvancedStripePattern(Canvas canvas, Size size, Offset center) {
    // Rayas con efecto 3D
    for (int i = 0; i < 8; i++) {
      final y = center.dy - 40 + (i * 12);

      // Raya principal
      final stripePaint =
          Paint()
            ..color = Colors.white.withOpacity(0.4)
            ..style = PaintingStyle.fill;

      final stripePath = Path();
      stripePath.moveTo(center.dx - 45, y);
      stripePath.lineTo(center.dx + 45, y);
      stripePath.lineTo(center.dx + 45, y + 6);
      stripePath.lineTo(center.dx - 45, y + 6);
      stripePath.close();

      canvas.drawPath(stripePath, stripePaint);

      // Highlight superior para efecto 3D
      final highlightPaint =
          Paint()
            ..color = Colors.white.withOpacity(0.6)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1;

      canvas.drawLine(
        Offset(center.dx - 45, y),
        Offset(center.dx + 45, y),
        highlightPaint,
      );
    }
  }

  void _addAdvancedDotPattern(Canvas canvas, Size size, Offset center) {
    // Puntos con efecto de profundidad
    for (int x = 0; x < 5; x++) {
      for (int y = 0; y < 6; y++) {
        final dotCenter = Offset(
          center.dx - 32 + (x * 16),
          center.dy - 36 + (y * 14),
        );

        // Sombra del punto
        final shadowPaint =
            Paint()
              ..color = Colors.black.withOpacity(0.2)
              ..style = PaintingStyle.fill;

        canvas.drawCircle(
          Offset(dotCenter.dx + 1, dotCenter.dy + 1),
          4,
          shadowPaint,
        );

        // Punto principal con gradiente
        final dotGradient = RadialGradient(
          colors: [
            Colors.white.withOpacity(0.8),
            Colors.white.withOpacity(0.4),
            Colors.white.withOpacity(0.1),
          ],
        );

        final dotPaint =
            Paint()
              ..shader = dotGradient.createShader(
                Rect.fromCircle(center: dotCenter, radius: 4),
              );

        canvas.drawCircle(dotCenter, 4, dotPaint);

        // Highlight brillante
        final highlightPaint =
            Paint()
              ..color = Colors.white.withOpacity(0.9)
              ..style = PaintingStyle.fill;

        canvas.drawCircle(
          Offset(dotCenter.dx - 1, dotCenter.dy - 1),
          1.5,
          highlightPaint,
        );
      }
    }
  }

  void _addAdvancedCheckeredPattern(Canvas canvas, Size size, Offset center) {
    // Patrón de cuadros con efecto 3D
    for (int x = 0; x < 7; x++) {
      for (int y = 0; y < 8; y++) {
        if ((x + y) % 2 == 0) {
          final squareRect = Rect.fromLTWH(
            center.dx - 42 + (x * 12),
            center.dy - 40 + (y * 10),
            12,
            10,
          );

          // Cuadro con gradiente
          final checkGradient = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.4),
              Colors.white.withOpacity(0.2),
              Colors.white.withOpacity(0.1),
            ],
          );

          final checkPaint =
              Paint()..shader = checkGradient.createShader(squareRect);

          canvas.drawRect(squareRect, checkPaint);

          // Borde sutil
          final borderPaint =
              Paint()
                ..color = Colors.white.withOpacity(0.3)
                ..style = PaintingStyle.stroke
                ..strokeWidth = 0.5;

          canvas.drawRect(squareRect, borderPaint);
        }
      }
    }
  }

  void _addDenimTexture(Canvas canvas, Size size, Offset center) {
    // Textura de mezclilla con costuras

    // Costuras verticales
    final seamPaint =
        Paint()
          ..color = Colors.orange.withOpacity(0.6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;

    // Costura central
    canvas.drawLine(
      Offset(center.dx, center.dy - 40),
      Offset(center.dx, center.dy + 60),
      seamPaint,
    );

    // Costuras laterales
    canvas.drawLine(
      Offset(center.dx - 25, center.dy - 30),
      Offset(center.dx - 25, center.dy + 50),
      seamPaint,
    );
    canvas.drawLine(
      Offset(center.dx + 25, center.dy - 30),
      Offset(center.dx + 25, center.dy + 50),
      seamPaint,
    );

    // Textura de fibras
    final fiberPaint =
        Paint()
          ..color = Colors.white.withOpacity(0.1)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.5;

    for (int i = 0; i < 30; i++) {
      final x = center.dx - 40 + (i * 2.5);
      for (int j = 0; j < 25; j++) {
        final y = center.dy - 35 + (j * 4);
        if ((i + j) % 3 == 0) {
          canvas.drawLine(Offset(x, y), Offset(x + 1.5, y + 2), fiberPaint);
        }
      }
    }
  }

  void _addGraphicPattern(Canvas canvas, Size size, Offset center) {
    // Patrón gráfico moderno

    // Elemento geométrico central
    final graphicPaint =
        Paint()
          ..color = Colors.white.withOpacity(0.7)
          ..style = PaintingStyle.fill;

    // Triángulo central
    final trianglePath = Path();
    trianglePath.moveTo(center.dx, center.dy - 15);
    trianglePath.lineTo(center.dx - 20, center.dy + 15);
    trianglePath.lineTo(center.dx + 20, center.dy + 15);
    trianglePath.close();

    canvas.drawPath(trianglePath, graphicPaint);

    // Círculos decorativos
    final circlePaint =
        Paint()
          ..color = Colors.white.withOpacity(0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

    canvas.drawCircle(center, 30, circlePaint);
    canvas.drawCircle(center, 45, circlePaint);

    // Líneas dinámicas
    final linePaint =
        Paint()
          ..color = Colors.white.withOpacity(0.6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3;

    // Líneas diagonales
    canvas.drawLine(
      Offset(center.dx - 35, center.dy - 25),
      Offset(center.dx + 35, center.dy + 25),
      linePaint,
    );
    canvas.drawLine(
      Offset(center.dx + 35, center.dy - 25),
      Offset(center.dx - 35, center.dy + 25),
      linePaint,
    );
  }

  void _addFabricTexture(Canvas canvas, Size size, Offset center) {
    // Textura de tela con trama

    final fabricPaint =
        Paint()
          ..color = Colors.white.withOpacity(0.15)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8;

    // Trama horizontal
    for (int i = 0; i < 20; i++) {
      final y = center.dy - 40 + (i * 4);
      canvas.drawLine(
        Offset(center.dx - 45, y),
        Offset(center.dx + 45, y),
        fabricPaint,
      );
    }

    // Trama vertical
    for (int i = 0; i < 23; i++) {
      final x = center.dx - 45 + (i * 4);
      canvas.drawLine(
        Offset(x, center.dy - 40),
        Offset(x, center.dy + 40),
        fabricPaint,
      );
    }

    // Efecto de brillos aleatorios en la trama
    final shimmerPaint =
        Paint()
          ..color = Colors.white.withOpacity(0.3)
          ..style = PaintingStyle.fill;

    for (int i = 0; i < 15; i++) {
      final x = center.dx - 40 + (i * 5.5);
      for (int j = 0; j < 12; j++) {
        final y = center.dy - 35 + (j * 6);
        if ((i * j) % 7 == 0) {
          canvas.drawCircle(Offset(x, y), 0.8, shimmerPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is Advanced3DGarmentPainter &&
        (oldDelegate.design != design ||
            oldDelegate.animationValue != animationValue);
  }
}
