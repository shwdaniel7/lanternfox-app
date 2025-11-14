# Guia de Contribuição - LanternFox

Obrigado por considerar contribuir para LanternFox! Este documento fornece diretrizes e instruções para contribuir com o projeto.

## Código de Conduta

Ao participar deste projeto, você concorda em manter um ambiente respeitoso e inclusivo para todos.

## Como Contribuir

### Reportando Bugs

Antes de criar um relatório de bug, certifique-se de que:

- Você leu a documentação
- Você pode reproduzir o problema
- O problema não foi já relatado

Para reportar um bug, crie uma issue com as seguintes informações:

```markdown
## Descrição do Bug
[Descrição clara e concisa do que é o bug]

## Para Reproduzir
1. Passo 1
2. Passo 2
3. Passo 3

## Comportamento Esperado
[O que você esperava que acontecesse]

## Comportamento Atual
[O que realmente aconteceu]

## Screenshots
[Se aplicável, adicione screenshots]

## Informações do Dispositivo
- Flutter version: [ex: 3.13.0]
- Dart version: [ex: 3.1.0]
- Sistema Operacional: [ex: iOS 16, Android 13]
- Device: [ex: iPhone 14, Pixel 6]

## Contexto Adicional
[Qualquer outro contexto relevante]
```

### Sugerindo Melhorias

Para sugerir uma melhoria:

1. Verifique se a sugestão já não foi feita
2. Crie uma issue com o título começando com "[FEATURE]"
3. Inclua uma descrição clara da melhoria
4. Explique o caso de uso

```markdown
## [FEATURE] Título da Funcionalidade

### Descrição
[Descrição clara da funcionalidade desejada]

### Caso de Uso
[Por que essa funcionalidade é útil?]

### Possível Implementação
[Se tiver ideias de como implementar, compartilhe]
```

### Pull Requests

1. **Fork o repositório** e crie sua branch a partir de `main`
   ```bash
   git clone https://github.com/seu-usuario/lanternfox.git
   cd lanternfox
   git checkout -b feature/NomeDaFeature
   ```

2. **Instale as dependências**
   ```bash
   flutter pub get
   ```

3. **Faça suas mudanças**
   - Siga o estilo de código do projeto
   - Adicione comentários onde necessário
   - Mantenha as mudanças focadas em um único objetivo

4. **Teste suas mudanças**
   ```bash
   flutter test
   flutter run
   ```

5. **Commit suas mudanças**
   ```bash
   git add .
   git commit -m "Descrição clara da mudança"
   ```

6. **Push para sua branch**
   ```bash
   git push origin feature/NomeDaFeature
   ```

7. **Abra um Pull Request**
   - Preencha o template de PR completamente
   - Descreva a mudança e por que ela é necessária
   - Referencie qualquer issue relacionada (ex: "Fixes #123")
   - Certifique-se de que todos os testes passam

## Padrões de Código

### Dart/Flutter Style Guide

- Siga as [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use `flutter format` para formatar código
- Use `flutter analyze` para analisar problemas de código

### Naming Conventions

```dart
// Classes: PascalCase
class ProductCard {}

// Variables e functions: camelCase
final int productCount = 10;
void showDialog() {}

// Constants: camelCase
const int defaultTimeout = 30;

// Private variables/functions: _camelCase
final String _privateVariable = 'value';
void _privateFunction() {}
```

### Exemplo de Código bem Estruturado

```dart
/// Descrição clara do que a classe faz
class ProductDetailPage extends StatefulWidget {
  final int productId;

  const ProductDetailPage({
    super.key,
    required this.productId,
  });

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late final Future<Map<String, dynamic>> _productFuture;

  @override
  void initState() {
    super.initState();
    _productFuture = _fetchProductDetails();
  }

  // Documentação de métodos complexos
  /// Busca os detalhes do produto no banco de dados
  Future<Map<String, dynamic>> _fetchProductDetails() async {
    try {
      // Implementação
    } catch (e) {
      // Tratamento de erro apropriado
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // implementação
    );
  }
}
```

## Estrutura de Branch

- `main` - Código em produção
- `develop` - Desenvolvimento principal
- `feature/*` - Novas funcionalidades
- `bugfix/*` - Correções de bugs
- `hotfix/*` - Correções urgentes de produção

Exemplo: `feature/shopping-cart`, `bugfix/login-error`, `hotfix/crash-on-startup`

## Checklist para Pull Request

Antes de enviar seu PR, certifique-se de que:

- [ ] Código segue os padrões do projeto
- [ ] Testes foram adicionados/atualizados
- [ ] Documentação foi atualizada
- [ ] Nenhuma dependência não necessária foi adicionada
- [ ] Código foi testado localmente
- [ ] Commit messages são claras e descritivas
- [ ] Nenhuma informação sensível foi incluída (chaves, senhas, etc)

## Processo de Revisão

1. Um mantenedor revisará seu PR
2. Podem ser solicitadas mudanças
3. Uma vez aprovado, seu PR será mergeado

## Dúvidas?

- Abra uma issue com a tag [QUESTION]
- Consulte a documentação em README.md
- Verifique issues fechadas anteriores

## Licença

Ao contribuir, você concorda que suas contribuições serão licenciadas sob a licença MIT do projeto.

---

Obrigado por contribuir para tornar LanternFox melhor! 🎉
