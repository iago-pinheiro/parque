import 'package:bank/data/ingresso_local_data_source.dart';
import 'package:bank/models/ingresso_parque.dart';
import 'package:bank/repositories/ingresso_repository.dart';
import 'package:bank/services/ingresso_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('salva localmente sem depender da API', () async {
    final local = _LocalFake();
    final repository = IngressoRepository(local, _RemotoFake());

    await repository.salvar(IngressoParque(45, 1001));

    expect(local.ingressos.single.numeroBilhete, 1001);
    expect(local.ingressos.single.sincronizado, isFalse);
  });

  test('sincroniza pendentes e baixa registros remotos', () async {
    final local = _LocalFake()
      ..ingressos.add(IngressoParque(45, 1001, id: 1))
      ..ingressos.add(
        IngressoParque(30, 999, id: 2, idRemoto: 99, sincronizado: true),
      );
    final remoto = _RemotoFake()
      ..ingressos.add(
        IngressoParque(80, 1002, idRemoto: 8, sincronizado: true),
      );
    final repository = IngressoRepository(local, remoto);

    final enviados = await repository.sincronizar();

    expect(enviados, 1);
    expect(remoto.ingressos.map((item) => item.numeroBilhete), [1002, 1001]);
    expect(local.ingressos.every((item) => item.sincronizado), isTrue);
  });
}

class _LocalFake implements IngressoLocalDataSource {
  final ingressos = <IngressoParque>[];

  @override
  Future<List<IngressoParque>> listar() async => List.of(ingressos);

  @override
  Future<List<IngressoParque>> listarPendentes() async {
    return ingressos.where((item) => !item.sincronizado).toList();
  }

  @override
  Future<int> salvar(IngressoParque ingresso) async {
    final id = ingressos.length + 1;
    ingressos.add(
      IngressoParque(ingresso.valor, ingresso.numeroBilhete, id: id),
    );
    return id;
  }

  @override
  Future<void> marcarSincronizado(int idLocal, int idRemoto) async {
    final index = ingressos.indexWhere((item) => item.id == idLocal);
    final atual = ingressos[index];
    ingressos[index] = IngressoParque(
      atual.valor,
      atual.numeroBilhete,
      id: atual.id,
      idRemoto: idRemoto,
      sincronizado: true,
    );
  }

  @override
  Future<void> salvarRemotos(List<IngressoParque> remotos) async {
    for (final remoto in remotos) {
      final index = ingressos.indexWhere(
        (item) => item.numeroBilhete == remoto.numeroBilhete,
      );
      if (index >= 0) {
        final local = ingressos[index];
        ingressos[index] = IngressoParque(
          remoto.valor,
          remoto.numeroBilhete,
          id: local.id,
          idRemoto: remoto.idRemoto,
          sincronizado: true,
        );
      } else {
        ingressos.add(remoto);
      }
    }
  }
}

class _RemotoFake implements IngressoRemoteDataSource {
  final ingressos = <IngressoParque>[];

  @override
  Future<List<IngressoParque>> listar() async => List.of(ingressos);

  @override
  Future<IngressoParque> salvar(IngressoParque ingresso) async {
    final remoto = IngressoParque(
      ingresso.valor,
      ingresso.numeroBilhete,
      idRemoto: ingressos.length + 1,
      sincronizado: true,
    );
    ingressos.add(remoto);
    return remoto;
  }
}
