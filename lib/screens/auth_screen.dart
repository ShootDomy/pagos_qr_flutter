import 'package:flutter/material.dart';
import '../services/usuario_service.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'principal_screen.dart';

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
      appBar: AppBar(title: Text('Iniciar Sesión')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
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
                child: _loading
                    ? CircularProgressIndicator()
                    : Text('Ingresar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
