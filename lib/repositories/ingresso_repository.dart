import 'package:bank/data/ingresso_local_data_source.dart';
import 'package:bank/models/ingresso_parque.dart';
import 'package:bank/services/ingresso_service.dart';

class IngressoRepository {
  final IngressoLocalDataSource _local;
  final IngressoRemoteDataSource _remoto;

  IngressoRepository(this._local, this._remoto);

  Future<List<IngressoParque>> listar() => _local.listar();

  Future<void> salvar(IngressoParque ingresso) async {
    await _local.salvar(ingresso);
  }

  Future<int> sincronizar() async {
    final pendentes = await _local.listarPendentes();
    for (final ingresso in pendentes) {
      final remoto = await _remoto.salvar(ingresso);
      await _local.marcarSincronizado(ingresso.id!, remoto.idRemoto!);
    }

    await _local.salvarRemotos(await _remoto.listar());
    return pendentes.length;
  }
}
