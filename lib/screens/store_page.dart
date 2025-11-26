import 'package:flutter/material.dart';
import '../main.dart';
import '../widgets/product_card.dart';
import 'product_detail_page.dart';
import 'search_page.dart';

class StorePage extends StatefulWidget {
  const StorePage({super.key});

  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  late final Future<Map<String, dynamic>> _pageDataFuture;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _promotionsKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _pageDataFuture = _fetchPageData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> _fetchPageData() async {
    try {
      final responses = await Future.wait([
        supabase
            .from('produtos_loja')
            .select()
            .eq('em_promocao', true)
            .limit(4),
        supabase
            .from('produtos_loja')
            .select()
            .order('created_at', ascending: false)
            .limit(3),
      ]);

      return {
        'promotions': responses[0] as List,
        'new_arrivals': responses[1] as List,
      };
    } catch (e) {
      throw 'Falha ao carregar dados da página: $e';
    }
  }

  void _scrollToPromotions() {
    final context = _promotionsKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>>(
        future: _pageDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('Nenhum dado encontrado.'));
          }

          final promotions = snapshot.data!['promotions'] as List;
          final newArrivals = snapshot.data!['new_arrivals'] as List;

          return ListView(
            controller: _scrollController,
            children: [
              _buildHeroBanner(context, onButtonPressed: _scrollToPromotions),
              _buildSectionTitle(context, 'Navegue por Departamentos'),
              _buildDepartmentsCarousel(context),
              if (promotions.isNotEmpty) ...[
                _buildSectionTitle(context, '🔥 Ofertas da Semana',
                    key: _promotionsKey),
                _buildHorizontalProductList(promotions),
              ],
              if (newArrivals.isNotEmpty) ...[
                _buildSectionTitle(context, 'Lançamentos'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.6,
                    ),
                    itemCount: newArrivals.length,
                    itemBuilder: (context, index) {
                      final product = newArrivals[index];
                      return ProductCard(
                        imageUrl: product['imagem_url'],
                        name: product['nome'],
                        price: (product['preco'] as num).toDouble(),
                        onTap: () => _navigateToProduct(context, product['id']),
                      );
                    },
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeroBanner(BuildContext context,
      {required VoidCallback onButtonPressed}) {
    return Container(
      height: 250,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFf39c12).withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Imagem de fundo
            Positioned.fill(
              child: Image.asset(
                'assets/hero_banner.jpg',
                fit: BoxFit.cover,
              ),
            ),
            // Gradiente overlay premium
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFFf39c12).withValues(alpha: 0.4),
                      Colors.black.withValues(alpha: 0.7),
                      Colors.black.withValues(alpha: 0.9),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),
            // Conteúdo
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [
                        Color(0xFFf39c12),
                        Color(0xFFe67e22),
                      ],
                    ).createShader(bounds),
                    child: Text(
                      'BEM-VINDO A LanternFox',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'O melhor lugar para comprar, vender e trocar seu hardware.',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(color: Colors.white.withValues(alpha: 0.9)),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: onButtonPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        elevation: 8,
                        shadowColor:
                            const Color(0xFFf39c12).withValues(alpha: 0.5),
                      ),
                      child: const Text('Ver Produtos'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, {Key? key}) {
    return Padding(
      key: key,
      padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0),
      child: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .headlineSmall
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildDepartmentsCarousel(BuildContext context) {
    final departments = [
      {'name': 'Processador', 'icon': Icons.memory, 'label': 'Processador'},
      {'name': 'Placas-Mãe', 'icon': Icons.dns, 'label': 'Placas-Mãe'},
      {
        'name': 'Placas de Vídeo',
        'icon': Icons.desktop_windows,
        'label': 'Placas de Vídeo'
      },
      {
        'name': 'Memória RAM',
        'icon': Icons.developer_board,
        'label': 'Memória RAM'
      },
      {'name': 'Periféricos', 'icon': Icons.keyboard, 'label': 'Periféricos'},
      {'name': 'Fontes', 'icon': Icons.settings_input_hdmi, 'label': 'Fontes'},
      {'name': 'SSDs', 'icon': Icons.save, 'label': 'SSDs'},
      {'name': 'Notebooks', 'icon': Icons.laptop, 'label': 'Notebooks'},
      {'name': 'Consoles', 'icon': Icons.gamepad, 'label': 'Consoles'},
    ];
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: departments.length,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          final dept = departments[index];
          return _DepartmentCard(
            name: dept['name'] as String,
            icon: dept['icon'] as IconData,
            label: dept['label'] as String,
          );
        },
      ),
    );
  }

  Widget _buildHorizontalProductList(List products) {
    return SizedBox(
      height: 320,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          final product = products[index];
          return SizedBox(
            width: 220,
            child: ProductCard(
              imageUrl: product['imagem_url'],
              name: product['nome'],
              price: (product['preco_promocional'] as num?)?.toDouble() ??
                  (product['preco'] as num).toDouble(),
              onTap: () => _navigateToProduct(context, product['id']),
            ),
          );
        },
      ),
    );
  }

  void _navigateToProduct(BuildContext context, int productId) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ProductDetailPage(productId: productId)),
    );
  }
}

/// Widget de card de departamento com animação de hover
class _DepartmentCard extends StatefulWidget {
  final String name;
  final IconData icon;
  final String label;

  const _DepartmentCard({
    required this.name,
    required this.icon,
    required this.label,
  });

  @override
  State<_DepartmentCard> createState() => _DepartmentCardState();
}

class _DepartmentCardState extends State<_DepartmentCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isHovered = true);
        _controller.forward();
      },
      onTapUp: (_) {
        setState(() => _isHovered = false);
        _controller.reverse();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SearchPage(initialCategory: widget.name),
          ),
        );
      },
      onTapCancel: () {
        setState(() => _isHovered = false);
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: 100,
              margin: const EdgeInsets.only(right: 10),
              child: Card(
                elevation: _isHovered ? 8 : 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: _isHovered
                        ? const Color(0xFFf39c12).withValues(alpha: 0.5)
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: _isHovered
                        ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(0xFFf39c12).withValues(alpha: 0.1),
                              Colors.transparent,
                            ],
                          )
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        widget.icon,
                        color: _isHovered
                            ? const Color(0xFFf39c12)
                            : Theme.of(context).colorScheme.primary,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight:
                              _isHovered ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
