import 'package:bank/data/ingresso_local_data_source.dart';
import 'package:bank/models/ingresso_parque.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  late SqliteIngressoLocalDataSource local;

  setUp(() async {
    local = await SqliteIngressoLocalDataSource.abrir(
      factory: databaseFactoryFfi,
      caminho: inMemoryDatabasePath,
    );
  });

  tearDown(() => local.fechar());

  test('salva ingresso local como pendente', () async {
    await local.salvar(IngressoParque(45, 1001));

    final ingressos = await local.listar();
    final pendentes = await local.listarPendentes();

    expect(ingressos, hasLength(1));
    expect(ingressos.single.numeroBilhete, 1001);
    expect(ingressos.single.sincronizado, isFalse);
    expect(pendentes, hasLength(1));
  });

  test('marca ingresso como sincronizado com o id remoto', () async {
    final idLocal = await local.salvar(IngressoParque(45, 1001));

    await local.marcarSincronizado(idLocal, 9);

    final ingresso = (await local.listar()).single;
    expect(ingresso.idRemoto, 9);
    expect(ingresso.sincronizado, isTrue);
    expect(await local.listarPendentes(), isEmpty);
  });
}
