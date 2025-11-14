import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../main.dart'; // Para acessar o supabase

class CreateAdPage extends StatefulWidget {
  const CreateAdPage({super.key});

  @override
  State<CreateAdPage> createState() => _CreateAdPageState();
}

class _CreateAdPageState extends State<CreateAdPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  File? _selectedImage;
  bool _isLoading = false;

  Future<void> _createAd() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Por favor, selecione uma imagem.'),
            backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userId = supabase.auth.currentUser!.id;
      final fileExt = _selectedImage!.path.split('.').last;
      final fileName = '$userId-${DateTime.now().toIso8601String()}.$fileExt';
      final filePath = fileName;

      // 1. Upload da imagem
      await supabase.storage
          .from('imagens_anuncios')
          .upload(filePath, _selectedImage!);
      final imageUrl =
          supabase.storage.from('imagens_anuncios').getPublicUrl(filePath);

      // 2. Inserção dos dados na tabela
      await supabase.from('anuncios_usuarios').insert({
        'usuario_id': userId,
        'titulo': _titleController.text,
        'descricao': _descriptionController.text,
        'preco_sugerido': double.parse(_priceController.text),
        'imagem_url': imageUrl,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Anúncio criado com sucesso!'),
              backgroundColor: Colors.green),
        );
        Navigator.of(context)
            .pop(true); // Volta para a tela anterior e envia 'true'
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erro ao criar anúncio: $e'),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Criar Novo Anúncio')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration:
                    const InputDecoration(labelText: 'Título do Anúncio'),
                validator: (value) =>
                    value!.isEmpty ? 'O título é obrigatório.' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Descrição'),
                maxLines: 4,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration:
                    const InputDecoration(labelText: 'Preço Sugerido (R\$)'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? 'O preço é obrigatório.' : null,
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                icon: const Icon(Icons.image),
                label: const Text('Selecionar Imagem'),
                onPressed: () async {
                  final picker = ImagePicker();
                  final image =
                      await picker.pickImage(source: ImageSource.gallery);
                  if (image != null) {
                    setState(() {
                      _selectedImage = File(image.path);
                    });
                  }
                },
              ),
              if (_selectedImage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Image.file(_selectedImage!,
                      height: 150, fit: BoxFit.contain),
                ),
              const SizedBox(height: 24),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                ElevatedButton(
                  onPressed: _createAd,
                  child: const Text('Publicar Anúncio'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
