import 'package:flutter/material.dart';
import '../main.dart';
import '../widgets/product_card.dart';
import 'ad_detail_page.dart';

class MarketplacePage extends StatefulWidget {
  const MarketplacePage({super.key});

  @override
  State<MarketplacePage> createState() => _MarketplacePageState();
}

class _MarketplacePageState extends State<MarketplacePage> {
  late final Future<List<Map<String, dynamic>>> _adsFuture;

  @override
  void initState() {
    super.initState();
    _adsFuture = _fetchUserAds();
  }

  Future<List<Map<String, dynamic>>> _fetchUserAds() async {
    try {
      final response = await supabase
          .from('anuncios_usuarios')
          .select('*, profiles(full_name)')
          .eq('status', 'disponivel')
          .order('created_at', ascending: false);
      return response;
    } catch (e) {
      throw 'Falha ao carregar anúncios: $e';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _adsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }
          if (snapshot.hasData) {
            final ads = snapshot.data!;
            if (ads.isEmpty) {
              return const Center(child: Text('Nenhum anúncio encontrado.'));
            }

            return ListView.builder(
              padding: const EdgeInsets.only(top: 16, bottom: 16),
              itemCount: ads.length,
              itemBuilder: (context, index) {
                final ad = ads[index];
                return ProductCard(
                  imageUrl:
                      ad['imagem_url'] ?? 'https://via.placeholder.com/400',
                  name: ad['titulo'],
                  price: (ad['preco_sugerido'] as num?)?.toDouble() ?? 0.0,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AdDetailPage(
                          adId: ad['id'] as int,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }
          return const Center(child: Text('Algo deu errado.'));
        },
      ),
    );
  }
}
