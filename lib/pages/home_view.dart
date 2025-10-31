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
  int _selectedIndex = 0;
  // external resumo removed — values not required in Home

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
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            tooltip: 'Abrir menu',
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
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
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              UserAccountsDrawerHeader(
                accountName: Text(usuario?.nome ?? 'Usuário'),
                accountEmail: Text(usuario?.email ?? ''),
                currentAccountPicture: CircleAvatar(
                  child: Text(
                      (usuario?.nome ?? 'U').substring(0, 1).toUpperCase()),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Home'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _selectedIndex = 0);
                },
              ),
              ListTile(
                leading: const Icon(Icons.arrow_upward),
                title: const Text('Receitas'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _selectedIndex = 1);
                },
              ),
              ListTile(
                leading: const Icon(Icons.arrow_downward),
                title: const Text('Despesas'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _selectedIndex = 2);
                },
              ),
              ListTile(
                leading: const Icon(Icons.bar_chart),
                title: const Text('Relatórios'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _selectedIndex = 3);
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Configurações'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _selectedIndex = 4);
                  // Navegar para a tela de configurações (a implementar)
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Sair'),
                onTap: _logout,
              ),
            ],
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _carregarDados,
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            const _DashboardContent(),
            _ReceitaTab(),
            _DespesaTab(),
            const RelatoriosView(),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.arrow_upward), label: 'Receita'),
          BottomNavigationBarItem(
              icon: Icon(Icons.arrow_downward), label: 'Despesa'),
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart), label: 'Relatórios'),
        ],
      ),
    );
  }

  Widget? _buildFloatingActionButton() {
    // Show context-aware FAB: add receita/despesa when on respective tabs, default "Adicionar" on home
    if (_selectedIndex == 1) {
      return FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AdicionarReceitaView()),
        ),
        backgroundColor: Colors.green,
        icon: const Icon(Icons.add),
        label: const Text('Adicionar Receita'),
      );
    }

    if (_selectedIndex == 2) {
      return FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AdicionarDespesaView()),
        ),
        backgroundColor: Colors.red,
        icon: const Icon(Icons.add),
        label: const Text('Adicionar Despesa'),
      );
    }

    // Default FAB (home)
    return FloatingActionButton.extended(
      onPressed: _mostrarOpcoesAdicionar,
      backgroundColor: const Color.fromARGB(212, 5, 166, 13),
      icon: const Icon(Icons.add),
      label: const Text('Adicionar'),
    );
  }

  // navigation to RelatoriosView is now a simple push; no data returned

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
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Resumo', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _ResumoCardItem(
                      icon: Icons.arrow_upward_rounded,
                      label: 'Receitas',
                      valor: formatter.format(receitas),
                      color: Colors.green,
                    ),
                    _ResumoCardItem(
                      icon: Icons.arrow_downward_rounded,
                      label: 'Despesas',
                      valor: formatter.format(despesas),
                      color: Colors.red,
                    ),
                  ],
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
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        Text(valor,
            style: TextStyle(
                color: color, fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

// Note: transaction list widgets were moved to RelatoriosView (_ListaTransacoesRel)

// 🔹 RECEITA TAB
class _ReceitaTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final receitaVM = context.watch<ReceitaViewModel>();
    final formatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    final receitas = receitaVM.receitas;

    if (receitas.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.arrow_upward, size: 64, color: Colors.green),
            SizedBox(height: 12),
            Text('Nenhuma receita encontrada'),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: receitas.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        final r = receitas[index];
        return Dismissible(
          key: ValueKey(r.id),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          confirmDismiss: (_) async {
            final ok = await showDialog<bool>(
              context: context,
              builder: (c) => AlertDialog(
                title: const Text('Confirmar'),
                content: const Text('Deseja remover esta receita?'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(c, false),
                      child: const Text('Cancelar')),
                  TextButton(
                      onPressed: () => Navigator.pop(c, true),
                      child: const Text('Remover')),
                ],
              ),
            );
            return ok == true;
          },
          onDismissed: (_) async {
            final messenger = ScaffoldMessenger.of(context);
            if (r.id != null) await receitaVM.removerReceita(r.id!);
            messenger.showSnackBar(
                const SnackBar(content: Text('Receita removida')));
          },
          child: ListTile(
            title: Text(r.descricao),
            subtitle: Text('${r.data.day}/${r.data.month}/${r.data.year}'),
            trailing: Text(formatter.format(r.valor),
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.green)),
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => AdicionarReceitaView(receita: r))),
          ),
        );
      },
    );
  }
}

// 🔹 DESPESA TAB
class _DespesaTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final despesaVM = context.watch<DespesaViewModel>();
    final formatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    final despesas = despesaVM.despesas;

    if (despesas.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.arrow_downward, size: 64, color: Colors.red),
            SizedBox(height: 12),
            Text('Nenhuma despesa encontrada'),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: despesas.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        final d = despesas[index];
        return Dismissible(
          key: ValueKey(d.id),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          confirmDismiss: (_) async {
            final ok = await showDialog<bool>(
              context: context,
              builder: (c) => AlertDialog(
                title: const Text('Confirmar'),
                content: const Text('Deseja remover esta despesa?'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(c, false),
                      child: const Text('Cancelar')),
                  TextButton(
                      onPressed: () => Navigator.pop(c, true),
                      child: const Text('Remover')),
                ],
              ),
            );
            return ok == true;
          },
          onDismissed: (_) async {
            final messenger = ScaffoldMessenger.of(context);
            if (d.id != null) await despesaVM.removerDespesa(d.id!);
            messenger.showSnackBar(
                const SnackBar(content: Text('Despesa removida')));
          },
          child: ListTile(
            title: Text(d.descricao),
            subtitle: Text('${d.data.day}/${d.data.month}/${d.data.year}'),
            trailing: Text(formatter.format(d.valor),
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.red)),
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => AdicionarDespesaView(despesa: d))),
          ),
        );
      },
    );
  }
}
