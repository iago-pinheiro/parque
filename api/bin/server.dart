import 'dart:io';

import 'package:parque_api/app.dart';
import 'package:parque_api/postgres_ingresso_store.dart';
import 'package:postgres/postgres.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

Future<void> main() async {
  final databaseUrl = Platform.environment['DATABASE_URL'];
  if (databaseUrl == null || databaseUrl.isEmpty) {
    throw StateError('DATABASE_URL não configurada');
  }

  final pool = Pool<void>.withUrl(databaseUrl);
  final store = PostgresIngressoStore(pool);
  await store.inicializar();

  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = await shelf_io.serve(
    criarHandler(store),
    InternetAddress.anyIPv4,
    port,
  );
  stdout.writeln('API disponível na porta ${server.port}');
}
