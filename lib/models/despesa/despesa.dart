class Despesa {
  int? id;
  int usuarioId;
  int? categoriaId;
  String descricao;
  double valor;
  DateTime data;
  DateTime dataCriacao;

  Despesa({
    this.id,
    required this.usuarioId,
    this.categoriaId,
    required this.descricao,
    required this.valor,
    required this.data,
    DateTime? dataCriacao,
  }) : dataCriacao = dataCriacao ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'usuarioId': usuarioId,
      'categoriaId': categoriaId,
      'descricao': descricao,
      'valor': valor,
      'data': data.toIso8601String(),
      'dataCriacao': dataCriacao.toIso8601String(),
    };
  }

  factory Despesa.fromMap(Map<String, dynamic> map) {
    return Despesa(
      id: map['id'],
      usuarioId: map['usuarioId'],
      categoriaId: map['categoriaId'],
      descricao: map['descricao'],
      valor: map['valor'],
      data: DateTime.parse(map['data']),
      dataCriacao: DateTime.parse(map['dataCriacao']),
    );
  }

  @override
  String toString() {
    return 'Despesa{id: $id, descricao: $descricao, valor: $valor, data: $data}';
  }
}
