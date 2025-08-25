import 'package:flutter/material.dart';
import '../services/usuario_service.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

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

      // Decodificar el JWT
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      debugPrint('Datos decodificados del JWT: $decodedToken');

      // Redirigir a la página principal
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
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
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _usuCorreoController,
              decoration: InputDecoration(labelText: 'Correo'),
            ),
            TextField(
              controller: _usuContrasenaController,
              decoration: InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            if (_error != null)
              Text(_error!, style: TextStyle(color: Colors.red)),
            ElevatedButton(
              onPressed: _loading ? null : _inicioSesion,
              child: _loading ? CircularProgressIndicator() : Text('Ingresar'),
            ),
          ],
        ),
      ),
    );
  }
}
