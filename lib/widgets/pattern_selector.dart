import 'package:flutter/material.dart';
import 'dart:math' as math;

class PatternSelector extends StatelessWidget {
  final String selectedPattern;
  final Function(String) onPatternSelected;

  const PatternSelector({
    super.key,
    required this.selectedPattern,
    required this.onPatternSelected,
  });

  final List<Map<String, dynamic>> patterns = const [
    {
      'id': 'solid',
      'name': 'Sólido',
      'description': 'Color liso sin patrones',
      'icon': Icons.circle,
    },
    {
      'id': 'stripes',
      'name': 'Rayas',
      'description': 'Patrón de rayas horizontales',
      'icon': Icons.view_headline,
    },
    {
      'id': 'dots',
      'name': 'Puntos',
      'description': 'Patrón de puntos distribuidos',
      'icon': Icons.fiber_manual_record,
    },
    {
      'id': 'checkered',
      'name': 'Cuadros',
      'description': 'Patrón de cuadros alternados',
      'icon': Icons.grid_4x4,
    },
    {
      'id': 'floral',
      'name': 'Floral',
      'description': 'Diseños con motivos florales',
      'icon': Icons.local_florist,
    },
    {
      'id': 'geometric',
      'name': 'Geométrico',
      'description': 'Formas geométricas abstractas',
      'icon': Icons.change_history,
    },
    {
      'id': 'tie_dye',
      'name': 'Tie Dye',
      'description': 'Efecto de teñido anudado',
      'icon': Icons.brush,
    },
    {
      'id': 'gradient',
      'name': 'Degradado',
      'description': 'Transición suave de colores',
      'icon': Icons.gradient,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.texture, size: 24),
              const SizedBox(width: 8),
              const Text(
                'Patrones y Texturas',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Text(
                  _getPatternName(selectedPattern),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          const Text(
            'Selecciona un patrón para tu diseño',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 16),

          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: patterns.length,
              itemBuilder: (context, index) {
                final pattern = patterns[index];
                final isSelected = pattern['id'] == selectedPattern;

                return _buildPatternCard(pattern, isSelected);
              },
            ),
          ),

          // Vista previa del patrón seleccionado
          Container(
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Vista Previa',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: CustomPaint(
                    painter: PatternPreviewPainter(selectedPattern),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _getPatternDescription(selectedPattern),
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatternCard(Map<String, dynamic> pattern, bool isSelected) {
    return Card(
      elevation: isSelected ? 8 : 2,
      shadowColor: isSelected ? Colors.blue.withOpacity(0.3) : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? Colors.blue : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () => onPatternSelected(pattern['id']),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color:
                      isSelected ? Colors.blue.shade50 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  pattern['icon'],
                  size: 28,
                  color: isSelected ? Colors.blue : Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                pattern['name'],
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.blue : Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                pattern['description'],
                style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getPatternName(String patternId) {
    final pattern = patterns.firstWhere(
      (p) => p['id'] == patternId,
      orElse: () => patterns.first,
    );
    return pattern['name'];
  }

  String _getPatternDescription(String patternId) {
    final pattern = patterns.firstWhere(
      (p) => p['id'] == patternId,
      orElse: () => patterns.first,
    );
    return pattern['description'];
  }
}

class PatternPreviewPainter extends CustomPainter {
  final String pattern;

  PatternPreviewPainter(this.pattern);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.blue.shade300
          ..style = PaintingStyle.fill;

    switch (pattern) {
      case 'solid':
        canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
        break;

      case 'stripes':
        for (int i = 0; i < 8; i++) {
          final y = (size.height / 8) * i;
          if (i % 2 == 0) {
            canvas.drawRect(
              Rect.fromLTWH(0, y, size.width, size.height / 8),
              paint,
            );
          }
        }
        break;

      case 'dots':
        for (int i = 0; i < 6; i++) {
          for (int j = 0; j < 4; j++) {
            final x = (size.width / 6) * i + (size.width / 12);
            final y = (size.height / 4) * j + (size.height / 8);
            canvas.drawCircle(Offset(x, y), 6, paint);
          }
        }
        break;

      case 'checkered':
        for (int i = 0; i < 8; i++) {
          for (int j = 0; j < 4; j++) {
            if ((i + j) % 2 == 0) {
              final x = (size.width / 8) * i;
              final y = (size.height / 4) * j;
              canvas.drawRect(
                Rect.fromLTWH(x, y, size.width / 8, size.height / 4),
                paint,
              );
            }
          }
        }
        break;

      case 'floral':
        // Dibujar flores simples
        for (int i = 0; i < 3; i++) {
          for (int j = 0; j < 2; j++) {
            final x = (size.width / 3) * i + (size.width / 6);
            final y = (size.height / 2) * j + (size.height / 4);
            _drawFlower(canvas, Offset(x, y), paint);
          }
        }
        break;

      case 'geometric':
        // Dibujar triángulos
        for (int i = 0; i < 4; i++) {
          for (int j = 0; j < 2; j++) {
            final x = (size.width / 4) * i + (size.width / 8);
            final y = (size.height / 2) * j + (size.height / 4);
            _drawTriangle(canvas, Offset(x, y), 12, paint);
          }
        }
        break;

      case 'tie_dye':
        // Efecto tie dye con círculos concéntricos
        final center = Offset(size.width / 2, size.height / 2);
        for (int i = 1; i <= 4; i++) {
          paint.color = Colors.blue.withOpacity(0.8 / i);
          canvas.drawCircle(center, i * 15.0, paint);
        }
        break;

      case 'gradient':
        // Gradiente horizontal
        final gradient = LinearGradient(
          colors: [Colors.blue.shade100, Colors.blue.shade500],
        );
        final rect = Rect.fromLTWH(0, 0, size.width, size.height);
        canvas.drawRect(rect, Paint()..shader = gradient.createShader(rect));
        break;

      default:
        canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
    }
  }

  void _drawFlower(Canvas canvas, Offset center, Paint paint) {
    // Pétalos
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60) * (3.14159 / 180);
      final petalCenter = Offset(
        center.dx + 8 * math.cos(angle),
        center.dy + 8 * math.sin(angle),
      );
      canvas.drawCircle(petalCenter, 4, paint);
    }
    // Centro
    paint.color = Colors.yellow;
    canvas.drawCircle(center, 3, paint);
    paint.color = Colors.blue.shade300;
  }

  void _drawTriangle(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    path.moveTo(center.dx, center.dy - size);
    path.lineTo(center.dx - size, center.dy + size);
    path.lineTo(center.dx + size, center.dy + size);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
