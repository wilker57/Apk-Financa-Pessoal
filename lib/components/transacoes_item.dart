import 'package:flutter/material.dart';

// Modelo de Dados da Transação
class TransacaoModel {
  final String description;
  final double value;
  // 'entrada' ou 'saida' para determinar cor e ícone
  final String type;
  final String date;

  TransacaoModel({
    required this.description,
    required this.value,
    required this.type,
    required this.date,
  });
}

// Widget Reutilizável para o Item da Lista
class TransacoesItem extends StatelessWidget {
  final TransacaoModel transacao; // Nome do parâmetro corrigido

  const TransacoesItem({super.key, required this.transacao});

  @override
  Widget build(BuildContext context) {
    // Define a cor e o ícone com base no tipo
    final isIncome = transacao.type == 'entrada';
    final color = isIncome ? Colors.green.shade600 : Colors.red.shade600;
    final icon = isIncome ? Icons.arrow_upward : Icons.arrow_downward;
    // Formata o valor para o padrão BR: R$ 0.000,00
    final formattedValue =
        'R\$ ${transacao.value.toStringAsFixed(2).replaceAll('.', ',')}';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Lado Esquerdo: Descrição e Data
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transacao.description,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  transacao.date,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),

          // Lado Direito: Valor e Ícone de Tipo
          Row(
            // Alinha o valor e o ícone na linha
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Texto do Valor
              Text(
                formattedValue,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(width: 8),

              // O Ícone de Tipo (Entrada/Saída)
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: color.withValues(),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
