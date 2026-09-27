import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'models/medicamento.dart';
import 'models/pedido.dart';
import 'models/usuario.dart';
import 'screens/login_screen.dart';
import 'screens/cadastro_screen.dart';
import 'screens/home_screen.dart';
import 'screens/medicamento_detalhes_screen.dart';
import 'screens/carrinho_screen.dart';
import 'screens/upload_receita_screen.dart';
import 'screens/rastreamento_screen.dart';
import 'screens/historico_screen.dart';
import 'screens/perfil_screen.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ClickFarmaApp());
}

class ClickFarmaApp extends StatelessWidget {
  const ClickFarmaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ClickFarma',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00897B), // Verde Farmacêutico
          primary: const Color(0xFF00897B),
          secondary: const Color(0xFF0288D1),
        ),
        useMaterial3: true,
      ),
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _indiceAba = 0;
  bool _estaLogado = false;
  bool _mostrandoCadastro = false;
  Usuario? _usuarioLogado;

  // Estado do Carrinho de Compras
  final List<ItemPedido> _itensCarrinho = [];
  String? _caminhoReceitaAnexada;
  Pedido? _ultimoPedidoRealizado;

  @override
  void initState() {
    super.initState();
    _carregarCarrinhoLocal();
    _carregarUsuarioPadrao();
  }

  Future<void> _carregarCarrinhoLocal() async {
    final itens = await StorageService.obterCarrinho();
    setState(() {
      _itensCarrinho.clear();
      _itensCarrinho.addAll(itens);
    });
  }

  Future<void> _carregarUsuarioPadrao() async {
    final user = await StorageService.obterUsuarioPorEmail('cliente@clickfarma.com');
    if (user != null) {
      setState(() {
        _usuarioLogado = user;
      });
    }
  }

  Future<void> _salvarCarrinhoLocal() async {
    await StorageService.salvarCarrinho(_itensCarrinho);
  }

  void _adicionarAoCarrinho(Medicamento med) {
    setState(() {
      final index = _itensCarrinho
          .indexWhere((item) => item.medicamento.id == med.id);
      if (index >= 0) {
        _itensCarrinho[index].quantidade++;
      } else {
        _itensCarrinho.add(ItemPedido(medicamento: med, quantidade: 1));
      }
    });
    _salvarCarrinhoLocal();
  }

  void _abrirDetalhesMedicamento(Medicamento med) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MedicamentoDetalhesScreen(
          medicamento: med,
          onAdicionarAoCarrinho: _adicionarAoCarrinho,
          onIrParaUploadReceita: () => _abrirUploadReceita(),
        ),
      ),
    );
  }

  void _abrirUploadReceita() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => UploadReceitaScreen(
          onReceitaAnexada: (caminho) {
            setState(() {
              _caminhoReceitaAnexada = caminho;
            });
          },
        ),
      ),
    );
  }

  void _finalizarPedidoEProcecer(Pedido novoPedido) {
    setState(() {
      _ultimoPedidoRealizado = novoPedido;
      _indiceAba = 2; // Muda para a aba de Rastreamento
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_estaLogado) {
      if (_mostrandoCadastro) {
        return CadastroScreen(
          onCadastroSucesso: () {
            setState(() {
              _mostrandoCadastro = false;
            });
          },
        );
      }
      return LoginScreen(
        onLoginSucesso: (usuario) {
          setState(() {
            _usuarioLogado = usuario;
            _estaLogado = true;
          });
        },
        onIrParaCadastro: () {
          setState(() {
            _mostrandoCadastro = true;
          });
        },
      );
    }

    final usuarioAtual = _usuarioLogado ??
        Usuario(
          id: 'USR-DEFAULT',
          nome: 'Gustavo Barros',
          email: 'cliente@clickfarma.com',
          cep: '01001000',
          logradouro: 'Praça da Sé',
          bairro: 'Sé',
          cidade: 'São Paulo',
          uf: 'SP',
          telefone: '(11) 99999-9999',
        );

    final List<Widget> telas = [
      // Aba 0: Home / Catálogo
      HomeScreen(
        onAdicionarAoCarrinho: _adicionarAoCarrinho,
        onVerDetalhes: _abrirDetalhesMedicamento,
      ),

      // Aba 1: Carrinho de Compras
      CarrinhoScreen(
        itensCarrinho: _itensCarrinho,
        caminhoReceitaAnexada: _caminhoReceitaAnexada,
        onIrParaUploadReceita: _abrirUploadReceita,
        onLimparCarrinho: () {
          setState(() {
            _itensCarrinho.clear();
            _caminhoReceitaAnexada = null;
          });
          StorageService.limparCarrinhoDb();
        },
        onPedidoFinalizado: (pedido) {
          _finalizarPedidoEProcecer(pedido);
          StorageService.limparCarrinhoDb();
        },
        onCarrinhoAlterado: _salvarCarrinhoLocal,
      ),

      // Aba 2: Rastreamento em Tempo Real
      RastreamentoScreen(pedido: _ultimoPedidoRealizado),

      // Aba 3: Histórico de Pedidos (SQLite)
      const HistoricoScreen(),

      // Aba 4: Perfil do Usuário
      PerfilScreen(
        usuario: usuarioAtual,
        onLogout: () {
          setState(() {
            _estaLogado = false;
            _usuarioLogado = null;
          });
        },
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _indiceAba,
        children: telas,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indiceAba,
        onTap: (index) {
          setState(() {
            _indiceAba = index;
          });
        },
        selectedItemColor: const Color(0xFF00897B),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Badge(
              label: Text('${_itensCarrinho.length}'),
              isLabelVisible: _itensCarrinho.isNotEmpty,
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            activeIcon: Badge(
              label: Text('${_itensCarrinho.length}'),
              isLabelVisible: _itensCarrinho.isNotEmpty,
              child: const Icon(Icons.shopping_cart),
            ),
            label: 'Carrinho',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.delivery_dining_outlined),
            activeIcon: Icon(Icons.delivery_dining),
            label: 'Entrega',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'Histórico',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
