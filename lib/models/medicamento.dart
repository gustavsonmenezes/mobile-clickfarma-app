class Medicamento {
  final String id;
  final String nome;
  final String laboratorio;
  final String categoria;
  final double preco;
  final bool precisaReceita;
  final String descricao;
  final String imagemUrl;
  final String dosagem;

  Medicamento({
    required this.id,
    required this.nome,
    required this.laboratorio,
    required this.categoria,
    required this.preco,
    required this.precisaReceita,
    required this.descricao,
    required this.imagemUrl,
    required this.dosagem,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'laboratorio': laboratorio,
      'categoria': categoria,
      'preco': preco,
      'precisaReceita': precisaReceita ? 1 : 0,
      'descricao': descricao,
      'imagemUrl': imagemUrl,
      'dosagem': dosagem,
    };
  }

  factory Medicamento.fromMap(Map<String, dynamic> map) {
    return Medicamento(
      id: map['id'] ?? '',
      nome: map['nome'] ?? '',
      laboratorio: map['laboratorio'] ?? '',
      categoria: map['categoria'] ?? '',
      preco: (map['preco'] as num).toDouble(),
      precisaReceita: map['precisaReceita'] == 1 || map['precisaReceita'] == true,
      descricao: map['descricao'] ?? '',
      imagemUrl: map['imagemUrl'] ?? '',
      dosagem: map['dosagem'] ?? '',
    );
  }
}
