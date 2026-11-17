import 'package:bank/models/ingresso_parque.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('converte ingresso entre JSON e modelo', () {
    final ingresso = IngressoParque.fromJson({
      'id': 7,
      'valor': 45.5,
      'numeroBilhete': 1001,
    });

    expect(ingresso.idRemoto, 7);
    expect(ingresso.valor, 45.5);
    expect(ingresso.numeroBilhete, 1001);
    expect(ingresso.sincronizado, isTrue);
    expect(ingresso.toJson(), {'valor': 45.5, 'numeroBilhete': 1001});
  });
}
