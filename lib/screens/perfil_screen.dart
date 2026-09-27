import 'package:flutter/material.dart';
import '../models/usuario.dart';

class PerfilScreen extends StatelessWidget {
  final Usuario usuario;
  final VoidCallback onLogout;

  const PerfilScreen({
    super.key,
    required this.usuario,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Meu Perfil'),
        backgroundColor: const Color(0xFF00897B),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Foto de Perfil e Nome
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 40,
                      backgroundColor: Color(0xFF00897B),
                      child: Icon(Icons.person, size: 50, color: Colors.white),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      usuario.nome,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      usuario.email,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Chip(
                      label: Text('Tel: ${usuario.telefone}'),
                      backgroundColor: const Color(0xFFE0F2F1),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Opções do Usuário
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.location_on_outlined,
                        color: Color(0xFF00897B)),
                    title: const Text('Meu Endereço Cadastrado'),
                    subtitle: Text(
                        '${usuario.logradouro}, ${usuario.bairro} - ${usuario.cidade}/${usuario.uf} (CEP: ${usuario.cep})'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.receipt_outlined,
                        color: Color(0xFF00897B)),
                    title: const Text('Minhas Receitas Salvas'),
                    subtitle: const Text('2 receitas cadastradas'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.payment, color: Color(0xFF00897B)),
                    title: const Text('Formas de Pagamento'),
                    subtitle: const Text('Cartão de Crédito e Pix'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.security, color: Color(0xFF00897B)),
                    title: const Text('Privacidade e Termos'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Botão de Logout
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: onLogout,
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text('SAIR DA CONTA',
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
