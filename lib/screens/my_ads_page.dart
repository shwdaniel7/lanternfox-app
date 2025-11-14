import 'package:flutter/material.dart';
import '../main.dart'; // Para acessar o supabase
import 'create_ad_page.dart'; // Importa a nova página de criação

class MyAdsPage extends StatefulWidget {
  const MyAdsPage({super.key});

  @override
  State<MyAdsPage> createState() => _MyAdsPageState();
}

class _MyAdsPageState extends State<MyAdsPage> {
  late Future<List<Map<String, dynamic>>> _adsFuture;
  final String? _userId = supabase.auth.currentUser?.id;

  @override
  void initState() {
    super.initState();
    if (_userId != null) {
      _adsFuture = _fetchMyAds(_userId);
    } else {
      _adsFuture = Future.error('Usuário não autenticado.');
    }
  }

  Future<List<Map<String, dynamic>>> _fetchMyAds(String userId) async {
    try {
      final response = await supabase
          .from('anuncios_usuarios')
          .select()
          .eq('usuario_id', userId)
          .order('created_at', ascending: false);
      return response;
    } catch (e) {
      throw 'Falha ao carregar seus anúncios: $e';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meus Anúncios')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _adsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Você ainda não criou nenhum anúncio.'),
            );
          }

          final ads = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 80), // Espaço para o botão flutuante não cobrir o último item
            itemCount: ads.length,
            itemBuilder: (context, index) {
              final ad = ads[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: ListTile(
                  leading: Image.network(
                    ad['imagem_url'] ?? 'https://via.placeholder.com/100',
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                  title: Text(ad['titulo'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    'Status: ${ad['status']}',
                    style: TextStyle(
                      color: ad['status'] == 'disponivel' ? Colors.green : Colors.orange,
                    ),
                  ),
                  trailing: Text(
                    'R\$ ${ad['preco_sugerido']}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (context) => const CreateAdPage()),
          );
          
          if (result == true && mounted && _userId != null) {
            setState(() {
              // Recarrega a lista de anúncios
              _adsFuture = _fetchMyAds(_userId);
            });
          }
        },
        label: const Text('Novo Anúncio'),
        icon: const Icon(Icons.add),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}