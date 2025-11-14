import 'package:flutter/foundation.dart';

import '../main.dart'; // Para acessar o helper 'supabase'

// Representa um item no carrinho
class CartItem {
  final String uniqueId;
  final int id;
  final String name;
  final double price;
  final String type;
  final double weight; // Peso em kg
  int quantity;

  CartItem({
    required this.uniqueId,
    required this.id,
    required this.name,
    required this.price,
    required this.type,
    this.weight = 0.5, // Peso padrão de 500g se não especificado
    this.quantity = 1,
  });
}

// A classe que gerencia o estado do carrinho
class CartManager extends ChangeNotifier {
  final List<CartItem> _items = [];
  double? _shippingCost;

  List<CartItem> get items => _items;
  double? get shippingCost => _shippingCost;

  int get totalItems => _items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => _items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
  
  double get totalPrice => subtotal + (_shippingCost ?? 0.0);

  void addItem(Map<String, dynamic> productData, {String type = 'loja'}) {
    final uniqueId = '$type-${productData['id']}';
    final existingIndex = _items.indexWhere((item) => item.uniqueId == uniqueId);

    if (existingIndex >= 0) {
      _items[existingIndex].quantity++;
    } else {
      _items.add(CartItem(
        uniqueId: uniqueId,
        id: productData['id'],
        name: productData['nome'] ?? productData['titulo'],
        price: (productData['preco'] ?? productData['preco_sugerido'] as num).toDouble(),
        type: type,
        weight: (productData['peso'] as num?)?.toDouble() ?? 0.5, // Usa peso do produto se disponível, senão usa 500g
      ));
    }
    // Notifica os 'ouvintes' (widgets) que o estado mudou
    notifyListeners();
  }

  void removeItem(String uniqueId) {
    _items.removeWhere((item) => item.uniqueId == uniqueId);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

    void setShippingCost(double cost) {
      _shippingCost = cost;
      notifyListeners();
    }

    Future<void> checkout() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      throw 'Usuário não está logado.';
    }
    if (_items.isEmpty) {
      throw 'O carrinho está vazio.';
    }
    if (_shippingCost == null) {
      throw 'Frete não calculado.';
    }

    // 1. Calcula o valor total
    final total = totalPrice; // Inclui o frete

    // 2. Insere o pedido principal na tabela 'pedidos' e pega o ID
    final pedidoResponse = await supabase
        .from('pedidos')
        .insert({'usuario_id': userId, 'valor_total': total})
        .select('id')
        .single();
    
    final pedidoId = pedidoResponse['id'];

    // 3. Prepara a lista de itens para inserir
    final itensParaInserir = _items.map((item) => {
      'pedido_id': pedidoId,
      'produto_loja_id': item.type == 'loja' ? item.id : null,
      'anuncio_usuario_id': item.type == 'marketplace' ? item.id : null,
      'quantidade': item.quantity,
      'preco_unitario': item.price,
    }).toList();

    // 4. Insere todos os itens na tabela 'itens_pedido'
    await supabase.from('itens_pedido').insert(itensParaInserir);

    // 5. Atualiza o valor do frete no pedido
    await supabase
        .from('pedidos')
        .update({'valor_frete': _shippingCost})
        .eq('id', pedidoId);

    // 6. Limpa o carrinho local
    clearCart();
    _shippingCost = null;
  }
  void updateQuantity(String uniqueId, int newQuantity) {
    final index = _items.indexWhere((item) => item.uniqueId == uniqueId);
    if (index != -1) {
      if (newQuantity > 0) {
        _items[index].quantity = newQuantity;
      } else {
        // Se a quantidade for 0 ou menos, remove o item
        removeItem(uniqueId);
      }
      notifyListeners();
    }
  }
}

