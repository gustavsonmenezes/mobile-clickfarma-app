import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pedido.dart';
import '../models/medicamento.dart';
import '../models/usuario.dart';

class StorageService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _keyCarrinho = 'clickfarma_carrinho';

  // --- Usuários (Cloud Firestore Direto - Sem reCAPTCHA/Auth Web) ---

  static Future<String?> cadastrarUsuario(Usuario usuario) async {
    try {
      if (usuario.email.trim().isEmpty ||
          usuario.senha == null ||
          usuario.senha!.length < 6) {
        return 'Informe um e-mail válido e uma senha de pelo menos 6 caracteres.';
      }

      // 1. Verificar se o e-mail já existe no Firestore
      final query = await _firestore
          .collection('usuarios')
          .where('email', isEqualTo: usuario.email.trim())
          .get();

      if (query.docs.isNotEmpty) {
        return 'Este e-mail já está cadastrado no sistema.';
      }

      // 2. Salvar novo usuário no Firestore
      final uid = 'USR-${DateTime.now().millisecondsSinceEpoch}';
      final usuarioMap = {
        'id': uid,
        'nome': usuario.nome.trim(),
        'email': usuario.email.trim(),
        'senha': usuario.senha!,
        'cep': usuario.cep,
        'logradouro': usuario.logradouro,
        'bairro': usuario.bairro,
        'cidade': usuario.cidade,
        'uf': usuario.uf,
        'telefone': usuario.telefone,
      };

      await _firestore.collection('usuarios').doc(uid).set(usuarioMap);
      return null; // Sucesso
    } catch (e) {
      return 'Erro ao cadastrar no Firestore: $e';
    }
  }

  static Future<Usuario?> autenticarUsuario(String email, String senha) async {
    // Caso especial para o usuário padrão de testes (sempre funciona instantaneamente)
    if (email.trim() == 'cliente@clickfarma.com' && senha == '123456') {
      return Usuario(
        id: 'USR-DEFAULT',
        nome: 'Gustavo Barros',
        email: 'cliente@clickfarma.com',
        senha: '123456',
        cep: '01001000',
        logradouro: 'Praça da Sé',
        bairro: 'Sé',
        cidade: 'São Paulo',
        uf: 'SP',
        telefone: '(11) 99999-9999',
      );
    }

    try {
      // Consulta otimizada por e-mail
      final query = await _firestore
          .collection('usuarios')
          .where('email', isEqualTo: email.trim())
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final data = query.docs.first.data();
        if (data['senha'] == senha) {
          return Usuario.fromMap(data);
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<Usuario?> obterUsuarioPorEmail(String email) async {
    try {
      final query = await _firestore
          .collection('usuarios')
          .where('email', isEqualTo: email.trim())
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        return Usuario.fromMap(query.docs.first.data());
      }
    } catch (_) {}
    return null;
  }

  // --- Carrinho (SharedPreferences Local) ---

  static Future<void> salvarCarrinho(List<ItemPedido> itens) async {
    final prefs = await SharedPreferences.getInstance();
    final listaMap = itens
        .map((item) => {
              'medicamentoId': item.medicamento.id,
              'medicamentoNome': item.medicamento.nome,
              'laboratorio': item.medicamento.laboratorio,
              'categoria': item.medicamento.categoria,
              'preco': item.medicamento.preco,
              'precisaReceita': item.medicamento.precisaReceita,
              'descricao': item.medicamento.descricao,
              'imagemUrl': item.medicamento.imagemUrl,
              'dosagem': item.medicamento.dosagem,
              'quantidade': item.quantidade,
            })
        .toList();
    await prefs.setString(_keyCarrinho, jsonEncode(listaMap));
  }

  static Future<List<ItemPedido>> obterCarrinho() async {
    final prefs = await SharedPreferences.getInstance();
    final carrinhoStr = prefs.getString(_keyCarrinho);
    if (carrinhoStr == null) return [];

    List<dynamic> lista = jsonDecode(carrinhoStr);
    return lista.map((map) {
      final medicamento = Medicamento(
        id: map['medicamentoId'],
        nome: map['medicamentoNome'],
        laboratorio: map['laboratorio'] ?? '',
        categoria: map['categoria'] ?? '',
        preco: (map['preco'] as num).toDouble(),
        precisaReceita: map['precisaReceita'] ?? false,
        descricao: map['descricao'] ?? '',
        imagemUrl: map['imagemUrl'] ?? '',
        dosagem: map['dosagem'] ?? '',
      );
      return ItemPedido(
        medicamento: medicamento,
        quantidade: map['quantidade'] ?? 1,
      );
    }).toList();
  }

  static Future<void> limparCarrinhoDb() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyCarrinho);
  }

  // --- Pedidos (Cloud Firestore) ---

  static Future<void> salvarPedido(Pedido pedido) async {
    try {
      final pedidoMap = {
        ...pedido.toMap(),
        'itens': pedido.itens
            .map((item) => {
                  'medicamentoId': item.medicamento.id,
                  'medicamentoNome': item.medicamento.nome,
                  'preco': item.medicamento.preco,
                  'quantidade': item.quantidade,
                })
            .toList(),
      };

      await _firestore.collection('pedidos').doc(pedido.id).set(pedidoMap);
    } catch (_) {}
  }

  static Future<List<Pedido>> obterPedidos() async {
    try {
      final querySnapshot = await _firestore
          .collection('pedidos')
          .orderBy('dataCriacao', descending: true)
          .get();

      List<Pedido> pedidos = [];
      for (var doc in querySnapshot.docs) {
        final mapPedido = doc.data();
        List<dynamic> itensMap = mapPedido['itens'] ?? [];
        List<ItemPedido> itens = itensMap.map((mapItem) {
          return ItemPedido(
            medicamento: Medicamento(
              id: mapItem['medicamentoId'] ?? '',
              nome: mapItem['medicamentoNome'] ?? '',
              laboratorio: 'Farmácia',
              categoria: 'Geral',
              preco: (mapItem['preco'] as num).toDouble(),
              precisaReceita: false,
              descricao: '',
              imagemUrl: '',
              dosagem: '',
            ),
            quantidade: mapItem['quantidade'] ?? 1,
          );
        }).toList();

        pedidos.add(Pedido.fromMap(mapPedido, itens));
      }
      return pedidos;
    } catch (_) {
      return [];
    }
  }
}
