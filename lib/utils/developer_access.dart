import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DeveloperAccess {
  // Código secreto para acceder al panel de desarrollador
  static const String _secretCode = "DEV_MODE_3D_2024";

  // Roles permitidos para acceder al panel de desarrollador
  static const List<String> _allowedRoles = [
    'developer',
    'admin',
    'super_admin',
  ];

  // Método para mostrar el dialog de acceso al panel de desarrollador
  static void showDeveloperAccess(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const DeveloperAccessDialog(),
    );
  }

  // Verificar si el código es correcto
  static bool verifyCode(String code) {
    return code == _secretCode;
  }

  // Verificar si el usuario tiene rol de desarrollador en la base de datos
  static Future<bool> verifyDeveloperRole() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return false;

      final userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

      if (!userDoc.exists) return false;

      final userData = userDoc.data() as Map<String, dynamic>;
      final userRole = userData['role'] as String?;

      return userRole != null && _allowedRoles.contains(userRole);
    } catch (e) {
      print('Error verificando rol de desarrollador: $e');
      return false;
    }
  }

  // Verificar acceso completo (código + rol)
  static Future<bool> verifyFullAccess(String code) async {
    if (!verifyCode(code)) return false;
    return await verifyDeveloperRole();
  }
}

class DeveloperAccessDialog extends StatefulWidget {
  const DeveloperAccessDialog({super.key});

  @override
  State<DeveloperAccessDialog> createState() => _DeveloperAccessDialogState();
}

class _DeveloperAccessDialogState extends State<DeveloperAccessDialog> {
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1A1A2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.developer_mode, color: const Color(0xFF6C63FF), size: 28),
          const SizedBox(width: 12),
          const Text(
            'Acceso Desarrollador',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Esta es una área restringida para desarrolladores.',
              style: TextStyle(color: Color(0xFF8892B0), fontSize: 14),
            ),
            const SizedBox(height: 16),
            const Text(
              'Código de Acceso:',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _codeController,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Ingresa el código secreto',
                hintStyle: const TextStyle(color: Color(0xFF8892B0)),
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
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF6C63FF)),
                ),
                prefixIcon: const Icon(
                  Icons.lock_outline,
                  color: Color(0xFF8892B0),
                ),
              ),
              onSubmitted: (_) => _handleAccess(),
            ),
            if (_errorMessage.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                _errorMessage,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ],
            const SizedBox(height: 24),
            const Text(
              '⚠️ Advertencia:',
              style: TextStyle(
                color: Colors.orange,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Esta área permite subir y gestionar plantillas 3D que afectan toda la aplicación. Solo personal autorizado debe tener acceso.',
              style: TextStyle(color: Color(0xFF8892B0), fontSize: 11),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Cancelar',
            style: TextStyle(color: Color(0xFF8892B0)),
          ),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleAccess,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6C63FF),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child:
              _isLoading
                  ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                  : const Text('Acceder'),
        ),
      ],
    );
  }

  Future<void> _handleAccess() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Verificar código y rol del usuario
      bool hasAccess = await DeveloperAccess.verifyFullAccess(
        _codeController.text,
      );

      if (hasAccess) {
        if (mounted) {
          Navigator.of(context).pop(); // Cerrar dialog
          Navigator.of(
            context,
          ).pushNamed('/developer'); // Ir a pantalla de desarrollador
        }
      } else {
        // Verificar si es problema de código o de rol
        bool codeValid = DeveloperAccess.verifyCode(_codeController.text);
        bool roleValid = await DeveloperAccess.verifyDeveloperRole();

        String errorMsg;
        if (!codeValid) {
          errorMsg = 'Código incorrecto. Acceso denegado.';
        } else if (!roleValid) {
          errorMsg = 'Usuario sin permisos de desarrollador.';
        } else {
          errorMsg = 'Acceso denegado. Contacte al administrador.';
        }

        setState(() {
          _errorMessage = errorMsg;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error de conexión. Intente nuevamente.';
        _isLoading = false;
      });
    }
  }
}
