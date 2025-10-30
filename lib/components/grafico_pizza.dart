import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class PieChartDataModel {
  final String category;
  final double value;
  final Color color;

  PieChartDataModel({
    required this.category,
    required this.value,
    required this.color,
  });
}

// Lista de dados
final List<PieChartDataModel> expenseData = [
  PieChartDataModel(category: 'Educação', value: 250.00, color: Colors.purple),
  PieChartDataModel(
    category: 'Casa',
    value: 276.00,
    color: Colors.blue.shade600,
  ),
  PieChartDataModel(
    category: 'Alimentação',
    value: 820.00,
    color: Colors.green,
  ),
  PieChartDataModel(category: 'Outros...', value: 290.00, color: Colors.grey),
];

class ExpensePieChart extends StatelessWidget {
  const ExpensePieChart({super.key});

  @override
  Widget build(BuildContext context) {
    // Calcula o valor total para determinar as porcentagens
    final double totalValue = expenseData.fold(
      0,
      (sum, item) => sum + item.value,
    );

    return Container(
      //Define o tamanho do Container para controlar o tamanho do gráfico
      height: 120,
      width: 120,
      child: PieChart(
        PieChartData(
          // Garante que o gráfico ocupe o centro do espaço disponível
          centerSpaceRadius: 35,
          sections: _getSections(totalValue),
        ),
      ),
    );
  }

  List<PieChartSectionData> _getSections(double totalValue) {
    return expenseData.map((data) {
      // O raio pode ser ajustado para dar um efeito de "zoom"
      const double radius = 25;
      // Calcula a porcentagem para mostrar no título do gráfico (opcional)
      // ignore: unused_local_variable
      final String percentage =
          '${((data.value / totalValue) * 100).toStringAsFixed(0)}%';

      return PieChartSectionData(
        color: data.color,
        value: data.value,
        title: '', // Deixa vazio para ter o estilo da sua imagem
        radius: radius,
        // Configuração do texto (se você quisesse mostrar a % dentro)
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }
}
