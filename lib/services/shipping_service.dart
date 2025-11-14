import 'dart:math';

class ShippingService {
  // Simula um cálculo de frete baseado no CEP e peso total
  static Future<double> calculateShipping(
      String zipCode, double totalWeight) async {
    // Simula uma chamada à API dos Correios
    await Future.delayed(const Duration(milliseconds: 800));

    // Remove caracteres não numéricos do CEP
    final cleanZip = zipCode.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanZip.length != 8) {
      throw Exception('CEP inválido');
    }

    // Simula diferentes valores de frete baseado na região do CEP
    // e no peso total dos produtos
    final region = int.parse(cleanZip.substring(0, 1));
    final baseRate = 15.0; // Taxa base do frete
    final weightRate = totalWeight * 0.5; // R$ 0,50 por kg
    final regionMultiplier =
        1.0 + (region / 10.0); // Regiões diferentes têm custos diferentes

    // Adiciona uma pequena variação aleatória para simular diferentes transportadoras
    final variation = Random().nextDouble() * 5;

    final shippingCost = (baseRate + weightRate) * regionMultiplier + variation;
    return double.parse(shippingCost.toStringAsFixed(2));
  }

  // Valida o formato do CEP
  static bool isValidZipCode(String zipCode) {
    final cleanZip = zipCode.replaceAll(RegExp(r'[^0-9]'), '');
    return cleanZip.length == 8;
  }

  // Formata o CEP no padrão 00000-000
  static String formatZipCode(String zipCode) {
    final cleanZip = zipCode.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanZip.length != 8) return zipCode;
    return '${cleanZip.substring(0, 5)}-${cleanZip.substring(5)}';
  }
}
