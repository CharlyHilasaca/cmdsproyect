import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

class Model3DViewer extends StatefulWidget {
  final String modelUrl;
  final String? textureUrl;
  final bool enableEditing;
  final Function(Map<String, dynamic>)? onModelChanged;
  final Map<String, dynamic>? initialTransform;

  const Model3DViewer({
    super.key,
    required this.modelUrl,
    this.textureUrl,
    this.enableEditing = false,
    this.onModelChanged,
    this.initialTransform,
  });

  @override
  State<Model3DViewer> createState() => _Model3DViewerState();
}

class _Model3DViewerState extends State<Model3DViewer>
    with TickerProviderStateMixin {
  
  // Controles de transformación
  double _rotationX = 0.0;
  double _rotationY = 0.0;
  double _rotationZ = 0.0;
  double _scale = 1.0;
  vector.Vector3 _position = vector.Vector3.zero();
  
  // Controles de iluminación
  double _lightIntensity = 1.0;
  Color _lightColor = Colors.white;
  
  // Controles de material
  Color _materialColor = Colors.grey;
  double _roughness = 0.5;
  double _metallic = 0.0;
  
  // Estado de la UI
  bool _showControls = false;
  String _selectedTool = 'rotate';

  @override
  void initState() {
    super.initState();
    _loadInitialTransform();
  }

  void _loadInitialTransform() {
    if (widget.initialTransform != null) {
      final transform = widget.initialTransform!;
      setState(() {
        _rotationX = transform['rotationX'] ?? 0.0;
        _rotationY = transform['rotationY'] ?? 0.0;
        _rotationZ = transform['rotationZ'] ?? 0.0;
        _scale = transform['scale'] ?? 1.0;
        _position = vector.Vector3(
          transform['positionX'] ?? 0.0,
          transform['positionY'] ?? 0.0,
          transform['positionZ'] ?? 0.0,
        );
      });
    }
  }

  Map<String, dynamic> _getCurrentTransform() {
    return {
      'rotationX': _rotationX,
      'rotationY': _rotationY,
      'rotationZ': _rotationZ,
      'scale': _scale,
      'positionX': _position.x,
      'positionY': _position.y,
      'positionZ': _position.z,
      'lightIntensity': _lightIntensity,
      'lightColor': _lightColor.value,
      'materialColor': _materialColor.value,
      'roughness': _roughness,
      'metallic': _metallic,
    };
  }

  void _notifyModelChanged() {
    if (widget.onModelChanged != null) {
      widget.onModelChanged!(_getCurrentTransform());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F23),
      body: Stack(
        children: [
          // Visor 3D principal
          _build3DViewer(),
          
          // Controles de edición (si están habilitados)
          if (widget.enableEditing) _buildEditingControls(),
          
          // Barra de herramientas flotante
          if (widget.enableEditing) _buildFloatingToolbar(),
          
          // Panel de propiedades (colapsable)
          if (widget.enableEditing && _showControls) _buildPropertiesPanel(),
        ],
      ),
    );
  }

  Widget _build3DViewer() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: ModelViewer(
        backgroundColor: const Color(0xFF1A1A2E),
        src: widget.modelUrl,
        alt: 'Modelo 3D',
        ar: false,
        autoRotate: false,
        disableZoom: false,
        disablePan: false,
        cameraControls: true,
        cameraOrbit: '${_rotationY}deg ${_rotationX}deg ${_scale * 5}m',
        environmentImage: 'assets/textures/studio_small_04_1k.hdr',
        exposure: _lightIntensity,
        shadowIntensity: 0.3,
        shadowSoftness: 0.5,
        loading: Loading.eager,
        onWebViewCreated: (controller) {
          // Configuración adicional del viewer
        },
      ),
    );
  }

  Widget _buildFloatingToolbar() {
    return Positioned(
      top: 60,
      left: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF6C63FF)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildToolButton(
              icon: Icons.threesixty,
              label: 'Rotar',
              isSelected: _selectedTool == 'rotate',
              onTap: () => setState(() => _selectedTool = 'rotate'),
            ),
            _buildToolButton(
              icon: Icons.open_with,
              label: 'Mover',
              isSelected: _selectedTool == 'move',
              onTap: () => setState(() => _selectedTool = 'move'),
            ),
            _buildToolButton(
              icon: Icons.zoom_in,
              label: 'Escalar',
              isSelected: _selectedTool == 'scale',
              onTap: () => setState(() => _selectedTool = 'scale'),
            ),
            _buildToolButton(
              icon: Icons.lightbulb,
              label: 'Luz',
              isSelected: _selectedTool == 'light',
              onTap: () => setState(() => _selectedTool = 'light'),
            ),
            _buildToolButton(
              icon: Icons.palette,
              label: 'Material',
              isSelected: _selectedTool == 'material',
              onTap: () => setState(() => _selectedTool = 'material'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: label,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(8),
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF6C63FF) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isSelected ? Colors.white : const Color(0xFF8892B0),
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildEditingControls() {
    return Positioned(
      bottom: 20,
      right: 20,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            mini: true,
            onPressed: () => setState(() => _showControls = !_showControls),
            backgroundColor: const Color(0xFF6C63FF),
            child: Icon(_showControls ? Icons.close : Icons.settings),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            mini: true,
            onPressed: _resetTransform,
            backgroundColor: const Color(0xFF4CAF50),
            child: const Icon(Icons.refresh),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            mini: true,
            onPressed: _saveModel,
            backgroundColor: const Color(0xFFFF9800),
            child: const Icon(Icons.save),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertiesPanel() {
    return Positioned(
      right: 20,
      top: 100,
      bottom: 100,
      width: 300,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF16213E)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Propiedades del Modelo',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _buildTransformControls(),
              const SizedBox(height: 20),
              _buildLightingControls(),
              const SizedBox(height: 20),
              _buildMaterialControls(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransformControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Transformación',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        _buildSlider(
          'Rotación X',
          _rotationX,
          -180,
          180,
          (value) => setState(() {
            _rotationX = value;
            _notifyModelChanged();
          }),
        ),
        _buildSlider(
          'Rotación Y',
          _rotationY,
          -180,
          180,
          (value) => setState(() {
            _rotationY = value;
            _notifyModelChanged();
          }),
        ),
        _buildSlider(
          'Escala',
          _scale,
          0.1,
          3.0,
          (value) => setState(() {
            _scale = value;
            _notifyModelChanged();
          }),
        ),
      ],
    );
  }

  Widget _buildLightingControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Iluminación',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        _buildSlider(
          'Intensidad',
          _lightIntensity,
          0.0,
          2.0,
          (value) => setState(() {
            _lightIntensity = value;
            _notifyModelChanged();
          }),
        ),
      ],
    );
  }

  Widget _buildMaterialControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Material',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        _buildSlider(
          'Rugosidad',
          _roughness,
          0.0,
          1.0,
          (value) => setState(() {
            _roughness = value;
            _notifyModelChanged();
          }),
        ),
        _buildSlider(
          'Metálico',
          _metallic,
          0.0,
          1.0,
          (value) => setState(() {
            _metallic = value;
            _notifyModelChanged();
          }),
        ),
      ],
    );
  }

  Widget _buildSlider(
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
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
      ),
    );
  }

  void _resetTransform() {
    setState(() {
      _rotationX = 0.0;
      _rotationY = 0.0;
      _rotationZ = 0.0;
      _scale = 1.0;
      _position = vector.Vector3.zero();
      _lightIntensity = 1.0;
      _roughness = 0.5;
      _metallic = 0.0;
    });
    _notifyModelChanged();
  }

  void _saveModel() {
    // Implementar guardado del modelo con las transformaciones actuales
    _notifyModelChanged();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Modelo guardado con éxito'),
        backgroundColor: Color(0xFF4CAF50),
      ),
    );
  }
}
