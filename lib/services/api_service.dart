import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/medicamento.dart';

class ApiService {
  // Consumo da API Externa ViaCEP para busca automatica de endereço
  static Future<Map<String, dynamic>?> buscarEnderecoPorCep(String cep) async {
    final cepLimpo = cep.replaceAll(RegExp(r'[^0-9]'), '');
    if (cepLimpo.length != 8) return null;

    final url = Uri.parse('https://viacep.com.br/ws/$cepLimpo/json/');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.containsKey('erro')) return null;
        return data;
      }
    } catch (e) {
      // Trata exceção de conexão na busca de CEP
    }
    return null;
  }

  // Catálogo de Medicamentos da API do ClickFarma
  static Future<List<Medicamento>> obterMedicamentos() async {
    // Simulação de resposta de API REST de medicamentos
    await Future.delayed(const Duration(milliseconds: 500));

    return [
      Medicamento(
        id: '1',
        nome: 'Paracetamol 750mg',
        laboratorio: 'Medley',
        categoria: 'Analgésicos',
        preco: 12.90,
        precisaReceita: false,
        descricao: 'Indicado para dor de cabeça, febre e dores no corpo em geral.',
        imagemUrl: 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=400',
        dosagem: '20 Comprimidos',
      ),
      Medicamento(
        id: '2',
        nome: 'Amoxicilina 500mg',
        laboratorio: 'EMS',
        categoria: 'Antibióticos',
        preco: 28.50,
        precisaReceita: true,
        descricao: 'Antibiótico de amplo espectro indicado para infecções bacterianas. Exige retenção de receita.',
        imagemUrl: 'https://images.unsplash.com/photo-1471864190281-a93a3070b6de?w=400',
        dosagem: '21 Cápsulas',
      ),
      Medicamento(
        id: '3',
        nome: 'Dipirona Sódica 1g',
        laboratorio: 'Eurofarma',
        categoria: 'Analgésicos',
        preco: 9.80,
        precisaReceita: false,
        descricao: 'Analgésico e antitérmico para alívio de dores moderadas a intensas e febre.',
        imagemUrl: 'https://images.unsplash.com/photo-1550572017-edf792890533?w=400',
        dosagem: '10 Comprimidos efervescentes',
      ),
      Medicamento(
        id: '4',
        nome: 'Omeprazol 20mg',
        laboratorio: 'Neo Química',
        categoria: 'Gastroenterologia',
        preco: 18.20,
        precisaReceita: false,
        descricao: 'Tratamento de azia, gastrite e proteção estomacal.',
        imagemUrl: 'https://images.unsplash.com/photo-1585435557343-3b092031a831?w=400',
        dosagem: '28 Cápsulas',
      ),
      Medicamento(
        id: '5',
        nome: 'Vitamina C + Zinco',
        laboratorio: 'Sundown',
        categoria: 'Vitaminas',
        preco: 32.00,
        precisaReceita: false,
        descricao: 'Suplemento vitamínico para fortalecimento do sistema imunológico.',
        imagemUrl: 'https://images.unsplash.com/photo-1584017911766-d451b3d0e843?w=400',
        dosagem: '30 Comprimidos efervescentes',
      ),
      Medicamento(
        id: '6',
        nome: 'Clonazepam 2mg',
        laboratorio: 'Pharlab',
        categoria: 'Controlados',
        preco: 22.40,
        precisaReceita: true,
        descricao: 'Medicamento ansiolítico de tarja preta. Exige retenção de receita médica na entrega.',
        imagemUrl: 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=400',
        dosagem: '30 Comprimidos',
      ),
    ];
  }
}
