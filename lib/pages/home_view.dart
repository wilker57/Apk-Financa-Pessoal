import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../mvvm/usuario_viewmodel.dart';
import '../mvvm/receita_viewmodel.dart';
import '../mvvm/despesa_viewmodel.dart';
import '../mvvm/saldo_viewmodel.dart';
import '../mvvm/categoria_viewmodel.dart';
import 'adicionar_receita_view.dart';
import 'adicionar_despesa_view.dart';
import 'login_view.dart';
import 'relatorios_view.dart';
<<<<<<< HEAD
=======
import 'package:intl/intl.dart';
>>>>>>> 33149a212ce0fcd001b971b6ddfda1ce09a5737e

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    final usuarioVM = context.read<UsuarioViewModel>();

    if (usuarioVM.usuarioAtual != null) {
      final usuarioId = usuarioVM.usuarioAtual!.id!;
      final receitaVM = context.read<ReceitaViewModel>();
      final despesaVM = context.read<DespesaViewModel>();
      final categoriaVM = context.read<CategoriaViewModel>();

      receitaVM.setUsuario(usuarioId);
      despesaVM.setUsuario(usuarioId);

      await Future.wait([
        receitaVM.carregarReceitas(),
        despesaVM.carregarDespesas(),
        categoriaVM.carregarCategorias(),
      ]);
    }

    if (mounted) setState(() => _isLoading = false);
  }

  void _logout() {
    context.read<UsuarioViewModel>().logout();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginView()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final usuario = context.watch<UsuarioViewModel>().usuarioAtual;

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Olá, ${usuario?.nome ?? "Usuário"} ',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
<<<<<<< HEAD
            icon: const Icon(Icons.bar_chart_rounded),
            tooltip: 'Relatórios',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RelatoriosView()),
            ),
=======
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (c) => const RelatoriosView()));
            },
            tooltip: 'Relatórios',
>>>>>>> 33149a212ce0fcd001b971b6ddfda1ce09a5737e
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: _logout,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _carregarDados,
        child: const _DashboardContent(),
      ),
<<<<<<< HEAD
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _mostrarOpcoesAdicionar,
        backgroundColor: const Color.fromARGB(212, 5, 166, 13),
        icon: const Icon(Icons.add),
        label: const Text('Adicionar'),
