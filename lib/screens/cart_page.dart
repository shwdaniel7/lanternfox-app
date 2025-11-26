import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../managers/cart_manager.dart';
import 'checkout_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<CartManager>(
      builder: (context, cart, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Meu Carrinho'),
            actions: [
              if (cart.items.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.delete_sweep_outlined),
                  tooltip: 'Limpar Carrinho',
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Limpar Carrinho'),
                        content: const Text(
                            'Tem certeza que deseja remover todos os itens?'),
                        actions: [
                          TextButton(
                            child: const Text('Cancelar'),
                            onPressed: () => Navigator.of(ctx).pop(),
                          ),
                          TextButton(
                            child: const Text('Sim'),
                            onPressed: () {
                              Provider.of<CartManager>(context, listen: false)
                                  .clearCart();
                              Navigator.of(ctx).pop();
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
          body: cart.items.isEmpty
              ? const Center(child: Text('Seu carrinho está vazio.'))
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: cart.items.length,
                        itemBuilder: (context, index) {
                          final item = cart.items[index];
                          return ListTile(
                            title: Text(item.name),
                            subtitle: Text('Qtd: ${item.quantity}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  tooltip: 'Diminuir quantidade',
                                  icon: const Icon(Icons.remove_circle_outline),
                                  onPressed: () {
                                    // Agora esta função existe
                                    cart.updateQuantity(
                                        item.uniqueId, item.quantity - 1);
                                  },
                                ),
                                Text(item.quantity.toString()),
                                IconButton(
                                  tooltip: 'Aumentar quantidade',
                                  icon: const Icon(Icons.add_circle_outline),
                                  onPressed: () {
                                    // E esta também
                                    cart.updateQuantity(
                                        item.uniqueId, item.quantity + 1);
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Total: R\$ ${cart.totalPrice.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: (cart.items.isEmpty)
                                ? null
                                : () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const CheckoutPage()),
                                    );
                                  },
                            child: const Text('Ir para o Checkout'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}
