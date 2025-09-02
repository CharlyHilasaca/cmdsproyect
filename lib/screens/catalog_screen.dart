import 'package:flutter/material.dart';
import 'mobile_clothing_designer_screen.dart';
import '../widgets/garment_3d_viewer.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  // Categorías de ropa disponibles
  final List<Map<String, dynamic>> _categories = [
    {
      'name': 'Camisetas',
      'icon': Icons.checkroom,
      'color': Colors.blue,
      'description': 'Camisetas personalizadas',
    },
    {
      'name': 'Hoodies',
      'icon': Icons.dry_cleaning,
      'color': Colors.purple,
      'description': 'Sudaderas con capucha',
    },
    {
      'name': 'Pantalones',
      'icon': Icons.straighten,
      'color': Colors.green,
      'description': 'Pantalones casuales',
    },
    {
      'name': 'Vestidos',
      'icon': Icons.woman,
      'color': Colors.pink,
      'description': 'Vestidos elegantes',
    },
    {
      'name': 'Chaquetas',
      'icon': Icons.yard,
      'color': Colors.orange,
      'description': 'Chaquetas deportivas',
    },
    {
      'name': 'Zapatos',
      'icon': Icons.sports_handball,
      'color': Colors.brown,
      'description': 'Calzado personalizado',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                '¡Bienvenido!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Selecciona una categoría para comenzar a diseñar',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 32),

              // Grid de categorías
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  return _buildCategoryCard(category);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> category) {
    return GestureDetector(
      onTap: () {
        // Navegar al diseñador móvil específico para esta categoría
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => MobileClothingDesignerScreen(
                  category: category['name'],
                  icon: category['icon'],
                  color:
                      category['color'] is Color
                          ? category['color']
                          : Colors.blue,
                ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Vista previa 3D pequeña
            QuickGarment3DPreview(
              garmentType: category['name'],
              primaryColor: category['color'],
              size: 85,
            ),
            const SizedBox(height: 16),

            // Nombre de la categoría
            Text(
              category['name'],
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),

            // Descripción
            Text(
              category['description'],
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}
