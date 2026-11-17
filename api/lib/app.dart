import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

abstract class IngressoStore {
  Future<List<Map<String, Object?>>> listar();

  Future<Map<String, Object?>> salvar({
    required double valor,
    required int numeroBilhete,
  });
}

Handler criarHandler(IngressoStore store) {
  final router = Router()
    ..get('/health', (Request request) => _json({'status': 'ok'}))
    ..get('/ingressos', (Request request) async {
      try {
        return _json(await store.listar());
      } catch (_) {
        return _json({'erro': 'Erro interno'}, statusCode: 500);
      }
    })
    ..post('/ingressos', (Request request) async {
      try {
        final body = jsonDecode(await request.readAsString());
        if (body is! Map<String, dynamic>) {
          return _requisicaoInvalida();
        }
        final valor = body['valor'];
        final numeroBilhete = body['numeroBilhete'];
        if (valor is! num ||
            valor <= 0 ||
            numeroBilhete is! int ||
            numeroBilhete <= 0) {
          return _requisicaoInvalida();
        }
        return _json(
          await store.salvar(
            valor: valor.toDouble(),
            numeroBilhete: numeroBilhete,
          ),
          statusCode: 201,
        );
      } on FormatException {
        return _requisicaoInvalida();
      } catch (_) {
        return _json({'erro': 'Erro interno'}, statusCode: 500);
      }
    });

  return const Pipeline().addMiddleware(logRequests()).addHandler(router.call);
}

Response _requisicaoInvalida() => _json({
  'erro': 'valor e numeroBilhete devem ser números positivos',
}, statusCode: 400);

Response _json(Object body, {int statusCode = 200}) {
  return Response(
    statusCode,
    body: jsonEncode(body),
    headers: {'content-type': 'application/json; charset=utf-8'},
  );
}
