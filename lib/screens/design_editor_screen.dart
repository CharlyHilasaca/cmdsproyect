import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/design_canvas.dart';
import '../widgets/color_palette.dart';
import '../widgets/pattern_selector.dart';
import '../widgets/size_selector.dart';

class DesignEditorScreen extends StatefulWidget {
  final Map<String, dynamic> garmentCategory;

  const DesignEditorScreen({super.key, required this.garmentCategory});

  @override
  State<DesignEditorScreen> createState() => _DesignEditorScreenState();
}

class _DesignEditorScreenState extends State<DesignEditorScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _designNameController;
  bool _isSaving = false;

  // Estado del diseño
  Map<String, dynamic> _currentDesign = {};

  // Configuraciones de diseño
  Color _selectedColor = Colors.blue;
  String _selectedPattern = 'solid';
  String _selectedSize = 'M';
  List<Color> _colorPalette = [];

  // Herramientas de diseño
  final List<Map<String, dynamic>> _tools = [
    {
      'name': 'Colores',
      'icon': Icons.palette,
      'description': 'Selecciona el color principal',
    },
    {
      'name': 'Patrones',
      'icon': Icons.texture,
      'description': 'Elige patrones y texturas',
    },
    {
      'name': 'Tallas',
      'icon': Icons.straighten,
      'description': 'Configura las dimensiones',
    },
    {
      'name': 'Vista 3D',
      'icon': Icons.view_in_ar,
      'description': 'Visualización tridimensional',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tools.length, vsync: this);
    _designNameController = TextEditingController();
    _initializeDesign();
    _generateColorPalette();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _designNameController.dispose();
    super.dispose();
  }

  void _initializeDesign() {
    _currentDesign = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'garmentType': widget.garmentCategory['id'],
      'category': widget.garmentCategory['name'],
      'name': 'Nuevo ${widget.garmentCategory['name']}',
      'colors': {
        'primary': _selectedColor.value,
        'secondary': Colors.white.value,
        'accent': widget.garmentCategory['color'].value,
      },
      'pattern': _selectedPattern,
      'size': _selectedSize,
      'customizations': {
        'logo_position': 'center',
        'text_content': '',
        'graphics': [],
      },
      'dimensions': {
        'width': 1.0,
        'height': 1.0,
        'sleeve_length': 0.6,
        'collar_size': 0.1,
      },
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };

    _designNameController.text = _currentDesign['name'];
  }

  void _generateColorPalette() {
    final baseColor = widget.garmentCategory['color'] as Color;
    _colorPalette = [
      Colors.white,
      Colors.black,
      Colors.grey,
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
      Colors.pink,
      Colors.teal,
      Colors.brown,
    ];
    
    // Solo agregar el color base si no está ya en la paleta
    if (!_colorPalette.any((color) => color.value == baseColor.value)) {
      _colorPalette.insert(0, baseColor);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Editor de Diseño',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            Text(
              widget.garmentCategory['name'],
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
        backgroundColor: widget.garmentCategory['color'],
        elevation: 0,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _showSaveDialog,
            icon: const Icon(Icons.save),
            tooltip: 'Guardar diseño',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          tabs:
              _tools
                  .map(
                    (tool) => Tab(icon: Icon(tool['icon']), text: tool['name']),
                  )
                  .toList(),
        ),
      ),
      body: Column(
        children: [
          // Canvas de diseño
          Expanded(
            flex: 3,
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: DesignCanvas(
                  garmentType: widget.garmentCategory['id'],
                  design: _currentDesign,
                  onDesignChange: _updateDesign,
                ),
              ),
            ),
          ),

          // Panel de herramientas
          Expanded(
            flex: 2,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  // Handle del panel
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Contenido de las pestañas
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildColorTool(),
                        _buildPatternTool(),
                        _buildSizeTool(),
                        _build3DViewTool(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorTool() {
    return SingleChildScrollView(
      child: ColorPalette(
        selectedColor: _selectedColor,
        colors: _colorPalette,
        onColorSelected: (color) {
          setState(() {
            _selectedColor = color;
            _currentDesign['colors']['primary'] = color.value;
          });
          _updateDesign();
        },
      ),
    );
  }

  Widget _buildPatternTool() {
    return SingleChildScrollView(
      child: PatternSelector(
        selectedPattern: _selectedPattern,
        onPatternSelected: (pattern) {
          setState(() {
            _selectedPattern = pattern;
            _currentDesign['pattern'] = pattern;
          });
          _updateDesign();
        },
      ),
    );
  }

  Widget _buildSizeTool() {
    return SingleChildScrollView(
      child: SizeSelector(
        selectedSize: _selectedSize,
        garmentType: widget.garmentCategory['key'] ?? 'shirt',
        onSizeChanged: (size) {
          setState(() {
            _selectedSize = size;
            _currentDesign['size'] = size;
          });
          _updateDesign();
        },
      ),
    );
  }

  Widget _build3DViewTool() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            'Vista 3D',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.view_in_ar, size: 64, color: Colors.grey.shade600),
                  const SizedBox(height: 16),
                  Text(
                    'Vista 3D de ${widget.garmentCategory['name']}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Aquí verás tu diseño en 3D',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Implementar vista 3D avanzada
                    },
                    icon: const Icon(Icons.rotate_right),
                    label: const Text('Rotar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.garmentCategory['color'],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _updateDesign() {
    _currentDesign['updatedAt'] = DateTime.now().toIso8601String();
    // Aquí puedes agregar lógica adicional para actualizar el diseño
  }

  void _showSaveDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Guardar Diseño'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _designNameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del diseño',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Tu diseño será guardado en la nube y podrás acceder a él desde cualquier dispositivo.',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _saveDesign();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.garmentCategory['color'],
                  foregroundColor: Colors.white,
                ),
                child: const Text('Guardar'),
              ),
            ],
          ),
    );
  }

  Future<void> _saveDesign() async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showErrorSnackBar('Debes iniciar sesión para guardar diseños');
        return;
      }

      // Actualizar datos del diseño
      _currentDesign['name'] =
          _designNameController.text.isNotEmpty
              ? _designNameController.text
              : 'Diseño ${widget.garmentCategory['name']}';

      final designData = {
        ..._currentDesign,
        'userId': user.uid,
        'userName': user.displayName ?? 'Usuario',
        'userEmail': user.email,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Guardar en Firestore
      await FirebaseFirestore.instance.collection('designs').add(designData);

      _showSuccessSnackBar('¡Diseño guardado exitosamente!');

      // Opcional: regresar a la pantalla anterior
      Navigator.pop(context);
    } catch (e) {
      _showErrorSnackBar('Error al guardar: $e');
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Ver Proyectos',
          textColor: Colors.white,
          onPressed: () {
            Navigator.popUntil(context, (route) => route.isFirst);
          },
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
