import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'mobile_clothing_designer_screen.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Proyectos',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey.shade600,
          indicatorColor: Colors.blue,
          tabs: const [
            Tab(icon: Icon(Icons.public), text: 'Todos los Proyectos'),
            Tab(icon: Icon(Icons.person), text: 'Mis Proyectos'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildAllProjectsTab(), _buildMyProjectsTab()],
      ),
    );
  }

  Widget _buildAllProjectsTab() {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('designs')
              .orderBy('createdAt', descending: true)
              .limit(50)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error al cargar proyectos',
                  style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                ),
              ],
            ),
          );
        }

        final projects = snapshot.data?.docs ?? [];

        if (projects.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.folder_outlined,
                  size: 80,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'No hay proyectos aún',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Los proyectos creados aparecerán aquí',
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
                ),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.8,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: projects.length,
          itemBuilder: (context, index) {
            final project = projects[index].data() as Map<String, dynamic>;
            return _buildProjectCard(project, projects[index].id);
          },
        );
      },
    );
  }

  Widget _buildMyProjectsTab() {
    if (user == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.login, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Inicia sesión para ver tus proyectos',
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('designs')
              .where('userId', isEqualTo: user!.uid)
              .orderBy('createdAt', descending: true)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error al cargar tus proyectos',
                  style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                ),
              ],
            ),
          );
        }

        final projects = snapshot.data?.docs ?? [];

        if (projects.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_circle_outline,
                  size: 80,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'No tienes proyectos aún',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Ve a "Crear" para diseñar tu primera prenda',
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
                ),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.8,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: projects.length,
          itemBuilder: (context, index) {
            final project = projects[index].data() as Map<String, dynamic>;
            return _buildProjectCard(
              project,
              projects[index].id,
              isOwner: true,
            );
          },
        );
      },
    );
  }

  Widget _buildProjectCard(
    Map<String, dynamic> project,
    String projectId, {
    bool isOwner = false,
  }) {
    final garmentType = project['garmentType'] ?? 'camiseta';
    final name = project['name'] ?? 'Diseño sin nombre';
    final userName = project['userName'] ?? 'Usuario desconocido';
    final createdAt = project['createdAt'] as Timestamp?;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => MobileClothingDesignerScreen(
                    category: _getGarmentDisplayName(garmentType),
                    icon: _getGarmentIcon(garmentType),
                    color: _getGarmentColor(garmentType),
                    garmentType: garmentType,
                  ),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _getGarmentIcon(garmentType),
                      size: 48,
                      color: Colors.blue.shade400,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getGarmentDisplayName(garmentType),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (!isOwner) ...[
                      const SizedBox(height: 4),
                      Text(
                        'por $userName',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const Spacer(),
                    if (createdAt != null)
                      Text(
                        _formatDate(createdAt.toDate()),
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade500,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getGarmentIcon(String garmentType) {
    switch (garmentType) {
      case 'camiseta':
        return Icons.sports_basketball; // Icono deportivo para camisetas
      case 'pantalón':
        return Icons.straighten; // Icono de línea recta para pantalones
      case 'vestido':
        return Icons.auto_awesome; // Icono de estrella brillante para vestidos
      case 'chaqueta':
        return Icons.umbrella; // Icono de paraguas para chaquetas
      case 'zapato':
        return Icons.hiking; // Icono de senderismo para zapatos
      default:
        return Icons.sports_basketball;
    }
  }

  String _getGarmentDisplayName(String garmentType) {
    switch (garmentType) {
      case 'camiseta':
        return 'Camiseta';
      case 'pantalón':
        return 'Pantalón';
      case 'vestido':
        return 'Vestido';
      case 'chaqueta':
        return 'Chaqueta';
      case 'zapato':
        return 'Zapato';
      default:
        return 'Prenda';
    }
  }

  Color _getGarmentColor(String garmentType) {
    switch (garmentType) {
      case 'camiseta':
        return Colors.blue;
      case 'pantalón':
        return Colors.green;
      case 'vestido':
        return Colors.pink;
      case 'chaqueta':
        return Colors.orange;
      case 'zapato':
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
      return 'hace ${difference.inDays} ${difference.inDays == 1 ? 'día' : 'días'}';
    } else if (difference.inHours > 0) {
      return 'hace ${difference.inHours} ${difference.inHours == 1 ? 'hora' : 'horas'}';
    } else {
      return 'hace un momento';
    }
  }
}
