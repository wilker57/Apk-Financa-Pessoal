import 'package:flutter/material.dart';
import '../components/card_entrada_saida.dart';
import '../components/grafico_pizza.dart';
import '../components/transacoes_item.dart';

class HomeView2 extends StatefulWidget {
  const HomeView2({super.key});

  @override
  State<HomeView2> createState() => _HomeView2State();
}

class _HomeView2State extends State<HomeView2> {
  // Dados Simulados das Transações
  final List<TransacaoModel> transactions = [
    TransacaoModel(
      description: 'Salário Mensal',
      value: 3000.00,
      type: 'entrada',
      date: '20 Out, 2025',
    ),
    TransacaoModel(
      description: 'Aluguel',
      value: 751.01,
      type: 'saida',
      date: '18 Out, 2025',
    ),
    TransacaoModel(
      description: 'Supermercado',
      value: 220.00,
      type: 'saida',
      date: '15 Out, 2025',
    ),
    TransacaoModel(
      description: 'Freelance Design',
      value: 550.00,
      type: 'entrada',
      date: '10 Out, 2025',
    ),
    TransacaoModel(
      description: 'Mensalidade Faculdade',
      value: 650.00,
      type: 'saida',
      date: '05 Out, 2025',
    ),
    TransacaoModel(
      description: 'Financiamento carro',
      value: 1500.00,
      type: 'saida',
      date: '05 Out, 2025',
    ),

    TransacaoModel(
      description: 'Farmacia',
      value: 250.00,
      type: 'saida',
      date: '05 Out, 2025',
    ),
  ];

  Widget _buildExpenseLegend() {
    return Column(
      // Alinha os elementos da legenda à esquerda
      crossAxisAlignment: CrossAxisAlignment.start,
      children: expenseData.map((data) {
        // Formata o valor para o padrão R$ X.XXX,XX
        final String formattedValue =
            'R\$ ${data.value.toStringAsFixed(2).replaceAll('.', ',')}';

        return Row(
          children: [
            // Indicador de cor (o pequeno círculo)
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: data.color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            // Nome da categoria
            Text(
              data.category,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
            // Spacer empurra o valor para a direita
            const Spacer(),
            // Valor da categoria
            Text(
              formattedValue,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal,
                color: Colors.black87,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  // Método que constrói a lista de transações
  Widget _buildTransacoesLista() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: transactions
              .map((transacao) => TransacoesItem(transacao: transacao))
              .toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: Padding(
            padding: const EdgeInsets.only(top: 8, left: 15),
            child: CircleAvatar(
              backgroundImage: NetworkImage(
                'https://marketplace.canva.com/yGfCQ/MAGiQUyGfCQ/1/tl/canva-MAGiQUyGfCQ.png',
              ),
              backgroundColor: Colors.grey[200],
            ),
          ),
          title: Text('Ola! Usuario'),
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                //Container Branco
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(18),
                      bottomRight: Radius.circular(18),
                    ),
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: 15),
                      Text('Saldo em conta'),
                      Text('R\$ 3.284,00', style: TextStyle(fontSize: 40)),
                      SizedBox(height: 25),
                      //Entrada de Dinheiro
                      Padding(
                        // CORREÇÃO APLICADA AQUI: Padding reduzida para 15
                        padding: const EdgeInsets.only(left: 15, right: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Expanded(
                              child: CardEntradaSaida(
                                titulo: 'Receitas',
                                valor: 'R\$ 3.000,00',
                                corDaLetra: Colors.green.shade700,
                                corBotaoCircular: Colors.green,
                                icone: Icons.arrow_upward,
                              ),
                            ),

                            Expanded(
                              child: CardEntradaSaida(
                                titulo: 'Despesas',
                                valor: 'R\$ 1.436,00',
                                corDaLetra: Colors.red.shade700,
                                corBotaoCircular: Colors.red,
                                icone: Icons.arrow_downward,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 25),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 25),
              //Separador Despesas por categoria
              Padding(
                padding: const EdgeInsets.only(left: 15),
                child: Text(
                  'Despesas por categoria',
                  style: TextStyle(fontSize: 20),
                  textAlign: TextAlign.left,
                ),
              ),
              SizedBox(height: 10),
              // Container com Gráfico e Legenda
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      //O Gráfico Pizza
                      const ExpensePieChart(),

                      const SizedBox(width: 25),

                      //A Legenda (lista de despesas)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: _buildExpenseLegend(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 25),
              Padding(
                padding: const EdgeInsets.only(left: 15),
                child: Text(
                  'Ultimas movimentações',
                  style: TextStyle(fontSize: 20),
                  textAlign: TextAlign.left,
                ),
              ),
              SizedBox(height: 10),
              //Container Com o conteudo das ultimas movimentações
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),

                  child: _buildTransacoesLista(),
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}
