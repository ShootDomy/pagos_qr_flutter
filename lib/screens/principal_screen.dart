import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaccion_request.dart';
import '../services/api_service.dart';
import '../services/transaccion_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

class PrincipalScreen extends StatefulWidget {
  const PrincipalScreen({super.key});

  @override
  State<PrincipalScreen> createState() => _PrincipalScreenState();
}

// ...existing code...

class _PrincipalScreenState extends State<PrincipalScreen> {
  String? nombre;
  String? apellido;

  Future<void> _cargarDatosUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      nombre = prefs.getString('usuNombre');
      apellido = prefs.getString('usuApellido');
    });

    debugPrint(
      "Datos del usuario: ${prefs.getString('usuNombre')} ${prefs.getString('usuApellido')}",
    );
  }

  void _cerrarSesion() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      Navigator.of(context).pushReplacementNamed('/');
    }
  }

  @override
  void initState() {
    super.initState();
    _cargarDatosUsuario();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          channelKey: 'basic_channel',
          title: message.notification?.title ?? 'Título',
          body: message.notification?.body ?? 'Contenido',
        ),
      );
    });
  }

  void _abrirScanner() async {
    // Abrimos la pantalla del scanner y esperamos un mensaje de retorno
    final mensaje = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const ScannerFullScreen()),
    );

    // Mostramos el mensaje después de cerrar el scanner
    if (mensaje != null && mensaje.isNotEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(mensaje)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Principal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: _cerrarSesion,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              nombre != null && apellido != null
                  ? 'Bienvenido $nombre $apellido'
                  : 'Bienvenido al gestor de códigos QRasdsa',
              style: const TextStyle(fontSize: 18),
            ),

            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _abrirScanner,
              child: const Text('Escanear código QR'),
            ),
          ],
        ),
      ),
    );
  }
}

class ScannerFullScreen extends StatefulWidget {
  const ScannerFullScreen({super.key});

  @override
  State<ScannerFullScreen> createState() => _ScannerFullScreenState();
}

class _ScannerFullScreenState extends State<ScannerFullScreen> {
  final MobileScannerController _scannerController = MobileScannerController();
  bool _procesandoCodigo = false;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  Map<String, dynamic> parseQRData(String code) {
    try {
      return Map<String, dynamic>.from(jsonDecode(code));
    } catch (_) {
      return {};
    }
  }

  Future<void> _procesarCodigo(String code) async {
    final prefs = await SharedPreferences.getInstance();
    final usuUuid = prefs.getString('usuUuid') ?? '';

    if (_procesandoCodigo) return;
    setState(() => _procesandoCodigo = true);

    final data = parseQRData(code);
    final camposRequeridos = ['traUuid', 'traAmount'];
    final camposFaltantes = camposRequeridos
        .where((c) => data[c] == null)
        .toList();

    await _scannerController.stop();
    // Si faltan campos, cerramos primero y luego retornamos mensaje
    if (camposFaltantes.isNotEmpty) {
      if (mounted) {
        Navigator.of(context).pop(
          '❌ Error: el QR no contiene los campos: ${camposFaltantes.join(', ')}',
        );
      }
      setState(() => _procesandoCodigo = false);
      return;
    }

    try {
      final tokenUsuario = await FirebaseMessaging.instance.getToken();

      final transaccion = TransaccionRequest(
        traUuid: data['traUuid'],
        usuUuid: usuUuid,
        traMetodoPago: 'WALLET',
        traAmount: data['traAmount'],
        tokenUsuario: tokenUsuario ?? '',
      );

      final service = TransaccionService(apiService: ApiService());
      await service.procesarTransaccion(transaccion);

      if (mounted) {
        Navigator.of(context).pop('✅ Transacción procesada correctamente');
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop('❌ Error al procesar el QR: ${e.toString()}');
      }
    } finally {
      setState(() => _procesandoCodigo = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Cámara full screen
          MobileScanner(
            controller: _scannerController,
            fit: BoxFit.cover,
            onDetect: (capture) {
              for (final barcode in capture.barcodes) {
                if (barcode.rawValue != null) {
                  _procesarCodigo(barcode.rawValue!);
                  break;
                }
              }
            },
          ),

          // Recuadro visible en el centro
          CustomPaint(
            size: MediaQuery.of(context).size,
            painter: ScannerOverlay(),
          ),

          // Loader mientras procesa
          if (_procesandoCodigo)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),

          // Botón de cancelar
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop('❌ Escaneo cancelado');
                },
                icon: const Icon(Icons.close),
                label: const Text("Cancelar"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ScannerOverlay extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width * 0.7;
    final height = size.width * 0.7;
    final left = (size.width - width) / 2;
    final top = (size.height - height) / 3;

    final borderPaint = Paint()
      ..color = Colors.greenAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(left, top, width, height),
        const Radius.circular(16),
      ),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
