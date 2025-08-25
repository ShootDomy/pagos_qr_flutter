import 'package:flutter/material.dart';
import '../services/usuario_service.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'principal_screen.dart';
import '../utils/colors.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  AuthScreenState createState() => AuthScreenState();
}

class AuthScreenState extends State<AuthScreen> {
  final TextEditingController _usuCorreoController = TextEditingController();
  final TextEditingController _usuContrasenaController =
      TextEditingController();

  bool _loading = false;
  String? _error;
  Future<void> _inicioSesion() async {
    final correo = _usuCorreoController.text.trim();
    final contrasena = _usuContrasenaController.text;

    // Validaciones
    if (correo.isEmpty || !correo.contains('@')) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ingresa un correo válido.')));
      return;
    }
    if (contrasena.isEmpty || contrasena.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('La contraseña debe tener al menos 6 caracteres.'),
        ),
      );
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final usuarioService = UsuarioService(apiService: ApiService());
      final response = await usuarioService.iniciarSesion(
        _usuCorreoController.text,
        _usuContrasenaController.text,
      );

      // Guardar el token JWT
      final prefs = await SharedPreferences.getInstance();
      final token = response['token'];
      await prefs.setString('token', token);

      // Decodificar el JWT y guardar usuUuid
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      debugPrint('Datos decodificados del JWT: $decodedToken');
      final usuUuid = decodedToken['usuUuid'];
      if (usuUuid != null) {
        await prefs.setString('usuUuid', usuUuid);
      }

      final usuNombre = decodedToken['usuNombre'];
      final usuApellido = decodedToken['usuApellido'];
      if (usuNombre != null) {
        await prefs.setString('usuNombre', usuNombre);
      }
      if (usuApellido != null) {
        await prefs.setString('usuApellido', usuApellido);
      }

      // Redirigir a la página principal
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => PrincipalScreen()),
        );
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColor,

      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 12,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset('assets/logo.png', fit: BoxFit.cover),
                ),
              ),
              SizedBox(height: 24),
              Text(
                "Inicio de Sesión",
                style: TextStyle(
                  color: kFieldColor,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  shadows: [
                    Shadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(1, 2),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Correo",
                  style: TextStyle(
                    color: kFieldColor,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              TextField(
                controller: _usuCorreoController,
                decoration: InputDecoration(
                  hintText: 'admin@example.com',
                  filled: true,
                  fillColor: kFieldColor,
                  labelStyle: TextStyle(color: kTextColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: TextStyle(color: kTextColor),
              ),
              SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Contraseña",
                  style: TextStyle(
                    color: kFieldColor,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              TextField(
                controller: _usuContrasenaController,
                decoration: InputDecoration(
                  hintText: '******',
                  filled: true,
                  fillColor: kFieldColor,
                  labelStyle: TextStyle(color: kTextColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                obscureText: true,
                style: TextStyle(color: kTextColor),
              ),
              SizedBox(height: 24),
              if (_error != null)
                Text(_error!, style: TextStyle(color: kErrorColor)),
              SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kFieldColor,
                    foregroundColor: kPrimaryColor,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _loading ? null : _inicioSesion,
                  child: _loading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text('Ingresar', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
