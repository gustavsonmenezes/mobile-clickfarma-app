import 'package:flutter/material.dart';
import '../models/medicamento.dart';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  final Function(Medicamento) onAdicionarAoCarrinho;
  final Function(Medicamento) onVerDetalhes;

  const HomeScreen({
    super.key,
    required this.onAdicionarAoCarrinho,
    required this.onVerDetalhes,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Medicamento> _todosMedicamentos = [];
  List<Medicamento> _medicamentosFiltrados = [];
  bool _carregando = true;
  String _categoriaSelecionada = 'Todos';
  final _buscaController = TextEditingController();

  final List<String> _categorias = [
    'Todos',
    'Analgésicos',
    'Antibióticos',
    'Vitaminas',
    'Gastroenterologia',
    'Controlados'
  ];

  @override
  void initState() {
    super.initState();
    _carregarCatalogo();
  }

  Future<void> _carregarCatalogo() async {
    setState(() => _carregando = true);
    final lista = await ApiService.obterMedicamentos();
    setState(() {
      _todosMedicamentos = lista;
      _medicamentosFiltrados = lista;
      _carregando = false;
    });
  }

  void _filtrarPorCategoria(String categoria) {
    setState(() {
      _categoriaSelecionada = categoria;
      _aplicarFiltros();
    });
  }

  void _aplicarFiltros() {
    final query = _buscaController.text.toLowerCase();
    setState(() {
      _medicamentosFiltrados = _todosMedicamentos.where((med) {
        final bateCategoria = _categoriaSelecionada == 'Todos' ||
            med.categoria.toLowerCase() == _categoriaSelecionada.toLowerCase();
        final bateTexto = med.nome.toLowerCase().contains(query) ||
            med.laboratorio.toLowerCase().contains(query) ||
            med.categoria.toLowerCase().contains(query);
        return bateCategoria && bateTexto;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            // Header Profissional
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              decoration: const BoxDecoration(
                color: Color(0xFF00897B),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.local_pharmacy_rounded,
                                color: Colors.white, size: 24),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'ClickFarma',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.verified_rounded,
                                color: Colors.white70, size: 14),
                            SizedBox(width: 4),
                            Text(
                              'Entrega Rápida',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Barra de Pesquisa Moderna com Sombra
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _buscaController,
                      onChanged: (_) => _aplicarFiltros(),
                      decoration: InputDecoration(
                        hintText: 'Buscar remédios, marcas ou categorias...',
                        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                        prefixIcon:
                            const Icon(Icons.search, color: Color(0xFF00897B)),
                        suffixIcon: _buscaController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, color: Colors.grey),
                                onPressed: () {
                                  _buscaController.clear();
                                  _aplicarFiltros();
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Categorias em Chips Horizontais
            Container(
              height: 56,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _categorias.length,
                itemBuilder: (context, index) {
                  final cat = _categorias[index];
                  final selecionado = cat == _categoriaSelecionada;
                  return Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: ChoiceChip(
                      selected: selecionado,
                      label: Text(cat),
                      selectedColor: const Color(0xFF00897B),
                      labelStyle: TextStyle(
                        color: selecionado ? Colors.white : Colors.grey[700],
                        fontWeight:
                            selecionado ? FontWeight.bold : FontWeight.w500,
                        fontSize: 13,
                      ),
                      backgroundColor: Colors.white,
                      elevation: selecionado ? 2 : 0,
                      pressElevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: selecionado
                              ? const Color(0xFF00897B)
                              : Colors.grey[300]!,
                        ),
                      ),
                      onSelected: (_) => _filtrarPorCategoria(cat),
                    ),
                  );
                },
              ),
            ),

            // Título da Seção
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _categoriaSelecionada == 'Todos'
                        ? 'Produtos em Destaque'
                        : 'Categoria: $_categoriaSelecionada',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  Text(
                    '${_medicamentosFiltrados.length} itens',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),

            // Grid de Medicamentos
            Expanded(
              child: _carregando
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFF00897B)))
                  : _medicamentosFiltrados.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off_rounded,
                                  size: 64, color: Colors.grey[400]),
                              const SizedBox(height: 12),
                              Text(
                                'Nenhum medicamento encontrado.',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.68,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                          ),
                          itemCount: _medicamentosFiltrados.length,
                          itemBuilder: (context, index) {
                            final med = _medicamentosFiltrados[index];
                            return _buildCardMedicamento(med);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardMedicamento(Medicamento med) {
    return InkWell(
      onTap: () => widget.onVerDetalhes(med),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagem e Tag de Receita
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Container(
                    color: Colors.grey[50],
                    height: 110,
                    width: double.infinity,
                    child: Image.network(
                      med.imagemUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 110,
                        color: const Color(0xFFE0F2F1),
                        child: const Icon(Icons.medication_rounded,
                            size: 40, color: Color(0xFF00897B)),
                      ),
                    ),
                  ),
                ),
                if (med.precisaReceita)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red[600],
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Text(
                        'Receita',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // Informações do Medicamento
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tag de Categoria
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F2F1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        med.categoria,
                        style: const TextStyle(
                          color: Color(0xFF00897B),
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      med.nome,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      med.laboratorio,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey[500], fontSize: 11),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      med.dosagem,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey[600], fontSize: 10, fontWeight: FontWeight.w500),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'R\$ ${med.preco.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF00897B),
                          ),
                        ),
                        Material(
                          color: const Color(0xFF00897B),
                          borderRadius: BorderRadius.circular(10),
                          child: InkWell(
                            onTap: () {
                              widget.onAdicionarAoCarrinho(med);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      '${med.nome} adicionado ao carrinho!'),
                                  duration: const Duration(milliseconds: 1200),
                                  backgroundColor: const Color(0xFF00897B),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: const Padding(
                              padding: EdgeInsets.all(7.0),
                              child: Icon(Icons.add_shopping_cart_rounded,
                                  color: Colors.white, size: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
