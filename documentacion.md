# Documentación de Pagos QR Flutter

## Requisitos de sistema y dependencias

### Requisitos de sistema

- **Flutter SDK:** >= 3.9.0
- **Dart SDK:** >= 3.9.0
- **Android/iOS:** Compatible con dispositivos móviles modernos.
- **Permisos requeridos:** Cámara, Internet, Notificaciones.

### Dependencias principales

- **firebase_core**: Inicialización de Firebase.
- **firebase_messaging**: Notificaciones push.
- **awesome_notifications**: Notificaciones locales.
- **http**: Llamadas HTTP a la API.
- **flutter_dotenv**: Manejo de variables de entorno.
- **shared_preferences**: Almacenamiento local de datos.
- **jwt_decoder**: Decodificación de tokens JWT.
- **mobile_scanner**: Escaneo de códigos QR.
- **provider**: Gestión de estado.

Este documento describe los principales flujos, funciones y servicios del proyecto **pagos_qr_flutter**.

---

## Flujos Principales

### 1. Autenticación de Usuario

- **Pantalla:** `AuthScreen`
- **Flujo:**
  - El usuario ingresa correo y contraseña.
  - Se valida el formato y longitud.
  - Se llama a `UsuarioService.iniciarSesion` para autenticar vía API.
  - El token JWT recibido se guarda en `SharedPreferences`.
  - Se decodifica el JWT para obtener datos del usuario (UUID, nombre, apellido).
  - Redirige a la pantalla principal (`PrincipalScreen`).

### 2. Pantalla Principal y Datos de Cuenta

- **Pantalla:** `PrincipalScreen`
- **Flujo:**
  - Al iniciar, carga nombre y apellido del usuario desde `SharedPreferences`.
  - Llama a `CuentaService.obtenerCuentaUsuario` para obtener saldo y número de cuenta.
  - Muestra los datos en la UI.
  - Permite cerrar sesión (limpia datos y redirige a login).

### 3. Escaneo de Código QR y Procesamiento de Transacción

- **Pantalla:** `ScannerFullScreen` (desde `PrincipalScreen`)
- **Flujo:**
  - El usuario pulsa "Escanear código QR".
  - Se abre la cámara y se detecta el QR.
  - Se parsea el contenido y valida campos requeridos (`traUuid`, `traAmount`).
  - Llama a `TransaccionService.procesarTransaccion` para procesar el pago.
  - Muestra mensaje de éxito o error.

---

## Servicios

### ApiService

- Encapsula llamadas HTTP (`get`, `post`, `postWithHeaders`).
- Usa la URL base definida en `.env`.
- Maneja errores y decodifica respuestas.

### UsuarioService

- **Método:** `iniciarSesion(usuCorreo, usuContrasena)`
- Llama a `/usuario/auth/inicio` vía POST.
- Devuelve datos de autenticación y usuario.

### CuentaService

- **Método:** `obtenerCuentaUsuario(request)`
- Llama a `/cuenta/usuario` vía GET, usando el token JWT.
- Devuelve saldo y número de cuenta.

### TransaccionService

- **Método:** `procesarTransaccion(request)`
- Llama a `/transaccion/procesar` vía POST, usando el token JWT.
- Procesa la transacción de pago.

---

## Modelos

### CuentaRequest

- Representa la solicitud para obtener datos de cuenta.
- Campos: `cueUuid`, `cueNumCuenta`, `cueSaldo`, `usuUuid`.

### TransaccionRequest

- Representa la solicitud para procesar una transacción.
- Campos: `traUuid`, `usuUuid`, `traMetodoPago`, `traAmount`, `tokenUsuario`.

---

## Notificaciones y Permisos

- Se usan `FirebaseMessaging` y `AwesomeNotifications` para notificaciones push.
- Permisos de cámara y notificaciones están definidos en los archivos de configuración (`AndroidManifest.xml`, `Info.plist`).

---

## Utilidades

- Colores y estilos definidos en `utils/colors.dart`.
- Manejo de preferencias con `SharedPreferences`.

---

## Resumen de Pantallas

- **AuthScreen:** Login y autenticación.
- **PrincipalScreen:** Dashboard principal, datos de usuario y cuenta, acceso a escaneo QR.
- **ScannerFullScreen:** Escaneo y procesamiento de códigos QR.

---

## Observaciones

- El flujo está orientado a pagos rápidos mediante QR.
- La seguridad se basa en JWT y validación de datos.
- El diseño es modular, separando servicios, modelos y pantallas.

---

## Contacto y Soporte

Este proyecto fue creado por **Domenica Vintimilla**.

- 📧 **Correo**: [canizaresdomenica4@gmail.com](mailto:canizaresdomenica4@gmail.com)
- 🐙 **GitHub**: [https://github.com/ShootDomy](https://github.com/ShootDomy)
- 💼 **LinkedIn**: [https://www.linkedin.com/in/domenica-vintimilla-24a735245/](https://www.linkedin.com/in/domenica-vintimilla-24a735245/)
