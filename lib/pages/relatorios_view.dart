import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../mvvm/receita_viewmodel.dart';
import '../mvvm/despesa_viewmodel.dart';
import '../mvvm/usuario_viewmodel.dart';

class RelatoriosView extends StatefulWidget {
  const RelatoriosView({super.key});

  @override
  State<RelatoriosView> createState() => _RelatoriosViewState();
}

// 🔹 LISTA DE TRANSAÇÕES (usada em RelatoriosView)
class _ListaTransacoesRel extends StatelessWidget {
  final String titulo;
  final Color corPrincipal;
  final List<dynamic> itens;
  final String tipo;

  const _ListaTransacoesRel({
    required this.titulo,
    required this.corPrincipal,
    required this.itens,
    required this.tipo,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final dateFormatter = DateFormat('dd/MM/yyyy');

    if (itens.isEmpty)
      return _EmptyStateRel(mensagem: 'Nenhuma $tipo cadastrada');

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                    tipo == 'receita'
                        ? Icons.arrow_upward
                        : Icons.arrow_downward,
                    color: corPrincipal),
                const SizedBox(width: 8),
                Text(
                  titulo,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text('${itens.length} itens',
                    style: TextStyle(color: Colors.grey.shade600)),
              ],
            ),
            const SizedBox(height: 12),
            ...itens.take(10).map((e) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: corPrincipal,
                  child: Icon(
                      tipo == 'receita'
                          ? Icons.arrow_upward
                          : Icons.arrow_downward,
                      color: Colors.white),
                ),
                title: Text(e.descricao),
                subtitle: Text(dateFormatter.format(e.data)),
                trailing: Text(
                  import 'package:flutter/material.dart';
                  import 'package:provider/provider.dart';
                  import 'package:intl/intl.dart';
                  import '../mvvm/receita_viewmodel.dart';
                  import '../mvvm/despesa_viewmodel.dart';
                  import '../mvvm/usuario_viewmodel.dart';

                  class RelatoriosView extends StatefulWidget {
                    const RelatoriosView({super.key});

                    @override
                    State<RelatoriosView> createState() => _RelatoriosViewState();
                  }

                  class _RelatoriosViewState extends State<RelatoriosView> {
                    final DateFormat _fmt = DateFormat('dd/MM/yyyy');

                    DateTime _from = DateTime.now().subtract(const Duration(days: 30));
                    DateTime _to = DateTime.now();
                    bool _isLoading = false;
                    double _totalReceitas = 0.0;
                    double _totalDespesas = 0.0;
                    List<Map<String, dynamic>> _receitasPorDia = [];
                    List<Map<String, dynamic>> _despesasPorDia = [];

                    @override
                    void initState() {
                      super.initState();
                      _loadData();
                    }

                    Future<void> _loadData() async {
                      setState(() => _isLoading = true);
                      try {
                        final usuarioVM = context.read<UsuarioViewModel>();
                        final receitaVM = context.read<ReceitaViewModel>();
                        final despesaVM = context.read<DespesaViewModel>();

                        if (usuarioVM.usuarioAtual == null) return;

                        _totalReceitas = await receitaVM.totalReceitasEntre(_from, _to);
                        _totalDespesas = await despesaVM.totalDespesasEntre(_from, _to);
                        _receitasPorDia = await receitaVM.receitasPorDia(_from, _to);
                        _despesasPorDia = await despesaVM.despesasPorDia(_from, _to);
                      } finally {
                        if (mounted) setState(() => _isLoading = false);
                      }
                    }

                    Future<void> _selecionarData({required bool isFrom}) async {
                      final initial = isFrom ? _from : _to;
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: initial,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() {
                          if (isFrom) {
                            _from = picked;
                          } else {
                            _to = picked;
                          }
                        });
                      }
                    }

