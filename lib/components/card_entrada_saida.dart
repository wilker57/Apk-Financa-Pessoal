import 'package:flutter/material.dart';

class CardEntradaSaida extends StatefulWidget {
  final String titulo;
  final String valor;
  final Color corDaLetra;
  final IconData icone;
  final Color corBotaoCircular;
  const CardEntradaSaida({
    super.key,
    required this.titulo,
    required this.valor,
    required this.corDaLetra,
    required this.corBotaoCircular,
    required this.icone,
  });

  @override
  State<CardEntradaSaida> createState() => _CardEntradaSaidaState();
}

class _CardEntradaSaidaState extends State<CardEntradaSaida> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: widget.corBotaoCircular,
                    shape: BoxShape.circle,
                  ),
                  width: 35,
                  height: 35,
                  child: Icon(widget.icone, color: Colors.white, size: 25),
                ),
              ),
              SizedBox(width: 5),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //Titulo que aparece a cima do valor
                  Text(widget.titulo),
                  //Valor de entrada ou saida
                  Text(
                    widget.valor,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: widget.corDaLetra,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
