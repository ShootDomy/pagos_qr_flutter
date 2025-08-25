import 'package:pagos_qr_flutter/services/api_service.dart';

class TransaccionService {
  final ApiService apiService;

  TransaccionService({required this.apiService});

  Future<dynamic> getTransaccion(String id) async {
    return await apiService.get('/transacciones/$id');
  }

  Future<dynamic> createTransaccion(Map<String, dynamic> data) async {
    return await apiService.post('/transacciones', data);
  }
}
