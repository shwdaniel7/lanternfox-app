import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../managers/cart_manager.dart';
import '../services/shipping_service.dart';
import 'home_page.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  bool _isLoading = false;
  bool _isCalculatingShipping = false;
  late final TextEditingController _zipController;
  String? _shippingError;

  @override
  void initState() {
    super.initState();
    _zipController = TextEditingController();
  }

  @override
  void dispose() {
    _zipController.dispose();
    super.dispose();
  }

  // Calcula o frete baseado no CEP informado
  Future<void> _calculateShipping() async {
    final zipCode = _zipController.text;
    if (zipCode.isEmpty) {
      setState(() {
        _shippingError = 'Digite um CEP';
      });
      return;
    }
    
    if (!ShippingService.isValidZipCode(zipCode)) {
      setState(() {
        _shippingError = 'CEP inválido';
      });
      return;
    }

    setState(() {
      _isCalculatingShipping = true;
      _shippingError = null;
    });

    try {
      final cart = Provider.of<CartManager>(context, listen: false);
      final totalWeight = cart.items.fold(0.0, (sum, item) => sum + (item.weight * item.quantity));
      
      final cost = await ShippingService.calculateShipping(
        _zipController.text,
        totalWeight,
      );

      if (mounted) {
        cart.setShippingCost(cost);
        setState(() {
          _isCalculatingShipping = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _shippingError = e.toString();
          _isCalculatingShipping = false;
        });
      }
    }
  }

  // Função que simula o pagamento e finaliza o pedido
  Future<void> _processPayment() async {
    if (context.read<CartManager>().shippingCost == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, calcule o frete antes de continuar'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    final cart = Provider.of<CartManager>(context, listen: false);

    try {
      // Simula um pequeno delay de processamento de pagamento
      await Future.delayed(const Duration(seconds: 2));

      // Chama a função de checkout que salva no Supabase
      await cart.checkout();

      if (mounted) {
        // Mostra uma tela de sucesso
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const OrderSuccessPage()),
          (route) => false, // Remove todas as telas anteriores
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao processar pedido: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartManager>();

    return Scaffold(
      appBar: AppBar(title: const Text('Finalizar Compra')),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Processando seu pagamento...'),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Card de Frete
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Calcular Frete', style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _zipController,
                                decoration: InputDecoration(
                                  labelText: 'CEP',
                                  hintText: '00000-000',
                                  errorText: _shippingError,
                                  border: const OutlineInputBorder(),
                                  prefixIcon: const Icon(Icons.location_on_outlined),
                                  filled: true,
                                  fillColor: Theme.of(context).colorScheme.surface,
                                ),
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(8),
                                  TextInputFormatter.withFunction((oldValue, newValue) {
                                    // Formata o CEP como 00000-000
                                    if (newValue.text.length <= 8) {
                                      return newValue;
                                    }
                                    return oldValue;
                                  }),
                                ],
                                onChanged: (value) {
                                  final cleanValue = value.replaceAll(RegExp(r'[^0-9]'), '');
                                  if (cleanValue.length == 8) {
                                    _calculateShipping();
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: _isCalculatingShipping ? null : _calculateShipping,
                              child: _isCalculatingShipping
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Text('Calcular'),
                            ),
                          ],
                        ),
                        if (cart.shippingCost != null) ...[
                          const SizedBox(height: 16),
                          Text(
                            'Frete: R\$ ${cart.shippingCost!.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'Prazo de entrega: 5-8 dias úteis',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Card de Resumo
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Resumo do Pedido', style: Theme.of(context).textTheme.titleLarge),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total de Itens:'),
                            Text(cart.totalItems.toString()),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Valor Total:'),
                            Text(
                              'R\$ ${cart.totalPrice.toStringAsFixed(2)}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text('Escolha o Método de Pagamento', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                // Botão de Cartão de Crédito (Simulado)
                ElevatedButton.icon(
                  icon: const Icon(Icons.credit_card),
                  label: const Text('Pagar com Cartão de Crédito'),
                  onPressed: _processPayment,
                ),
                const SizedBox(height: 12),
                // Botão de Pix (Simulado)
                OutlinedButton.icon(
                  icon: const Icon(Icons.qr_code),
                  label: const Text('Pagar com Pix'),
                  onPressed: _processPayment,
                ),
              ],
            ),
    );
  }
}

// --- Tela de Sucesso do Pedido ---
class OrderSuccessPage extends StatelessWidget {
  const OrderSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.green, size: 100),
              const SizedBox(height: 24),
              Text(
                'Pedido Realizado com Sucesso!',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Obrigado por comprar na LanternFox. Você pode acompanhar seu pedido na seção "Meus Pedidos".',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  // Volta para a tela inicial (HomePage)
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const HomePage()),
                  );
                },
                child: const Text('Voltar para a Loja'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}