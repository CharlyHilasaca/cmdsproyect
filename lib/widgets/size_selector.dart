import 'package:flutter/material.dart';

class SizeSelector extends StatefulWidget {
  final String selectedSize;
  final Function(String) onSizeChanged;
  final String garmentType;

  const SizeSelector({
    Key? key,
    required this.selectedSize,
    required this.onSizeChanged,
    required this.garmentType,
  }) : super(key: key);

  @override
  State<SizeSelector> createState() => _SizeSelectorState();
}

class _SizeSelectorState extends State<SizeSelector> {
  late String _selectedSize;

  // Tallas estándar por tipo de prenda
  final Map<String, List<SizeOption>> _sizesByGarment = {
    'shirt': [
      SizeOption('XS', 'Extra Small', {'chest': '84-89', 'waist': '71-76'}),
      SizeOption('S', 'Small', {'chest': '89-94', 'waist': '76-81'}),
      SizeOption('M', 'Medium', {'chest': '94-99', 'waist': '81-86'}),
      SizeOption('L', 'Large', {'chest': '99-104', 'waist': '86-91'}),
      SizeOption('XL', 'Extra Large', {'chest': '104-109', 'waist': '91-96'}),
      SizeOption('XXL', '2X Large', {'chest': '109-114', 'waist': '96-101'}),
    ],
    'hoodie': [
      SizeOption('XS', 'Extra Small', {'chest': '86-91', 'length': '62'}),
      SizeOption('S', 'Small', {'chest': '91-96', 'length': '64'}),
      SizeOption('M', 'Medium', {'chest': '96-101', 'length': '66'}),
      SizeOption('L', 'Large', {'chest': '101-106', 'length': '68'}),
      SizeOption('XL', 'Extra Large', {'chest': '106-111', 'length': '70'}),
      SizeOption('XXL', '2X Large', {'chest': '111-116', 'length': '72'}),
    ],
    'pants': [
      SizeOption('28', 'Cintura 28"', {'waist': '71', 'inseam': '81'}),
      SizeOption('30', 'Cintura 30"', {'waist': '76', 'inseam': '81'}),
      SizeOption('32', 'Cintura 32"', {'waist': '81', 'inseam': '84'}),
      SizeOption('34', 'Cintura 34"', {'waist': '86', 'inseam': '84'}),
      SizeOption('36', 'Cintura 36"', {'waist': '91', 'inseam': '86'}),
      SizeOption('38', 'Cintura 38"', {'waist': '96', 'inseam': '86'}),
    ],
    'dress': [
      SizeOption('XS', 'Extra Small', {
        'bust': '81-84',
        'waist': '64-66',
        'hips': '89-91',
      }),
      SizeOption('S', 'Small', {
        'bust': '84-89',
        'waist': '66-71',
        'hips': '91-96',
      }),
      SizeOption('M', 'Medium', {
        'bust': '89-94',
        'waist': '71-76',
        'hips': '96-101',
      }),
      SizeOption('L', 'Large', {
        'bust': '94-99',
        'waist': '76-81',
        'hips': '101-106',
      }),
      SizeOption('XL', 'Extra Large', {
        'bust': '99-104',
        'waist': '81-86',
        'hips': '106-111',
      }),
      SizeOption('XXL', '2X Large', {
        'bust': '104-109',
        'waist': '86-91',
        'hips': '111-116',
      }),
    ],
    'jacket': [
      SizeOption('XS', 'Extra Small', {
        'chest': '86-89',
        'length': '58',
        'sleeve': '58',
      }),
      SizeOption('S', 'Small', {
        'chest': '89-94',
        'length': '60',
        'sleeve': '59',
      }),
      SizeOption('M', 'Medium', {
        'chest': '94-99',
        'length': '62',
        'sleeve': '60',
      }),
      SizeOption('L', 'Large', {
        'chest': '99-104',
        'length': '64',
        'sleeve': '61',
      }),
      SizeOption('XL', 'Extra Large', {
        'chest': '104-109',
        'length': '66',
        'sleeve': '62',
      }),
      SizeOption('XXL', '2X Large', {
        'chest': '109-114',
        'length': '68',
        'sleeve': '63',
      }),
    ],
    'shoes': [
      SizeOption('35', 'EU 35 / US 5', {'length': '22.5'}),
      SizeOption('36', 'EU 36 / US 6', {'length': '23.0'}),
      SizeOption('37', 'EU 37 / US 6.5', {'length': '23.5'}),
      SizeOption('38', 'EU 38 / US 7.5', {'length': '24.0'}),
      SizeOption('39', 'EU 39 / US 8', {'length': '24.5'}),
      SizeOption('40', 'EU 40 / US 9', {'length': '25.0'}),
      SizeOption('41', 'EU 41 / US 9.5', {'length': '25.5'}),
      SizeOption('42', 'EU 42 / US 10.5', {'length': '26.0'}),
      SizeOption('43', 'EU 43 / US 11', {'length': '26.5'}),
      SizeOption('44', 'EU 44 / US 11.5', {'length': '27.0'}),
      SizeOption('45', 'EU 45 / US 12.5', {'length': '27.5'}),
    ],
  };

