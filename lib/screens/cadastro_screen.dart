import 'package:flutter/material.dart';
import '../models/usuario.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class CadastroScreen extends StatefulWidget {
  final VoidCallback onCadastroSucesso;

  const CadastroScreen({super.key, required this.onCadastroSucesso});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _cepController = TextEditingController(text: '01001000');

  String _logradouro = 'Praça da Sé';
  String _bairro = 'Sé';
  String _cidade = 'São Paulo';
  String _uf = 'SP';
  bool _buscandoCep = false;
  bool _carregando = false;
  bool _senhaOculta = true;

  Future<void> _buscarCep() async {
    setState(() => _buscandoCep = true);
    final endereco = await ApiService.buscarEnderecoPorCep(_cepController.text);
    setState(() => _buscandoCep = false);

    if (!mounted) return;

    if (endereco != null) {
      setState(() {
        _logradouro = endereco['logradouro'] ?? '';
        _bairro = endereco['bairro'] ?? '';
        _cidade = endereco['localidade'] ?? '';
        _uf = endereco['uf'] ?? '';
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
          content: Text('CEP não encontrado.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _fazerCadastro() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _carregando = true);

      final novoUsuario = Usuario(
        id: 'USR-${DateTime.now().millisecondsSinceEpoch}',
        nome: _nomeController.text.trim(),
        email: _emailController.text.trim(),
        senha: _senhaController.text,
        cep: _cepController.text.trim(),
        logradouro: _logradouro,
        bairro: _bairro,
        cidade: _cidade,
        uf: _uf,
        telefone: _telefoneController.text.trim(),
      );

      final erro = await StorageService.cadastrarUsuario(novoUsuario);
      setState(() => _carregando = false);

      if (!mounted) return;

      if (erro == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Conta criada com sucesso! Faça login para continuar.'),
            backgroundColor: Color(0xFF00897B),
          ),
        );
        widget.onCadastroSucesso();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(erro),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Nova Conta'),
        backgroundColor: const Color(0xFF00897B),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Cadastre-se no ClickFarma',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00897B),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Preencha seus dados para começar a comprar com rapidez.',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),

                // Nome
                TextFormField(
                  controller: _nomeController,
                  decoration: InputDecoration(
                    labelText: 'Nome Completo',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Informe seu nome.' : null,
                ),
                const SizedBox(height: 16),

                // E-mail
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'E-mail',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Informe seu e-mail.' : null,
                ),
                const SizedBox(height: 16),

                // Senha
                TextFormField(
                  controller: _senhaController,
                  obscureText: _senhaOculta,
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_senhaOculta
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () =>
                          setState(() => _senhaOculta = !_senhaOculta),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (val) =>
                      val == null || val.length < 6 ? 'Mínimo de 6 caracteres.' : null,
                ),
                const SizedBox(height: 16),

                // Telefone
                TextFormField(
                  controller: _telefoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Telefone / Celular',
                    prefixIcon: const Icon(Icons.phone_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Informe seu telefone.' : null,
                ),
                const SizedBox(height: 16),

                // CEP
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _cepController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'CEP',
                          prefixIcon: const Icon(Icons.location_on_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _buscandoCep ? null : _buscarCep,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00897B),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _buscandoCep
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : const Text('BUSCAR CEP'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Endereço: $_logradouro, $_bairro - $_cidade/$_uf',
                  style: TextStyle(color: Colors.grey[700], fontSize: 13),
                ),
                const SizedBox(height: 32),

                // Botão Cadastrar
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _carregando ? null : _fazerCadastro,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00897B),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _carregando
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'CADASTRAR',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
