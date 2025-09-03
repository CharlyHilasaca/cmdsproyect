import 'package:flutter/material.dart';

class ColorPalette extends StatelessWidget {
  final Color selectedColor;
  final List<Color> colors;
  final Function(Color) onColorSelected;

  const ColorPalette({
    super.key,
    required this.selectedColor,
    required this.colors,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.palette, size: 24),
              const SizedBox(width: 8),
              const Text(
                'Paleta de Colores',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: selectedColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade400, width: 2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Grid de colores principales
          const Text(
            'Colores Principales',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),

          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: colors.map((color) => _buildColorButton(color)).toList(),
          ),

          const SizedBox(height: 24),

          // Selector de tonalidades
          const Text(
            'Tonalidades',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),

          _buildColorShades(),

          const SizedBox(height: 24),

          // Información del color seleccionado
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: selectedColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Color Seleccionado',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getColorName(selectedColor),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        '#${selectedColor.value.toRadixString(16).substring(2).toUpperCase()}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorButton(Color color) {
    final isSelected = color.value == selectedColor.value;

    return GestureDetector(
      onTap: () => onColorSelected(color),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.black : Colors.grey.shade400,
            width: isSelected ? 3 : 2,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: color.withOpacity(0.5),
                blurRadius: 8,
                spreadRadius: 2,
              ),
          ],
        ),
        child:
            isSelected
                ? const Icon(Icons.check, color: Colors.white, size: 24)
                : null,
      ),
    );
  }

  Widget _buildColorShades() {
    return Container(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 10,
        itemBuilder: (context, index) {
          final opacity = 0.2 + (0.8 / 9) * index;
          final shadeColor = selectedColor.withOpacity(opacity);
          final solidColor =
              Color.lerp(Colors.white, selectedColor, opacity) ?? selectedColor;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onColorSelected(solidColor),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: solidColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade400),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _getColorName(Color color) {
    if (color.value == Colors.red.value) return 'Rojo';
    if (color.value == Colors.blue.value) return 'Azul';
    if (color.value == Colors.green.value) return 'Verde';
    if (color.value == Colors.yellow.value) return 'Amarillo';
    if (color.value == Colors.purple.value) return 'Morado';
    if (color.value == Colors.orange.value) return 'Naranja';
    if (color.value == Colors.pink.value) return 'Rosa';
    if (color.value == Colors.teal.value) return 'Verde Azulado';
    if (color.value == Colors.brown.value) return 'Marrón';
    if (color.value == Colors.grey.value) return 'Gris';
    if (color.value == Colors.black.value) return 'Negro';
    if (color.value == Colors.white.value) return 'Blanco';
    return 'Color Personalizado';
  }
}
