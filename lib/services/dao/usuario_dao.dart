import '../database_helper.dart';
import '../../models/usuario/usuario.dart';

class UsuarioDao {
  final dbHelper = DatabaseHelper.instance;

  Future<int> create(Usuario usuario) async {
    final db = await dbHelper.database;
    return await db.insert('usuarios', usuario.toMap());
  }

  Future<Usuario?> read(int id) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      'usuarios',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Usuario.fromMap(maps.first);
    }
    return null;
  }

  Future<Usuario?> findByEmail(String email) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      'usuarios',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (maps.isNotEmpty) {
      return Usuario.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Usuario>> readAll() async {
    final db = await dbHelper.database;
    final result = await db.query('usuarios');
    return result.map((map) => Usuario.fromMap(map)).toList();
  }

  Future<int> update(Usuario usuario) async {
    final db = await dbHelper.database;
    return await db.update(
      'usuarios',
      usuario.toMap(),
      where: 'id = ?',
      whereArgs: [usuario.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await dbHelper.database;
    return await db.delete(
      'usuarios',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