=======
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _mostrarOpcoesAdicionar();
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSaldoCard(ReceitaViewModel receitaVM, DespesaViewModel despesaVM,
      SaldoViewModel saldoVM) {
    return FutureBuilder<List<double>>(
      future: Future.wait([
        receitaVM.totalReceitas,
        despesaVM.totalDespesas,
      ]),
      builder: (context, snapshot) {
        final totalReceitas = snapshot.data?[0] ?? 0.0;
        final totalDespesas = snapshot.data?[1] ?? 0.0;
        final saldoAtual =
            saldoVM.calcularSaldoAtual(totalReceitas, totalDespesas);
        final formatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

        return Card(
          elevation: 4,
          color: saldoAtual >= 0 ? Colors.green.shade50 : Colors.red.shade50,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const Text(
                  'Saldo Atual',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  formatter.format(saldoAtual),
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: saldoAtual >= 0
                        ? Colors.green.shade700
                        : Colors.red.shade700,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildResumoCard(
      ReceitaViewModel receitaVM, DespesaViewModel despesaVM) {
    return FutureBuilder<List<double>>(
      future: Future.wait([
        receitaVM.totalReceitas,
        despesaVM.totalDespesas,
      ]),
      builder: (context, snapshot) {
        final totalReceitas = snapshot.data?[0] ?? 0.0;
        final totalDespesas = snapshot.data?[1] ?? 0.0;
        final formatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

        return Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      const Icon(Icons.arrow_upward,
                          color: Colors.green, size: 32),
                      const SizedBox(height: 8),
                      const Text(
                        'Receitas',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formatter.format(totalReceitas),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 80,
                  color: Colors.grey.shade300,
                ),
                Expanded(
                  child: Column(
                    children: [
                      const Icon(Icons.arrow_downward,
                          color: Colors.red, size: 32),
                      const SizedBox(height: 8),
                      const Text(
                        'Despesas',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formatter.format(totalDespesas),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildReceitasSection(ReceitaViewModel receitaVM) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Receitas Recentes',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${receitaVM.receitas.length} itens',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            receitaVM.receitas.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Nenhuma receita cadastrada',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                : Column(
                    children: receitaVM.receitas.take(5).map((receita) {
                      final formatter =
                          NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
                      final dateFormatter = DateFormat('dd/MM/yyyy');

                      return ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Colors.green,
                          child: Icon(Icons.arrow_upward, color: Colors.white),
                        ),
                        title: Text(receita.descricao),
                        subtitle: Text(dateFormatter.format(receita.data)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              formatter.format(receita.valor),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            PopupMenuButton<String>(
                              onSelected: (value) async {
                                final receitaVM = Provider.of<ReceitaViewModel>(
                                    context,
                                    listen: false);
                                if (value == 'edit') {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (c) => AdicionarReceitaView(
                                          receita: receita)));
                                } else if (value == 'delete') {
                                  final ok = await showDialog<bool>(
                                      context: context,
                                      builder: (c) => AlertDialog(
                                            title: const Text('Confirmar'),
                                            content: const Text(
                                                'Remover esta receita?'),
                                            actions: [
                                              TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(c, false),
                                                  child:
                                                      const Text('Cancelar')),
                                              TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(c, true),
                                                  child: const Text('Remover'))
                                            ],
                                          ));
                                  if (ok == true)
                                    await receitaVM.removerReceita(receita.id!);
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                    value: 'edit', child: Text('Editar')),
                                const PopupMenuItem(
                                    value: 'delete', child: Text('Excluir')),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildDespesasSection(DespesaViewModel despesaVM) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Despesas Recentes',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${despesaVM.despesas.length} itens',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            despesaVM.despesas.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Nenhuma despesa cadastrada',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                : Column(
                    children: despesaVM.despesas.take(5).map((despesa) {
                      final formatter =
                          NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
                      final dateFormatter = DateFormat('dd/MM/yyyy');

                      return ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Colors.red,
                          child:
                              Icon(Icons.arrow_downward, color: Colors.white),
                        ),
                        title: Row(
                          children: [
                            Expanded(child: Text(despesa.descricao)),
                            if (despesa.pagamentoTipo == 'PARCELADO')
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Chip(
                                  label: Text(
                                      '${despesa.parcelaNumero}/${despesa.parcelasTotal}'),
                                  backgroundColor: Colors.orange.shade100,
                                ),
                              ),
                          ],
                        ),
                        subtitle: Text(dateFormatter.format(despesa.data)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              formatter.format(despesa.valor),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                            PopupMenuButton<String>(
                              onSelected: (value) async {
                                final despesaVM = Provider.of<DespesaViewModel>(
                                    context,
                                    listen: false);
                                if (value == 'edit') {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (c) => AdicionarDespesaView(
                                          despesa: despesa)));
                                } else if (value == 'delete') {
                                  final ok = await showDialog<bool>(
                                      context: context,
                                      builder: (c) => AlertDialog(
                                            title: const Text('Confirmar'),
                                            content: const Text(
                                                'Remover esta despesa?'),
                                            actions: [
                                              TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(c, false),
                                                  child:
                                                      const Text('Cancelar')),
                                              TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(c, true),
                                                  child: const Text('Remover'))
                                            ],
                                          ));
                                  if (ok == true)
                                    await despesaVM.removerDespesa(despesa.id!);
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                    value: 'edit', child: Text('Editar')),
                                const PopupMenuItem(
                                    value: 'delete', child: Text('Excluir')),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
          ],
        ),
>>>>>>> 33149a212ce0fcd001b971b6ddfda1ce09a5737e
      ),
    );
  }

  void _mostrarOpcoesAdicionar() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Adicionar novo registro',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Escolha o que deseja adicionar:',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // 🔹 Opção: Receita
              ElevatedButton.icon(
                icon:
                    const Icon(Icons.arrow_upward_rounded, color: Colors.white),
                label: const Text(
                  'Adicionar Receita',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
<<<<<<< HEAD
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const AdicionarReceitaView()),
=======
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AdicionarReceitaView(),
                    ),
>>>>>>> 33149a212ce0fcd001b971b6ddfda1ce09a5737e
                  );
                },
              ),
              const SizedBox(height: 12),

              // 🔹 Opção: Despesa
              ElevatedButton.icon(
                icon: const Icon(Icons.arrow_downward_rounded,
                    color: Colors.white),
                label: const Text(
                  'Adicionar Despesa',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
<<<<<<< HEAD
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const AdicionarDespesaView()),
=======
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AdicionarDespesaView(),
                    ),
>>>>>>> 33149a212ce0fcd001b971b6ddfda1ce09a5737e
                  );
                },
              ),
            ],
          ),

          // 🔹 Botão de cancelar
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent();

  @override
  Widget build(BuildContext context) {
    final receitaVM = context.watch<ReceitaViewModel>();
    final despesaVM = context.watch<DespesaViewModel>();
    final saldoVM = context.watch<SaldoViewModel>();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SaldoCard(
            receitaVM: receitaVM, despesaVM: despesaVM, saldoVM: saldoVM),
        const SizedBox(height: 16),
        _ResumoCard(receitaVM: receitaVM, despesaVM: despesaVM),
        const SizedBox(height: 16),
        _ListaTransacoes(
          titulo: 'Receitas Recentes',
          corPrincipal: Colors.green,
          itens: receitaVM.receitas,
          tipo: 'receita',
        ),
        const SizedBox(height: 16),
        _ListaTransacoes(
          titulo: 'Despesas Recentes',
          corPrincipal: Colors.red,
          itens: despesaVM.despesas,
          tipo: 'despesa',
        ),
      ],
    );
  }
}

