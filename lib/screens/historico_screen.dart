import 'package:flutter/material.dart';
import '../models/pedido.dart';
import '../services/storage_service.dart';

class HistoricoScreen extends StatefulWidget {
  const HistoricoScreen({super.key});

  @override
  State<HistoricoScreen> createState() => _HistoricoScreenState();
}

class _HistoricoScreenState extends State<HistoricoScreen> {
  List<Pedido> _pedidosLocal = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarHistoricoLocal();
  }

  // Consulta do Banco de Dados SQLite (Persistência Offline)
  Future<void> _carregarHistoricoLocal() async {
    setState(() => _carregando = true);
    final lista = await StorageService.obterPedidos();
    setState(() {
      _pedidosLocal = lista;
      _carregando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Histórico de Pedidos'),
        backgroundColor: const Color(0xFF00897B),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _carregarHistoricoLocal,
            tooltip: 'Atualizar do SQLite',
          ),
        ],
      ),
      body: _carregando
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF00897B)))
          : Column(
              children: [
                // Banner Explicativo do Armazenamento Local
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  color: const Color(0xFFE0F2F1),
                  child: Row(
                    children: const [
                      Icon(Icons.storage, color: Color(0xFF00897B)),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Dados gravados no banco SQLite local. Acesso completo aos seus pedidos offline!',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF00897B),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: _pedidosLocal.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.history_toggle_off,
                                  size: 80, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              Text(
                                'Nenhum pedido gravado no histórico.',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _pedidosLocal.length,
                          itemBuilder: (context, index) {
                            final pedido = _pedidosLocal[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ExpansionTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE0F2F1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.receipt_long,
                                      color: Color(0xFF00897B)),
                                ),
                                title: Text(
                                  'Pedido #${pedido.id}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  'Data: ${pedido.dataCriacao} • R\$ ${pedido.valorTotal.toStringAsFixed(2)}',
                                ),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Status: ${pedido.status}',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF00897B))),
                                        const SizedBox(height: 4),
                                        Text(
                                            'Endereço: ${pedido.enderecoEntrega}'),
                                        if (pedido.caminhoReceita != null &&
                                            pedido.caminhoReceita!.isNotEmpty) ...[
                                          const SizedBox(height: 4),
                                          Row(
                                            children: const [
                                              Icon(Icons.verified,
                                                  size: 16, color: Colors.green),
                                              SizedBox(width: 4),
                                              Text(
                                                  'Receita médica anexada com sucesso.',
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.green)),
                                            ],
                                          ),
                                        ],
                                        const Divider(height: 16),
                                        const Text('Itens:',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold)),
                                        ...pedido.itens.map(
                                          (item) => Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 2.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                    '${item.quantidade}x ${item.medicamento.nome}'),
                                                Text(
                                                    'R\$ ${item.subtotal.toStringAsFixed(2)}'),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
