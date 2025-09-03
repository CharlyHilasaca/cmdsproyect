import 'package:flutter/material.dart';
import 'design_editor_screen.dart';
import '../utils/responsive_helper.dart';

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
      'key': 'shirt',
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
      'key': 'hoodie',
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
      'key': 'pants',
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
      'key': 'dress',
      'name': 'Vestidos',
      'description': 'Vestidos casuales y elegantes',
      'icon': Icons.auto_awesome,
      'color': Colors.pink,
      'gradient': [Colors.pink.shade400, Colors.pink.shade600],
      'features': ['Corte A', 'Manga corta', 'Estampados florales', 'Elegante'],
    },
    {
      'id': 'jacket',
      'key': 'jacket',
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
      'key': 'shoes',
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
      appBar:
          ResponsiveHelper.isWideScreen
              ? null // No AppBar en web/escritorio para más espacio
              : AppBar(
                title: const Text(
                  'Crear Nuevo Diseño',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                backgroundColor: Colors.indigo,
                elevation: 0,
                centerTitle: true,
                foregroundColor: Colors.white,
              ),
      body: ResponsiveBuilder(
        builder: (context, constraints) {
          return ResponsiveContainer(
            maxWidth: 1200,
            child: SingleChildScrollView(
              padding: ResponsiveHelper.getResponsivePadding(
                constraints.maxWidth,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header con introducción adaptativo
                  _buildHeader(constraints.maxWidth),

                  const SizedBox(height: 32),

                  // Título de sección
                  _buildSectionTitle(),

                  const SizedBox(height: 24),

                  // Grid de categorías responsivo
                  _buildCategoriesGrid(constraints.maxWidth),

                  const SizedBox(height: 40),

                  // Información adicional
                  _buildInfoSection(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(double screenWidth) {
    final isWideScreen = ResponsiveHelper.isWideScreen;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isWideScreen ? 32 : 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo.shade400, Colors.indigo.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(isWideScreen ? 20 : 16),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.3),
            blurRadius: isWideScreen ? 16 : 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isWideScreen) ...[
            // Título más prominente para web/escritorio
            Text(
              'Crear Nuevo Diseño',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 16),
          ],
          Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: Colors.white,
                size: isWideScreen ? 32 : 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Diseño Personalizado',
                  style: TextStyle(
                    fontSize: isWideScreen ? 24 : 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            isWideScreen
                ? 'Crea prendas únicas con nuestro editor avanzado. Personaliza colores, patrones, tallas y más. Perfecto para expresar tu estilo personal.'
                : 'Crea prendas únicas con colores, patrones y tallas personalizadas.',
            style: TextStyle(
              fontSize: isWideScreen ? 18 : 16,
              color: Colors.white.withOpacity(0.9),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Elige tu prenda',
          style: TextStyle(
            fontSize: ResponsiveHelper.isWideScreen ? 32 : 24,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Selecciona el tipo de prenda que quieres personalizar',
          style: TextStyle(
            fontSize: ResponsiveHelper.isWideScreen ? 18 : 16,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoriesGrid(double screenWidth) {
    final columns = ResponsiveHelper.getGridColumns(screenWidth);
    final aspectRatio = ResponsiveHelper.getCardAspectRatio(screenWidth);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        childAspectRatio: aspectRatio,
        crossAxisSpacing: ResponsiveHelper.isWideScreen ? 24 : 16,
        mainAxisSpacing: ResponsiveHelper.isWideScreen ? 24 : 16,
      ),
      itemCount: _garmentCategories.length,
      itemBuilder: (context, index) {
        final category = _garmentCategories[index];
        return _buildCategoryCard(category, screenWidth);
      },
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> category, double screenWidth) {
    final isWideScreen = ResponsiveHelper.isWideScreen;

    return Card(
      elevation: isWideScreen ? 12 : 8,
      shadowColor: category['color'].withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isWideScreen ? 20 : 16),
      ),
      child: InkWell(
        onTap: () => _selectCategory(category),
        borderRadius: BorderRadius.circular(isWideScreen ? 20 : 16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(isWideScreen ? 20 : 16),
            gradient: LinearGradient(
              colors: category['gradient'],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(isWideScreen ? 20 : 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icono
                Container(
                  padding: EdgeInsets.all(isWideScreen ? 12 : 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(isWideScreen ? 16 : 12),
                  ),
                  child: Icon(
                    category['icon'],
                    size: isWideScreen ? 36 : 28,
                    color: Colors.white,
                  ),
                ),

                SizedBox(height: isWideScreen ? 16 : 8),

                // Nombre
                Text(
                  category['name'],
                  style: TextStyle(
                    fontSize: isWideScreen ? 20 : 16,
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
                      fontSize: isWideScreen ? 14 : 12,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    maxLines: isWideScreen ? 3 : 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                const Spacer(),

                // Características
                if (isWideScreen) ...[
                  // Mostrar más características en pantallas grandes
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children:
                        (category['features'] as List<String>)
                            .take(4)
                            .map(
                              (feature) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  feature,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                  ),
                ] else ...[
                  // Mostrar menos características en móviles
                  Wrap(
                    spacing: 4,
                    runSpacing: 2,
                    children:
                        (category['features'] as List<String>)
                            .take(2)
                            .map(
                              (feature) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  feature,
                                  style: const TextStyle(
                                    fontSize: 9,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
    final isWideScreen = ResponsiveHelper.isWideScreen;

    return Container(
      padding: EdgeInsets.all(isWideScreen ? 32 : 20),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(isWideScreen ? 20 : 12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.blue.shade600,
                size: isWideScreen ? 28 : 24,
              ),
              SizedBox(width: isWideScreen ? 16 : 12),
              Expanded(
                child: Text(
                  '¿Sabías que...?',
                  style: TextStyle(
                    fontSize: isWideScreen ? 22 : 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isWideScreen ? 16 : 12),
          Text(
            isWideScreen
                ? 'Cada prenda que diseñes puede ser completamente personalizada con una amplia gama de colores, patrones únicos y tallas precisas. Nuestro sistema de diseño 3D te permite visualizar tu creación en tiempo real, asegurando que el resultado final sea exactamente lo que imaginaste.'
                : 'Cada prenda puede ser personalizada con colores, patrones y tallas específicas. Usa nuestro editor 3D para ver los cambios en tiempo real.',
            style: TextStyle(
              fontSize: isWideScreen ? 16 : 14,
              color: Colors.blue.shade600,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  void _selectCategory(Map<String, dynamic> category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DesignEditorScreen(garmentCategory: category),
      ),
    );
  }
}
