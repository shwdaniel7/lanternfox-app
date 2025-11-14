# 🚀 Quick Start Guide - LanternFox

Comece rapidamente com LanternFox em apenas alguns minutos!

## ⚡ Instalação Rápida (5 minutos)

### Pré-requisito
- Flutter 3.0+ instalado
- Conta Supabase (gratuita em supabase.com)

### Passos

**1. Clone e instale**
```bash
git clone https://github.com/seu-usuario/lanternfox.git
cd lanternfox
flutter pub get
```

**2. Configure Supabase**

Abra `lib/main.dart` e substitua:
```dart
const String supabaseUrl = 'YOUR_SUPABASE_URL';
const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
```

**3. Configure Banco de Dados**

No Supabase Dashboard, execute os scripts SQL em `SETUP.md`

**4. Execute**
```bash
flutter run
```

Done! 🎉

## 📱 Teste Rápido

Após iniciar, você pode:

1. **Criar uma conta**: Clique em "Sign Up"
2. **Explorar a loja**: Veja produtos por departamento
3. **Adicionar ao carrinho**: Clique em um produto
4. **Ir ao checkout**: Calcule frete com CEP: `01310100`
5. **Simular pagamento**: Clique em "Pagar"

## 📁 Arquivos Importantes

| Arquivo | Função |
|---------|--------|
| `lib/main.dart` | Configuração do Supabase |
| `lib/screens/` | Todas as telas |
| `lib/managers/cart_manager.dart` | Gerenciador do carrinho |
| `lib/services/shipping_service.dart` | Cálculo de frete |
| `pubspec.yaml` | Dependências |

## 🔧 Troubleshooting Rápido

| Problema | Solução |
|----------|---------|
| "Bad state: no element" | Execute os scripts SQL do Supabase |
| "Connection refused" | Verifique suas credenciais do Supabase |
| "Plugin not found" | Execute `flutter clean && flutter pub get` |
| "Build failed" | Execute `flutter clean` e `flutter pub upgrade` |

## 💡 Dicas

- Use `flutter run -v` para debug detalhado
- Use `flutter format .` para formatar código
- Use `flutter analyze` para verificar problemas
- Use `flutter test` para rodar testes

## 📚 Aprenda Mais

- [README.md](README.md) - Documentação completa
- [SETUP.md](SETUP.md) - Guia detalhado
- [ARCHITECTURE.md](ARCHITECTURE.md) - Estrutura do projeto
- [CONTRIBUTING.md](CONTRIBUTING.md) - Como contribuir

## 🆘 Precisa de Ajuda?

1. Verifique [README.md](README.md) → Troubleshooting
2. Abra uma [Issue](https://github.com/seu-usuario/lanternfox/issues)
3. Leia o código comentado em `lib/`

## 🎯 Próximos Passos

- [ ] Explorar o código em `lib/screens/`
- [ ] Entender a arquitetura em [ARCHITECTURE.md](ARCHITECTURE.md)
- [ ] Adicionar um teste em `test/`
- [ ] Fazer sua primeira contribuição!

---

**Versão**: 1.0.0  
**Atualizado**: Novembro 2025

Aproveite! 🚀
