# Flutter Firebase Integration

## 🔥 Estado de la Integración

✅ **Firebase Core** - Configurado e inicializado  
✅ **Firebase Analytics** - Instalado y funcionando  
✅ **Cloud Firestore** - Instalado y listo para usar  
✅ **Firebase Auth** - Instalado y listo para usar  
✅ **Configuración de Plataformas** - Android, iOS, macOS y Web configurados  

## 📋 Dependencias Instaladas

```yaml
dependencies:
  firebase_core: ^3.3.0
  firebase_auth: ^5.1.4
  cloud_firestore: ^5.2.1
  firebase_analytics: ^11.2.1
```

## 🚀 Cómo usar Firebase en tu aplicación

### 1. Firebase Analytics
```dart
import 'package:firebase_analytics/firebase_analytics.dart';

// Registrar un evento
FirebaseAnalytics analytics = FirebaseAnalytics.instance;
await analytics.logEvent(
  name: 'button_pressed',
  parameters: {'counter_value': 1},
);
```

### 2. Cloud Firestore
```dart
import 'package:cloud_firestore/cloud_firestore.dart';

// Escribir datos
FirebaseFirestore firestore = FirebaseFirestore.instance;
await firestore.collection('users').add({
  'name': 'Juan',
  'email': 'juan@example.com',
});

// Leer datos
QuerySnapshot snapshot = await firestore.collection('users').get();
```

### 3. Firebase Auth
```dart
import 'package:firebase_auth/firebase_auth.dart';

// Registrar usuario
FirebaseAuth auth = FirebaseAuth.instance;
UserCredential userCredential = await auth.createUserWithEmailAndPassword(
  email: 'email@example.com',
  password: 'password123',
);
```

## 🛠️ Firebase Service Helper

Se ha creado un archivo `firebase_service.dart` con métodos helper para facilitar el uso de Firebase:

```dart
import 'firebase_service.dart';

// Agregar datos a Firestore
await FirebaseService.addData('users', {'name': 'Juan', 'age': 25});

// Obtener datos de Firestore
List<QueryDocumentSnapshot> docs = await FirebaseService.getData('users');

// Registrar evento en Analytics
await FirebaseService.logEvent('user_action', {'action': 'button_click'});
```

## 🌐 Plataformas Configuradas

- ✅ **Android** - `com.example.cmdproyect`
- ✅ **iOS** - `com.example.cmdproyect` *(Solucionado)*
- ✅ **macOS** - `com.example.cmdproyect`
- ✅ **Web** - Configurado para Edge/Chrome
- ❌ **Windows** - Pendiente (requiere Visual Studio Build Tools)
- ❌ **Linux** - No configurado

## 📝 Próximos Pasos

1. **Habilitar servicios en Firebase Console:**
   - Ir a https://console.firebase.google.com/
   - Seleccionar el proyecto `cmdproyect`
   - Habilitar Authentication, Firestore, Analytics según necesites

2. **Configurar reglas de seguridad en Firestore:**
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /{document=**} {
         allow read, write: if request.auth != null;
       }
     }
   }
   ```

3. **Agregar autenticación:**
   - Habilitar métodos de autenticación en Firebase Console
   - Implementar login/registro en la aplicación

## 🚨 Notas Importantes

- Los archivos de configuración (`firebase_options.dart`) fueron generados automáticamente
- No subir estos archivos a repositorios públicos si contienen información sensible
- Para iOS se necesitará ejecutar `flutterfire configure` nuevamente y configurar el bundle ID
- Para Windows se necesita instalar Visual Studio Build Tools

## 🔧 Comandos Útiles

```bash
# Reconfigurar Firebase
flutterfire configure

# Obtener dependencias
flutter pub get

# Ejecutar en web
flutter run -d edge

# Verificar configuración de Flutter
flutter doctor
```
