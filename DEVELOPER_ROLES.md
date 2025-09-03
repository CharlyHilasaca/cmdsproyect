# Configuración de Roles para Panel de Desarrollador

## Roles Permitidos

Para acceder al panel de desarrollador, el usuario debe tener uno de los siguientes roles en la base de datos:

### 🔧 `developer`
- **Propósito**: Desarrolladores del equipo
- **Permisos**: Acceso completo al panel de desarrollador
- **Funcionalidades**: Subir plantillas 3D, gestionar categorías, configurar formatos

### 👑 `admin` 
- **Propósito**: Administradores del sistema
- **Permisos**: Acceso completo al panel de desarrollador + funciones administrativas
- **Funcionalidades**: Todas las del desarrollador + gestión de usuarios

### 🚀 `super_admin`
- **Propósito**: Super administradores
- **Permisos**: Acceso total al sistema
- **Funcionalidades**: Control completo sobre el sistema

## Configuración en Firestore

### Estructura del Documento de Usuario

```javascript
// Ruta: /users/{userId}
{
  "email": "developer@empresa.com",
  "name": "Juan Pérez",
  "role": "developer",        // ← Campo requerido para acceso
  "createdAt": "2024-01-15T10:30:00Z",
  "isActive": true,
  // ... otros campos del usuario
}
```

### Pasos para Asignar Rol de Desarrollador

#### Opción 1: Desde Firebase Console
1. Abrir Firebase Console
2. Ir a **Firestore Database**
3. Navegar a la colección `users`
4. Seleccionar el documento del usuario (usar su UID)
5. Agregar/editar el campo `role` con valor `developer`

#### Opción 2: Desde el Código (para administradores)
```dart
// Asignar rol de desarrollador a un usuario
Future<void> assignDeveloperRole(String userId) async {
  await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .update({'role': 'developer'});
}
```

#### Opción 3: Script de Cloud Functions (recomendado para producción)
```javascript
// Cloud Function para asignar roles de manera segura
exports.assignDeveloperRole = functions.https.onCall(async (data, context) => {
  // Verificar que quien hace la petición es super_admin
  const callerUid = context.auth.uid;
  const callerDoc = await admin.firestore()
    .collection('users')
    .doc(callerUid)
    .get();
  
  if (callerDoc.data().role !== 'super_admin') {
    throw new functions.https.HttpsError('permission-denied', 
      'Solo super_admin puede asignar roles');
  }
  
  // Asignar el rol
  const { userId, role } = data;
  await admin.firestore()
    .collection('users')
    .doc(userId)
    .update({ role: role });
    
  return { success: true };
});
```

## Sistema de Acceso

### Doble Verificación
El sistema verifica **ambos** requisitos:
1. **Código Secreto**: `DEV_MODE_3D_2024`
2. **Rol en Base de Datos**: `developer`, `admin`, o `super_admin`

### Flujo de Acceso
```
Usuario toca 7 veces el icono
        ↓
Aparece diálogo de código
        ↓
Usuario ingresa código secreto
        ↓
Sistema verifica:
  ✓ Código correcto
  ✓ Usuario autenticado
  ✓ Rol válido en Firestore
        ↓
Acceso concedido al panel
```

### Mensajes de Error
- **Código incorrecto**: "Código incorrecto. Acceso denegado."
- **Sin rol válido**: "Usuario sin permisos de desarrollador."
- **Error de conexión**: "Error de conexión. Intente nuevamente."

## Seguridad

### Mejores Prácticas
1. **Nunca** hardcodear roles en el código cliente
2. **Siempre** verificar roles desde Firestore
3. **Usar** Cloud Functions para operaciones críticas
4. **Registrar** todos los accesos al panel de desarrollador
5. **Rotar** códigos secretos periódicamente

### Auditoría
```dart
// Registrar acceso al panel de desarrollador
Future<void> logDeveloperAccess() async {
  await FirebaseFirestore.instance
      .collection('developer_access_logs')
      .add({
    'userId': FirebaseAuth.instance.currentUser?.uid,
    'timestamp': FieldValue.serverTimestamp(),
    'action': 'panel_access',
    'ip': await getClientIP(), // implementar según necesidades
  });
}
```

## Comandos Útiles

### Consultar usuarios con rol de desarrollador
```javascript
// En Firebase Console > Firestore
users.where('role', 'in', ['developer', 'admin', 'super_admin'])
```

### Revocar acceso de desarrollador
```dart
Future<void> revokeDeveloperAccess(String userId) async {
  await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .update({'role': 'user'}); // o remover el campo
}
```

---

## ⚠️ Importante
- El panel de desarrollador **NO** es accesible desde la navegación normal de la app
- Solo se puede acceder mediante el gesto secreto + código + rol válido
- Los cambios en el panel afectan a **toda la aplicación**
- Asignar roles de desarrollador solo a personal autorizado
