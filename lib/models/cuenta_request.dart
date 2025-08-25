class CuentaRequest {
  final String? cueUuid;
  final int? cueNumCuenta;
  final double? cueSaldo;
  final String? usuUuid;

  CuentaRequest({this.cueUuid, this.cueNumCuenta, this.cueSaldo, this.usuUuid});

  Map<String, dynamic> toJson() {
    return {
      'cueUuid': cueUuid,
      'cueNumCuenta': cueNumCuenta,
      'cueSaldo': cueSaldo,
      'usuUuid': usuUuid,
    };
  }
}
