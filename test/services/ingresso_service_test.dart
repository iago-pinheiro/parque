import 'dart:convert';

import 'package:bank/models/ingresso_parque.dart';
import 'package:bank/services/ingresso_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('lista ingressos retornados pela API', () async {
    final service = IngressoService(
      Uri.parse('https://api.exemplo.com'),
      client: MockClient((request) async {
        expect(request.url.path, '/ingressos');
        return http.Response(
          jsonEncode([
            {'id': 1, 'valor': 45.0, 'numeroBilhete': 1001},
          ]),
          200,
          headers: {'content-type': 'application/json'},
        );
      }),
    );

    final ingressos = await service.listar();

    expect(ingressos.single.numeroBilhete, 1001);
  });

  test('envia ingresso para a API', () async {
    final service = IngressoService(
      Uri.parse('https://api.exemplo.com'),
      client: MockClient((request) async {
        expect(request.method, 'POST');
        expect(jsonDecode(request.body), {
          'valor': 45.0,
          'numeroBilhete': 1001,
        });
        return http.Response(
          jsonEncode({'id': 3, 'valor': 45.0, 'numeroBilhete': 1001}),
          201,
        );
      }),
    );

    final remoto = await service.salvar(IngressoParque(45, 1001));

    expect(remoto.idRemoto, 3);
  });
}
