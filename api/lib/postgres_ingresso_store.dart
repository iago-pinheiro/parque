import 'package:parque_api/app.dart';
import 'package:postgres/postgres.dart';

class PostgresIngressoStore implements IngressoStore {
  final Pool<void> _pool;

  PostgresIngressoStore(this._pool);

  Future<void> inicializar() async {
    await _pool.execute('''
      CREATE TABLE IF NOT EXISTS ingressos (
        id SERIAL PRIMARY KEY,
        valor DOUBLE PRECISION NOT NULL CHECK (valor > 0),
        numero_bilhete INTEGER NOT NULL UNIQUE CHECK (numero_bilhete > 0)
      )
    ''');
  }

  @override
  Future<List<Map<String, Object?>>> listar() async {
    final result = await _pool.execute('''
      SELECT id, valor, numero_bilhete
      FROM ingressos
      ORDER BY id ASC
    ''');
    return result.map(_mapear).toList();
  }

  @override
  Future<Map<String, Object?>> salvar({
    required double valor,
    required int numeroBilhete,
  }) async {
    final result = await _pool.execute(
      Sql.named('''
        INSERT INTO ingressos (valor, numero_bilhete)
        VALUES (@valor, @numeroBilhete)
        ON CONFLICT (numero_bilhete) DO UPDATE SET valor = excluded.valor
        RETURNING id, valor, numero_bilhete
      '''),
      parameters: {'valor': valor, 'numeroBilhete': numeroBilhete},
    );
    return _mapear(result.single);
  }

  Map<String, Object?> _mapear(ResultRow row) {
    final columns = row.toColumnMap();
    return {
      'id': columns['id'] as int,
      'valor': (columns['valor'] as num).toDouble(),
      'numeroBilhete': columns['numero_bilhete'] as int,
    };
  }
}
