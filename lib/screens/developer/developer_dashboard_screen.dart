import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import '../../widgets/auth_wrapper.dart';
import '../admin/user_management_screen.dart';

class DeveloperDashboardScreen extends StatefulWidget {
  const DeveloperDashboardScreen({super.key});

  @override
  State<DeveloperDashboardScreen> createState() =>
      _DeveloperDashboardScreenState();
}

class _DeveloperDashboardScreenState extends State<DeveloperDashboardScreen> {
  int _selectedIndex = 0;
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  final List<Map<String, dynamic>> _menuItems = [
    {
      'title': 'Plantillas 3D',
      'icon': Icons.view_in_ar_outlined,
      'selectedIcon': Icons.view_in_ar,
    },
    {
      'title': 'Categorías',
      'icon': Icons.category_outlined,
      'selectedIcon': Icons.category,
    },
    {
      'title': 'Formatos',
      'icon': Icons.description_outlined,
      'selectedIcon': Icons.description,
    },
    {
      'title': 'Usuarios',
      'icon': Icons.people_outlined,
      'selectedIcon': Icons.people,
    },
    {
      'title': 'Configuración',
      'icon': Icons.settings_outlined,
      'selectedIcon': Icons.settings,
    },
  ];

  final List<Map<String, dynamic>> _supportedFormats = [
    {
      'name': '3D Models',
      'extensions': ['.obj', '.fbx', '.gltf', '.glb'],
      'description': 'Modelos 3D para renderizado de prendas',
      'icon': Icons.view_in_ar,
      'color': Colors.blue,
    },
    {
      'name': 'Texturas',
      'extensions': ['.png', '.jpg', '.jpeg', '.tiff'],
      'description': 'Texturas y materiales para aplicar a los modelos',
      'icon': Icons.texture,
      'color': Colors.green,
    },
    {
      'name': 'Patterns',
      'extensions': ['.svg', '.ai', '.pdf'],
      'description': 'Patrones vectoriales para personalización',
      'icon': Icons.dashboard_customize,
      'color': Colors.orange,
    },
    {
      'name': 'Animations',
      'extensions': ['.fbx', '.bvh', '.json'],
      'description': 'Animaciones para preview de movimiento',
      'icon': Icons.animation,
      'color': Colors.purple,
    },
  ];

  final List<String> _clothingCategories = [
    'Camisetas',
    'Pantalones',
    'Vestidos',
    'Chaquetas',
    'Faldas',
    'Shorts',
    'Sudaderas',
    'Blusas',
    'Abrigos',
    'Trajes',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F23),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth > 1024;
          final isTablet =
              constraints.maxWidth > 600 && constraints.maxWidth <= 1024;

