import '../database_helper.dart';
import '../../models/receita/receita.dart';

class ReceitaDao {
  final dbHelper = DatabaseHelper.instance;

  Future<int> create(Receita receita) async {
    final db = await dbHelper.database;
    return await db.insert('receitas', receita.toMap());
  }

  Future<Receita?> read(int id) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      'receitas',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Receita.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Receita>> readAll() async {
    final db = await dbHelper.database;
    final result = await db.query('receitas', orderBy: 'data DESC');
    return result.map((map) => Receita.fromMap(map)).toList();
  }

  Future<List<Receita>> readByUsuario(int usuarioId) async {
    final db = await dbHelper.database;
    final result = await db.query(
      'receitas',
      where: 'usuarioId = ?',
      whereArgs: [usuarioId],
      orderBy: 'data DESC',
    );
    return result.map((map) => Receita.fromMap(map)).toList();
  }

  Future<double> getTotalByUsuario(int usuarioId) async {
    final db = await dbHelper.database;
    final result = await db.rawQuery(
      'SELECT SUM(valor) as total FROM receitas WHERE usuarioId = ?',
      [usuarioId],
    );
    return result.first['total'] as double? ?? 0.0;
  }

  Future<int> update(Receita receita) async {
    final db = await dbHelper.database;
    return await db.update(
      'receitas',
      receita.toMap(),
      where: 'id = ?',
      whereArgs: [receita.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await dbHelper.database;
    return await db.delete(
      'receitas',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