// 🔹 SALDO CARD
class _SaldoCard extends StatelessWidget {
  final ReceitaViewModel receitaVM;
  final DespesaViewModel despesaVM;
  final SaldoViewModel saldoVM;

  const _SaldoCard({
    required this.receitaVM,
    required this.despesaVM,
    required this.saldoVM,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return FutureBuilder<List<double>>(
      future: Future.wait([receitaVM.totalReceitas, despesaVM.totalDespesas]),
      builder: (context, snapshot) {
        final receitas = snapshot.data?[0] ?? 0.0;
        final despesas = snapshot.data?[1] ?? 0.0;
        final saldo = saldoVM.calcularSaldoAtual(receitas, despesas);

        return AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: saldo >= 0 ? Colors.green.shade50 : Colors.red.shade50,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Text(
                'Saldo Atual',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Text(
                formatter.format(saldo),
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color:
                      saldo >= 0 ? Colors.green.shade700 : Colors.red.shade700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                saldo >= 0
                    ? 'Você está no positivo 🎉'
                    : 'Cuidado! Gastos altos ⚠️',
                style: TextStyle(
                  color:
                      saldo >= 0 ? Colors.green.shade600 : Colors.red.shade600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// 🔹 RESUMO CARD
class _ResumoCard extends StatelessWidget {
  final ReceitaViewModel receitaVM;
  final DespesaViewModel despesaVM;

  const _ResumoCard({required this.receitaVM, required this.despesaVM});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return FutureBuilder<List<double>>(
      future: Future.wait([receitaVM.totalReceitas, despesaVM.totalDespesas]),
      builder: (context, snapshot) {
        final receitas = snapshot.data?[0] ?? 0.0;
        final despesas = snapshot.data?[1] ?? 0.0;

        return Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _ResumoCardItem(
                    icon: Icons.arrow_upward,
                    label: 'Receitas',
                    valor: formatter.format(receitas),
                    color: Colors.green,
                  ),
                ),
                Container(width: 1, height: 70, color: Colors.grey.shade300),
                Expanded(
                  child: _ResumoCardItem(
                    icon: Icons.arrow_downward,
                    label: 'Despesas',
                    valor: formatter.format(despesas),
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ResumoCardItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String valor;
  final Color color;

  const _ResumoCardItem({
    required this.icon,
    required this.label,
    required this.valor,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 6),
        Text(label,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        Text(valor,
            style: TextStyle(
                color: color, fontSize: 26, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

// 🔹 LISTA DE TRANSAÇÕES
class _ListaTransacoes extends StatelessWidget {
  final String titulo;
  final Color corPrincipal;
  final List<dynamic> itens;
  final String tipo;

  const _ListaTransacoes({
    required this.titulo,
    required this.corPrincipal,
    required this.itens,
    required this.tipo,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final dateFormatter = DateFormat('dd/MM/yyyy');

    if (itens.isEmpty) {
      return _EmptyState(mensagem: 'Nenhuma $tipo cadastrada');
    }

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
            ...itens.take(5).map((e) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: corPrincipal,
                  child: Icon(
                    tipo == 'receita'
                        ? Icons.arrow_upward
                        : Icons.arrow_downward,
                    color: Colors.white,
                  ),
                ),
                title: Text(e.descricao),
                subtitle: Text(dateFormatter.format(e.data)),
                trailing: Text(
                  formatter.format(e.valor),
                  style: TextStyle(
                      color: corPrincipal,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// 🔹 EMPTY STATE PADRÃO
class _EmptyState extends StatelessWidget {
  final String mensagem;

  const _EmptyState({required this.mensagem});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Icon(Icons.inbox_rounded, color: Colors.grey, size: 48),
            const SizedBox(height: 8),
            Text(
              mensagem,
              style: const TextStyle(color: Colors.grey, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}
