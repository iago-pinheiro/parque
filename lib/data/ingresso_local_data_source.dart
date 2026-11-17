import 'package:bank/models/ingresso_parque.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

abstract class IngressoLocalDataSource {
  Future<List<IngressoParque>> listar();
  Future<List<IngressoParque>> listarPendentes();
  Future<int> salvar(IngressoParque ingresso);
  Future<void> marcarSincronizado(int idLocal, int idRemoto);
  Future<void> salvarRemotos(List<IngressoParque> ingressos);
}

class SqliteIngressoLocalDataSource implements IngressoLocalDataSource {
  static const _tabela = 'ingressos';
  final Database _database;

  SqliteIngressoLocalDataSource._(this._database);

  static Future<SqliteIngressoLocalDataSource> abrir({
    DatabaseFactory? factory,
    String? caminho,
  }) async {
    final selectedFactory = factory ?? databaseFactory;
    final databasePath = caminho ?? join(await getDatabasesPath(), 'parque.db');
    final database = await selectedFactory.openDatabase(
      databasePath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE $_tabela (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              id_remoto INTEGER UNIQUE,
              valor REAL NOT NULL,
              numero_bilhete INTEGER NOT NULL UNIQUE,
              sincronizado INTEGER NOT NULL DEFAULT 0
            )
          ''');
        },
      ),
    );
    return SqliteIngressoLocalDataSource._(database);
  }

  @override
  Future<List<IngressoParque>> listar() async {
    final rows = await _database.query(_tabela, orderBy: 'id ASC');
    return rows.map(IngressoParque.fromMap).toList();
  }

  @override
  Future<List<IngressoParque>> listarPendentes() async {
    final rows = await _database.query(
      _tabela,
      where: 'sincronizado = ?',
      whereArgs: [0],
      orderBy: 'id ASC',
    );
    return rows.map(IngressoParque.fromMap).toList();
  }

  @override
  Future<int> salvar(IngressoParque ingresso) {
    return _database.insert(_tabela, ingresso.toMap());
  }

  @override
  Future<void> marcarSincronizado(int idLocal, int idRemoto) async {
    await _database.update(
      _tabela,
      {'id_remoto': idRemoto, 'sincronizado': 1},
      where: 'id = ?',
      whereArgs: [idLocal],
    );
  }

  @override
  Future<void> salvarRemotos(List<IngressoParque> ingressos) async {
    await _database.transaction((transaction) async {
      for (final ingresso in ingressos) {
        await transaction.rawInsert(
          '''
          INSERT INTO $_tabela (id_remoto, valor, numero_bilhete, sincronizado)
          VALUES (?, ?, ?, 1)
          ON CONFLICT(numero_bilhete) DO UPDATE SET
            id_remoto = excluded.id_remoto,
            valor = excluded.valor,
            sincronizado = 1
          ''',
          [ingresso.idRemoto, ingresso.valor, ingresso.numeroBilhete],
        );
      }
    });
  }

  Future<void> fechar() => _database.close();
}
