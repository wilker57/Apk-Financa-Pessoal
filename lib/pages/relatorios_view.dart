import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../mvvm/receita_viewmodel.dart';
import '../mvvm/despesa_viewmodel.dart';
import '../mvvm/usuario_viewmodel.dart';

class RelatoriosView extends StatefulWidget {
  const RelatoriosView({super.key});

  @override
  State<RelatoriosView> createState() => _RelatoriosViewState();
}

class _RelatoriosViewState extends State<RelatoriosView> {
  DateTime _from = DateTime.now().subtract(const Duration(days: 30));
  DateTime _to = DateTime.now();
  bool _isLoading = false;
  double _totalReceitas = 0.0;
  double _totalDespesas = 0.0;
  List<Map<String, dynamic>> _receitasPorDia = [];
  List<Map<String, dynamic>> _despesasPorDia = [];

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final usuarioVM = Provider.of<UsuarioViewModel>(context, listen: false);
    final receitaVM = Provider.of<ReceitaViewModel>(context, listen: false);
    final despesaVM = Provider.of<DespesaViewModel>(context, listen: false);

    if (usuarioVM.usuarioAtual == null) return;

    _totalReceitas = await receitaVM.totalReceitasEntre(_from, _to);
    _totalDespesas = await despesaVM.totalDespesasEntre(_from, _to);
    _receitasPorDia = await receitaVM.receitasPorDia(_from, _to);
    _despesasPorDia = await despesaVM.despesasPorDia(_from, _to);

    setState(() => _isLoading = false);
  }

  Future<DateTime?> _pickDate(DateTime initial) async {
    return await showDatePicker(
        context: context,
        initialDate: initial,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100));
  }

  List<BarChartGroupData> _buildBarGroups() {
    // Build map of date string -> totals
    final map = <String, Map<String, double>>{};
    for (var r in _receitasPorDia) {
      final day = r['day'] as String;
      map.putIfAbsent(day, () => {'receita': 0.0, 'despesa': 0.0});
      map[day]!['receita'] = (r['total'] as num).toDouble();
    }
    for (var d in _despesasPorDia) {
      final day = d['day'] as String;
      map.putIfAbsent(day, () => {'receita': 0.0, 'despesa': 0.0});
      map[day]!['despesa'] = (d['total'] as num).toDouble();
    }

    final sortedKeys = map.keys.toList()..sort();
    final groups = <BarChartGroupData>[];
    for (int i = 0; i < sortedKeys.length; i++) {
      final values = map[sortedKeys[i]]!;
      final r = values['receita']!;
      final d = values['despesa']!;
      groups.add(BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(toY: r, color: Colors.green, width: 10),
            BarChartRodData(toY: d, color: Colors.red, width: 10),
          ],
          barsSpace: 4));
    }
    return groups;
  }

  double _computeMaxY(List<BarChartGroupData> groups) {
    double maxY = 0.0;
    for (var g in groups) {
      for (var rod in g.barRods) {
        if (rod.toY > maxY) maxY = rod.toY;
      }
    }
    if (maxY <= 0) return 1.0;
    return maxY * 1.2;
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Relatórios')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final d = await _pickDate(_from);
                      if (d != null) setState(() => _from = d);
                    },
                    child:
                        Text('De: ${_from.day}/${_from.month}/${_from.year}'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final d = await _pickDate(_to);
                      if (d != null) setState(() => _to = d);
                    },
                    child: Text('Até: ${_to.day}/${_to.month}/${_to.year}'),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                    onPressed: _loadData, icon: const Icon(Icons.refresh)),
              ],
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Expanded(
                child: ListView(
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: [
                            Text(
                                'Totais: Receitas R\$ ${_totalReceitas.toStringAsFixed(2)} - Despesas R\$ ${_totalDespesas.toStringAsFixed(2)}'),
                            SizedBox(
                              height: 200,
                              child: PieChart(PieChartData(sections: [
                                PieChartSectionData(
                                    value: _totalReceitas,
                                    color: Colors.green,
                                    title: 'Receitas'),
                                PieChartSectionData(
                                    value: _totalDespesas,
                                    color: Colors.red,
                                    title: 'Despesas'),
                              ])),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: [
                            const Text('Receitas x Despesas por dia'),
                            SizedBox(
                              height: 300,
                              child: Builder(builder: (context) {
                                final groups = _buildBarGroups();
                                if (groups.isEmpty) {
                                  return const Center(
                                      child: Text(
                                          'Nenhum dado por dia para o período selecionado'));
                                }
                                final maxY = _computeMaxY(groups);
                                return BarChart(BarChartData(
                                  barGroups: groups,
                                  gridData: FlGridData(show: true),
                                  titlesData: FlTitlesData(show: false),
                                  borderData: FlBorderData(show: false),
                                  alignment: BarChartAlignment.spaceAround,
                                  maxY: maxY,
                                ));
                              }),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )
          ],
        ),
      ),
    );
  }
}
