import 'package:flutter/material.dart';
import '../main.dart';
import '../widgets/product_card.dart';
import 'product_detail_page.dart';
import 'ad_detail_page.dart';

class SearchPage extends StatefulWidget {
  final String? initialSearchTerm;
  final String? initialCategory;

  const SearchPage({super.key, this.initialSearchTerm, this.initialCategory});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  Future<List<Map<String, dynamic>>>? _searchFuture;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Preenche o campo de busca e/ou realiza a busca inicial
    if (widget.initialSearchTerm != null) {
      _searchController.text = widget.initialSearchTerm!;
      _performSearch(widget.initialSearchTerm!);
    }
    if (widget.initialCategory != null) {
      // Quando é uma busca por categoria, não usamos o texto da categoria como termo de busca
      _searchController.text = '';
      _performSearch('');
    }
  }

  void _performSearch(String searchTerm) {
    // Sempre executa a busca se tiver categoria, mesmo com termo vazio
    if (searchTerm.trim().isEmpty && widget.initialCategory == null) {
      setState(() {
        _searchFuture = null;
      });
      return;
    }
    setState(() {
      _searchFuture = _fetchSearchResults(searchTerm.trim());
    });
  }

  Future<List<Map<String, dynamic>>> _fetchSearchResults(
      String searchTerm) async {
    try {
      var productsResponse = supabase.from('produtos_loja').select();

      var adsResponse = supabase
          .from('anuncios_usuarios')
          .select('*, profiles(full_name)')
          .eq('status', 'disponivel');

      // Primeiro aplica o filtro de categoria se existir
      if (widget.initialCategory != null) {
        productsResponse =
            productsResponse.eq('categoria', widget.initialCategory!);
        adsResponse = adsResponse.eq('categoria', widget.initialCategory!);
      }

      // Depois aplica o filtro de busca por texto se existir
      if (searchTerm.isNotEmpty) {
        productsResponse = productsResponse.ilike('nome', '%$searchTerm%');
        adsResponse = adsResponse.ilike('titulo', '%$searchTerm%');
      }

      final results = await Future.wait([productsResponse, adsResponse]);

      final products = (results[0] as List)
          .map((p) => Map<String, dynamic>.from(p)..['type'] = 'loja')
          .toList();

      final ads = (results[1] as List)
          .map((a) => Map<String, dynamic>.from(a)..['type'] = 'marketplace')
          .toList();

      return [...products, ...ads];
    } catch (e) {
      throw 'Falha ao realizar busca: $e';
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: widget.initialCategory ==
              null, // Foca automaticamente, exceto se for busca por categoria
          decoration: const InputDecoration(
            hintText: 'O que você está procurando?',
            border: InputBorder.none,
          ),
          onSubmitted: _performSearch,
        ),
      ),
      body: _searchFuture == null
          ? const Center(child: Text('Digite para buscar produtos e anúncios.'))
          : FutureBuilder<List<Map<String, dynamic>>>(
              future: _searchFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Erro: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                      child: Text('Nenhum resultado encontrado.'));
                }

                final results = snapshot.data!;

                return ListView.builder(
                  padding: const EdgeInsets.only(top: 16, bottom: 16),
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final item = results[index];
                    final isProduct = item['type'] == 'loja';

                    return ProductCard(
                      imageUrl: item['imagem_url'] ??
                          'https://via.placeholder.com/400',
                      name: isProduct ? item['nome'] : item['titulo'],
                      price: (isProduct
                              ? item['preco']
                              : item['preco_sugerido'] as num)
                          .toDouble(),
                      onTap: () {
                        if (isProduct) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductDetailPage(
                                  productId: item['id'] as int),
                            ),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  AdDetailPage(adId: item['id'] as int),
                            ),
                          );
                        }
                      },
                    );
                  },
                );
              },
            ),
    );
  }
}
