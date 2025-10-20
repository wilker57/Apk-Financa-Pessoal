import 'package:flutter/foundation.dart';
import '../models/despesa/despesa.dart';
import '../services/dao/despesa_dao.dart';

class DespesaViewModel extends ChangeNotifier {
  final DespesaDao _despesaDao = DespesaDao();
  List<Despesa> _despesas = [];
  int? _usuarioIdAtual;

  List<Despesa> get despesas => _despesas;

  void setUsuario(int usuarioId) {
    _usuarioIdAtual = usuarioId;
    carregarDespesas();
  }

  Future<void> carregarDespesas() async {
    if (_usuarioIdAtual != null) {
      _despesas = await _despesaDao.readByUsuario(_usuarioIdAtual!);
      notifyListeners();
    }
  }

  Future<void> adicionarDespesa(Despesa despesa) async {
    await _despesaDao.create(despesa);
    await carregarDespesas();
  }

  Future<void> removerDespesa(int id) async {
    await _despesaDao.delete(id);
    await carregarDespesas();
  }

  Future<void> atualizarDespesa(Despesa despesa) async {
    await _despesaDao.update(despesa);
    await carregarDespesas();
  }

  Future<double> get totalDespesas async {
    if (_usuarioIdAtual != null) {
      return await _despesaDao.getTotalByUsuario(_usuarioIdAtual!);
    }
    return 0.0;
  }
}
