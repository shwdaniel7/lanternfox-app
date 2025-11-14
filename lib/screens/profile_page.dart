import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart';
import 'my_ads_page.dart';
import 'my_orders_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<Map<String, dynamic>> _profileFuture;
  final String? _userId = supabase.auth.currentUser?.id;

  @override
  void initState() {
    super.initState();
    if (_userId != null) {
      _profileFuture = _fetchProfile(_userId);
    } else {
      _profileFuture = Future.error('Usuário não autenticado.');
    }
  }

  Future<Map<String, dynamic>> _fetchProfile(String userId) async {
    try {
      final response = await supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      return response;
    } catch (e) {
      throw 'Falha ao carregar perfil: $e';
    }
  }

void _showEditProfileForm(Map<String, dynamic> currentProfile) {
    final nameController = TextEditingController(text: currentProfile['full_name']);
    final formKey = GlobalKey<FormState>();
    File? selectedImage; // Variável para guardar a imagem selecionada

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Permite que o modal cresça com o teclado
      backgroundColor: Theme.of(context).cardColor, // Usa a cor do card do tema
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        // Usamos um StatefulWidget para o modal poder atualizar a UI quando a imagem é selecionada
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                top: 20,
                left: 20,
                right: 20,
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // "Puxador" do modal
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade700,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    Text('Editar Perfil', style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Nome Completo'),
                      validator: (value) => value!.isEmpty ? 'O nome não pode ser vazio.' : null,
                    ),
                    const SizedBox(height: 20),
                    
                    OutlinedButton.icon(
                      icon: const Icon(Icons.image_search),
                      label: const Text('Selecionar Novo Avatar'),
                      onPressed: () async {
                        final picker = ImagePicker();
                        final XFile? imageFile = await picker.pickImage(
                          source: ImageSource.gallery,
                          imageQuality: 50, // Comprime a imagem para uploads mais rápidos
                        );
                        if (imageFile != null) {
                          setModalState(() {
                            selectedImage = File(imageFile.path);
                          });
                        }
                      },
                    ),
                    
                    if (selectedImage != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(selectedImage!, height: 100, fit: BoxFit.contain),
                        ),
                      ),

                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) return;

                        // Mostra um indicador de loading
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => const Center(child: CircularProgressIndicator()),
                        );

                        try {
                          String? imageUrl;
                          if (selectedImage != null) {
                            final fileExt = selectedImage!.path.split('.').last;
                            final filePath = '$_userId/avatar.$fileExt';
                            
                            await supabase.storage.from('avatares').upload(
                                  filePath,
                                  selectedImage!,
                                  fileOptions: const FileOptions(upsert: true),
                                );
                            
                            imageUrl = supabase.storage.from('avatares').getPublicUrl(filePath);
                            imageUrl = '$imageUrl?t=${DateTime.now().millisecondsSinceEpoch}';
                          }

                          final updates = {
                            'full_name': nameController.text.trim(),
                            if (imageUrl != null) 'avatar_url': imageUrl,
                          };

                          await supabase.from('profiles').update(updates).eq('id', _userId!);

                          if (mounted) {
                            Navigator.pop(context); // Fecha o indicador de loading
                            Navigator.pop(context); // Fecha o modal
                            setState(() { _profileFuture = _fetchProfile(_userId); });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Perfil atualizado!'), backgroundColor: Colors.green),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            Navigator.pop(context); // Fecha o indicador de loading
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Erro ao atualizar: $e'), backgroundColor: Colors.red),
                            );
                          }
                        }
                      },
                      child: const Text('Salvar Alterações'),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }
          if (snapshot.hasData) {
            final profile = snapshot.data!;
            final user = supabase.auth.currentUser;

            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.grey.shade800,
                          backgroundImage: (profile['avatar_url'] != null && profile['avatar_url'].isNotEmpty)
                              ? NetworkImage(profile['avatar_url'])
                              : null,
                          child: (profile['avatar_url'] == null || profile['avatar_url'].isEmpty)
                              ? const Icon(Icons.person, size: 60, color: Colors.grey)
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: MediaQuery.of(context).size.width / 2 - 80,
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            child: IconButton(
                              tooltip: 'Editar perfil',
                              icon: const Icon(Icons.edit, color: Colors.black, size: 20),
                              onPressed: () => _showEditProfileForm(profile),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      profile['full_name'] ?? 'Nome não definido',
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      user?.email ?? 'Email não encontrado',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.receipt_long_outlined),
                      label: const Text('Meus Pedidos'),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const MyOrdersPage()));
                      },
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.campaign_outlined),
                      label: const Text('Meus Anúncios'),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const MyAdsPage()));
                      },
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: () async {
                        await supabase.auth.signOut();
                      },
                      child: const Text('Sair'),
                    ),
                  ],
                ),
              ),
            );
          }
          return const Center(child: Text('Não foi possível carregar o perfil.'));
        },
      ),
    );
  }
}