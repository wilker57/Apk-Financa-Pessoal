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
            icon: const Icon(Icons.bar_chart_rounded),
            tooltip: 'Relatórios',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RelatoriosView()),
            ),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _mostrarOpcoesAdicionar,
        backgroundColor: const Color.fromARGB(212, 5, 166, 13),
        icon: const Icon(Icons.add),
        label: const Text('Adicionar'),
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const AdicionarReceitaView()),
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const AdicionarDespesaView()),
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
