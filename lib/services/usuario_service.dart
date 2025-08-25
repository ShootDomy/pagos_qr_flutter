import 'package:pagos_qr_flutter/services/api_service.dart';

class UsuarioService {
  final ApiService apiService;

  UsuarioService({required this.apiService});

  // AUTENTICACIÓN
  Future<dynamic> iniciarSesion(String usuCorreo, String usuContrasena) async {
    return await apiService.post('/usuario/auth/inicio', {
      'usuCorreo': usuCorreo,
      'usuContrasena': usuContrasena,
    });
  }
}
