import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final List<String> _availableRoles = [
    'user',
    'manufacturer',
    'designer',
    'developer',
    'admin',
    'super_admin',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F23),
      appBar: AppBar(
        title: const Text('Gestión de Usuarios'),
        backgroundColor: const Color(0xFF1A1A2E),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No hay usuarios registrados',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final userDoc = snapshot.data!.docs[index];
              final userData = userDoc.data() as Map<String, dynamic>;

              return _buildUserCard(userDoc.id, userData);
            },
          );
        },
      ),
    );
  }

  Widget _buildUserCard(String userId, Map<String, dynamic> userData) {
    final currentRole = userData['role'] ?? 'user';
    final userName = userData['name'] ?? 'Sin nombre';
    final userEmail = userData['email'] ?? 'Sin email';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
              CircleAvatar(
                backgroundColor: _getRoleColor(currentRole),
                child: Icon(
                  _getRoleIcon(currentRole),
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      userEmail,
                      style: const TextStyle(
                        color: Color(0xFF8892B0),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getRoleColor(currentRole).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _getRoleColor(currentRole).withOpacity(0.5),
                  ),
                ),
                child: Text(
                  _getRoleDisplayName(currentRole),
                  style: TextStyle(
                    color: _getRoleColor(currentRole),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              const Text(
                'Cambiar rol:',
                style: TextStyle(color: Color(0xFF8892B0), fontSize: 14),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: currentRole,
                  dropdownColor: const Color(0xFF1A1A2E),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    isDense: true,
                    filled: true,
                    fillColor: const Color(0xFF0F0F23),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF16213E)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF16213E)),
                    ),
                  ),
                  items:
                      _availableRoles.map((role) {
                        return DropdownMenuItem<String>(
                          value: role,
                          child: Row(
                            children: [
                              Icon(
                                _getRoleIcon(role),
                                color: _getRoleColor(role),
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(_getRoleDisplayName(role)),
                            ],
                          ),
                        );
                      }).toList(),
                  onChanged: (newRole) {
                    if (newRole != null && newRole != currentRole) {
                      _changeUserRole(userId, newRole, userName);
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'super_admin':
        return Colors.purple;
      case 'admin':
        return Colors.red;
      case 'developer':
        return const Color(0xFF6C63FF);
      case 'manufacturer':
        return Colors.orange;
      case 'designer':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getRoleIcon(String role) {
    switch (role) {
      case 'super_admin':
        return Icons.admin_panel_settings;
      case 'admin':
        return Icons.security;
      case 'developer':
        return Icons.code;
      case 'manufacturer':
        return Icons.factory;
      case 'designer':
        return Icons.design_services;
      default:
        return Icons.person;
    }
  }

  String _getRoleDisplayName(String role) {
    switch (role) {
      case 'super_admin':
        return 'Super Admin';
      case 'admin':
        return 'Administrador';
      case 'developer':
        return 'Desarrollador';
      case 'manufacturer':
        return 'Confeccionista';
      case 'designer':
        return 'Diseñador';
      case 'user':
        return 'Usuario';
      default:
        return role;
    }
  }

  Future<void> _changeUserRole(
    String userId,
    String newRole,
    String userName,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF1A1A2E),
            title: const Text(
              'Confirmar Cambio de Rol',
              style: TextStyle(color: Colors.white),
            ),
            content: Text(
              '¿Estás seguro de cambiar el rol de "$userName" a "${_getRoleDisplayName(newRole)}"?',
              style: const TextStyle(color: Color(0xFF8892B0)),
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
                  backgroundColor: const Color(0xFF6C63FF),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Confirmar'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(userId).update(
          {'role': newRole},
        );

        // Log del cambio de rol
        await _logRoleChange(userId, newRole, userName);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Rol actualizado para $userName'),
              backgroundColor: const Color(0xFF6C63FF),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al actualizar rol: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _logRoleChange(
    String targetUserId,
    String newRole,
    String targetUserName,
  ) async {
    try {
      await FirebaseFirestore.instance.collection('role_change_logs').add({
        'changedBy': FirebaseAuth.instance.currentUser?.uid,
        'changedByEmail': FirebaseAuth.instance.currentUser?.email,
        'targetUserId': targetUserId,
        'targetUserName': targetUserName,
        'newRole': newRole,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error logging role change: $e');
    }
  }
}
