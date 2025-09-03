import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/auth_wrapper.dart';

class ManufacturerDashboardScreen extends StatefulWidget {
  const ManufacturerDashboardScreen({super.key});

  @override
  State<ManufacturerDashboardScreen> createState() =>
      _ManufacturerDashboardScreenState();
}

class _ManufacturerDashboardScreenState
    extends State<ManufacturerDashboardScreen> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> _menuItems = [
    {
      'title': 'Dashboard',
      'icon': Icons.dashboard_outlined,
      'selectedIcon': Icons.dashboard,
    },
    {
      'title': 'Órdenes',
      'icon': Icons.assignment_outlined,
      'selectedIcon': Icons.assignment,
    },
    {
      'title': 'Producción',
      'icon': Icons.factory_outlined,
      'selectedIcon': Icons.factory,
    },
    {
      'title': 'Trabajadores',
      'icon': Icons.people_outline,
      'selectedIcon': Icons.people,
    },
    {
      'title': 'Planificación',
      'icon': Icons.calendar_month_outlined,
      'selectedIcon': Icons.calendar_month,
    },
    {
      'title': 'Reportes',
      'icon': Icons.analytics_outlined,
      'selectedIcon': Icons.analytics,
    },
    {
      'title': 'Configuración',
      'icon': Icons.settings_outlined,
      'selectedIcon': Icons.settings,
    },
  ];

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Cerrar Sesión'),
            content: const Text('¿Estás seguro que deseas cerrar tu sesión?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
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
          color: Colors.white,
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
          color: Colors.white,
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
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1F2937),
        elevation: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1),
        ),
      ),
      drawer: Drawer(child: _buildSidebar(expanded: true, isMobile: true)),
      body: _buildMainContent(),
    );
  }

  Widget _buildSidebar({required bool expanded, bool isMobile = false}) {
    return Container(
      color: Colors.white,
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
                    color: const Color(0xFF3B82F6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.business,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                if (expanded) ...[
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Confeccionista',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const Divider(),

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
                              ? const Color(0xFF3B82F6)
                              : const Color(0xFF6B7280),
                      size: 24,
                    ),
                    title:
                        expanded
                            ? Text(
                              item['title'],
                              style: TextStyle(
                                color:
                                    isSelected
                                        ? const Color(0xFF3B82F6)
                                        : const Color(0xFF374151),
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
                    selectedTileColor: const Color(0xFF3B82F6).withOpacity(0.1),
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

          // User section
          if (expanded) ...[
            const Divider(),
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color(0xFF3B82F6).withOpacity(0.1),
                    child: const Icon(
                      Icons.person,
                      color: Color(0xFF3B82F6),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Usuario',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        Text(
                          'Confeccionista',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _handleLogout,
                    icon: const Icon(
                      Icons.logout,
                      color: Color(0xFF6B7280),
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
      color: Colors.white,
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
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Gestiona tu producción y órdenes',
                  style: TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
                ),
              ],
            ),
          ),
          // Actions
          Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_outlined),
                color: const Color(0xFF6B7280),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.search),
                color: const Color(0xFF6B7280),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboardContent();
      case 1:
        return _buildOrdersContent();
      case 2:
        return _buildProductionContent();
      case 3:
        return _buildWorkersContent();
      case 4:
        return _buildPlanningContent();
      case 5:
        return _buildReportsContent();
      case 6:
        return _buildSettingsContent();
      default:
        return _buildDashboardContent();
    }
  }

  Widget _buildDashboardContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth <= 600;
          final crossAxisCount =
              isMobile
                  ? 2
                  : constraints.maxWidth <= 800
                  ? 3
                  : 4;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Métricas principales
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: isMobile ? 1.3 : 1.2,
                ),
                itemCount: _getMetrics().length,
                itemBuilder: (context, index) {
                  final metric = _getMetrics()[index];
                  return _buildMetricCard(metric, isMobile);
                },
              ),

              const SizedBox(height: 32),

              // Órdenes recientes
              _buildRecentOrdersSection(isMobile),
            ],
          );
        },
      ),
    );
  }

  List<Map<String, dynamic>> _getMetrics() {
    return [
      {
        'title': 'Órdenes Activas',
        'value': '24',
        'icon': Icons.assignment,
        'color': const Color(0xFF3B82F6),
        'trend': '+12%',
      },
      {
        'title': 'En Producción',
        'value': '12',
        'icon': Icons.factory,
        'color': const Color(0xFF10B981),
        'trend': '+8%',
      },
      {
        'title': 'Completadas Hoy',
        'value': '8',
        'icon': Icons.check_circle,
        'color': const Color(0xFF8B5CF6),
        'trend': '+15%',
      },
      {
        'title': 'Trabajadores',
        'value': '15',
        'icon': Icons.people,
        'color': const Color(0xFFF59E0B),
        'trend': '+2',
      },
    ];
  }

  Widget _buildMetricCard(Map<String, dynamic> metric, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 8 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Header row with icon and trend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                metric['icon'],
                color: metric['color'],
                size: isMobile ? 16 : 20,
              ),
              if (!isMobile)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    metric['trend'],
                    style: const TextStyle(
                      color: Color(0xFF10B981),
                      fontSize: 8,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),

          // Value
          Expanded(
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  metric['value'],
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 24,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1F2937),
                  ),
                ),
              ),
            ),
          ),

          // Title
          Text(
            metric['title'],
            style: TextStyle(
              fontSize: isMobile ? 8 : 10,
              color: const Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentOrdersSection(bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Órdenes Recientes',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedIndex = 1; // Ir a órdenes
                  });
                },
                child: const Text('Ver todas'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...List.generate(3, (index) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE5E7EB)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.shopping_bag,
                      color: Color(0xFF3B82F6),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Orden #${1000 + index}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        Text(
                          'Cliente ${index + 1}',
                          style: const TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      'En progreso',
                      style: TextStyle(
                        color: Color(0xFF10B981),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildOrdersContent() {
    return const Center(
      child: Text(
        'Gestión de Órdenes',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildProductionContent() {
    return const Center(
      child: Text(
        'Gestión de Producción',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildWorkersContent() {
    return const Center(
      child: Text(
        'Gestión de Trabajadores',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildPlanningContent() {
    return const Center(
      child: Text(
        'Planificación',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildReportsContent() {
    return const Center(
      child: Text(
        'Reportes',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSettingsContent() {
    return const Center(
      child: Text(
        'Configuración',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}
