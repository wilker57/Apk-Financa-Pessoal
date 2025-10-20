import 'package:flutter/foundation.dart';

class SaldoViewModel extends ChangeNotifier {
  double _saldoInicial = 0;

  double get saldoInicial => _saldoInicial;

  void setSaldoInicial(double valor) {
    _saldoInicial = valor;
    notifyListeners();
  }

  double calcularSaldoAtual(double totalReceitas, double totalDespesas) {
    return _saldoInicial + totalReceitas - totalDespesas;
  }
}
