import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'mvvm/receita_viewmodel.dart';
import 'mvvm/despesa_viewmodel.dart';
import 'mvvm/saldo_viewmodel.dart';
import 'mvvm/categoria_viewmodel.dart';
import 'mvvm/usuario_viewmodel.dart';
import 'pages/login_view.dart';
// Suporte para sqflite em desktop
import 'dart:io' show Platform;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  // Inicializa o sqflite FFI para plataformas desktop (Windows/Linux/macOS)
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
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
