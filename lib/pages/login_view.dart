import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../mvvm/usuario_viewmodel.dart';
import '../mvvm/receita_viewmodel.dart';
import '../mvvm/despesa_viewmodel.dart';
import '../mvvm/categoria_viewmodel.dart';
import 'cadastro_view.dart';
import 'home_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  // conter vazamentos de memória
  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }
  // Autenticação de dados do formulário
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
  // inicia o carregamento
    setState(() => _isLoading = true);
  // interage com o pacote provider para obter a instância UsuarioView
    final usuarioVM = Provider.of<UsuarioViewModel>(context, listen: false);
    final sucesso = await usuarioVM.login(
      _emailController.text.trim().toLowerCase(),
      _senhaController.text,
    );
    // garante que o codigo não tente atualizar um widget que não exixte
    if (!mounted) return;
    // finaliza o carregamento
    setState(() => _isLoading = false);
    // chama outra função para carregar os dados do usuário
    if (sucesso) {
      await _inicializarViewModels();
      if (!mounted) return;
      // susbstitui a tela de login
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeView()),
      );
    } else {
      _mostrarErro('E-mail ou senha incorretos ');
    }
  }
 // exibi uma barra de notificação flutuante no rodape com 
  // a mensagem de erro
  void _mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem, textAlign: TextAlign.center),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
  // traz os dados do usuário logado e informa outros viewModel
  Future<void> _inicializarViewModels() async {
    final usuarioVM = Provider.of<UsuarioViewModel>(context, listen: false);
    if (usuarioVM.usuarioAtual != null) {
      final id = usuarioVM.usuarioAtual!.id!;
      final receitaVM = Provider.of<ReceitaViewModel>(context, listen: false);
      final despesaVM = Provider.of<DespesaViewModel>(context, listen: false);
      final categoriaVM =
          Provider.of<CategoriaViewModel>(context, listen: false);

      receitaVM.setUsuario(id);
      despesaVM.setUsuario(id);
  // carrega os demais dados 
      await Future.wait([
        receitaVM.carregarReceitas(),
        despesaVM.carregarDespesas(),
        categoriaVM.carregarCategorias(),
      ]);
    }
  }
  // base da tela 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // 🔹 Logo animado simples e dinâmico
              AnimatedContainer(
                duration: const Duration(seconds: 1),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  size: 70,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 16),

              const Text(
                'Bem-vindo de volta!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Insira o login e senha para continuar',
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 32),

              // 🔹 Card de login com campos
              Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'E-mail',
                            prefixIcon: Icon(Icons.email_outlined),
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Digite seu e-mail';
                            }
                            if (!value.contains('@')) {
                              return 'E-mail inválido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _senhaController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Senha',
                            prefixIcon: const Icon(Icons.lock_outline),
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off),
                              onPressed: () => setState(() {
                                _obscurePassword = !_obscurePassword;
                              }),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Digite sua senha';
                            }
                            if (value.length < 6) {
                              return 'A senha deve ter pelo menos 6 caracteres';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // 🔹 Botão de login
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _login,
                            icon: _isLoading
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.login_rounded,
                                    color: Colors.white),
                            label: Text(
                              _isLoading ? 'Entrando...' : 'Entrar',
                              style: const TextStyle(fontSize: 16),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 🔹 Botão de cadastro simples e claro
              TextButton.icon(
                icon: const Icon(Icons.person_add_alt_1_rounded,
                    color: Colors.blueAccent),
                label: const Text(
                  'Não tem conta? Criar agora',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.blueAccent,
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CadastroView()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
