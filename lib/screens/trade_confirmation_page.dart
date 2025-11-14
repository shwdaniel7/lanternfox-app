import 'package:flutter/material.dart';
import '../main.dart'; // Para acessar o supabase

class TradeConfirmationPage extends StatefulWidget {
  final Map<String, dynamic> storeProduct;
  final Map<String, dynamic> userAd;

  const TradeConfirmationPage({
    super.key,
    required this.storeProduct,
    required this.userAd,
  });

  @override
  State<TradeConfirmationPage> createState() => _TradeConfirmationPageState();
}

class _TradeConfirmationPageState extends State<TradeConfirmationPage> {
  bool _isLoading = false;

  Future<void> _confirmTrade() async {
    setState(() => _isLoading = true);

    try {
      final userId = supabase.auth.currentUser!.id;

      // 1. Cria o registro na tabela 'trocas'
      await supabase.from('trocas').insert({
        'usuario_id': userId,
        'produto_loja_id': widget.storeProduct['id'],
        'anuncio_usuario_id': widget.userAd['id'],
        'status': 'pendente', // Status inicial
      });

      // 2. Atualiza o status do anúncio do usuário para 'em_troca' ou 'trocado'
      await supabase
          .from('anuncios_usuarios')
          .update({'status': 'trocado'})
          .eq('id', widget.userAd['id']);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Proposta de troca enviada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        // Volta para a tela inicial (HomePage) após a troca
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao enviar proposta: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final finalPrice = (widget.storeProduct['preco'] as num) - (widget.userAd['preco_sugerido'] as num);

    return Scaffold(
      appBar: AppBar(title: const Text('Confirmar Troca')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Você está oferecendo:', style: TextStyle(fontSize: 16)),
            _buildItemCard(
              imageUrl: widget.userAd['imagem_url'],
              title: widget.userAd['titulo'],
              price: widget.userAd['preco_sugerido'],
            ),
            const SizedBox(height: 24),
            const Icon(Icons.swap_vert, size: 40, color: Colors.orange),
            const SizedBox(height: 24),
            const Text('Para receber:', style: TextStyle(fontSize: 16)),
            _buildItemCard(
              imageUrl: widget.storeProduct['imagem_url'],
              title: widget.storeProduct['nome'],
              price: widget.storeProduct['preco'],
            ),
            const Spacer(), // Empurra o conteúdo para baixo
            const Divider(),
            const SizedBox(height: 16),
            Text(
              'Valor a pagar: R\$ ${finalPrice.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              ElevatedButton(
                onPressed: _confirmTrade,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
                child: const Text('Confirmar Proposta'),
              ),
          ],
        ),
      ),
    );
  }

  // Widget auxiliar para criar os cards de item
  Widget _buildItemCard({required String? imageUrl, required String title, required num price}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Image.network(
              imageUrl ?? 'https://via.placeholder.com/100',
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('Valor: R\$ ${price.toStringAsFixed(2)}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}