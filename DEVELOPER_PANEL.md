# Panel de Desarrollador - Documentación

## Acceso al Panel de Desarrollador

El panel de desarrollador es una funcionalidad **exclusiva** y **restringida** para personal autorizado. Esta área permite gestionar plantillas 3D que afectan toda la aplicación.

### Cómo Acceder

1. **Gesto Secreto**: En la pantalla de login, toca **7 veces seguidas** el icono de usuario (círculo azul/morado)
2. **Código de Acceso**: Aparecerá un diálogo solicitando un código secreto
3. **Código Actual**: `DEV_MODE_3D_2024`
4. **Acceso Directo**: También puedes navegar directamente a la ruta `/developer` (solo funciona cuando la app está en modo debug)

### Funcionalidades del Panel

#### 🗂️ Gestión de Plantillas 3D
- **Subida de Archivos**: Sube plantillas 3D para diferentes categorías de ropa
- **Formatos Soportados**:
  - **Modelos 3D**: `.obj`, `.fbx`, `.gltf`, `.glb`
  - **Texturas**: `.png`, `.jpg`, `.jpeg`, `.tiff`
  - **Patrones**: `.svg`, `.ai`, `.pdf`
  - **Animaciones**: `.fbx`, `.bvh`, `.json`

#### 📊 Categorías de Ropa
- Camisetas
- Pantalones  
- Vestidos
- Chaquetas
- Faldas
- Shorts
- Sudaderas
- Blusas
- Abrigos
- Trajes

#### ⚙️ Configuración Avanzada
- Gestión de formatos de archivo
- Configuración del sistema de renderizado 3D
- Administración de plantillas por categoría

### Seguridad

⚠️ **Advertencias Importantes**:
- Este panel NO puede ser asignado desde la aplicación normal
- Solo personal autorizado debe tener acceso
- Los cambios afectan a todos los usuarios de la aplicación
- Mantén el código de acceso confidencial

### Estructura de Archivos

```
lib/
├── screens/
│   └── developer/
│       └── developer_dashboard_screen.dart
├── utils/
│   └── developer_access.dart
└── main.dart (contiene la ruta '/developer')
```

### Notas Técnicas

- La pantalla es completamente responsiva (mobile/tablet/desktop)
- Utiliza Firebase Storage para almacenar las plantillas
- Interfaz oscura especializada para desarrolladores
- Sistema de progreso de subida de archivos
- Logout integrado con confirmación

### Modificar el Código de Acceso

Para cambiar el código secreto, edita el archivo `lib/utils/developer_access.dart`:

```dart
static const String _secretCode = "NUEVO_CODIGO_AQUI";
```

### Soporte

Para dudas sobre el panel de desarrollador, contacta al equipo de desarrollo.
