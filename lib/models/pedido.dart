import 'medicamento.dart';

class ItemPedido {
  final Medicamento medicamento;
  int quantidade;

  ItemPedido({
    required this.medicamento,
    this.quantidade = 1,
  });

  double get subtotal => medicamento.preco * quantidade;

  Map<String, dynamic> toMap() {
    return {
      'medicamentoId': medicamento.id,
      'medicamentoNome': medicamento.nome,
      'preco': medicamento.preco,
      'quantidade': quantidade,
    };
  }
}

class Pedido {
  final String id;
  final List<ItemPedido> itens;
  final double valorTotal;
  final String status; // 'Em analise', 'Em separacao', 'A caminho', 'Entregue'
  final String dataCriacao;
  final String? caminhoReceita;
  final String enderecoEntrega;

  Pedido({
    required this.id,
    required this.itens,
    required this.valorTotal,
    required this.status,
    required this.dataCriacao,
    this.caminhoReceita,
    required this.enderecoEntrega,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'valorTotal': valorTotal,
      'status': status,
      'dataCriacao': dataCriacao,
      'caminhoReceita': caminhoReceita ?? '',
      'enderecoEntrega': enderecoEntrega,
    };
  }

  factory Pedido.fromMap(Map<String, dynamic> map, List<ItemPedido> itens) {
    return Pedido(
      id: map['id'] ?? '',
      itens: itens,
      valorTotal: (map['valorTotal'] as num).toDouble(),
      status: map['status'] ?? 'Em separacao',
      dataCriacao: map['dataCriacao'] ?? '',
      caminhoReceita: map['caminhoReceita'],
      enderecoEntrega: map['enderecoEntrega'] ?? '',
    );
  }
}
