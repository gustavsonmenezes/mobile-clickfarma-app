import 'package:flutter/material.dart';
import '../models/usuario.dart';
import '../services/storage_service.dart';

class LoginScreen extends StatefulWidget {
  final Function(Usuario) onLoginSucesso;
  final VoidCallback onIrParaCadastro;

  const LoginScreen({
    super.key,
    required this.onLoginSucesso,
    required this.onIrParaCadastro,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'cliente@clickfarma.com');
  final _senhaController = TextEditingController(text: '123456');
  bool _senhaOculta = true;
  bool _carregando = false;

  Future<void> _fazerLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _carregando = true);
      final usuario = await StorageService.autenticarUsuario(
        _emailController.text,
        _senhaController.text,
      );
      setState(() => _carregando = false);

      if (!mounted) return;

      if (usuario != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bem-vindo, ${usuario.nome}! Login efetuado com sucesso.'),
            backgroundColor: const Color(0xFF00897B),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        widget.onLoginSucesso(usuario);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('E-mail ou senha incorretos. Verifique seus dados.'),
            backgroundColor: Colors.red[700],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  Future<void> _entrarComoVisitante() async {
    final usuarioPadrao = await StorageService.obterUsuarioPorEmail('cliente@clickfarma.com');
    widget.onLoginSucesso(
      usuarioPadrao ??
          Usuario(
            id: 'VISITANTE',
            nome: 'Visitante',
            email: 'visitante@clickfarma.com',
            cep: '01001000',
            logradouro: 'Praça da Sé',
            bairro: 'Sé',
            cidade: 'São Paulo',
            uf: 'SP',
            telefone: '(11) 00000-0000',
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 420),
              padding: const EdgeInsets.all(28.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo com fundo suave
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F2F1),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00897B).withValues(alpha: 0.15),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.local_pharmacy_rounded,
                        size: 52,
                        color: Color(0xFF00897B),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'ClickFarma',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00897B),
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Sua farmácia online rápida e segura',
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    ),
                    const SizedBox(height: 32),

                    // Campo E-mail
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'E-mail',
                        labelStyle: TextStyle(color: Colors.grey[600]),
                        prefixIcon: const Icon(Icons.email_outlined,
                            color: Color(0xFF00897B)),
                        filled: true,
                        fillColor: Colors.grey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                              color: Color(0xFF00897B), width: 2),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, informe seu e-mail.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Campo Senha
                    TextFormField(
                      controller: _senhaController,
                      obscureText: _senhaOculta,
                      decoration: InputDecoration(
                        labelText: 'Senha',
                        labelStyle: TextStyle(color: Colors.grey[600]),
                        prefixIcon: const Icon(Icons.lock_outline_rounded,
                            color: Color(0xFF00897B)),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _senhaOculta
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _senhaOculta = !_senhaOculta;
                            });
                          },
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                              color: Color(0xFF00897B), width: 2),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, informe sua senha.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Botão Entrar
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _carregando ? null : _fazerLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00897B),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 2,
                        ),
                        child: _carregando
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'ENTRAR',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.8,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Botão Criar Conta
                    TextButton(
                      onPressed: widget.onIrParaCadastro,
                      child: const Text(
                        'Não tem uma conta? Cadastre-se',
                        style: TextStyle(
                          color: Color(0xFF00897B),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextButton(
                      onPressed: _entrarComoVisitante,
                      child: Text(
                        'Continuar como Visitante',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
