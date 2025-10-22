import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('despesa_pessoal.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    // bump DB version to 2 to add payment fields for parcelas
    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          try {
            await db.execute(
                "ALTER TABLE despesas ADD COLUMN pagamentoTipo TEXT DEFAULT 'AVISTA'");
          } catch (e) {
            // ignore if column already exists
          }
          try {
            await db.execute(
                "ALTER TABLE despesas ADD COLUMN parcelasTotal INTEGER DEFAULT 1");
          } catch (e) {}
          try {
            await db.execute(
                "ALTER TABLE despesas ADD COLUMN parcelaNumero INTEGER DEFAULT 1");
          } catch (e) {}
        }
      },
    );
  }

  Future<void> _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const integerType = 'INTEGER NOT NULL';
    const realType = 'REAL NOT NULL';

    // Tabela de Usuários
    await db.execute('''
      CREATE TABLE usuarios (
        id $idType,
        nome $textType,
        email $textType,
        senha $textType,
        dataCriacao $textType
      )
    ''');

    // Tabela de Categorias
    await db.execute('''
      CREATE TABLE categorias (
        id $idType,
        nome $textType,
        descricao TEXT,
        tipo $textType
      )
    ''');

    // Tabela de Receitas
    await db.execute('''
      CREATE TABLE receitas (
        id $idType,
        usuarioId $integerType,
        categoriaId INTEGER,
        descricao $textType,
        valor $realType,
        data $textType,
        dataCriacao $textType,
        FOREIGN KEY (usuarioId) REFERENCES usuarios (id) ON DELETE CASCADE,
        FOREIGN KEY (categoriaId) REFERENCES categorias (id) ON DELETE SET NULL
      )
    ''');

    // Tabela de Despesas
    await db.execute('''
      CREATE TABLE despesas (
        id $idType,
        usuarioId $integerType,
        categoriaId INTEGER,
        descricao $textType,
        valor $realType,
        data $textType,
        dataCriacao $textType,
        pagamentoTipo TEXT,
        parcelasTotal INTEGER,
        parcelaNumero INTEGER,
        FOREIGN KEY (usuarioId) REFERENCES usuarios (id) ON DELETE CASCADE,
        FOREIGN KEY (categoriaId) REFERENCES categorias (id) ON DELETE SET NULL
      )
    ''');

    // Inserir categorias padrão
    await _insertDefaultCategories(db);
  }

  Future<void> _insertDefaultCategories(Database db) async {
    final categorias = [
      {
        'nome': 'Alimentação',
        'descricao': 'Gastos com comida',
        'tipo': 'DESPESA'
      },
      {
        'nome': 'Transporte',
        'descricao': 'Gastos com transporte',
        'tipo': 'DESPESA'
      },
      {'nome': 'Saúde', 'descricao': 'Gastos com saúde', 'tipo': 'DESPESA'},
      {
        'nome': 'Educação',
        'descricao': 'Gastos com educação',
        'tipo': 'DESPESA'
      },
      {'nome': 'Lazer', 'descricao': 'Gastos com lazer', 'tipo': 'DESPESA'},
      {'nome': 'Moradia', 'descricao': 'Gastos com moradia', 'tipo': 'DESPESA'},
      {'nome': 'Outros', 'descricao': 'Outros gastos', 'tipo': 'DESPESA'},
      {'nome': 'Salário', 'descricao': 'Receita de salário', 'tipo': 'RECEITA'},
      {
        'nome': 'Investimentos',
        'descricao': 'Receita de investimentos',
        'tipo': 'RECEITA'
      },
      {
        'nome': 'Freelance',
        'descricao': 'Receita de trabalhos freelance',
        'tipo': 'RECEITA'
      },
      {'nome': 'Outros', 'descricao': 'Outras receitas', 'tipo': 'RECEITA'},
    ];

    for (var categoria in categorias) {
      await db.insert('categorias', categoria);
    }
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
