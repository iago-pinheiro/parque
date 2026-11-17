import 'dart:convert';

import 'package:bank/models/ingresso_parque.dart';
import 'package:http/http.dart' as http;

abstract class IngressoRemoteDataSource {
  Future<List<IngressoParque>> listar();
  Future<IngressoParque> salvar(IngressoParque ingresso);
}

class IngressoService implements IngressoRemoteDataSource {
  final Uri _baseUrl;
  final http.Client _client;

  IngressoService(Uri baseUrl, {http.Client? client})
    : _baseUrl = baseUrl,
      _client = client ?? http.Client();

  Uri get _ingressosUrl => _baseUrl.resolve('/ingressos');

  @override
  Future<List<IngressoParque>> listar() async {
    final response = await _client.get(_ingressosUrl);
    if (response.statusCode != 200) {
      throw Exception('Falha ao buscar ingressos (${response.statusCode})');
    }
    final json = jsonDecode(response.body) as List<dynamic>;
    return json
        .map((item) => IngressoParque.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<IngressoParque> salvar(IngressoParque ingresso) async {
    final response = await _client.post(
      _ingressosUrl,
      headers: {'content-type': 'application/json'},
      body: jsonEncode(ingresso.toJson()),
    );
    if (response.statusCode != 201) {
      throw Exception('Falha ao enviar ingresso (${response.statusCode})');
    }
    return IngressoParque.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }
}