          if (isDesktop) {
            return _buildDesktopLayout();
          } else if (isTablet) {
            return _buildTabletLayout();
          } else {
            return _buildMobileLayout();
          }
        },
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Sidebar
        Container(
          width: 280,
          decoration: const BoxDecoration(
            color: Color(0xFF1A1A2E),
            border: Border(
              right: BorderSide(color: Color(0xFF16213E), width: 1),
            ),
          ),
          child: _buildSidebar(expanded: true),
        ),
        // Main content
        Expanded(
          child: Column(
            children: [_buildHeader(), Expanded(child: _buildMainContent())],
          ),
        ),
      ],
    );
  }

  Widget _buildTabletLayout() {
    return Row(
      children: [
        // Collapsed sidebar
        Container(
          width: 72,
          decoration: const BoxDecoration(
            color: Color(0xFF1A1A2E),
            border: Border(
              right: BorderSide(color: Color(0xFF16213E), width: 1),
            ),
          ),
          child: _buildSidebar(expanded: false),
        ),
        // Main content
        Expanded(
          child: Column(
            children: [_buildHeader(), Expanded(child: _buildMainContent())],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      appBar: AppBar(
        title: Text(_menuItems[_selectedIndex]['title']),
        backgroundColor: const Color(0xFF1A1A2E),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      drawer: Drawer(
        backgroundColor: const Color(0xFF1A1A2E),
        child: _buildSidebar(expanded: true, isMobile: true),
      ),
      body: _buildMainContent(),
    );
  }

  Widget _buildSidebar({required bool expanded, bool isMobile = false}) {
    return Container(
      color: const Color(0xFF1A1A2E),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(expanded ? 24 : 16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6C63FF), Color(0xFF3F3CBB)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.developer_mode,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                if (expanded) ...[
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Developer Panel',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const Divider(color: Color(0xFF16213E)),

          // Menu items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _menuItems.length,
              itemBuilder: (context, index) {
                final item = _menuItems[index];
                final isSelected = _selectedIndex == index;

                return Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: expanded ? 12 : 8,
                    vertical: 2,
                  ),
                  child: ListTile(
                    leading: Icon(
                      isSelected ? item['selectedIcon'] : item['icon'],
                      color:
                          isSelected
                              ? const Color(0xFF6C63FF)
                              : const Color(0xFF8892B0),
                      size: 24,
                    ),
                    title:
                        expanded
                            ? Text(
                              item['title'],
                              style: TextStyle(
                                color:
                                    isSelected
                                        ? const Color(0xFF6C63FF)
                                        : const Color(0xFFCCD6F6),
                                fontWeight:
                                    isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                fontSize: 14,
                              ),
                            )
                            : null,
                    onTap: () {
                      setState(() {
                        _selectedIndex = index;
                      });
                      if (isMobile) {
                        Navigator.pop(context);
                      }
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    selected: isSelected,
                    selectedTileColor: const Color(0xFF6C63FF).withOpacity(0.1),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: expanded ? 16 : 24,
                      vertical: 4,
                    ),
                    minLeadingWidth: 0,
                  ),
                );
              },
            ),
          ),

          // User section & logout
          if (expanded) ...[
            const Divider(color: Color(0xFF16213E)),
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color(0xFF6C63FF).withOpacity(0.2),
                    child: const Icon(
                      Icons.code,
                      color: Color(0xFF6C63FF),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Developer',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Admin Access',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF8892B0),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _handleLogout,
                    icon: const Icon(
                      Icons.logout,
                      color: Color(0xFF8892B0),
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0F0F23),
        border: Border(bottom: BorderSide(color: Color(0xFF16213E), width: 1)),
      ),
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _menuItems[_selectedIndex]['title'],
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Gestión avanzada de plantillas y configuraciones 3D',
                  style: TextStyle(fontSize: 16, color: Color(0xFF8892B0)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildTemplatesContent();
      case 1:
        return _buildCategoriesContent();
      case 2:
        return _buildFormatsContent();
      case 3:
        return _buildUsersContent();
      case 4:
        return _buildSettingsContent();
      default:
        return _buildTemplatesContent();
    }
  }

  Widget _buildTemplatesContent() {
    final isMobile = MediaQuery.of(context).size.width < 600;
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Upload section
          _buildUploadSection(),

          SizedBox(height: isMobile ? 24 : 32),

          // Current templates
          _buildCurrentTemplatesSection(),
        ],
      ),
    );
  }

  Widget _buildUploadSection() {
    final isMobile = MediaQuery.of(context).size.width < 600;
    
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF16213E)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.cloud_upload_outlined,
                color: const Color(0xFF6C63FF),
                size: isMobile ? 24 : 28,
              ),
              SizedBox(width: isMobile ? 8 : 12),
              Expanded(
                child: Text(
                  'Subir Nueva Plantilla 3D',
                  style: TextStyle(
                    fontSize: isMobile ? 18 : 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: isMobile ? 12 : 16),

          Text(
            'Sube archivos 3D que servirán como plantillas base para las categorías de ropa. Los formatos soportados incluyen modelos 3D, texturas, patrones y animaciones.',
            style: TextStyle(
              color: const Color(0xFF8892B0),
              fontSize: isMobile ? 13 : 14,
            ),
          ),

          SizedBox(height: isMobile ? 16 : 24),

          // Category selector
          // Category and format selectors
          isMobile
              ? Column(
                  children: [
                    _buildCategorySelector(),
                    const SizedBox(height: 16),
                    _buildFormatSelector(),
                  ],
                )
              : Row(
                  children: [
                    Expanded(child: _buildCategorySelector()),
                    const SizedBox(width: 16),
                    Expanded(child: _buildFormatSelector()),
                  ],
                ),

          SizedBox(height: isMobile ? 16 : 24),

          // Upload button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isUploading ? null : _handleFileUpload,
              icon: _isUploading
                  ? SizedBox(
                      width: isMobile ? 16 : 20,
                      height: isMobile ? 16 : 20,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                    )
                  : Icon(
                      Icons.upload_file,
                      size: isMobile ? 18 : 20,
                    ),
              label: Text(
                _isUploading ? 'Subiendo...' : 'Seleccionar y Subir Archivo',
                style: TextStyle(fontSize: isMobile ? 14 : 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  vertical: isMobile ? 12 : 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),

          if (_isUploading) ...[
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: _uploadProgress,
              backgroundColor: const Color(0xFF16213E),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF6C63FF),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${(_uploadProgress * 100).toInt()}% completado',
              style: const TextStyle(color: Color(0xFF8892B0), fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Categoría de Ropa',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF0F0F23),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF16213E)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _clothingCategories.first,
              isExpanded: true,
              dropdownColor: const Color(0xFF1A1A2E),
              style: const TextStyle(color: Colors.white),
              items:
                  _clothingCategories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
              onChanged: (value) {
                // Handle category selection
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormatSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tipo de Archivo',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF0F0F23),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF16213E)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _supportedFormats.first['name'],
              isExpanded: true,
              dropdownColor: const Color(0xFF1A1A2E),
              style: const TextStyle(color: Colors.white),
              items: _supportedFormats.map((format) {
                return DropdownMenuItem<String>(
                  value: format['name'] as String,
                  child: Row(
                    children: [
                      Icon(
                        format['icon'],
                        color: format['color'],
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          format['name'],
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                // Handle format selection
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentTemplatesSection() {
    final isMobile = MediaQuery.of(context).size.width < 600;
    
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF16213E)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Plantillas Actuales',
            style: TextStyle(
              fontSize: isMobile ? 18 : 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: isMobile ? 12 : 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isMobile ? 2 : 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: isMobile ? 1.1 : 1.2,
            ),
            itemCount: _clothingCategories.length,
            itemBuilder: (context, index) {
              return _buildTemplateCard(_clothingCategories[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateCard(String category) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F23),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF16213E)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.view_in_ar,
            color: const Color(0xFF6C63FF),
            size: isMobile ? 24 : 32,
          ),
          SizedBox(height: isMobile ? 6 : 8),
          Flexible(
            child: Text(
              category,
              style: TextStyle(
                color: Colors.white,
                fontSize: isMobile ? 12 : 14,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(height: isMobile ? 2 : 4),
          Text(
            '3 archivos',
            style: TextStyle(
              color: const Color(0xFF8892B0),
              fontSize: isMobile ? 10 : 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesContent() {
    return const Center(
      child: Text(
        'Gestión de Categorías',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildFormatsContent() {
    final isMobile = MediaQuery.of(context).size.width < 600;
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Formatos Soportados',
            style: TextStyle(
              fontSize: isMobile ? 20 : 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: isMobile ? 16 : 24),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isMobile ? 1 : 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: isMobile ? 2.5 : 1.8,
            ),
            itemCount: _supportedFormats.length,
            itemBuilder: (context, index) {
              return _buildFormatCard(_supportedFormats[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUsersContent() {
    final isMobile = MediaQuery.of(context).size.width < 600;
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.people,
                color: const Color(0xFF6C63FF),
                size: isMobile ? 24 : 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Gestión de Usuarios',
                  style: TextStyle(
                    fontSize: isMobile ? 20 : 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Administra los roles y permisos de usuarios en el sistema',
            style: TextStyle(
              color: const Color(0xFF8892B0),
              fontSize: isMobile ? 14 : 16,
            ),
          ),
          SizedBox(height: isMobile ? 24 : 32),

          // Información de roles
          Container(
            padding: EdgeInsets.all(isMobile ? 16 : 20),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF16213E)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Roles del Sistema',
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: isMobile ? 12 : 16),
                _buildRoleInfo(
                  'developer',
                  'Desarrollador',
                  'Acceso al panel de desarrollo y gestión de plantillas 3D',
                ),
                _buildRoleInfo(
                  'admin',
                  'Administrador',
                  'Gestión de usuarios y configuraciones del sistema',
                ),
                _buildRoleInfo(
                  'super_admin',
                  'Super Admin',
                  'Control total del sistema y asignación de roles',
                ),
                _buildRoleInfo(
                  'manufacturer',
                  'Confeccionista',
                  'Acceso al panel de confección y pedidos',
                ),
                _buildRoleInfo(
                  'designer',
                  'Diseñador',
                  'Creación y edición de diseños de ropa',
                ),
                _buildRoleInfo(
                  'user',
                  'Usuario',
                  'Acceso básico para navegar y realizar pedidos',
                ),
              ],
            ),
          ),

          SizedBox(height: isMobile ? 16 : 24),

          // Botón para ir a gestión completa
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const UserManagementScreen(),
                  ),
                );
              },
              icon: Icon(
                Icons.admin_panel_settings,
                size: isMobile ? 18 : 20,
              ),
              label: Text(
                isMobile ? 'Gestión de Usuarios' : 'Abrir Gestión Completa de Usuarios',
                style: TextStyle(fontSize: isMobile ? 14 : 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  vertical: isMobile ? 12 : 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleInfo(String roleKey, String roleName, String description) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    
    Color roleColor;
    IconData roleIcon;

    switch (roleKey) {
      case 'super_admin':
        roleColor = Colors.purple;
        roleIcon = Icons.admin_panel_settings;
        break;
      case 'admin':
        roleColor = Colors.red;
        roleIcon = Icons.security;
        break;
      case 'developer':
        roleColor = const Color(0xFF6C63FF);
        roleIcon = Icons.code;
        break;
      case 'manufacturer':
        roleColor = Colors.orange;
        roleIcon = Icons.factory;
        break;
      case 'designer':
        roleColor = Colors.green;
        roleIcon = Icons.design_services;
        break;
      default:
        roleColor = Colors.grey;
        roleIcon = Icons.person;
    }

    return Container(
      margin: EdgeInsets.only(bottom: isMobile ? 8 : 12),
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F23),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: roleColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            roleIcon,
            color: roleColor,
            size: isMobile ? 20 : 24,
          ),
          SizedBox(width: isMobile ? 8 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  roleName,
                  style: TextStyle(
                    color: roleColor,
                    fontSize: isMobile ? 14 : 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: isMobile ? 2 : 4),
                Text(
                  description,
                  style: TextStyle(
                    color: const Color(0xFF8892B0),
                    fontSize: isMobile ? 12 : 14,
                  ),
                  maxLines: isMobile ? 2 : null,
                  overflow: isMobile ? TextOverflow.ellipsis : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormatCard(Map<String, dynamic> format) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF16213E)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                format['icon'],
                color: format['color'],
                size: isMobile ? 22 : 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  format['name'],
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 8 : 12),
          Text(
            format['description'],
            style: TextStyle(
              color: const Color(0xFF8892B0),
              fontSize: isMobile ? 12 : 14,
            ),
            maxLines: isMobile ? 2 : 3,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: isMobile ? 8 : 12),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: (format['extensions'] as List<String>).map((ext) {
              return Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 6 : 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: (format['color'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: format['color'].withOpacity(0.3),
                  ),
                ),
                child: Text(
                  ext,
                  style: TextStyle(
                    color: format['color'],
                    fontSize: isMobile ? 10 : 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsContent() {
    return const Center(
      child: Text(
        'Configuración del Sistema',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Future<void> _handleFileUpload() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result != null) {
        setState(() {
          _isUploading = true;
          _uploadProgress = 0.0;
        });

        // Simulate upload progress
        for (int i = 0; i <= 100; i += 10) {
          await Future.delayed(const Duration(milliseconds: 200));
          setState(() {
            _uploadProgress = i / 100;
          });
        }

        // Here you would implement the actual Firebase Storage upload
        // final file = File(result.files.single.path!);
        // await _uploadToFirebaseStorage(file);

        setState(() {
          _isUploading = false;
          _uploadProgress = 0.0;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Archivo subido exitosamente'),
              backgroundColor: Color(0xFF6C63FF),
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
        _uploadProgress = 0.0;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al subir archivo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF1A1A2E),
            title: const Text(
              'Cerrar Sesión',
              style: TextStyle(color: Colors.white),
            ),
            content: const Text(
              '¿Estás seguro que deseas cerrar tu sesión de desarrollador?',
              style: TextStyle(color: Color(0xFF8892B0)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(color: Color(0xFF8892B0)),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Cerrar Sesión'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      try {
        await FirebaseAuth.instance.signOut();
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const AuthWrapper()),
            (route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al cerrar sesión: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
