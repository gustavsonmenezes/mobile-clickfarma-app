import 'package:flutter/material.dart';
import '../models/medicamento.dart';

class MedicamentoDetalhesScreen extends StatelessWidget {
  final Medicamento medicamento;
  final Function(Medicamento) onAdicionarAoCarrinho;
  final VoidCallback onIrParaUploadReceita;

  const MedicamentoDetalhesScreen({
    super.key,
    required this.medicamento,
    required this.onAdicionarAoCarrinho,
    required this.onIrParaUploadReceita,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(medicamento.nome),
        backgroundColor: const Color(0xFF00897B),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagem do Medicamento
            Container(
              width: double.infinity,
              height: 220,
              color: const Color(0xFFE0F2F1),
              child: Image.network(
                medicamento.imagemUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Center(
                  child: Icon(Icons.medication,
                      size: 80, color: Color(0xFF00897B)),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Alerta de Receita Médica
                  if (medicamento.precisaReceita) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber[50],
                        border: Border.all(color: Colors.amber[800]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber_rounded,
                              color: Colors.amber[900], size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Exige Retenção de Receita',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber[900],
                                  ),
                                ),
                                const Text(
                                  'Envie a foto da receita para autorização do farmacêutico.',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.camera_alt,
                                color: Color(0xFF00897B)),
                            onPressed: onIrParaUploadReceita,
                            tooltip: 'Fotografar Receita',
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Título e Laboratório
                  Text(
                    medicamento.nome,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Laboratório: ${medicamento.laboratorio} • ${medicamento.dosagem}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 16),

                  // Categoria e Preço
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Chip(
                        label: Text(medicamento.categoria),
                        backgroundColor: const Color(0xFFE0F2F1),
                        labelStyle: const TextStyle(
                          color: Color(0xFF00897B),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'R\$ ${medicamento.preco.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00897B),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32),

                  // Descrição / Bula simplificada
                  const Text(
                    'Descrição e Indicações',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    medicamento.descricao,
                    style: TextStyle(
                        fontSize: 15, color: Colors.grey[800], height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            )
          ],
        ),
        child: SizedBox(
          height: 52,
          child: ElevatedButton.icon(
            onPressed: () {
              onAdicionarAoCarrinho(medicamento);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${medicamento.nome} adicionado ao carrinho!'),
                  backgroundColor: const Color(0xFF00897B),
                ),
              );
            },
            icon: const Icon(Icons.add_shopping_cart),
            label: const Text('ADICIONAR AO CARRINHO',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00897B),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
