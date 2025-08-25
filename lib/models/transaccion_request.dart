class TransaccionRequest {
  final String traUuid;
  final String usuUuid;
  final String traMetodoPago;
  final int traAmount;
  final String tokenUsuario;

  TransaccionRequest({
    required this.traUuid,
    required this.usuUuid,
    required this.traMetodoPago,
    required this.traAmount,
    required this.tokenUsuario,
  });

  Map<String, dynamic> toJson() => {
    'traUuid': traUuid,
    'usuUuid': usuUuid,
    'traMetodoPago': traMetodoPago,
    'traAmount': traAmount,
    'tokenUsuario': tokenUsuario,
  };
}
