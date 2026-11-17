class IngressoParque {
  final int? id;
  final int? idRemoto;
  final double valor;
  final int numeroBilhete;
  final bool sincronizado;

  IngressoParque(
    this.valor,
    this.numeroBilhete, {
    this.id,
    this.idRemoto,
    this.sincronizado = false,
  });

  factory IngressoParque.fromJson(Map<String, dynamic> json) {
    return IngressoParque(
      (json['valor'] as num).toDouble(),
      json['numeroBilhete'] as int,
      idRemoto: json['id'] as int,
      sincronizado: true,
    );
  }

  factory IngressoParque.fromMap(Map<String, Object?> map) {
    return IngressoParque(
      (map['valor'] as num).toDouble(),
      map['numero_bilhete'] as int,
      id: map['id'] as int?,
      idRemoto: map['id_remoto'] as int?,
      sincronizado: map['sincronizado'] == 1,
    );
  }

  Map<String, dynamic> toJson() => {
    'valor': valor,
    'numeroBilhete': numeroBilhete,
  };

  Map<String, Object?> toMap() => {
    'id': id,
    'id_remoto': idRemoto,
    'valor': valor,
    'numero_bilhete': numeroBilhete,
    'sincronizado': sincronizado ? 1 : 0,
  };

  @override
  String toString() {
    return 'IngressoParque{valor: $valor, numeroBilhete: $numeroBilhete}';
  }
}
