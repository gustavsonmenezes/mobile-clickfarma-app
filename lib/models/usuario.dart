class Usuario {
  final String id;
  final String nome;
  final String email;
  final String? senha;
  final String cep;
  final String logradouro;
  final String bairro;
  final String cidade;
  final String uf;
  final String telefone;

  Usuario({
    required this.id,
    required this.nome,
    required this.email,
    this.senha,
    required this.cep,
    required this.logradouro,
    required this.bairro,
    required this.cidade,
    required this.uf,
    required this.telefone,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'senha': senha ?? '',
      'cep': cep,
      'logradouro': logradouro,
      'bairro': bairro,
      'cidade': cidade,
      'uf': uf,
      'telefone': telefone,
    };
  }

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id: map['id'] ?? '',
      nome: map['nome'] ?? '',
      email: map['email'] ?? '',
      senha: map['senha'],
      cep: map['cep'] ?? '',
      logradouro: map['logradouro'] ?? '',
      bairro: map['bairro'] ?? '',
      cidade: map['cidade'] ?? '',
      uf: map['uf'] ?? '',
      telefone: map['telefone'] ?? '',
    );
  }
}
