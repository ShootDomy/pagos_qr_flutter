import 'package:pagos_qr_flutter/models/cuenta_request.dart';
import 'package:pagos_qr_flutter/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CuentaService {
  final ApiService apiService;

  CuentaService({required this.apiService});

  Future<dynamic> obtenerCuentaUsuario(CuentaRequest request) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final headers = {'Authorization': 'Bearer $token'};

      // Si necesitas enviar parámetros, puedes agregarlos aquí
      final queryParams = {
        'usuUuid': request.usuUuid,
        // agrega otros parámetros si tu endpoint los requiere
      };

      final response = await apiService.get(
        '/cuenta/usuario',
        headers: headers,
        queryParameters: queryParams,
      );

      return response;
    } catch (e) {
      // Manejo de error simple
      return {'error': e.toString()};
    }
  }
}
