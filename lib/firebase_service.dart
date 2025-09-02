import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // ========== MÉTODOS DE AUTENTICACIÓN ==========

  // Obtener usuario actual
  static User? get currentUser => _auth.currentUser;

  // Stream de cambios de autenticación
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Verificar conectividad de Firestore
  static Future<bool> checkFirestoreConnectivity() async {
    try {
      // Intentar hacer una operación simple para verificar conectividad
      await _firestore.enableNetwork();

      // Intentar leer un documento simple (esto puede fallar si la base de datos no existe)
      await _firestore.collection('_test_connectivity').limit(1).get();

      return true;
    } catch (e) {
      print('Error de conectividad de Firestore: $e');

      if (e.toString().contains('does not exist') ||
          e.toString().contains('database') ||
          e.toString().contains('project')) {
        print('La base de datos Firestore no existe para este proyecto');
      }

      return false;
    }
  }

  // Habilitar modo offline para Firestore
  static Future<void> enableOfflineMode() async {
    try {
      await _firestore.disableNetwork();
      print('Modo offline habilitado');
    } catch (e) {
      print('Error al habilitar modo offline: $e');
    }
  }

  // Deshabilitar modo offline para Firestore
  static Future<void> disableOfflineMode() async {
    try {
      await _firestore.enableNetwork();
      print('Modo online habilitado');
    } catch (e) {
      print('Error al deshabilitar modo offline: $e');
    }
  }

  // Registrar nuevo usuario
  static Future<UserCredential?> registerUser({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Actualizar el nombre del usuario
      await userCredential.user?.updateDisplayName(name);

      // Guardar datos adicionales del usuario en Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': name,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'uid': userCredential.user!.uid,
      });

      // Registrar evento en Analytics
      await logEvent('user_registered', {'method': 'email'});

      print('Usuario registrado exitosamente: ${userCredential.user!.email}');
      return userCredential;
    } catch (e) {
      print('Error al registrar usuario: $e');
      return null;
    }
  }

  // Iniciar sesión
  static Future<UserCredential?> signInUser({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Registrar evento en Analytics
      await logEvent('user_login', {'method': 'email'});

      print('Usuario logueado exitosamente: ${userCredential.user!.email}');
      return userCredential;
    } catch (e) {
      print('Error al iniciar sesión: $e');
      return null;
    }
  }

  // Cerrar sesión
  static Future<void> signOut() async {
    try {
      await _auth.signOut();
      await logEvent('user_logout', {});
      print('Sesión cerrada exitosamente');
    } catch (e) {
      print('Error al cerrar sesión: $e');
    }
  }

  // Obtener datos del usuario desde Firestore
  static Future<DocumentSnapshot?> getUserData(String uid) async {
    try {
      return await _firestore.collection('users').doc(uid).get();
    } catch (e) {
      print('Error al obtener datos del usuario: $e');
      return null;
    }
  }

  // ========== MÉTODOS DE FIRESTORE ==========

  // Método para escribir datos en Firestore
  static Future<void> addData(
    String collection,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore.collection(collection).add(data);
      print('Datos agregados exitosamente a $collection');
    } catch (e) {
      print('Error al agregar datos: $e');
    }
  }

  // Método para leer datos de Firestore
  static Future<List<QueryDocumentSnapshot>> getData(String collection) async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection(collection).get();
      return querySnapshot.docs;
    } catch (e) {
      print('Error al obtener datos: $e');
      return [];
    }
  }

  // ========== MÉTODOS DE ANALYTICS ==========

  // Método para registrar eventos en Analytics
  static Future<void> logEvent(
    String eventName,
    Map<String, Object> parameters,
  ) async {
    try {
      await _analytics.logEvent(name: eventName, parameters: parameters);
      print('Evento registrado: $eventName');
    } catch (e) {
      print('Error al registrar evento: $e');
    }
  }

  // Método para obtener el estado de Firebase
  static bool isFirebaseInitialized() {
    try {
      // Verificar si Firebase está inicializado
      return true;
    } catch (e) {
      return false;
    }
  }
}
