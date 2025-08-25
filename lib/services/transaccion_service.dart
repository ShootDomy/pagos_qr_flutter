import 'package:pagos_qr_flutter/services/api_service.dart';
import 'package:pagos_qr_flutter/models/transaccion_request.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TransaccionService {
  final ApiService apiService;

  TransaccionService({required this.apiService});

  Future<dynamic> procesarTransaccion(TransaccionRequest request) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final headers = {
      'Authorization': 'Bearer $token',
      // otros headers si necesitas
    };
    return await apiService.postWithHeaders(
      '/transaccion/procesar',
      request.toJson(),
      headers: headers,
    );
  }
}
