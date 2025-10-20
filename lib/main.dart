import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'mvvm/receita_viewmodel.dart';
import 'mvvm/despesa_viewmodel.dart';
import 'mvvm/saldo_viewmodel.dart';
import 'mvvm/categoria_viewmodel.dart';
import 'mvvm/usuario_viewmodel.dart';
import 'pages/login_view.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UsuarioViewModel()),
        ChangeNotifierProvider(create: (_) => ReceitaViewModel()),
        ChangeNotifierProvider(create: (_) => DespesaViewModel()),
        ChangeNotifierProvider(create: (_) => SaldoViewModel()),
        ChangeNotifierProvider(create: (_) => CategoriaViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Despesa Pessoal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LoginView(),
    );
  }
}
