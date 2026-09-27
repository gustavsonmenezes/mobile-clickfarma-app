import 'package:flutter/material.dart';
import '../models/pedido.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class CarrinhoScreen extends StatefulWidget {
  final List<ItemPedido> itensCarrinho;
  final String? caminhoReceitaAnexada;
  final VoidCallback onIrParaUploadReceita;
  final VoidCallback onLimparCarrinho;
  final Function(Pedido) onPedidoFinalizado;
  final VoidCallback? onCarrinhoAlterado;

  const CarrinhoScreen({
    super.key,
    required this.itensCarrinho,
    this.caminhoReceitaAnexada,
    required this.onIrParaUploadReceita,
    required this.onLimparCarrinho,
    required this.onPedidoFinalizado,
    this.onCarrinhoAlterado,
  });

  @override
  State<CarrinhoScreen> createState() => _CarrinhoScreenState();
}

class _CarrinhoScreenState extends State<CarrinhoScreen> {
  final _cepController = TextEditingController(text: '01001000');
  String _enderecoFormatado = 'Praça da Sé, São Paulo - SP';
  bool _buscandoCep = false;
  final double _frete = 8.50;

  double get _subtotal =>
      widget.itensCarrinho.fold(0, (total, item) => total + item.subtotal);

  double get _total => _subtotal + _frete;

  bool get _exigeReceita =>
      widget.itensCarrinho.any((item) => item.medicamento.precisaReceita);

  bool get _receitaAnexadaOk => !_exigeReceita || widget.caminhoReceitaAnexada != null;

  Future<void> _buscarCep() async {
    setState(() => _buscandoCep = true);
    final endereco = await ApiService.buscarEnderecoPorCep(_cepController.text);
    setState(() => _buscandoCep = false);

    if (!mounted) return;

    if (endereco != null) {
      setState(() {
        _enderecoFormatado =
            '${endereco['logradouro']}, ${endereco['bairro']} - ${endereco['localidade']}/${endereco['uf']}';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Endereço localizado via API ViaCEP!'),
          backgroundColor: Color(0xFF00897B),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('CEP não encontrado na API. Tente outro CEP.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _finalizarCompra() async {
    if (widget.itensCarrinho.isEmpty) return;

    if (!_receitaAnexadaOk) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Anexe a receita médica para medicamentos controlados.'),
          backgroundColor: Colors.orange,
        ),
      );
      widget.onIrParaUploadReceita();
      return;
    }

    final novoPedido = Pedido(
      id: 'PED-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      itens: List.from(widget.itensCarrinho),
      valorTotal: _total,
      status: 'Em separação',
      dataCriacao: DateTime.now().toString().substring(0, 16),
      caminhoReceita: widget.caminhoReceitaAnexada,
      enderecoEntrega: _enderecoFormatado,
    );

    // Grava no Banco SQLite local (Persistência Offline)
    await StorageService.salvarPedido(novoPedido);

    widget.onPedidoFinalizado(novoPedido);
    widget.onLimparCarrinho();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Seu Carrinho'),
        backgroundColor: const Color(0xFF00897B),
        foregroundColor: Colors.white,
      ),
      body: widget.itensCarrinho.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined,
                      size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Seu carrinho está vazio',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Alerta de Receita Médica
                  if (_exigeReceita) ...[
                    Card(
                      color: _receitaAnexadaOk
                          ? const Color(0xFFE0F2F1)
                          : Colors.orange[50],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: _receitaAnexadaOk
                              ? const Color(0xFF00897B)
                              : Colors.orange,
                        ),
                      ),
                      child: ListTile(
                        leading: Icon(
                          _receitaAnexadaOk
                              ? Icons.check_circle
                              : Icons.warning_amber_rounded,
                          color: _receitaAnexadaOk
                              ? const Color(0xFF00897B)
                              : Colors.orange[900],
                        ),
                        title: Text(
                          _receitaAnexadaOk
                              ? 'Receita Médica Anexada!'
                              : 'Receita Médica Obrigatória',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          _receitaAnexadaOk
                              ? 'Sua receita foi enviada e vinculada ao pedido.'
                              : 'Toque para usar a Câmera/Galeria do celular.',
                        ),
                        trailing: ElevatedButton(
                          onPressed: widget.onIrParaUploadReceita,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00897B),
                            foregroundColor: Colors.white,
                          ),
                          child: Text(_receitaAnexadaOk ? 'VER' : 'ANEXAR'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Lista de Itens no Carrinho
                  const Text('Itens do Pedido',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: widget.itensCarrinho.length,
                    itemBuilder: (context, index) {
                      final item = widget.itensCarrinho[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE0F2F1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.medication,
                                    color: Color(0xFF00897B)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.medicamento.nome,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    Text(
                                      'R\$ ${item.medicamento.preco.toStringAsFixed(2)} cada',
                                      style: TextStyle(
                                          color: Colors.grey[600], fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),

                              // Botões Quantidade + e -
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline),
                                    onPressed: () {
                                      setState(() {
                                        if (item.quantidade > 1) {
                                          item.quantidade--;
                                        } else {
                                          widget.itensCarrinho.removeAt(index);
                                        }
                                      });
                                      widget.onCarrinhoAlterado?.call();
                                    },
                                  ),
                                  Text('${item.quantidade}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline),
                                    onPressed: () {
                                      setState(() {
                                        item.quantidade++;
                                      });
                                      widget.onCarrinhoAlterado?.call();
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Consulta CEP via API Externa ViaCEP
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.local_shipping,
                                  color: Color(0xFF00897B)),
                              SizedBox(width: 8),
                              Text('Entrega e Frete (API ViaCEP)',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 16)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _cepController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: 'CEP de Entrega',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    isDense: true,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: _buscandoCep ? null : _buscarCep,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF00897B),
                                  foregroundColor: Colors.white,
                                ),
                                child: _buscandoCep
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white))
                                    : const Text('BUSCAR CEP'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _enderecoFormatado,
                            style: TextStyle(
                                color: Colors.grey[700], fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Resumo dos Valores
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Subtotal:'),
                              Text('R\$ ${_subtotal.toStringAsFixed(2)}'),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Frete:'),
                              Text('R\$ ${_frete.toStringAsFixed(2)}'),
                            ],
                          ),
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'TOTAL:',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                              Text(
                                'R\$ ${_total.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                  color: Color(0xFF00897B),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Botão Finalizar Pedido
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: _finalizarCompra,
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('FINALIZAR COMPRA',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00897B),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }
}