  @override
  void initState() {
    super.initState();
    _selectedSize = widget.selectedSize;
  }

  List<SizeOption> get _availableSizes {
    return _sizesByGarment[widget.garmentType] ?? _sizesByGarment['shirt']!;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.grey.shade50, Colors.white],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado con información del tipo de prenda
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(_getGarmentIcon(), color: Colors.blue.shade600, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tallas disponibles para ${_getGarmentDisplayName()}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Selecciona la talla que mejor se ajuste',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Grid de tallas
          Text(
            'Tallas Disponibles:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 16),

          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.5,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _availableSizes.length,
              itemBuilder: (context, index) {
                final size = _availableSizes[index];
                final isSelected = _selectedSize == size.code;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedSize = size.code;
                    });
                    widget.onSizeChanged(size.code);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue.shade600 : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color:
                            isSelected
                                ? Colors.blue.shade600
                                : Colors.grey.shade300,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                              isSelected
                                  ? Colors.blue.shade600.withOpacity(0.3)
                                  : Colors.grey.withOpacity(0.2),
                          blurRadius: isSelected ? 8 : 4,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            size.code,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color:
                                  isSelected
                                      ? Colors.white
                                      : Colors.blue.shade600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            size.name,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color:
                                  isSelected
                                      ? Colors.white.withOpacity(0.9)
                                      : Colors.grey.shade600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 6),
                          // Mostrar medidas principales
                          Column(
                            children:
                                size.measurements.entries.take(2).map((entry) {
                                  return Text(
                                    '${_getMeasurementLabel(entry.key)}: ${entry.value}cm',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color:
                                          isSelected
                                              ? Colors.white.withOpacity(0.8)
                                              : Colors.grey.shade500,
                                    ),
                                  );
                                }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Información detallada de la talla seleccionada
          if (_selectedSize.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green.shade600,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Talla seleccionada: $_selectedSize',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Medidas detalladas:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.green.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ...(_getSelectedSize()?.measurements.entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 8, top: 2),
                          child: Text(
                            '• ${_getMeasurementLabel(entry.key)}: ${entry.value}cm',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.green.shade600,
                            ),
                          ),
                        );
                      }) ??
                      []),
                ],
              ),
            ),
        ],
      ),
    );
  }

  SizeOption? _getSelectedSize() {
    return _availableSizes.firstWhere(
      (size) => size.code == _selectedSize,
      orElse: () => _availableSizes.first,
    );
  }

  IconData _getGarmentIcon() {
    switch (widget.garmentType) {
      case 'shirt':
        return Icons.checkroom;
      case 'hoodie':
        return Icons.checkroom_outlined;
      case 'pants':
        return Icons.content_cut;
      case 'dress':
        return Icons.woman;
      case 'jacket':
        return Icons.dry_cleaning;
      case 'shoes':
        return Icons.local_mall;
      default:
        return Icons.checkroom;
    }
  }

  String _getGarmentDisplayName() {
    switch (widget.garmentType) {
      case 'shirt':
        return 'Camisa/Camiseta';
      case 'hoodie':
        return 'Sudadera';
      case 'pants':
        return 'Pantalón';
      case 'dress':
        return 'Vestido';
      case 'jacket':
        return 'Chaqueta';
      case 'shoes':
        return 'Zapatos';
      default:
        return 'Prenda';
    }
  }

  String _getMeasurementLabel(String key) {
    switch (key) {
      case 'chest':
        return 'Pecho';
      case 'waist':
        return 'Cintura';
      case 'hips':
        return 'Cadera';
      case 'length':
        return 'Largo';
      case 'sleeve':
        return 'Manga';
      case 'inseam':
        return 'Entrepierna';
      case 'bust':
        return 'Busto';
      default:
        return key.toUpperCase();
    }
  }
}

class SizeOption {
  final String code;
  final String name;
  final Map<String, String> measurements;

  SizeOption(this.code, this.name, this.measurements);
}
