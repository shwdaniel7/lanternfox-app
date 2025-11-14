import 'package:flutter/material.dart';
import '../main.dart'; // Para acessar o supabase
import 'package:provider/provider.dart';
import '../managers/cart_manager.dart';

class AdDetailPage extends StatefulWidget {
  final int adId;

  const AdDetailPage({super.key, required this.adId});

  @override
  State<AdDetailPage> createState() => _AdDetailPageState();
}

class _AdDetailPageState extends State<AdDetailPage> {
  late final Future<Map<String, dynamic>> _adFuture;

  @override
  void initState() {
    super.initState();
    _adFuture = _fetchAdDetails();
  }

  Future<Map<String, dynamic>> _fetchAdDetails() async {
    try {
      final response = await supabase
          .from('anuncios_usuarios')
          .select('*, profiles(full_name)')
          .eq('id', widget.adId)
          .single();
      return response;
    } catch (e) {
      throw 'Falha ao carregar detalhes do anúncio: $e';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes do Anúncio')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _adFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }
          if (snapshot.hasData) {
            final ad = snapshot.data!;
            final seller = ad['profiles'];

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.network(ad['imagem_url'] ?? 'https://via.placeholder.com/400'),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(ad['titulo'], style: Theme.of(context).textTheme.headlineSmall),
                        const SizedBox(height: 16),
                        Text(
                          'R\$ ${ad['preco_sugerido']}',
                          style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Text('Vendido por: ${seller?['full_name'] ?? 'Usuário'}'),
                        const SizedBox(height: 24),
                        const Text('Sobre o produto', style: TextStyle(fontWeight: FontWeight.bold)),
                        const Divider(),
                        Text(ad['descricao'] ?? 'Sem descrição disponível.'),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Provider.of<CartManager>(context, listen: false).addItem(ad, type: 'marketplace');

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${ad['titulo']} adicionado ao carrinho!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            },
                            child: const Text('Comprar'),
                        ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}