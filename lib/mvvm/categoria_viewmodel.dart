import 'package:flutter/foundation.dart';
import '../models/categoria/categoria.dart';
import '../services/dao/categoria_dao.dart';

class CategoriaViewModel extends ChangeNotifier {
  final CategoriaDao _categoriaDao = CategoriaDao();
  List<Categoria> _categorias = [];

  List<Categoria> get categorias => _categorias;

  Future<void> carregarCategorias() async {
    _categorias = await _categoriaDao.readAll();
    notifyListeners();
  }

  Future<List<Categoria>> getCategoriasPorTipo(String tipo) async {
    return await _categoriaDao.readByTipo(tipo);
  }

  Future<void> adicionarCategoria(Categoria categoria) async {
    await _categoriaDao.create(categoria);
    await carregarCategorias();
  }

  Future<void> removerCategoria(int id) async {
    await _categoriaDao.delete(id);
    await carregarCategorias();
  }

  Future<void> atualizarCategoria(Categoria categoria) async {
    await _categoriaDao.update(categoria);
    await carregarCategorias();
  }
}
