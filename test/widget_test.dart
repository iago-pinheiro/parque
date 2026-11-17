import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:bank/data/ingresso_local_data_source.dart';
import 'package:bank/main.dart';
import 'package:bank/models/ingresso_parque.dart';
import 'package:bank/repositories/ingresso_repository.dart';
import 'package:bank/services/ingresso_service.dart';

void main() {
  sqfliteFfiInit();

  testWidgets('creates and lists a ticket', (WidgetTester tester) async {
    final local = await SqliteIngressoLocalDataSource.abrir(
      factory: databaseFactoryFfiNoIsolate,
      caminho: inMemoryDatabasePath,
    );
    final repository = IngressoRepository(local, _RemotoFake());
    addTearDown(local.fechar);

    await tester.pumpWidget(AppParque(repository: repository));
    await tester.pumpAndSettle();

    expect(find.text('Ingressos do parque'), findsOneWidget);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), '1003');
    await tester.enterText(find.byType(TextField).at(1), '12.50');
    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();

    await tester.pumpAndSettle();

    expect(find.text('Bilhete nº 1003'), findsOneWidget);
    expect(find.text('Pendente de sincronização'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.sync));
    await tester.pumpAndSettle();

    expect(find.text('Sincronização concluída'), findsOneWidget);
  });

  testWidgets('rejects invalid ticket values', (WidgetTester tester) async {
    final local = await SqliteIngressoLocalDataSource.abrir(
      factory: databaseFactoryFfiNoIsolate,
      caminho: inMemoryDatabasePath,
    );
    addTearDown(local.fechar);

    await tester.pumpWidget(
      AppParque(repository: IngressoRepository(local, _RemotoFake())),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), '0');
    await tester.enterText(find.byType(TextField).at(1), '-1');
    await tester.tap(find.text('Confirmar'));
    await tester.pump();

    expect(find.text('Informe números positivos válidos'), findsOneWidget);
    expect(find.text('Criando ingresso'), findsOneWidget);
  });
}

class _RemotoFake implements IngressoRemoteDataSource {
  final _ingressos = <IngressoParque>[];

  @override
  Future<List<IngressoParque>> listar() async => List.of(_ingressos);

  @override
  Future<IngressoParque> salvar(IngressoParque ingresso) async {
    final remoto = IngressoParque(
      ingresso.valor,
      ingresso.numeroBilhete,
      idRemoto: _ingressos.length + 1,
      sincronizado: true,
    );
    _ingressos.add(remoto);
    return remoto;
  }
}
