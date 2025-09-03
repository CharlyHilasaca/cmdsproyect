import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_screen.dart';
import 'manufacturer/manufacturer_dashboard_screen.dart';
import '../utils/responsive_helper.dart';

enum UserRole {
  designer(
    'designer',
    'Diseñador',
    Icons.palette,
    'Crea y personaliza diseños únicos',
  ),
  manufacturer(
    'manufacturer',
    'Confeccionista',
    Icons.precision_manufacturing,
    'Produce y fabrica las prendas diseñadas',
  );

  const UserRole(this.value, this.displayName, this.icon, this.description);
  final String value;
  final String displayName;
  final IconData icon;
  final String description;
}

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen>
    with TickerProviderStateMixin {
  UserRole? _selectedRole;
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutQuart),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWideScreen = ResponsiveHelper.isWideScreen;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: ResponsiveBuilder(
        builder: (context, constraints) {
          return ResponsiveContainer(
            maxWidth: 800,
            child: SingleChildScrollView(
              padding: ResponsiveHelper.getResponsivePadding(
                constraints.maxWidth,
              ),
              child: Column(
                children: [
                  SizedBox(height: isWideScreen ? 60 : 40),

                  // Header animado
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: _buildHeader(isWideScreen),
                    ),
                  ),

                  SizedBox(height: isWideScreen ? 60 : 40),

                  // Opciones de rol
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildRoleOptions(constraints.maxWidth),
                  ),

                  SizedBox(height: isWideScreen ? 50 : 30),

                  // Botón de continuar
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildContinueButton(isWideScreen),
                  ),

                  SizedBox(height: isWideScreen ? 40 : 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(bool isWideScreen) {
    return Column(
      children: [
        // Logo o icono principal
        Container(
          width: isWideScreen ? 120 : 80,
          height: isWideScreen ? 120 : 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.indigo.shade400, Colors.purple.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.indigo.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Icon(
            Icons.person_add,
            size: isWideScreen ? 60 : 40,
            color: Colors.white,
          ),
        ),

        SizedBox(height: isWideScreen ? 30 : 20),

        // Título
        Text(
          '¡Bienvenido!',
          style: TextStyle(
            fontSize: isWideScreen ? 36 : 28,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),

        SizedBox(height: isWideScreen ? 16 : 12),

        // Subtítulo
        Text(
          'Elige tu rol para personalizar tu experiencia',
          style: TextStyle(
            fontSize: isWideScreen ? 18 : 16,
            color: Colors.grey.shade600,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRoleOptions(double screenWidth) {
    final isWideScreen = ResponsiveHelper.isWideScreen;

    if (isWideScreen) {
      // Layout horizontal para pantallas grandes
      return Row(
        children:
            UserRole.values.map((role) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: _buildRoleCard(role, isWideScreen),
                ),
              );
            }).toList(),
      );
    } else {
      // Layout vertical para móviles
      return Column(
        children:
            UserRole.values.map((role) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: _buildRoleCard(role, isWideScreen),
              );
            }).toList(),
      );
    }
  }

  Widget _buildRoleCard(UserRole role, bool isWideScreen) {
    final isSelected = _selectedRole == role;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRole = role;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.all(isWideScreen ? 32 : 24),
        decoration: BoxDecoration(
          color: isSelected ? role._getColor().withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(isWideScreen ? 20 : 16),
          border: Border.all(
            color: isSelected ? role._getColor() : Colors.grey.shade300,
            width: isSelected ? 3 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color:
                  isSelected
                      ? role._getColor().withOpacity(0.2)
                      : Colors.black.withOpacity(0.1),
              blurRadius: isSelected ? 15 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Icono
            Container(
              width: isWideScreen ? 80 : 60,
              height: isWideScreen ? 80 : 60,
              decoration: BoxDecoration(
                color: isSelected ? role._getColor() : Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                role.icon,
                size: isWideScreen ? 40 : 30,
                color: isSelected ? Colors.white : Colors.grey.shade600,
              ),
            ),

            SizedBox(height: isWideScreen ? 20 : 16),

            // Título del rol
            Text(
              role.displayName,
              style: TextStyle(
                fontSize: isWideScreen ? 24 : 20,
                fontWeight: FontWeight.bold,
                color: isSelected ? role._getColor() : Colors.grey.shade800,
              ),
            ),

            SizedBox(height: isWideScreen ? 12 : 8),

            // Descripción
            Text(
              role.description,
              style: TextStyle(
                fontSize: isWideScreen ? 16 : 14,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            if (isSelected) ...[
              SizedBox(height: isWideScreen ? 16 : 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: role._getColor(),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Seleccionado',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: isWideScreen ? 14 : 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildContinueButton(bool isWideScreen) {
    return SizedBox(
      width: isWideScreen ? 300 : double.infinity,
      height: isWideScreen ? 60 : 50,
      child: ElevatedButton(
        onPressed:
            _selectedRole != null && !_isLoading ? _continueWithRole : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _selectedRole?._getColor() ?? Colors.grey,
          foregroundColor: Colors.white,
          elevation: _selectedRole != null ? 8 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isWideScreen ? 30 : 25),
          ),
        ),
        child:
            _isLoading
                ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                : Text(
                  'Continuar',
                  style: TextStyle(
                    fontSize: isWideScreen ? 18 : 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
      ),
    );
  }

  Future<void> _continueWithRole() async {
    if (_selectedRole == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Actualizar el rol del usuario en Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
              'role': _selectedRole!.value,
              'roleUpdatedAt': FieldValue.serverTimestamp(),
            });

        if (mounted) {
          // Navegar según el rol seleccionado
          if (_selectedRole == UserRole.designer) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const ManufacturerDashboardScreen(),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al asignar rol: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

extension _UserRoleExtension on UserRole {
  Color _getColor() {
    switch (this) {
      case UserRole.designer:
        return Colors.purple;
      case UserRole.manufacturer:
        return Colors.indigo;
    }
  }
}
