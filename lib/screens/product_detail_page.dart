import 'package:flutter/material.dart';
import '../main.dart'; // Para acessar o supabase
import 'trade_confirmation_page.dart'; // Importa a nova página
import 'package:provider/provider.dart';
import '../managers/cart_manager.dart';

class ProductDetailPage extends StatefulWidget {
  final int productId;

  const ProductDetailPage({super.key, required this.productId});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late final Future<Map<String, dynamic>> _productFuture;

  @override
  void initState() {
    super.initState();
    _productFuture = _fetchProductDetails();
  }

  Future<Map<String, dynamic>> _fetchProductDetails() async {
    try {
      final response = await supabase
          .from('produtos_loja')
          .select()
          .eq('id', widget.productId)
          .single();
      return response;
    } catch (e) {
      throw Exception('Falha ao carregar detalhes do produto: $e');
    }
  }

  void _showTradeInModal(Map<String, dynamic> storeProduct) {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Você precisa estar logado para propor uma troca.'),
              backgroundColor: Colors.red),
        );
      }
      return;
    }

    if (storeProduct['em_promocao'] == true) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('A troca não está disponível para produtos em promoção.'),
              backgroundColor: Colors.orange),
        );
      }
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.5,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return FutureBuilder<List<Map<String, dynamic>>>(
              future: supabase
                  .from('anuncios_usuarios')
                  .select()
                  .eq('usuario_id', userId)
                  .eq('status', 'disponivel'),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Erro: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Text('Você não tem nenhum anúncio disponível para troca.'),
                    ),
                  );
                }

                final myAds = snapshot.data!;

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Escolha um item para dar como entrada',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: myAds.length,
                        itemBuilder: (context, index) {
                          final ad = myAds[index];
                          return ListTile(
                            leading: Image.network(ad['imagem_url'] ?? 'https://via.placeholder.com/100'),
                            title: Text(ad['titulo']),
                            subtitle: Text('Valor: R\$ ${ad['preco_sugerido']}'),
                            onTap: () {
                              // Navega para a página de confirmação
                              Navigator.pop(context); // Fecha o modal
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TradeConfirmationPage(
                                    storeProduct: storeProduct,
                                    userAd: ad,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes do Produto')),
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>>(
          future: _productFuture,
          builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('Produto não encontrado.'));
          }

          final product = snapshot.data!;
          final isPromo = product['em_promocao'] == true;

          return SingleChildScrollView(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(
                  product['imagem_url'] ?? 'https://via.placeholder.com/400',
                  width: double.infinity,
                  height: 300,
                  fit: BoxFit.cover,
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product['nome'],
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      
                      if (isPromo) ...[
                        Text(
                          'R\$ ${product['preco']}',
                          style: const TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'R\$ ${product['preco_promocional']}',
                          style: const TextStyle(
                            color: Colors.green,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ] else ...[
                        Text(
                          'R\$ ${product['preco']}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],

                      const SizedBox(height: 16),
                      Text(
                        'Em estoque: ${product['estoque']} unidades',
                        style: const TextStyle(color: Colors.green),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Sobre o produto',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const Divider(),
                      Text(product['descricao'] ?? 'Sem descrição disponível.'),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                                onPressed: () {
                                  // Acessa o CartManager e chama o método addItem
                                  Provider.of<CartManager>(context, listen: false).addItem(product);

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('${product['nome']} adicionado ao carrinho!'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                },
                                child: const Text('Adicionar ao Carrinho'),
                              ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => _showTradeInModal(product),
                          style: isPromo ? OutlinedButton.styleFrom(foregroundColor: Colors.grey) : null,
                          child: const Text('Dar item como entrada'),
                        ),
                      ),
                      if (isPromo)
                        const Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Text(
                            'Esta opção não está disponível para produtos em promoção.',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                      ),
                      const SizedBox(height: 32), // Add extra padding at the bottom
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ));
  }
}