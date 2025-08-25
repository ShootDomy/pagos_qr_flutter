import 'package:pagos_qr_flutter/services/api_service.dart';

class UsuarioService {
  final ApiService apiService;

  UsuarioService({required this.apiService});

  Future<dynamic> getUsuario(String id) async {
    return await apiService.get('/usuarios/$id');
  }

  Future<dynamic> createUsuario(Map<String, dynamic> data) async {
    return await apiService.post('/usuarios', data);
  }
}
