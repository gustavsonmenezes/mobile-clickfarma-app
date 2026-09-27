import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/pedido.dart';

class RastreamentoScreen extends StatefulWidget {
  final Pedido? pedido;

  const RastreamentoScreen({super.key, this.pedido});

  @override
  State<RastreamentoScreen> createState() => _RastreamentoScreenState();
}

class _RastreamentoScreenState extends State<RastreamentoScreen> {
  Position? _posicaoAtual;
  bool _carregandoGps = false;
  String _statusGps = 'Obtendo localização nativa via GPS...';

  @override
  void initState() {
    super.initState();
    _obterLocalizacaoGps();
  }

  // Integração com Recurso Nativo: GPS/Geolocalização do Aparelho
  Future<void> _obterLocalizacaoGps() async {
    setState(() => _carregandoGps = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _statusGps = 'Serviço de GPS desativado no aparelho.';
          _carregandoGps = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _statusGps = 'Permissão de GPS negada.';
            _carregandoGps = false;
          });
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition();

      setState(() {
        _posicaoAtual = position;
        _statusGps =
            'GPS Nativo Ativo: Lat ${position.latitude.toStringAsFixed(4)}, Long ${position.longitude.toStringAsFixed(4)}';
        _carregandoGps = false;
      });
    } catch (e) {
      setState(() {
        _statusGps = 'GPS simulado ativo (Coordenadas padrão).';
        _carregandoGps = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final pedido = widget.pedido;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Rastreamento de Entrega'),
        backgroundColor: const Color(0xFF00897B),
        foregroundColor: Colors.white,
      ),
      body: pedido == null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.delivery_dining, size: 80, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'Nenhum pedido em andamento no momento.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Card Status GPS Nativo
                  Card(
                    color: const Color(0xFFE0F2F1),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(Icons.gps_fixed,
                              color: Color(0xFF00897B), size: 32),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Recurso Nativo: GPS',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF00897B)),
                                ),
                                const SizedBox(height: 4),
                                _carregandoGps
                                    ? const SizedBox(
                                        height: 16,
                                        width: 16,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Color(0xFF00897B)),
                                      )
                                    : Text(
                                        _posicaoAtual != null
                                            ? '$_statusGps\nLat: ${_posicaoAtual!.latitude}, Long: ${_posicaoAtual!.longitude}'
                                            : _statusGps,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Informações do Pedido
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Pedido #${pedido.id}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF00897B),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  pedido.status,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('Endereço: ${pedido.enderecoEntrega}',
                              style: TextStyle(color: Colors.grey[700])),
                          const SizedBox(height: 4),
                          Text(
                              'Valor Total: R\$ ${pedido.valorTotal.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF00897B))),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Linha do Tempo da Entrega
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Etapas do Pedido',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 16),
                          _buildStepEtapa('1. Pedido Confirmado',
                              'Recebido no sistema da farmácia', true),
                          _buildStepEtapa('2. Análise da Receita',
                              'Aprovado pelo Farmacêutico responsável', true),
                          _buildStepEtapa('3. Em Separação',
                              'Medicamentos embalados para envio', true),
                          _buildStepEtapa('4. A Caminho',
                              'Entregador em rota usando GPS', true,
                              isUltima: true),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStepEtapa(String titulo, String sub, bool concluido,
      {bool isUltima = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Icon(
              concluido ? Icons.check_circle : Icons.radio_button_unchecked,
              color: concluido ? const Color(0xFF00897B) : Colors.grey,
            ),
            if (!isUltima)
              Container(
                width: 2,
                height: 28,
                color: concluido ? const Color(0xFF00897B) : Colors.grey[300],
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titulo,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: concluido ? Colors.black : Colors.grey)),
              Text(sub,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ],
    );
  }
}
