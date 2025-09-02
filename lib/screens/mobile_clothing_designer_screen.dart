import 'package:flutter/material.dart';
import '../widgets/advanced_3d_viewer.dart';
import '../widgets/template_3d_editor.dart';

class MobileClothingDesignerScreen extends StatefulWidget {
  final String category;
  final IconData icon;
  final Color color;

  const MobileClothingDesignerScreen({
    super.key,
    required this.category,
    required this.icon,
    required this.color,
  });

  @override
  State<MobileClothingDesignerScreen> createState() =>
      _MobileClothingDesignerScreenState();
}

class _MobileClothingDesignerScreenState
    extends State<MobileClothingDesignerScreen>
    with TickerProviderStateMixin {
  bool _isPanelVisible = false;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late TextEditingController _designNameController;

  Color _selectedColor = Colors.blue;
  String _selectedPattern = 'Sólido';
  String _selectedSize = 'M';

  // Diseño actual del modelo 3D
  Map<String, dynamic> _currentDesign = {};

  final List<Color> _availableColors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.purple,
    Colors.orange,
    Colors.pink,
    Colors.teal,
    Colors.brown,
    Colors.grey,
    Colors.black,
  ];

  final List<String> _availablePatterns = [
    'Sólido',
    'Rayas',
    'Cuadros',
    'Puntos',
    'Floral',
  ];

  final List<String> _availableSizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL'];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _designNameController = TextEditingController();

    // Inicializar diseño por defecto
    _currentDesign = {
      'garment_type': widget.category.toLowerCase(),
      'colors': [
        _selectedColor,
      ], // Cambio: usar Color directamente en lugar de .value
      'pattern': 'solid',
      'size': _selectedSize,
      'name': 'Diseño ${widget.category}',
    };
  }

  @override
  void dispose() {
    _animationController.dispose();
    _designNameController.dispose();
    super.dispose();
  }

  void _togglePanel() {
    setState(() {
      _isPanelVisible = !_isPanelVisible;
    });

    if (_isPanelVisible) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _openTemplateEditor() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => Template3DEditor(
              currentTemplate: _currentDesign,
              onTemplateChanged: (design) {
                setState(() {
                  _currentDesign = design;
                  // Actualizar colores y patrones si están presentes
                  if (design['color'] != null) {
                    final colorValue = design['color'];
                    if (colorValue is Color) {
                      _selectedColor = colorValue;
                    } else if (colorValue is int) {
                      _selectedColor = Color(colorValue);
                    } else {
                      _selectedColor = Colors.blue;
                    }
                  }
                  if (design['pattern'] != null) {
                    _selectedPattern = _getPatternDisplayName(
                      design['pattern'],
                    );
                  }
                });
              },
            ),
      ),
    );
  }

  String _getPatternDisplayName(String pattern) {
    switch (pattern) {
      case 'solid':
        return 'Sólido';
      case 'stripes':
        return 'Rayas';
      case 'checks':
        return 'Cuadros';
      case 'dots':
        return 'Puntos';
      case 'floral':
        return 'Floral';
      default:
        return 'Sólido';
    }
  }

  String _getPatternValue(String displayName) {
    switch (displayName) {
      case 'Sólido':
        return 'solid';
      case 'Rayas':
        return 'stripes';
      case 'Cuadros':
        return 'checks';
      case 'Puntos':
        return 'dots';
      case 'Floral':
        return 'floral';
      default:
        return 'solid';
    }
  }

  Color _getCurrentDisplayColor() {
    if (_currentDesign['colors'] != null &&
        (_currentDesign['colors'] as List).isNotEmpty) {
      final colorValue = _currentDesign['colors'][0];
      if (colorValue is Color) {
        return colorValue;
      } else if (colorValue is int) {
        return Color(colorValue);
      }
    }
    return Colors.blue;
  }

  void _updateDesign() {
    setState(() {
      _currentDesign = {
        ..._currentDesign,
        'colors': [
          _selectedColor,
        ], // Cambio: usar Color directamente en lugar de .value
        'pattern': _getPatternValue(_selectedPattern),
        'size': _selectedSize,
        'name':
            _designNameController.text.isNotEmpty
                ? _designNameController.text
                : 'Diseño ${widget.category}',
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Diseñar ${widget.category}',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: widget.color,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Visor 3D Principal - Simplificado
                  Container(
                    width: double.infinity,
                    height: 400,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Advanced3DViewer(
                        design: _currentDesign,
                        onDesignChanged: (design) {
                          setState(() {
                            _currentDesign = design;
                            // Actualizar colores y patrones si están presentes
                            if (design['color'] != null) {
                              final colorValue = design['color'];
                              if (colorValue is Color) {
                                _selectedColor = colorValue;
                              } else if (colorValue is int) {
                                _selectedColor = Color(colorValue);
                              } else {
                                _selectedColor = Colors.blue;
                              }
                            }
                            if (design['pattern'] != null) {
                              _selectedPattern = _getPatternDisplayName(
                                design['pattern'],
                              );
                            }
                          });
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Información del diseño actual
                  if (_currentDesign.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.style, color: widget.color, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Diseño Actual: ${_currentDesign['name'] ?? 'Personalizado'}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: widget.color,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Text(
                                'Patrón: ',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                _getPatternDisplayName(
                                  _currentDesign['pattern'] ?? 'solid',
                                ),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 16),
                              if (_currentDesign['colors'] != null &&
                                  (_currentDesign['colors'] as List)
                                      .isNotEmpty) ...[
                                const Text(
                                  'Color: ',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: _getCurrentDisplayColor(),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.grey[300]!,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),

                  // Botón personalizar (único)
                  Container(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _togglePanel,
                      icon: Icon(
                        _isPanelVisible
                            ? Icons.keyboard_arrow_down
                            : Icons.tune,
                        color: Colors.white,
                      ),
                      label: Text(
                        _isPanelVisible ? 'Ocultar Panel' : 'Personalizar',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.color,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  // Panel de personalización
                  AnimatedBuilder(
                    animation: _slideAnimation,
                    builder: (context, child) {
                      return Container(
                        height: _slideAnimation.value * 400,
                        child: SingleChildScrollView(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            margin: const EdgeInsets.only(top: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Center(
                                  child: Text(
                                    'Personalizar ${widget.category}',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: widget.color,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // Nombre del diseño
                                _buildSectionTitle('Nombre del Diseño'),
                                TextField(
                                  controller: _designNameController,
                                  decoration: InputDecoration(
                                    hintText:
                                        'Ingresa un nombre para tu diseño',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                  ),
                                  onChanged: (value) => _updateDesign(),
                                ),
                                const SizedBox(height: 20),

                                // Selector de colores
                                _buildSectionTitle('Color Principal'),
                                _buildColorSelector(),
                                const SizedBox(height: 20),

                                // Selector de patrones
                                _buildSectionTitle('Patrón'),
                                _buildPatternSelector(),
                                const SizedBox(height: 20),

                                // Selector de tallas
                                _buildSectionTitle('Talla'),
                                _buildSizeSelector(),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      // Solo un FAB para el editor de plantillas
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openTemplateEditor,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.auto_fix_high),
        label: const Text('Editor 3D'),
        tooltip: 'Abrir Editor de Plantillas 3D',
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 16,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildColorSelector() {
    return Container(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _availableColors.length,
        itemBuilder: (context, index) {
          final color = _availableColors[index];
          final isSelected = _selectedColor == color;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedColor = color;
              });
              _updateDesign();
            },
            child: Container(
              width: 50,
              height: 50,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.black : Colors.grey[300]!,
                  width: isSelected ? 3 : 1,
                ),
                boxShadow:
                    isSelected
                        ? [
                          BoxShadow(
                            color: color.withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                        : null,
              ),
              child:
                  isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 20)
                      : null,
            ),
          );
        },
      ),
    );
  }

  Widget _buildPatternSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          _availablePatterns.map((pattern) {
            final isSelected = _selectedPattern == pattern;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedPattern = pattern;
                });
                _updateDesign();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? widget.color : Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? widget.color : Colors.grey[300]!,
                  ),
                ),
                child: Text(
                  pattern,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }

  Widget _buildSizeSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          _availableSizes.map((size) {
            final isSelected = _selectedSize == size;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedSize = size;
                });
                _updateDesign();
              },
              child: Container(
                width: 50,
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected ? widget.color : Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? widget.color : Colors.grey[300]!,
                  ),
                ),
                child: Center(
                  child: Text(
                    size,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }
}
