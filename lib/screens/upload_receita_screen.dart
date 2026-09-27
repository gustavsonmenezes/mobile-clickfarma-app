import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UploadReceitaScreen extends StatefulWidget {
  final Function(String caminhoImagem) onReceitaAnexada;

  const UploadReceitaScreen({super.key, required this.onReceitaAnexada});

  @override
  State<UploadReceitaScreen> createState() => _UploadReceitaScreenState();
}

class _UploadReceitaScreenState extends State<UploadReceitaScreen> {
  File? _imagemReceita;
  final ImagePicker _picker = ImagePicker();

  // Integração com Recurso Nativo: Câmera ou Galeria do aparelho
  Future<void> _selecionarImagem(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _imagemReceita = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao acessar recurso nativo de imagem: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _confirmarReceita() {
    if (_imagemReceita != null) {
      widget.onReceitaAnexada(_imagemReceita!.path);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Receita médica anexada com sucesso!'),
          backgroundColor: Color(0xFF00897B),
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Anexar Receita Médica'),
        backgroundColor: const Color(0xFF00897B),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Icon(Icons.assignment_turned_in,
                size: 48, color: Color(0xFF00897B)),
            const SizedBox(height: 12),
            const Text(
              'Fotografe ou envie a Receita Médica',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'A receita deve estar legível com o nome do médico, CRM e data visíveis.',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Área da Imagem Selecionada
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  border: Border.all(color: Colors.grey[300]!, width: 2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: _imagemReceita != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.file(_imagemReceita!, fit: BoxFit.contain),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.camera_enhance_outlined,
                              size: 64, color: Colors.grey),
                          SizedBox(height: 12),
                          Text(
                            'Nenhuma imagem selecionada',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 24),

            // Botões Câmera e Galeria
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _selecionarImagem(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt, color: Color(0xFF00897B)),
                    label: const Text('CÂMERA'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Color(0xFF00897B)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _selecionarImagem(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library,
                        color: Color(0xFF00897B)),
                    label: const Text('GALERIA'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Color(0xFF00897B)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Botão Confirmar
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _imagemReceita != null ? _confirmarReceita : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00897B),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('CONFIRMAR E VINCULAR RECEITA',
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
