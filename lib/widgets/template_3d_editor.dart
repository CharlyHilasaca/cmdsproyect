import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math' as math;

class Template3DEditor extends StatefulWidget {
  final Map<String, dynamic> currentTemplate;
  final Function(Map<String, dynamic>) onTemplateChanged;
  final String garmentType; // Tipo específico de prenda
  final String category; // Categoría de la prenda

  const Template3DEditor({
    super.key,
    required this.currentTemplate,
    required this.onTemplateChanged,
    required this.garmentType,
    required this.category,
  });

  @override
  State<Template3DEditor> createState() => _Template3DEditorState();
}

class _Template3DEditorState extends State<Template3DEditor>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late TabController _tabController;

  // Plantillas predefinidas para diferentes tipos de prendas
  Map<String, dynamic> _currentTemplate = {};
  late String _currentGarmentType; // Tipo de prenda específico que no cambia

  // Editor de dimensiones
  Map<String, double> _dimensions = {
    'width': 1.0,
    'height': 1.0,
    'depth': 0.3,
    'shoulder_width': 0.8,
    'waist_width': 0.7,
    'hip_width': 0.9,
    'sleeve_length': 0.6,
    'collar_height': 0.1,
  };

  // Editor de detalles
  Map<String, dynamic> _details = {
    'collar_type': 'Round',
    'sleeve_type': 'Short',
    'pocket_count': 0,
    'button_count': 3,
    'seam_style': 'Normal',
    'hem_style': 'Straight',
  };

  @override
  void initState() {
    super.initState();
    _currentTemplate = Map<String, dynamic>.from(widget.currentTemplate);
    _currentGarmentType = widget.garmentType; // Fijar el tipo de prenda
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _tabController = TabController(length: 4, vsync: this);

    _initializeTemplate();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _initializeTemplate() {
    // Inicializar con valores por defecto si no existen
    _currentTemplate['garment_type'] ??= 'Camiseta';
    _currentTemplate['dimensions'] ??= _dimensions;
    _currentTemplate['details'] ??= _details;
    _currentTemplate['color'] ??= Colors.blue.value;
    _currentTemplate['material'] ??= 'Algodón';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editor de Plantillas 3D'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveTemplate),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetTemplate,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.category), text: 'Tipo'),
            Tab(icon: Icon(Icons.straighten), text: 'Dimensiones'),
            Tab(icon: Icon(Icons.details), text: 'Detalles'),
            Tab(icon: Icon(Icons.preview), text: 'Vista Previa'),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildGarmentTypeEditor(),
                _buildDimensionsEditor(),
                _buildDetailsEditor(),
                _buildPreviewTab(),
              ],
            ),
          ),
          _buildBottomControls(),
        ],
      ),
    );
  }

  // 1. EDITOR DE PRENDA ESPECÍFICA (No permite cambiar tipo)
  Widget _buildGarmentTypeEditor() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Editando Prenda',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          // Widget informativo del tipo de prenda seleccionado
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.indigo.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.indigo, width: 2),
            ),
            child: Column(
              children: [
                Icon(
                  _getGarmentIcon(_currentGarmentType),
                  size: 80,
                  color: Colors.indigo,
                ),
                const SizedBox(height: 16),
                Text(
                  widget.category,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tipo: $_currentGarmentType',
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 16),
                Text(
                  'Utiliza las pestañas para personalizar las dimensiones, detalles y vista previa de tu ${widget.category.toLowerCase()}.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Botón para guardar diseño
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _saveDesignToFirebase,
              icon: const Icon(Icons.save),
              label: const Text('Guardar Diseño en Firebase'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Información adicional
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info, color: Colors.blue.shade600),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Este editor está específicamente configurado para ${widget.category.toLowerCase()}. Los cambios se guardarán automáticamente.',
                    style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 2. EDITOR DE DIMENSIONES
  Widget _buildDimensionsEditor() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ajusta las dimensiones de la prenda',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children:
                  _dimensions.keys.map((key) {
                    final value = _dimensions[key]!;
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getDimensionLabel(key),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: Slider(
                                    value: value,
                                    min: 0.1,
                                    max: 2.0,
                                    divisions: 19,
                                    label: value.toStringAsFixed(1),
                                    onChanged: (newValue) {
                                      setState(() {
                                        _dimensions[key] = newValue;
                                        _updateTemplate();
                                      });
                                    },
                                  ),
                                ),
                                SizedBox(
                                  width: 60,
                                  child: Text(
                                    value.toStringAsFixed(1),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // 3. EDITOR DE DETALLES
  Widget _buildDetailsEditor() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Personaliza los detalles de la prenda',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: [
                _buildDetailSelector('Tipo de Cuello', 'collar_type', [
                  'Round',
                  'V-neck',
                  'Polo',
                  'Turtleneck',
                  'Hoodie',
                ]),

                _buildDetailSelector('Tipo de Manga', 'sleeve_type', [
                  'Short',
                  'Long',
                  '3/4',
                  'Sleeveless',
                  'Cap',
                ]),

                _buildNumberSelector(
                  'Número de Botones',
                  'button_count',
                  0,
                  10,
                ),

                _buildNumberSelector(
                  'Número de Bolsillos',
                  'pocket_count',
                  0,
                  6,
                ),

                _buildDetailSelector('Estilo de Costura', 'seam_style', [
                  'Normal',
                  'French',
                  'Flat',
                  'Overlocked',
                ]),

                _buildDetailSelector('Estilo de Dobladillo', 'hem_style', [
                  'Straight',
                  'Curved',
                  'Asymmetric',
                  'Layered',
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 4. VISTA PREVIA 3D
  Widget _buildPreviewTab() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Text(
            'Vista Previa de la Plantilla',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: const RadialGradient(
                  center: Alignment.center,
                  radius: 1.0,
                  colors: [Color(0xFF2A2A3E), Color(0xFF1A1A2E)],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.indigo, width: 2),
              ),
              child: CustomPaint(
                size: Size.infinite,
                painter: Template3DPreviewPainter(
                  template: _currentTemplate,
                  dimensions: _dimensions,
                  details: _details,
                  animationValue: _animationController.value,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildPreviewControls(),
        ],
      ),
    );
  }

  Widget _buildPreviewControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            if (_animationController.isAnimating) {
              _animationController.stop();
            } else {
              _animationController.repeat();
            }
          },
          icon: Icon(
            _animationController.isAnimating ? Icons.pause : Icons.play_arrow,
          ),
          label: Text(_animationController.isAnimating ? 'Pausar' : 'Rotar'),
        ),
        ElevatedButton.icon(
          onPressed: _exportTemplate,
          icon: const Icon(Icons.download),
          label: const Text('Exportar'),
        ),
        ElevatedButton.icon(
          onPressed: _shareTemplate,
          icon: const Icon(Icons.share),
          label: const Text('Compartir'),
        ),
      ],
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _saveTemplate,
              icon: const Icon(Icons.save),
              label: const Text('Guardar Plantilla'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _applyTemplate,
              icon: const Icon(Icons.check),
              label: const Text('Aplicar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSelector(String title, String key, List<String> options) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children:
                  options.map((option) {
                    final isSelected = _details[key] == option;
                    return FilterChip(
                      label: Text(option),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _details[key] = option;
                          _updateTemplate();
                        });
                      },
                      selectedColor: Colors.indigo.withOpacity(0.3),
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberSelector(String title, String key, int min, int max) {
    final value = _details[key] as int;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  onPressed:
                      value > min
                          ? () {
                            setState(() {
                              _details[key] = value - 1;
                              _updateTemplate();
                            });
                          }
                          : null,
                  icon: const Icon(Icons.remove),
                ),
                Expanded(
                  child: Slider(
                    value: value.toDouble(),
                    min: min.toDouble(),
                    max: max.toDouble(),
                    divisions: max - min,
                    label: value.toString(),
                    onChanged: (newValue) {
                      setState(() {
                        _details[key] = newValue.round();
                        _updateTemplate();
                      });
                    },
                  ),
                ),
                IconButton(
                  onPressed:
                      value < max
                          ? () {
                            setState(() {
                              _details[key] = value + 1;
                              _updateTemplate();
                            });
                          }
                          : null,
                  icon: const Icon(Icons.add),
                ),
                SizedBox(
                  width: 40,
                  child: Text(
                    value.toString(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Métodos auxiliares
  IconData _getGarmentIcon(String type) {
    switch (type) {
      case 'Camiseta':
        return Icons.checkroom;
      case 'Pantalón':
        return Icons.description;
      case 'Vestido':
        return Icons.woman;
      case 'Chaqueta':
        return Icons.dry_cleaning;
      case 'Falda':
        return Icons.accessibility_new;
      case 'Blusa':
        return Icons.style;
      default:
        return Icons.checkroom;
    }
  }

  String _getDimensionLabel(String key) {
    switch (key) {
      case 'width':
        return 'Ancho General';
      case 'height':
        return 'Alto General';
      case 'depth':
        return 'Profundidad';
      case 'shoulder_width':
        return 'Ancho de Hombros';
      case 'waist_width':
        return 'Ancho de Cintura';
      case 'hip_width':
        return 'Ancho de Caderas';
      case 'sleeve_length':
        return 'Largo de Manga';
      case 'collar_height':
        return 'Alto del Cuello';
      default:
        return key;
    }
  }

  // Método para guardar el diseño en Firebase
  Future<void> _saveDesignToFirebase() async {
    try {
      // Mostrar dialog de progreso
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => const AlertDialog(
              content: Row(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 16),
                  Text('Guardando diseño...'),
                ],
              ),
            ),
      );

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        Navigator.pop(context); // Cerrar dialog de progreso
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Debes iniciar sesión para guardar diseños'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Preparar datos del diseño
      final designData = {
        'userId': user.uid,
        'userName': user.displayName ?? 'Usuario desconocido',
        'userEmail': user.email,
        'name': 'Diseño ${widget.category}',
        'garmentType': _currentGarmentType,
        'category': widget.category,
        'dimensions': Map<String, double>.from(_dimensions),
        'details': Map<String, dynamic>.from(_details),
        'template': Map<String, dynamic>.from(_currentTemplate),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Guardar en Firestore
      await FirebaseFirestore.instance.collection('designs').add(designData);

      Navigator.pop(context); // Cerrar dialog de progreso

      // Mostrar confirmación
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('¡Diseño guardado exitosamente!'),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: 'Ver Proyectos',
            textColor: Colors.white,
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
        ),
      );

      // Actualizar el template actual
      _updateTemplate();
    } catch (e) {
      Navigator.pop(context); // Cerrar dialog de progreso
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _updateTemplate() {
    _currentTemplate['dimensions'] = Map<String, double>.from(_dimensions);
    _currentTemplate['details'] = Map<String, dynamic>.from(_details);
    _currentTemplate['last_modified'] = DateTime.now().millisecondsSinceEpoch;
  }

  void _saveTemplate() {
    _updateTemplate();
    widget.onTemplateChanged(_currentTemplate);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Plantilla guardada exitosamente'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _resetTemplate() {
    setState(() {
      _dimensions = {
        'width': 1.0,
        'height': 1.0,
        'depth': 0.3,
        'shoulder_width': 0.8,
        'waist_width': 0.7,
        'hip_width': 0.9,
        'sleeve_length': 0.6,
        'collar_height': 0.1,
      };
      _details = {
        'collar_type': 'Round',
        'sleeve_type': 'Short',
        'pocket_count': 0,
        'button_count': 3,
        'seam_style': 'Normal',
        'hem_style': 'Straight',
      };
      _updateTemplate();
    });
  }

  void _applyTemplate() {
    _updateTemplate();
    widget.onTemplateChanged(_currentTemplate);
    Navigator.of(context).pop();
  }

  void _exportTemplate() {
    // Implementar exportación de plantilla
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Función de exportación en desarrollo'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _shareTemplate() {
    // Implementar compartir plantilla
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Función de compartir en desarrollo'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}

// Painter personalizado para la vista previa 3D
class Template3DPreviewPainter extends CustomPainter {
  final Map<String, dynamic> template;
  final Map<String, double> dimensions;
  final Map<String, dynamic> details;
  final double animationValue;

  Template3DPreviewPainter({
    required this.template,
    required this.dimensions,
    required this.details,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final rotation = animationValue * 2 * math.pi;

    canvas.save();
    canvas.translate(center.dx, center.dy);

    // Aplicar rotación animada
    canvas.rotate(rotation);

    // Dibujar modelo 3D basado en la plantilla
    _drawGarmentTemplate(canvas, Size(size.width * 0.6, size.height * 0.6));

    canvas.restore();
  }

  void _drawGarmentTemplate(Canvas canvas, Size modelSize) {
    final garmentType = template['garment_type'] ?? 'Camiseta';

    switch (garmentType) {
      case 'Camiseta':
        _drawShirtTemplate(canvas, modelSize);
        break;
      case 'Pantalón':
        _drawPantsTemplate(canvas, modelSize);
        break;
      case 'Vestido':
        _drawDressTemplate(canvas, modelSize);
        break;
      case 'Chaqueta':
        _drawJacketTemplate(canvas, modelSize);
        break;
      case 'Falda':
        _drawSkirtTemplate(canvas, modelSize);
        break;
      case 'Blusa':
        _drawBlouseTemplate(canvas, modelSize);
        break;
      default:
        _drawShirtTemplate(canvas, modelSize);
    }
  }

  void _drawShirtTemplate(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Color(template['color'] ?? Colors.blue.value)
          ..style = PaintingStyle.fill;

    final width = size.width * (dimensions['width'] ?? 1.0);
    final height = size.height * (dimensions['height'] ?? 1.0);
    final shoulderWidth = width * (dimensions['shoulder_width'] ?? 0.8);
    final waistWidth = width * (dimensions['waist_width'] ?? 0.7);

    // Cuerpo de la camiseta
    final bodyPath = Path();
    bodyPath.moveTo(-shoulderWidth / 2, -height / 2);
    bodyPath.lineTo(shoulderWidth / 2, -height / 2);
    bodyPath.lineTo(waistWidth / 2, height / 2);
    bodyPath.lineTo(-waistWidth / 2, height / 2);
    bodyPath.close();

    canvas.drawPath(bodyPath, paint);

    // Mangas si aplica
    if (details['sleeve_type'] != 'Sleeveless') {
      _drawSleeves(canvas, size, paint);
    }

    // Cuello
    _drawCollar(canvas, size, paint);

    // Botones si aplica
    if ((details['button_count'] as int) > 0) {
      _drawButtons(canvas, size);
    }

    // Bolsillos si aplica
    if ((details['pocket_count'] as int) > 0) {
      _drawPockets(canvas, size);
    }
  }

  void _drawPantsTemplate(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Color(template['color'] ?? Colors.blue.value)
          ..style = PaintingStyle.fill;

    final width = size.width * (dimensions['width'] ?? 1.0);
    final height = size.height * (dimensions['height'] ?? 1.0);

    // Pierna izquierda
    final leftLeg = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(-width / 4, 0),
        width: width / 2.5,
        height: height,
      ),
      const Radius.circular(8),
    );

    // Pierna derecha
    final rightLeg = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(width / 4, 0),
        width: width / 2.5,
        height: height,
      ),
      const Radius.circular(8),
    );

    canvas.drawRRect(leftLeg, paint);
    canvas.drawRRect(rightLeg, paint);

    // Cintura
    final waistPaint =
        Paint()
          ..color = paint.color.withOpacity(0.8)
          ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(0, -height / 2 + 20),
        width: width * 0.8,
        height: 40,
      ),
      waistPaint,
    );
  }

  void _drawDressTemplate(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Color(template['color'] ?? Colors.blue.value)
          ..style = PaintingStyle.fill;

    final width = size.width * (dimensions['width'] ?? 1.0);
    final height = size.height * (dimensions['height'] ?? 1.0);
    final shoulderWidth = width * (dimensions['shoulder_width'] ?? 0.8);
    final waistWidth = width * (dimensions['waist_width'] ?? 0.7);
    final hipWidth = width * (dimensions['hip_width'] ?? 0.9);

    // Forma del vestido
    final dressPath = Path();
    dressPath.moveTo(-shoulderWidth / 2, -height / 2);
    dressPath.lineTo(shoulderWidth / 2, -height / 2);
    dressPath.lineTo(waistWidth / 2, -height / 4);
    dressPath.lineTo(hipWidth / 2, height / 2);
    dressPath.lineTo(-hipWidth / 2, height / 2);
    dressPath.lineTo(-waistWidth / 2, -height / 4);
    dressPath.close();

    canvas.drawPath(dressPath, paint);

    // Mangas si aplica
    if (details['sleeve_type'] != 'Sleeveless') {
      _drawSleeves(canvas, size, paint);
    }

    // Cuello
    _drawCollar(canvas, size, paint);
  }

  void _drawJacketTemplate(Canvas canvas, Size size) {
    _drawShirtTemplate(canvas, size); // Base similar a camiseta

    // Agregar detalles de chaqueta
    final outlinePaint =
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

    // Contorno de chaqueta
    final width = size.width * (dimensions['width'] ?? 1.0);
    final height = size.height * (dimensions['height'] ?? 1.0);

    canvas.drawRect(
      Rect.fromCenter(center: Offset.zero, width: width, height: height),
      outlinePaint,
    );
  }

  void _drawSkirtTemplate(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Color(template['color'] ?? Colors.blue.value)
          ..style = PaintingStyle.fill;

    final width = size.width * (dimensions['width'] ?? 1.0);
    final height =
        size.height * (dimensions['height'] ?? 1.0) * 0.6; // Más corta
    final waistWidth = width * (dimensions['waist_width'] ?? 0.7);
    final hipWidth = width * (dimensions['hip_width'] ?? 0.9);

    // Forma de la falda
    final skirtPath = Path();
    skirtPath.moveTo(-waistWidth / 2, -height / 2);
    skirtPath.lineTo(waistWidth / 2, -height / 2);
    skirtPath.lineTo(hipWidth / 2, height / 2);
    skirtPath.lineTo(-hipWidth / 2, height / 2);
    skirtPath.close();

    canvas.drawPath(skirtPath, paint);
  }

  void _drawBlouseTemplate(Canvas canvas, Size size) {
    _drawShirtTemplate(canvas, size); // Similar a camiseta pero más elegante

    // Agregar detalles de blusa
    final detailPaint =
        Paint()
          ..color = Colors.white.withOpacity(0.3)
          ..style = PaintingStyle.fill;

    // Detalles decorativos
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(0, -size.height / 4),
        width: size.width * 0.8,
        height: 4,
      ),
      detailPaint,
    );
  }

  void _drawSleeves(Canvas canvas, Size size, Paint paint) {
    final sleeveLength = (dimensions['sleeve_length'] ?? 0.6);
    final sleeveWidth = size.width * 0.2;
    final sleeveHeight = size.height * sleeveLength;

    // Manga izquierda
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(-size.width * 0.4, -size.height * 0.3),
          width: sleeveWidth,
          height: sleeveHeight,
        ),
        const Radius.circular(8),
      ),
      paint,
    );

    // Manga derecha
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(size.width * 0.4, -size.height * 0.3),
          width: sleeveWidth,
          height: sleeveHeight,
        ),
        const Radius.circular(8),
      ),
      paint,
    );
  }

  void _drawCollar(Canvas canvas, Size size, Paint paint) {
    final collarType = details['collar_type'] ?? 'Round';
    final collarHeight = (dimensions['collar_height'] ?? 0.1) * size.height;

    final collarPaint =
        Paint()
          ..color = paint.color.withOpacity(0.8)
          ..style = PaintingStyle.fill;

    switch (collarType) {
      case 'Round':
        canvas.drawCircle(
          Offset(0, -size.height / 2 + collarHeight / 2),
          collarHeight,
          collarPaint,
        );
        break;
      case 'V-neck':
        final vPath = Path();
        vPath.moveTo(-collarHeight, -size.height / 2);
        vPath.lineTo(0, -size.height / 2 + collarHeight);
        vPath.lineTo(collarHeight, -size.height / 2);
        canvas.drawPath(vPath, collarPaint);
        break;
      case 'Polo':
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset(0, -size.height / 2 + collarHeight / 2),
            width: collarHeight * 2,
            height: collarHeight,
          ),
          collarPaint,
        );
        break;
    }
  }

  void _drawButtons(Canvas canvas, Size size) {
    final buttonCount = details['button_count'] as int;
    final buttonPaint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;

    for (int i = 0; i < buttonCount; i++) {
      final y = -size.height / 3 + (i * size.height / (buttonCount + 1));
      canvas.drawCircle(Offset(0, y), 4, buttonPaint);
    }
  }

  void _drawPockets(Canvas canvas, Size size) {
    final pocketCount = details['pocket_count'] as int;
    final pocketPaint =
        Paint()
          ..color = Colors.black.withOpacity(0.2)
          ..style = PaintingStyle.fill;

    if (pocketCount >= 1) {
      // Bolsillo izquierdo
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(-size.width * 0.2, size.height * 0.1),
            width: size.width * 0.15,
            height: size.height * 0.1,
          ),
          const Radius.circular(4),
        ),
        pocketPaint,
      );
    }

    if (pocketCount >= 2) {
      // Bolsillo derecho
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(size.width * 0.2, size.height * 0.1),
            width: size.width * 0.15,
            height: size.height * 0.1,
          ),
          const Radius.circular(4),
        ),
        pocketPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant Template3DPreviewPainter oldDelegate) {
    return template != oldDelegate.template ||
        dimensions != oldDelegate.dimensions ||
        details != oldDelegate.details ||
        animationValue != oldDelegate.animationValue;
  }
}
