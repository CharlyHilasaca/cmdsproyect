import 'package:flutter/material.dart';

class Model3DCreator extends StatefulWidget {
  final Function(Map<String, dynamic>)? onModelCreated;

  const Model3DCreator({
    super.key,
    this.onModelCreated,
  });

  @override
  State<Model3DCreator> createState() => _Model3DCreatorState();
}

class _Model3DCreatorState extends State<Model3DCreator>
    with TickerProviderStateMixin {
  
  // Primitivas 3D disponibles
  final List<Map<String, dynamic>> _primitives = [
    {
      'name': 'Cubo',
      'icon': Icons.view_in_ar,
      'type': 'cube',
      'description': 'Forma básica cúbica',
    },
    {
      'name': 'Esfera',
      'icon': Icons.circle,
      'type': 'sphere',
      'description': 'Forma esférica perfecta',
    },
    {
      'name': 'Cilindro',
      'icon': Icons.circle_outlined,
      'type': 'cylinder',
      'description': 'Forma cilíndrica',
    },
    {
      'name': 'Cono',
      'icon': Icons.change_history,
      'type': 'cone',
      'description': 'Forma cónica',
    },
    {
      'name': 'Plano',
      'icon': Icons.crop_square,
      'type': 'plane',
      'description': 'Superficie plana',
    },
    {
      'name': 'Camiseta',
      'icon': Icons.checkroom,
      'type': 'tshirt',
      'description': 'Plantilla de camiseta',
    },
    {
      'name': 'Pantalón',
      'icon': Icons.dry_cleaning,
      'type': 'pants',
      'description': 'Plantilla de pantalón',
    },
    {
      'name': 'Vestido',
      'icon': Icons.woman,
      'type': 'dress',
      'description': 'Plantilla de vestido',
    },
  ];

  // Objetos en la escena
  List<Map<String, dynamic>> _sceneObjects = [];
  Map<String, dynamic>? _selectedObject;
  
  // Herramientas
  String _currentTool = 'select';
  
  // Propiedades de creación
  String _objectName = '';
  String _objectCategory = 'ropa';
  Color _objectColor = Colors.blue;
  
  // Controles de cámara
  double _cameraDistance = 10.0;
  double _cameraAngleX = 0.0;
  double _cameraAngleY = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F23),
      appBar: AppBar(
        title: const Text('Motor de Creación 3D'),
        backgroundColor: const Color(0xFF1A1A2E),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _saveProject,
            icon: const Icon(Icons.save),
            tooltip: 'Guardar Proyecto',
          ),
          IconButton(
            onPressed: _exportModel,
            icon: const Icon(Icons.download),
            tooltip: 'Exportar Modelo',
          ),
        ],
      ),
      body: Row(
        children: [
          // Panel de herramientas lateral
          _buildToolsPanel(),
          
          // Viewport 3D principal
          Expanded(
            flex: 3,
            child: _build3DViewport(),
          ),
          
          // Panel de propiedades
          _buildPropertiesPanel(),
        ],
      ),
      floatingActionButton: _buildQuickActions(),
    );
  }

  Widget _buildToolsPanel() {
    return Container(
      width: 250,
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A2E),
        border: Border(
          right: BorderSide(color: Color(0xFF16213E)),
        ),
      ),
      child: Column(
        children: [
          // Herramientas de selección
          _buildToolSection(
            'Herramientas',
            [
              _buildToolButton(
                icon: Icons.touch_app,
                label: 'Seleccionar',
                tool: 'select',
              ),
              _buildToolButton(
                icon: Icons.open_with,
                label: 'Mover',
                tool: 'move',
              ),
              _buildToolButton(
                icon: Icons.threesixty,
                label: 'Rotar',
                tool: 'rotate',
              ),
              _buildToolButton(
                icon: Icons.zoom_out_map,
                label: 'Escalar',
                tool: 'scale',
              ),
            ],
          ),
          
          const Divider(color: Color(0xFF16213E)),
          
          // Primitivas 3D
          Expanded(
            child: _buildPrimitivesSection(),
          ),
        ],
      ),
    );
  }

  Widget _buildToolSection(String title, List<Widget> tools) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tools,
          ),
        ],
      ),
    );
  }

  Widget _buildToolButton({
    required IconData icon,
    required String label,
    required String tool,
  }) {
    final isSelected = _currentTool == tool;
    
    return GestureDetector(
      onTap: () => setState(() => _currentTool = tool),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6C63FF) : const Color(0xFF0F0F23),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF6C63FF) : const Color(0xFF16213E),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : const Color(0xFF8892B0),
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF8892B0),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrimitivesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Primitivas 3D',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _primitives.length,
            itemBuilder: (context, index) {
              final primitive = _primitives[index];
              return _buildPrimitiveCard(primitive);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPrimitiveCard(Map<String, dynamic> primitive) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F23),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF16213E)),
      ),
      child: ListTile(
        leading: Icon(
          primitive['icon'],
          color: const Color(0xFF6C63FF),
        ),
        title: Text(
          primitive['name'],
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
        subtitle: Text(
          primitive['description'],
          style: const TextStyle(color: Color(0xFF8892B0), fontSize: 12),
        ),
        onTap: () => _addPrimitiveToScene(primitive),
      ),
    );
  }

  Widget _build3DViewport() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0F0F23),
        border: Border.symmetric(
          vertical: BorderSide(color: Color(0xFF16213E)),
        ),
      ),
      child: Stack(
        children: [
          // Grid del viewport
          _buildViewportGrid(),
          
          // Objetos 3D renderizados
          _buildSceneObjects(),
          
          // Controles de cámara
          _buildCameraControls(),
          
          // HUD de información
          _buildViewportHUD(),
        ],
      ),
    );
  }

  Widget _buildViewportGrid() {
    return CustomPaint(
      size: Size.infinite,
      painter: GridPainter(),
    );
  }

  Widget _buildSceneObjects() {
    return Stack(
      children: _sceneObjects.map((obj) => _buildSceneObject(obj)).toList(),
    );
  }

  Widget _buildSceneObject(Map<String, dynamic> object) {
    final isSelected = _selectedObject?['id'] == object['id'];
    
    return Positioned(
      left: object['position']['x'] * 100.0 + 200,
      top: object['position']['y'] * 100.0 + 200,
      child: GestureDetector(
        onTap: () => _selectObject(object),
        onPanUpdate: (details) => _updateObjectPosition(object, details),
        child: Container(
          width: object['scale'] * 50.0,
          height: object['scale'] * 50.0,
          decoration: BoxDecoration(
            color: Color(object['color']).withOpacity(0.8),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? const Color(0xFF6C63FF) : Colors.transparent,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(2, 2),
              ),
            ],
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  object['icon'],
                  color: Colors.white,
                  size: object['scale'] * 20.0,
                ),
                if (object['scale'] > 1.0)
                  Text(
                    object['name'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCameraControls() {
    return Positioned(
      top: 20,
      left: 20,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF16213E)),
        ),
        child: Column(
          children: [
            IconButton(
              onPressed: () => setState(() => _cameraDistance -= 1),
              icon: const Icon(Icons.zoom_in, color: Colors.white),
            ),
            IconButton(
              onPressed: () => setState(() => _cameraDistance += 1),
              icon: const Icon(Icons.zoom_out, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewportHUD() {
    return Positioned(
      bottom: 20,
      left: 20,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E).withOpacity(0.9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Objetos: ${_sceneObjects.length}',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
            Text(
              'Herramienta: $_currentTool',
              style: const TextStyle(color: Color(0xFF8892B0), fontSize: 12),
            ),
            if (_selectedObject != null)
              Text(
                'Seleccionado: ${_selectedObject!['name']}',
                style: const TextStyle(color: Color(0xFF6C63FF), fontSize: 12),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertiesPanel() {
    return Container(
      width: 300,
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A2E),
        border: Border(
          left: BorderSide(color: Color(0xFF16213E)),
        ),
      ),
      child: _selectedObject != null
          ? _buildObjectProperties()
          : _buildSceneProperties(),
    );
  }

  Widget _buildObjectProperties() {
    if (_selectedObject == null) return Container();
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Propiedades del Objeto',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          
          // Nombre del objeto
          TextFormField(
            initialValue: _selectedObject!['name'],
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Nombre',
              labelStyle: TextStyle(color: Color(0xFF8892B0)),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF16213E)),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _selectedObject!['name'] = value;
              });
            },
          ),
          
          const SizedBox(height: 16),
          
          // Transformaciones
          const Text(
            'Transformación',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          
          _buildSlider(
            'Escala',
            _selectedObject!['scale'],
            0.1,
            3.0,
            (value) => setState(() => _selectedObject!['scale'] = value),
          ),
          
          // Color
          const SizedBox(height: 16),
          const Text(
            'Apariencia',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          
          GestureDetector(
            onTap: _showColorPicker,
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Color(_selectedObject!['color']),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF16213E)),
              ),
              child: const Center(
                child: Text(
                  'Cambiar Color',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Acciones del objeto
          ElevatedButton.icon(
            onPressed: _duplicateObject,
            icon: const Icon(Icons.copy),
            label: const Text('Duplicar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: _deleteObject,
            icon: const Icon(Icons.delete),
            label: const Text('Eliminar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSceneProperties() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Propiedades de la Escena',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          
          Text(
            'Objetos en la escena: ${_sceneObjects.length}',
            style: const TextStyle(color: Color(0xFF8892B0)),
          ),
          
          const SizedBox(height: 20),
          
          ElevatedButton.icon(
            onPressed: _clearScene,
            icon: const Icon(Icons.clear_all),
            label: const Text('Limpiar Escena'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlider(
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ${value.toStringAsFixed(2)}',
          style: const TextStyle(color: Color(0xFF8892B0), fontSize: 12),
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          onChanged: onChanged,
          activeColor: const Color(0xFF6C63FF),
          inactiveColor: const Color(0xFF16213E),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          heroTag: 'create',
          onPressed: _showCreateDialog,
          backgroundColor: const Color(0xFF4CAF50),
          child: const Icon(Icons.add),
        ),
        const SizedBox(height: 8),
        FloatingActionButton(
          heroTag: 'undo',
          onPressed: _undo,
          backgroundColor: const Color(0xFFFF9800),
          child: const Icon(Icons.undo),
        ),
      ],
    );
  }

  // Métodos de funcionalidad

  void _addPrimitiveToScene(Map<String, dynamic> primitive) {
    final newObject = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'name': '${primitive['name']} ${_sceneObjects.length + 1}',
      'type': primitive['type'],
      'icon': primitive['icon'],
      'position': {'x': 0.0, 'y': 0.0, 'z': 0.0},
      'rotation': {'x': 0.0, 'y': 0.0, 'z': 0.0},
      'scale': 1.0,
      'color': _objectColor.value,
    };
    
    setState(() {
      _sceneObjects.add(newObject);
      _selectedObject = newObject;
    });
  }

  void _selectObject(Map<String, dynamic> object) {
    setState(() {
      _selectedObject = object;
    });
  }

  void _updateObjectPosition(Map<String, dynamic> object, DragUpdateDetails details) {
    if (_currentTool == 'move') {
      setState(() {
        object['position']['x'] += details.delta.dx / 100.0;
        object['position']['y'] += details.delta.dy / 100.0;
      });
    }
  }

  void _duplicateObject() {
    if (_selectedObject != null) {
      final newObject = Map<String, dynamic>.from(_selectedObject!);
      newObject['id'] = DateTime.now().millisecondsSinceEpoch.toString();
      newObject['name'] = '${newObject['name']} Copia';
      newObject['position'] = {
        'x': newObject['position']['x'] + 1.0,
        'y': newObject['position']['y'] + 1.0,
        'z': newObject['position']['z'],
      };
      
      setState(() {
        _sceneObjects.add(newObject);
        _selectedObject = newObject;
      });
    }
  }

  void _deleteObject() {
    if (_selectedObject != null) {
      setState(() {
        _sceneObjects.removeWhere((obj) => obj['id'] == _selectedObject!['id']);
        _selectedObject = null;
      });
    }
  }

  void _clearScene() {
    setState(() {
      _sceneObjects.clear();
      _selectedObject = null;
    });
  }

  void _showColorPicker() {
    // Implementar selector de color
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seleccionar Color'),
        content: const Text('Selector de color próximamente'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showCreateDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text(
          'Crear Nuevo Modelo',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Nombre del modelo',
                labelStyle: TextStyle(color: Color(0xFF8892B0)),
              ),
              onChanged: (value) => _objectName = value,
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
              _createNewModel();
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }

  void _createNewModel() {
    // Implementar creación de modelo personalizado
  }

  void _undo() {
    // Implementar funcionalidad de deshacer
  }

  void _saveProject() async {
    try {
      // Convertir la escena a formato JSON
      final projectData = {
        'name': _objectName.isNotEmpty ? _objectName : 'Proyecto 3D',
        'category': _objectCategory,
        'objects': _sceneObjects,
        'camera': {
          'distance': _cameraDistance,
          'angleX': _cameraAngleX,
          'angleY': _cameraAngleY,
        },
        'createdAt': DateTime.now().toIso8601String(),
      };

      // Aquí implementarías el guardado en Firebase
      // Por ahora, solo mostramos un mensaje
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Proyecto guardado con éxito'),
          backgroundColor: Color(0xFF4CAF50),
        ),
      );

      if (widget.onModelCreated != null) {
        widget.onModelCreated!(projectData);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _exportModel() {
    // Implementar exportación del modelo
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Exportación próximamente'),
        backgroundColor: Color(0xFFFF9800),
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF16213E)
      ..strokeWidth = 1;

    const gridSize = 50.0;

    // Líneas verticales
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Líneas horizontales
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
