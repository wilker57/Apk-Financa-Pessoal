// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:despesa_pessoal/main.dart';
import 'package:despesa_pessoal/mvvm/receita_viewmodel.dart';
import 'package:despesa_pessoal/mvvm/despesa_viewmodel.dart';
import 'package:despesa_pessoal/mvvm/saldo_viewmodel.dart';
import 'package:despesa_pessoal/mvvm/categoria_viewmodel.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ReceitaViewModel()),
          ChangeNotifierProvider(create: (_) => DespesaViewModel()),
          ChangeNotifierProvider(create: (_) => SaldoViewModel()),
          ChangeNotifierProvider(create: (_) => CategoriaViewModel()),
        ],
        child: const MyApp(),
      ),
    );

    // Verify that the login screen is displayed.
    expect(find.text('Despesa Pessoal'), findsOneWidget);
    expect(find.text('E-mail'), findsOneWidget);
    expect(find.text('Senha'), findsOneWidget);
  });
}
