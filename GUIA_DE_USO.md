# 📖 Guía de Uso - Sistema de Autenticación

## 🚀 Cómo usar tu nueva aplicación con autenticación

### 📱 **Al abrir la aplicación por primera vez:**

1. **Pantalla de Login aparece automáticamente**
   - La aplicación detecta que no hay usuario logueado
   - Muestra el formulario de inicio de sesión

### 👤 **Para crear una nueva cuenta:**

1. **Toca "Regístrate"** en la pantalla de login
2. **Llena el formulario de registro:**
   - Nombre completo
   - Correo electrónico válido
   - Contraseña (mínimo 6 caracteres)
   - Confirmar contraseña
3. **Toca "Crear Cuenta"**
4. **¡Automáticamente serás llevado a la pantalla principal!**

### 🔐 **Para iniciar sesión:**

1. **En la pantalla de login, ingresa:**
   - Tu correo electrónico
   - Tu contraseña
2. **Toca "Iniciar Sesión"**
3. **Serás llevado a la pantalla principal**

### 🏠 **En la pantalla principal:**

#### **Verás:**
- ✅ Tu nombre y email en la tarjeta de bienvenida
- ✅ Un contador interactivo
- ✅ Indicadores de estado de Firebase (Auth, Firestore, Analytics)
- ✅ Botón flotante para incrementar el contador

#### **Funcionalidades:**
- 🔢 **Contador:** Cada clic se registra en Firebase Analytics y se guarda en Firestore
- 📊 **Analytics:** Todos tus eventos se registran automáticamente
- 💾 **Firestore:** Tus interacciones se guardan en la base de datos
- 🚪 **Cerrar Sesión:** Botón en la barra superior

### 🔄 **Persistencia de sesión:**

- ✅ **Una vez logueado, permaneces logueado** incluso si cierras la app
- ✅ **No necesitas volver a ingresar credenciales** a menos que cierres sesión manualmente
- ✅ **La app recordará tu estado** automáticamente

### 🚪 **Para cerrar sesión:**

1. **Toca el ícono de logout** (🚪) en la barra superior
2. **Confirma que quieres cerrar sesión**
3. **Serás regresado a la pantalla de login**

### 🔧 **Características técnicas que funcionan automáticamente:**

#### **Firebase Authentication:**
- ✅ Registro seguro de usuarios
- ✅ Inicio de sesión con validación
- ✅ Persistencia automática de sesión
- ✅ Manejo de errores

#### **Firebase Firestore:**
- ✅ Creación automática de perfil de usuario
- ✅ Guardado de interacciones en tiempo real
- ✅ Sincronización automática

#### **Firebase Analytics:**
- ✅ Tracking de registro de usuarios
- ✅ Tracking de inicios de sesión
- ✅ Tracking de interacciones del usuario
- ✅ Métricas automáticas

### 🎯 **Consejos de uso:**

1. **Email válido:** Asegúrate de usar un email real y válido
2. **Contraseña segura:** Usa al menos 6 caracteres
3. **Confirma contraseña:** Debe coincidir exactamente
4. **Interactúa:** Usa el contador para ver Firebase en acción
5. **Explora:** Revisa todos los indicadores de estado

### 🐛 **Manejo de errores:**

- ❌ **Email inválido:** La app te avisará con un mensaje
- ❌ **Contraseña incorrecta:** Recibirás una notificación de error
- ❌ **Email ya registrado:** El sistema te informará si ya existe
- ❌ **Campos vacíos:** La validación te pedirá llenar todos los campos

### 📊 **Ver datos en Firebase Console:**

1. **Ve a:** https://console.firebase.google.com/
2. **Selecciona tu proyecto:** cmdproyect-ae457
3. **Revisa:**
   - **Authentication:** Para ver usuarios registrados
   - **Firestore Database:** Para ver datos guardados
   - **Analytics:** Para ver eventos y métricas

### 🎉 **¡Disfruta tu aplicación con autenticación completa!**

Tu app ahora tiene todas las características de una aplicación profesional:
- 🔐 Sistema de usuarios seguro
- 💾 Base de datos en tiempo real
- 📊 Analytics automático
- 🎨 Interfaz moderna y responsiva

¡Todo está listo para usar! 🚀
