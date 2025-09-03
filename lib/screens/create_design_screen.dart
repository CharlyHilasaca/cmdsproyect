import 'package:flutter/material.dart';
import 'design_editor_screen.dart';

class CreateDesignScreen extends StatefulWidget {
  const CreateDesignScreen({super.key});

  @override
  State<CreateDesignScreen> createState() => _CreateDesignScreenState();
}

class _CreateDesignScreenState extends State<CreateDesignScreen> {
  // Categorías de prendas con información completa
  final List<Map<String, dynamic>> _garmentCategories = [
    {
      'id': 'tshirt',
      'name': 'Camisetas',
      'description': 'Camisetas básicas y deportivas',
      'icon': Icons.sports_basketball,
      'color': Colors.blue,
      'gradient': [Colors.blue.shade400, Colors.blue.shade600],
      'features': [
        'Manga corta',
        'Cuello redondo',
        'Estampados',
        'Colores lisos',
      ],
    },
    {
      'id': 'hoodie',
      'name': 'Hoodies',
      'description': 'Sudaderas con capucha',
      'icon': Icons.wb_cloudy,
      'color': Colors.purple,
      'gradient': [Colors.purple.shade400, Colors.purple.shade600],
      'features': [
        'Capucha ajustable',
        'Bolsillo frontal',
        'Manga larga',
        'Cordones',
      ],
    },
    {
      'id': 'pants',
      'name': 'Pantalones',
      'description': 'Pantalones casuales y deportivos',
      'icon': Icons.straighten,
      'color': Colors.green,
      'gradient': [Colors.green.shade400, Colors.green.shade600],
      'features': [
        'Cintura elástica',
        'Bolsillos laterales',
        'Corte recto',
        'Cómodos',
      ],
    },
    {
      'id': 'dress',
      'name': 'Vestidos',
      'description': 'Vestidos casuales y elegantes',
      'icon': Icons.auto_awesome,
      'color': Colors.pink,
      'gradient': [Colors.pink.shade400, Colors.pink.shade600],
      'features': ['Corte A', 'Manga corta', 'Estampados florales', 'Elegante'],
    },
    {
      'id': 'jacket',
      'name': 'Chaquetas',
      'description': 'Chaquetas deportivas y casuales',
      'icon': Icons.umbrella,
      'color': Colors.orange,
      'gradient': [Colors.orange.shade400, Colors.orange.shade600],
      'features': [
        'Resistente al viento',
        'Bolsillos con zipper',
        'Capucha',
        'Ligera',
      ],
    },
    {
      'id': 'shoes',
      'name': 'Zapatos',
      'description': 'Calzado deportivo personalizable',
      'icon': Icons.hiking,
      'color': Colors.brown,
      'gradient': [Colors.brown.shade400, Colors.brown.shade600],
      'features': [
        'Suela antideslizante',
        'Transpirable',
        'Cómodo',
        'Duradero',
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Crear Nuevo Diseño',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.indigo,
        elevation: 0,
        centerTitle: true,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con introducción
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.indigo.shade400, Colors.indigo.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.indigo.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.brush, size: 40, color: Colors.white),
                  const SizedBox(height: 12),
                  const Text(
                    '¡Diseña tu prenda perfecta!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Selecciona el tipo de prenda que quieres personalizar y comienza a crear tu diseño único.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            const Text(
              'Elige tu prenda',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Selecciona el tipo de prenda que quieres personalizar',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),

            const SizedBox(height: 24),

            // Grid de categorías
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75, // Cambiado de 0.85 a 0.75 para más altura
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _garmentCategories.length,
              itemBuilder: (context, index) {
                final category = _garmentCategories[index];
                return _buildCategoryCard(category);
              },
            ),

            const SizedBox(height: 32),

            // Información adicional
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue.shade600),
                      const SizedBox(width: 12),
                      Text(
                        '¿Cómo funciona?',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildInfoStep('1', 'Selecciona el tipo de prenda'),
                  _buildInfoStep(
                    '2',
                    'Personaliza colores, patrones y diseños',
                  ),
                  _buildInfoStep('3', 'Ajusta las dimensiones y detalles'),
                  _buildInfoStep('4', 'Guarda tu diseño en la nube'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> category) {
    return Card(
      elevation: 8,
      shadowColor: category['color'].withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _selectCategory(category),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: category['gradient'],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12), // Reducido de 16 a 12
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icono
                Container(
                  padding: const EdgeInsets.all(8), // Reducido de 12 a 8
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(category['icon'], size: 28, color: Colors.white), // Reducido de 32 a 28
                ),

                const SizedBox(height: 8), // Reducido de 12 a 8

                // Nombre
                Text(
                  category['name'],
                  style: const TextStyle(
                    fontSize: 16, // Reducido de 18 a 16
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 4),

                // Descripción
                Flexible(
                  child: Text(
                    category['description'],
                    style: TextStyle(
                      fontSize: 12, // Reducido de 14 a 12
                      color: Colors.white.withOpacity(0.9),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                const Spacer(),

                // Características
                Wrap(
                  spacing: 4,
                  runSpacing: 2,
                  children:
                      (category['features'] as List<String>)
                          .take(2)
                          .map(
                            (feature) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6, // Reducido de 8 a 6
                                vertical: 3, // Reducido de 4 a 3
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8), // Reducido de 12 a 8
                              ),
                              child: Text(
                                feature,
                                style: const TextStyle(
                                  fontSize: 9, // Reducido de 10 a 9
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.blue.shade600,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 14, color: Colors.blue.shade700),
            ),
          ),
        ],
      ),
    );
  }

  void _selectCategory(Map<String, dynamic> category) {
    // Navegar al editor de diseño con la categoría seleccionada
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DesignEditorScreen(garmentCategory: category),
      ),
    );
  }
}