                    @override
                    Widget build(BuildContext context) {
                      final receitaVM = context.watch<ReceitaViewModel>();
                      final despesaVM = context.watch<DespesaViewModel>();
                      return Scaffold(
                        appBar: AppBar(
                          title: const Text('Relatórios'),
                          actions: [
                            IconButton(
                              tooltip: 'Atualizar dados',
                              icon: AnimatedRotation(
                                turns: _isLoading ? 1 : 0,
                                duration: const Duration(seconds: 1),
                                child: const Icon(Icons.refresh),
                              ),
                              onPressed: _isLoading ? null : _loadData,
                            ),
                          ],
                        ),
                        body: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              _PeriodoSelector(
                                from: _from,
                                to: _to,
                                fmt: _fmt,
                                onSelectFrom: () => _selecionarData(isFrom: true),
                                onSelectTo: () => _selecionarData(isFrom: false),
                              ),
                              const SizedBox(height: 16),
                              Expanded(
                                child: _isLoading
                                    ? const Center(child: CircularProgressIndicator())
                                    : ListView(
                                        children: [
                                          _ResumoFinanceiroCard(
                                            totalReceitas: _totalReceitas,
                                            totalDespesas: _totalDespesas,
                                          ),
                                          const SizedBox(height: 16),
                                          _MediaDespesasCard(
                                            despesasPorDia: _despesasPorDia,
                                            from: _from,
                                            to: _to,
                                          ),
                                          const SizedBox(height: 16),
                                          _ListaTransacoesRel(
                                            titulo: 'Receitas Recentes',
                                            corPrincipal: Colors.green,
                                            itens: receitaVM.receitas,
                                            tipo: 'receita',
                                          ),
                                          const SizedBox(height: 12),
                                          _ListaTransacoesRel(
                                            titulo: 'Despesas Recentes',
                                            corPrincipal: Colors.red,
                                            itens: despesaVM.despesas,
                                            tipo: 'despesa',
                                          ),
                                        ],
                                      ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  }

                  class _PeriodoSelector extends StatelessWidget {
                    final DateTime from, to;
                    final DateFormat fmt;
                    final VoidCallback onSelectFrom, onSelectTo;

                    const _PeriodoSelector({
                      required this.from,
                      required this.to,
                      required this.fmt,
                      required this.onSelectFrom,
                      required this.onSelectTo,
                    });

                    @override
                    Widget build(BuildContext context) {
                      return Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: onSelectFrom,
                              icon: const Icon(Icons.date_range),
                              label: Text('De: ${fmt.format(from)}'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: onSelectTo,
                              icon: const Icon(Icons.date_range_outlined),
                              label: Text('Até: ${fmt.format(to)}'),
                            ),
                          ),
                        ],
                      );
                    }
                  }

                  class _ResumoFinanceiroCard extends StatelessWidget {
                    final double totalReceitas;
                    final double totalDespesas;

                    const _ResumoFinanceiroCard({
                      required this.totalReceitas,
                      required this.totalDespesas,
                    });

