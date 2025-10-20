import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../mvvm/usuario_viewmodel.dart';
import '../mvvm/receita_viewmodel.dart';
import '../mvvm/despesa_viewmodel.dart';
import '../mvvm/saldo_viewmodel.dart';
import '../mvvm/categoria_viewmodel.dart';
import 'login_view.dart';
import 'package:intl/intl.dart';

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
    final usuarioVM = Provider.of<UsuarioViewModel>(context, listen: false);

    if (usuarioVM.usuarioAtual != null) {
      final usuarioId = usuarioVM.usuarioAtual!.id!;

      final receitaVM = Provider.of<ReceitaViewModel>(context, listen: false);
      final despesaVM = Provider.of<DespesaViewModel>(context, listen: false);
      final categoriaVM =
          Provider.of<CategoriaViewModel>(context, listen: false);

      receitaVM.setUsuario(usuarioId);
      despesaVM.setUsuario(usuarioId);

      await Future.wait([
        receitaVM.carregarReceitas(),
        despesaVM.carregarDespesas(),
        categoriaVM.carregarCategorias(),
      ]);
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _logout() {
    final usuarioVM = Provider.of<UsuarioViewModel>(context, listen: false);
    usuarioVM.logout();

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginView()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final usuarioVM = Provider.of<UsuarioViewModel>(context);
    final receitaVM = Provider.of<ReceitaViewModel>(context);
    final despesaVM = Provider.of<DespesaViewModel>(context);
    final saldoVM = Provider.of<SaldoViewModel>(context);

    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Olá, ${usuarioVM.usuarioAtual?.nome ?? "Usuário"}'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Sair',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _carregarDados,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSaldoCard(receitaVM, despesaVM, saldoVM),
            const SizedBox(height: 16),
            _buildResumoCard(receitaVM, despesaVM),
            const SizedBox(height: 16),
            _buildReceitasSection(receitaVM),
            const SizedBox(height: 16),
            _buildDespesasSection(despesaVM),
          ],
        ),
      ),
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
                        trailing: Text(
                          formatter.format(receita.valor),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
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
                        title: Text(despesa.descricao),
                        subtitle: Text(dateFormatter.format(despesa.data)),
                        trailing: Text(
                          formatter.format(despesa.valor),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
          ],
        ),
      ),
    );
  }

  void _mostrarOpcoesAdicionar() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.arrow_upward, color: Colors.green),
                title: const Text('Adicionar Receita'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Tela de adicionar receita em desenvolvimento...'),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.arrow_downward, color: Colors.red),
                title: const Text('Adicionar Despesa'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Tela de adicionar despesa em desenvolvimento...'),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
