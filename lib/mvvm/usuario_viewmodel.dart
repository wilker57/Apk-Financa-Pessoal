import 'package:flutter/foundation.dart';
import '../models/usuario/usuario.dart';
import '../services/dao/usuario_dao.dart';

class UsuarioViewModel extends ChangeNotifier {
  final UsuarioDao _usuarioDao = UsuarioDao();
  Usuario? _usuarioAtual;

  Usuario? get usuarioAtual => _usuarioAtual;
  bool get isLogado => _usuarioAtual != null;

  Future<bool> login(String email, String senha) async {
    try {
      final usuario = await _usuarioDao.findByEmail(email);

      if (usuario != null && usuario.senha == senha) {
        _usuarioAtual = usuario;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Erro ao fazer login: $e');
      return false;
    }
  }

  Future<bool> cadastrar(Usuario usuario) async {
    try {
      // Verifica se já existe usuário com este email
      final usuarioExistente = await _usuarioDao.findByEmail(usuario.email);

      if (usuarioExistente != null) {
        return false; // Email já cadastrado
      }

      final id = await _usuarioDao.create(usuario);
      usuario.id = id;
      _usuarioAtual = usuario;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Erro ao cadastrar: $e');
      return false;
    }
  }

  void logout() {
    _usuarioAtual = null;
    notifyListeners();
  }

  Future<void> atualizarUsuario(Usuario usuario) async {
    try {
      await _usuarioDao.update(usuario);
      _usuarioAtual = usuario;
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao atualizar usuário: $e');
    }
  }
}
