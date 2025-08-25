import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaccion_request.dart';
import '../services/api_service.dart';
import '../services/transaccion_service.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  bool _procesandoCodigo = false;

  Future<void> _procesarCodigo(BuildContext context, String code) async {
    if (_procesandoCodigo) return;
    _procesandoCodigo = true;

    try {
      // Simulando parseo de QR
      final data = parseQRData(code);
      final camposRequeridos = ['traUuid', 'traAmount'];
      final camposFaltantes = camposRequeridos
          .where((c) => data[c] == null)
          .toList();

      if (camposFaltantes.isNotEmpty) {
        if (mounted) {
          Navigator.of(context).pop(
            '❌ Error: El QR no contiene los siguientes campos requeridos: ${camposFaltantes.join(", ")}',
          );
        }
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final usuUuid = prefs.getString('usuUuid') ?? '';
      final tokenUsuario = prefs.getString('tokenDispositivo') ?? '';

      final transaccion = TransaccionRequest(
        traUuid: data['traUuid'],
        usuUuid: usuUuid,
        traMetodoPago: 'WALLET',
        traAmount: data['traAmount'],
        tokenUsuario: tokenUsuario,
      );

      final service = TransaccionService(apiService: ApiService());
      await service.procesarTransaccion(transaccion);

      if (mounted) {
        Navigator.of(context).pop('✅ Transacción procesada correctamente');
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop('❌ Error al procesar el QR: $e');
      }
    } finally {
      _procesandoCodigo = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Escanear QR"),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              Navigator.of(context).pop('❌ Escaneo cancelado por el usuario');
            },
          ),
        ],
      ),
      body: MobileScanner(
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          for (final barcode in barcodes) {
            if (barcode.rawValue != null) {
              _procesarCodigo(context, barcode.rawValue!);
              break;
            }
          }
        },
      ),
    );
  }
}

// Ejemplo de parser
Map<String, dynamic> parseQRData(String qr) {
  // Aquí simulas parseo real, ejemplo:
  if (qr.contains("traUuid") && qr.contains("traAmount")) {
    return {"traUuid": "12345", "traAmount": "50.00"};
  }
  return {};
}
