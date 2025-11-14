import 'package:flutter/material.dart';
import '../main.dart'; // Para acessar o supabase

class MyOrdersPage extends StatefulWidget {
  const MyOrdersPage({super.key});

  @override
  State<MyOrdersPage> createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage> {
  late final Future<List<Map<String, dynamic>>> _ordersFuture;
  final String? _userId = supabase.auth.currentUser?.id;

  @override
  void initState() {
    super.initState();
    if (_userId != null) {
      _ordersFuture = _fetchOrders(_userId);
    } else {
      _ordersFuture = Future.error('Usuário não autenticado.');
    }
  }

  Future<List<Map<String, dynamic>>> _fetchOrders(String userId) async {
    try {
      final response = await supabase
          .from('pedidos')
          .select('*, itens_pedido(*, produtos_loja(nome), anuncios_usuarios(titulo))')
          .eq('usuario_id', userId)
          .order('created_at', ascending: false);
      return response;
    } catch (e) {
      throw 'Falha ao carregar pedidos: $e';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meus Pedidos')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Você ainda não fez nenhum pedido.'));
          }

          final orders = snapshot.data!;

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final items = order['itens_pedido'] as List;

              return Card(
                margin: const EdgeInsets.all(16.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Pedido #${order['id']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text('Total: R\$ ${order['valor_total']}'),
                        ],
                      ),
                      const Divider(),
                      // Lista os itens de cada pedido
                      ...items.map((item) {
                        final productName = item['produtos_loja']?['nome'] ?? item['anuncios_usuarios']?['titulo'] ?? 'Item desconhecido';
                        return ListTile(
                          title: Text(productName),
                          subtitle: Text('Qtd: ${item['quantidade']}'),
                          trailing: Text('R\$ ${item['preco_unitario']}'),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}