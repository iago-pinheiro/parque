import 'dart:convert';

import 'package:parque_api/app.dart';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

void main() {
  test('GET /ingressos lista os ingressos', () async {
    final store = _StoreFake()
      ..ingressos.add({'id': 1, 'valor': 45.0, 'numeroBilhete': 1001});
    final response = await criarHandler(store)(
      Request('GET', Uri.parse('http://localhost/ingressos')),
    );

    expect(response.statusCode, 200);
    expect(jsonDecode(await response.readAsString()), store.ingressos);
  });

  test('POST /ingressos cria um ingresso válido', () async {
    final store = _StoreFake();
    final response = await criarHandler(store)(
      Request(
        'POST',
        Uri.parse('http://localhost/ingressos'),
        body: jsonEncode({'valor': 80.5, 'numeroBilhete': 1002}),
      ),
    );

    expect(response.statusCode, 201);
    expect(jsonDecode(await response.readAsString()), {
      'id': 1,
      'valor': 80.5,
      'numeroBilhete': 1002,
    });
  });

  test('POST /ingressos rejeita dados inválidos', () async {
    final response = await criarHandler(_StoreFake())(
      Request(
        'POST',
        Uri.parse('http://localhost/ingressos'),
        body: jsonEncode({'valor': -1, 'numeroBilhete': 0}),
      ),
    );

    expect(response.statusCode, 400);
  });
}

class _StoreFake implements IngressoStore {
  final ingressos = <Map<String, Object?>>[];

  @override
  Future<List<Map<String, Object?>>> listar() async => ingressos;

  @override
  Future<Map<String, Object?>> salvar({
    required double valor,
    required int numeroBilhete,
  }) async {
    final ingresso = {
      'id': ingressos.length + 1,
      'valor': valor,
      'numeroBilhete': numeroBilhete,
    };
    ingressos.add(ingresso);
    return ingresso;
  }
}