                    @override
                    Widget build(BuildContext context) {
                      return Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              const Text('Resumo Financeiro', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                              const Divider(),
                              Text('Receitas: R\$ ${totalReceitas.toStringAsFixed(2)}', style: const TextStyle(color: Colors.green, fontSize: 18, fontWeight: FontWeight.w600)),
                              Text('Despesas: R\$ ${totalDespesas.toStringAsFixed(2)}', style: const TextStyle(color: Colors.red, fontSize: 18, fontWeight: FontWeight.w600)),
                              // Saldo intentionally removed from summary per request
                            ],
                          ),
                        ),
                      );
                    }
                  }

                  class _MediaDespesasCard extends StatelessWidget {
                    final List<Map<String, dynamic>> despesasPorDia;
                    final DateTime from;
                    final DateTime to;

                    const _MediaDespesasCard({
                      required this.despesasPorDia,
                      required this.from,
                      required this.to,
                    });

                    @override
                    Widget build(BuildContext context) {
                      final totalDias = to.difference(from).inDays + 1;
                      final totalDespesas = despesasPorDia.fold<double>(0.0, (sum, d) => sum + (d['total'] as num).toDouble());
                      final media = totalDias > 0 ? totalDespesas / totalDias : 0.0;

                      return Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              const Text('Média Diária de Despesas', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                              const Divider(),
                              if (despesasPorDia.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Column(
                                    children: [
                                      Icon(Icons.money_off_outlined, color: Colors.grey, size: 48),
                                      SizedBox(height: 8),
                                      Text('Nenhuma despesa registrada neste período.'),
                                    ],
                                  ),
                                )
                              else
                                Column(
                                  children: [
                                    Text('Período: ${DateFormat('dd/MM/yyyy').format(from)} - ${DateFormat('dd/MM/yyyy').format(to)}', style: const TextStyle(fontSize: 16, color: Colors.grey)),
                                    const SizedBox(height: 12),
                                    Text('R\$ ${media.toStringAsFixed(2)} / dia', style: const TextStyle(fontSize: 26, color: Colors.redAccent, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 8),
                                    Text('Total de ${totalDias} dias considerados.', style: const TextStyle(color: Colors.grey)),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      );
                    }
                  }

                  class _ListaTransacoesRel extends StatelessWidget {
                    final String titulo;
                    final Color corPrincipal;
                    final List<dynamic> itens;
                    final String tipo;

                    const _ListaTransacoesRel({
                      required this.titulo,
                      required this.corPrincipal,
                      required this.itens,
                      required this.tipo,
                    });

                    @override
                    Widget build(BuildContext context) {
                      final formatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
                      final dateFormatter = DateFormat('dd/MM/yyyy');

                      if (itens.isEmpty) return _EmptyStateRel(mensagem: 'Nenhuma $tipo cadastrada');

                      return Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Icon(tipo == 'receita' ? Icons.arrow_upward : Icons.arrow_downward, color: corPrincipal),
                                  const SizedBox(width: 8),
                                  Text(
                                    titulo,
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  const Spacer(),
                                  Text('${itens.length} itens', style: TextStyle(color: Colors.grey.shade600)),
                                ],
                              ),
                              const SizedBox(height: 12),
                              ...itens.take(10).map((e) {
                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: corPrincipal,
                                    child: Icon(tipo == 'receita' ? Icons.arrow_upward : Icons.arrow_downward, color: Colors.white),
                                  ),
                                  title: Text(e.descricao),
                                  subtitle: Text(dateFormatter.format(e.data)),
                                  trailing: Text(
                                    formatter.format(e.valor),
                                    style: TextStyle(color: corPrincipal, fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                      );
                    }
                  }

                  class _EmptyStateRel extends StatelessWidget {
                    final String mensagem;
                    const _EmptyStateRel({required this.mensagem});

                    @override
                    Widget build(BuildContext context) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            children: [
                              const Icon(Icons.inbox_rounded, color: Colors.grey, size: 48),
                              const SizedBox(height: 8),
                              Text(mensagem, style: const TextStyle(color: Colors.grey, fontSize: 15)),
                            ],
                          ),
                        ),
                      );
                    }
                  }

                  class _ListaTransacoesRel extends StatelessWidget {
                    final String titulo;
                    final Color corPrincipal;
                    final List<dynamic> itens;
                    final String tipo;

                    const _ListaTransacoesRel({
                      required this.titulo,
                      required this.corPrincipal,
                      required this.itens,
                      required this.tipo,
                    });

                    @override
                    Widget build(BuildContext context) {
                      final formatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\\$');
                      final dateFormatter = DateFormat('dd/MM/yyyy');

                      if (itens.isEmpty) return _EmptyStateRel(mensagem: 'Nenhuma $tipo cadastrada');

                      return Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Icon(tipo == 'receita' ? Icons.arrow_upward : Icons.arrow_downward, color: corPrincipal),
                                  const SizedBox(width: 8),
                                  Text(
                                    titulo,
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  const Spacer(),
                                  Text('${itens.length} itens', style: TextStyle(color: Colors.grey.shade600)),
                                ],
                              ),
                              const SizedBox(height: 12),
                              ...itens.take(10).map((e) {
                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: corPrincipal,
                                    child: Icon(tipo == 'receita' ? Icons.arrow_upward : Icons.arrow_downward, color: Colors.white),
                                  ),
                                  title: Text(e.descricao),
                                  subtitle: Text(dateFormatter.format(e.data)),
                                  trailing: Text(
                                    formatter.format(e.valor),
                                    style: TextStyle(color: corPrincipal, fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                      );
                    }
                  }

                  class _EmptyStateRel extends StatelessWidget {
                    final String mensagem;
                    const _EmptyStateRel({required this.mensagem});

                    @override
                    Widget build(BuildContext context) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            children: [
                              const Icon(Icons.inbox_rounded, color: Colors.grey, size: 48),
                              const SizedBox(height: 8),
                              Text(mensagem, style: const TextStyle(color: Colors.grey, fontSize: 15)),
                            ],
                          ),
                        ),
                      );
                    }
                  }
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Média Diária de Despesas',
                style: Theme.of(context).textTheme.titleMedium),
            const Divider(),
            if (despesasPorDia.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(Icons.money_off_outlined,
                        color: Colors.grey, size: 48),
                    SizedBox(height: 8),
                    Text('Nenhuma despesa registrada neste período.'),
                  ],
                ),
              )
            else
              Column(
                children: [
                  Text(
                    'Período: ${DateFormat('dd/MM/yyyy').format(from)} - ${DateFormat('dd/MM/yyyy').format(to)}',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'R\$ ${media.toStringAsFixed(2)} / dia',
                    style: const TextStyle(
                      fontSize: 22,
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Total de ${totalDias} dias considerados.',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
