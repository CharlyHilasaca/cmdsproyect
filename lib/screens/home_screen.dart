import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../firebase_service.dart';
import 'login_screen.dart';
import 'create_design_screen.dart';
import 'projects_screen.dart';
import 'profile_screen.dart';

// Modelo para los elementos de navegación
class NavigationItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  NavigationItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User? user = FirebaseService.currentUser;
  Map<String, dynamic>? userData;
  bool _isLoading = true;
  int _selectedIndex = 0;
  StreamSubscription<User?>? _authSubscription;

  // Navegación para diferentes pantallas
  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      label: 'Inicio',
    ),
    NavigationItem(
      icon: Icons.folder_outlined,
      selectedIcon: Icons.folder,
      label: 'Proyectos',
    ),
    NavigationItem(
      icon: Icons.add_circle_outline,
      selectedIcon: Icons.add_circle,
      label: 'Crear',
    ),
    NavigationItem(
      icon: Icons.person_outline,
      selectedIcon: Icons.person,
      label: 'Perfil',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _setupAuthListener();
    _checkUserAndLoadData();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  void _setupAuthListener() {
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((
      User? currentUser,
    ) {
      if (currentUser == null && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      } else if (currentUser != null && user != currentUser) {
        if (mounted) {
          setState(() {
            user = currentUser;
          });
        }
        _loadUserData();
      }
    });
  }

  Future<void> _checkUserAndLoadData() async {
    if (user != null) {
      await _loadUserData();
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadUserData() async {
    if (user == null) return;

    try {
      final userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user!.uid)
              .get();

      if (userDoc.exists) {
        if (mounted) {
          setState(() {
            userData = userDoc.data();
            _isLoading = false;
          });
        }
      } else {
        await _createUserDocument();
      }
    } catch (e) {
      print('Error cargando datos del usuario: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _createUserDocument() async {
    if (user == null) return;

    try {
      print('Usuario no encontrado en Firestore, creando datos por defecto');

      final defaultUserData = {
        'email': user!.email,
        'displayName': user!.displayName ?? 'Usuario',
        'createdAt': FieldValue.serverTimestamp(),
        'designs_count': 0,
        'favorites_count': 0,
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .set(defaultUserData);

      if (mounted) {
        setState(() {
          userData = defaultUserData;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error creando documento de usuario: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onBottomNavTap(int index) {
    if (mounted) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Lista de pantallas
    final List<Widget> screens = [
      const ProjectsScreen(), // Pantalla de inicio con todos los proyectos
      const ProjectsScreen(), // Pantalla de proyectos (mismo contenido)
      const CreateDesignScreen(), // Pantalla de crear diseño personalizado
      ProfileScreen(userData: userData), // Pantalla de perfil
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 0,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children:
                  _navigationItems.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    final isSelected = _selectedIndex == index;

                    return GestureDetector(
                      onTap: () => _onBottomNavTap(index),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? Colors.blue.withOpacity(0.1)
                                  : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isSelected ? item.selectedIcon : item.icon,
                              color:
                                  isSelected
                                      ? Colors.blue
                                      : Colors.grey.shade600,
                              size: 24,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.label,
                              style: TextStyle(
                                color:
                                    isSelected
                                        ? Colors.blue
                                        : Colors.grey.shade600,
                                fontSize: 12,
                                fontWeight:
                                    isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
