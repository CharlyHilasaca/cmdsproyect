import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../firebase_service.dart';
import '../screens/login_screen.dart';
import '../screens/home_screen.dart';
import '../screens/role_selection_screen.dart';
import '../screens/manufacturer/manufacturer_dashboard_screen.dart';
import '../screens/developer/developer_dashboard_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseService.authStateChanges,
      builder: (context, snapshot) {
        // Mostrar pantalla de carga mientras se verifica el estado
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingScreen();
        }

        // Si hay un usuario logueado, verificar su rol
        if (snapshot.hasData && snapshot.data != null) {
          return FutureBuilder<DocumentSnapshot>(
            future:
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(snapshot.data!.uid)
                    .get(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return _buildLoadingScreen();
              }

              // Manejar errores de conexión (Firestore offline)
              if (userSnapshot.hasError) {
                print('DEBUG: Error getting user data: ${userSnapshot.error}');
                print(
                  'DEBUG: Firestore seems to be offline, redirecting to RoleSelectionScreen',
                );
                return const RoleSelectionScreen();
              }

              if (userSnapshot.hasData && userSnapshot.data!.exists) {
                final userData =
                    userSnapshot.data!.data() as Map<String, dynamic>?;
                final userRole = userData?['role'] as String?;

                // Debug: Imprimir el rol del usuario
                print('DEBUG: User role detected: $userRole');
                print('DEBUG: User data: $userData');

                // Si el usuario tiene un rol asignado, dirigirlo a su pantalla correspondiente
                if (userRole != null) {
                  switch (userRole) {
                    case 'designer':
                      print('DEBUG: Redirecting to HomeScreen (designer)');
                      return const HomeScreen();
                    case 'manufacturer':
                      print(
                        'DEBUG: Redirecting to ManufacturerDashboardScreen (manufacturer)',
                      );
                      return const ManufacturerDashboardScreen();
                    case 'developer':
                      print('DEBUG: Redirecting to DeveloperDashboardScreen (developer)');
                      return const DeveloperDashboardScreen();
                    case 'admin':
                      print('DEBUG: Redirecting to DeveloperDashboardScreen (admin)');
                      return const DeveloperDashboardScreen();
                    case 'super_admin':
                      print('DEBUG: Redirecting to DeveloperDashboardScreen (super_admin)');
                      return const DeveloperDashboardScreen();
                    default:
                      // Si tiene un rol desconocido, enviar a selección de roles
                      print(
                        'DEBUG: Unknown role, redirecting to RoleSelectionScreen',
                      );
                      return const RoleSelectionScreen();
                  }
                } else {
                  // Si no tiene rol asignado, enviar a selección de roles
                  print(
                    'DEBUG: No role assigned, redirecting to RoleSelectionScreen',
                  );
                  return const RoleSelectionScreen();
                }
              } else {
                // Si no existe el documento del usuario, enviar a selección de roles
                print(
                  'DEBUG: User document does not exist, redirecting to RoleSelectionScreen',
                );
                return const RoleSelectionScreen();
              }
            },
          );
        }

        // Si no hay usuario, mostrar la pantalla de login
        return const LoginScreen();
      },
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade300,
              Colors.blue.shade600,
              Colors.blue.shade900,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo animado
              TweenAnimationBuilder(
                duration: const Duration(seconds: 2),
                tween: Tween<double>(begin: 0, end: 1),
                builder: (context, double value, child) {
                  return Transform.rotate(
                    angle: value * 2 * 3.14159,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.8),
                            Colors.blue.shade100,
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.cloud_done,
                        size: 60,
                        color: Colors.blue.shade600,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
              // Indicador de carga
              const SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 3,
                ),
              ),
              const SizedBox(height: 24),
              // Texto de carga
              Text(
                'Iniciando...',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  shadows: [
                    Shadow(color: Colors.black.withOpacity(0.3), blurRadius: 4),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Conectando con Firebase',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.9),
                  shadows: [
                    Shadow(color: Colors.black.withOpacity(0.3), blurRadius: 4),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
