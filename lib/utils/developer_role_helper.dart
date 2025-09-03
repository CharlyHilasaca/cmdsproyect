import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Utility class para gestionar roles de desarrollador
class DeveloperRoleHelper {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Establece el rol de desarrollador para el usuario actual
  static Future<void> setCurrentUserAsDeveloper() async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'role': 'developer',
        'roleUpdatedAt': FieldValue.serverTimestamp(),
      });
      print('✅ Rol de desarrollador asignado al usuario: ${user.email}');
    } else {
      print('❌ No hay usuario autenticado');
    }
  }

  /// Establece el rol de desarrollador para un usuario específico por email
  static Future<void> setUserAsDeveloperByEmail(String email) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final userDoc = querySnapshot.docs.first;
        await userDoc.reference.update({
          'role': 'developer',
          'roleUpdatedAt': FieldValue.serverTimestamp(),
        });
        print('✅ Rol de desarrollador asignado al usuario: $email');
      } else {
        print('❌ Usuario con email $email no encontrado');
      }
    } catch (e) {
      print('❌ Error asignando rol: $e');
    }
  }

  /// Establece el rol de desarrollador para un usuario específico por UID
  static Future<void> setUserAsDeveloperByUID(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'role': 'developer',
        'roleUpdatedAt': FieldValue.serverTimestamp(),
      });
      print('✅ Rol de desarrollador asignado al usuario: $uid');
    } catch (e) {
      print('❌ Error asignando rol: $e');
    }
  }

  /// Verifica si el usuario actual tiene rol de desarrollador
  static Future<bool> isCurrentUserDeveloper() async {
    final user = _auth.currentUser;
    if (user != null) {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        final role = userData['role'] as String?;
        return ['developer', 'admin', 'super_admin'].contains(role);
      }
    }
    return false;
  }

  /// Lista todos los usuarios con rol de desarrollador
  static Future<void> listDeveloperUsers() async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('role', whereIn: ['developer', 'admin', 'super_admin'])
          .get();

      print('👨‍💻 Usuarios con rol de desarrollador:');
      for (final doc in querySnapshot.docs) {
        final userData = doc.data();
        print('  - ${userData['name']} (${userData['email']}) - Rol: ${userData['role']}');
      }
    } catch (e) {
      print('❌ Error listando desarrolladores: $e');
    }
  }

  /// Función de debug para uso en desarrollo
  static Future<void> debugCreateDeveloperUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'name': user.displayName ?? 'Developer User',
        'role': 'developer',
        'createdAt': FieldValue.serverTimestamp(),
        'roleUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      print('🔧 Usuario de desarrollo creado/actualizado:');
      print('  - Email: ${user.email}');
      print('  - Rol: developer');
      print('  - UID: ${user.uid}');
    }
  }

  /// Función para uso rápido en debug: establecer usuario actual como super admin
  static Future<void> debugSetCurrentUserAsSuperAdmin() async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'role': 'super_admin',
        'roleUpdatedAt': FieldValue.serverTimestamp(),
      });
      print('👑 Rol de super_admin asignado al usuario: ${user.email}');
    }
  }
}

/// Funciones globales para uso rápido en debug
/// Estas funciones están pensadas para usar desde la consola de debug
/// o desde un botón temporal durante el desarrollo

/// Convierte el usuario actual en desarrollador
Future<void> makeMeDeveloper() async {
  await DeveloperRoleHelper.setCurrentUserAsDeveloper();
}

/// Convierte el usuario actual en super admin
Future<void> makeMeSuperAdmin() async {
  await DeveloperRoleHelper.debugSetCurrentUserAsSuperAdmin();
}

/// Lista todos los desarrolladores
Future<void> listDevs() async {
  await DeveloperRoleHelper.listDeveloperUsers();
}

/// Verifica mi rol actual
Future<void> checkMyRole() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    
    if (userDoc.exists) {
      final userData = userDoc.data() as Map<String, dynamic>;
      print('🔍 Tu información de usuario:');
      print('  - Email: ${userData['email']}');
      print('  - Nombre: ${userData['name']}');
      print('  - Rol actual: ${userData['role'] ?? 'Sin rol'}');
      print('  - UID: ${user.uid}');
    } else {
      print('❌ Documento de usuario no encontrado');
    }
  } else {
    print('❌ No hay usuario autenticado');
  }
}
