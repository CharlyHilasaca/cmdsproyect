import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';

class FirebaseStorageService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Sube un archivo 3D a Firebase Storage
  static Future<Map<String, dynamic>?> upload3DFile({
    required PlatformFile file,
    required String category,
    required String fileType,
    String? description,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw 'Usuario no autenticado';

      // Generar nombre único para el archivo
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${category}_${timestamp}_${file.name}';
      final filePath = '3d_models/$category/$fileName';

      // Referencia al archivo en Storage
      final ref = _storage.ref().child(filePath);

      // Subir archivo
      UploadTask uploadTask;
      if (file.bytes != null) {
        uploadTask = ref.putData(file.bytes!);
      } else if (file.path != null) {
        uploadTask = ref.putFile(File(file.path!));
      } else {
        throw 'No se pudo acceder al archivo';
      }

      // Monitorear progreso
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // Guardar metadata en Firestore
      final modelData = {
        'fileName': file.name,
        'filePath': filePath,
        'downloadUrl': downloadUrl,
        'category': category,
        'fileType': fileType,
        'fileSize': file.size,
        'description': description ?? '',
        'uploadedBy': user.uid,
        'uploadedAt': FieldValue.serverTimestamp(),
        'isActive': true,
        'version': 1,
        'tags': [category, fileType],
      };

      final docRef = await _firestore.collection('3d_models').add(modelData);

      return {
        'id': docRef.id,
        'downloadUrl': downloadUrl,
        'metadata': modelData,
      };
    } catch (e) {
      print('Error uploading 3D file: $e');
      rethrow;
    }
  }

  /// Obtiene todos los modelos 3D de una categoría
  static Stream<QuerySnapshot> get3DModelsByCategory(String category) {
    return _firestore
        .collection('3d_models')
        .where('category', isEqualTo: category)
        .where('isActive', isEqualTo: true)
        .orderBy('uploadedAt', descending: true)
        .snapshots();
  }

  /// Obtiene todos los modelos 3D
  static Stream<QuerySnapshot> getAllActiveModels() {
    return _firestore
        .collection('3d_models')
        .where('isActive', isEqualTo: true)
        .orderBy('uploadedAt', descending: true)
        .snapshots();
  }

  /// Elimina un modelo 3D
  static Future<void> deleteModel(String modelId, String filePath) async {
    try {
      // Eliminar archivo de Storage
      await _storage.ref().child(filePath).delete();

      // Marcar como inactivo en Firestore
      await _firestore.collection('3d_models').doc(modelId).update({
        'isActive': false,
        'deletedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error deleting model: $e');
      rethrow;
    }
  }

  /// Actualiza metadata de un modelo
  static Future<void> updateModelMetadata({
    required String modelId,
    String? description,
    List<String>? tags,
    String? category,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (description != null) updates['description'] = description;
      if (tags != null) updates['tags'] = tags;
      if (category != null) updates['category'] = category;

      await _firestore.collection('3d_models').doc(modelId).update(updates);
    } catch (e) {
      print('Error updating model metadata: $e');
      rethrow;
    }
  }

  /// Descarga un archivo 3D temporalmente para visualización
  static Future<String> getDownloadUrl(String filePath) async {
    try {
      return await _storage.ref().child(filePath).getDownloadURL();
    } catch (e) {
      print('Error getting download URL: $e');
      rethrow;
    }
  }

  /// Obtiene información de uso de almacenamiento
  static Future<Map<String, dynamic>> getStorageUsage() async {
    try {
      final snapshot = await _firestore
          .collection('3d_models')
          .where('isActive', isEqualTo: true)
          .get();

      int totalFiles = snapshot.docs.length;
      int totalSize = 0;
      Map<String, int> categoryCount = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        totalSize += (data['fileSize'] as int? ?? 0);
        
        final category = data['category'] as String? ?? 'unknown';
        categoryCount[category] = (categoryCount[category] ?? 0) + 1;
      }

      return {
        'totalFiles': totalFiles,
        'totalSize': totalSize,
        'categoryBreakdown': categoryCount,
        'averageFileSize': totalFiles > 0 ? totalSize / totalFiles : 0,
      };
    } catch (e) {
      print('Error getting storage usage: $e');
      return {};
    }
  }
}
