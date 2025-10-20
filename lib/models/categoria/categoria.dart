class Categoria {
  int? id;
  String nome;
  String? descricao;
  String tipo; // 'RECEITA' ou 'DESPESA'

  Categoria({
    this.id,
    required this.nome,
    this.descricao,
    required this.tipo,
  });

  // Converte Categoria
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'descricao': descricao,
      'tipo': tipo,
    };
  }

  // Cria Categoria
  factory Categoria.fromMap(Map<String, dynamic> map) {
    return Categoria(
      id: map['id'],
      nome: map['nome'],
      descricao: map['descricao'],
      tipo: map['tipo'],
    );
  }

  @override
  String toString() {
    return 'Categoria{id: $id, nome: $nome, tipo: $tipo}';
  }
}
