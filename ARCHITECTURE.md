# Arquitetura do LanternFox

## 🏗️ Visão Geral da Arquitetura

O LanternFox segue uma arquitetura camadas com Flutter e Supabase, utilizando Provider para gerenciamento de estado.

```
┌─────────────────────────────────────────┐
│     Presentation Layer (Screens)        │
│  (Telas, Widgets, UI Components)        │
└──────────────────┬──────────────────────┘
                   │
┌──────────────────▼──────────────────────┐
│  State Management Layer (Provider)      │
│  (CartManager, Controllers)             │
└──────────────────┬──────────────────────┘
                   │
┌──────────────────▼──────────────────────┐
│   Business Logic Layer (Services)       │
│  (ShippingService, Validators)          │
└──────────────────┬──────────────────────┘
                   │
┌──────────────────▼──────────────────────┐
│   Data Layer (Backend & Cache)          │
│  (Supabase, Local Storage)              │
└─────────────────────────────────────────┘
```

## 📁 Estrutura de Pastas

```
lib/
├── main.dart                      # Ponto de entrada da aplicação
│
├── screens/                       # Camada de Apresentação
│   ├── home_page.dart            # Navegação principal
│   ├── store_page.dart           # Loja de produtos
│   ├── marketplace_page.dart     # Marketplace de usuários
│   ├── product_detail_page.dart  # Detalhes do produto
│   ├── checkout_page.dart        # Checkout e pagamento
│   ├── cart_page.dart            # Carrinho de compras
│   ├── profile_page.dart         # Perfil do usuário
│   ├── search_page.dart          # Busca e filtros
│   ├── create_ad_page.dart       # Criar anúncio
│   ├── my_ads_page.dart          # Meus anúncios
│   ├── my_orders_page.dart       # Meus pedidos
│   ├── auth_page.dart            # Autenticação
│   ├── ad_detail_page.dart       # Detalhes do anúncio
│   ├── trade_confirmation_page.dart # Confirmação de troca
│   └── ...
│
├── widgets/                       # Componentes Reutilizáveis
│   ├── product_card.dart         # Card de produto
│   ├── gradient_background.dart  # Fundo com gradiente
│   └── ...
│
├── managers/                      # Camada de Gerenciamento de Estado
│   └── cart_manager.dart         # Provider para carrinho (ChangeNotifier)
│       ├── CartItem class
│       ├── addItem()
│       ├── removeItem()
│       ├── updateQuantity()
│       ├── setShippingCost()
│       └── checkout()
│
├── services/                      # Camada de Lógica de Negócio
│   └── shipping_service.dart     # Serviço de cálculo de frete
│       ├── calculateShipping()
│       ├── isValidZipCode()
│       └── formatZipCode()
│
└── assets/                        # Recursos da Aplicação
    ├── images/
    ├── icons/
    └── fonts/
```

## 🔄 Fluxo de Dados

### 1. Compra de Produto

```
Product Screen
     │
     ▼
Product Detail Page (mostra detalhes)
     │
     ▼ (adiciona ao carrinho)
Cart Manager (Provider)
     │
     ├─► Armazena localmente
     └─► Notifica listeners
     │
     ▼ (navega para checkout)
Checkout Page
     │
     ├─► Calcula frete (ShippingService)
     │   └─► Valida CEP
     │   └─► Calcula valor
     │
     ├─► Confirma pagamento
     │   └─► Chama checkout() no CartManager
     │
     ▼
Cart Manager → Supabase
     │
     ├─► Cria pedido em 'pedidos'
     ├─► Cria itens em 'itens_pedido'
     ├─► Salva frete
     └─► Limpa carrinho local
     │
     ▼
Order Success Page (sucesso)
```

### 2. Venda de Produto (Anúncio)

```
Novo Anúncio
     │
     ▼
Create Ad Page
     │
     ├─► Preenche dados
     ├─► Upload de imagem
     │
     ▼ (publica)
Cart Manager → Supabase
     │
     └─► INSERT em 'anuncios_usuarios'
     │
     ▼
My Ads Page (mostra anúncios)
```

### 3. Busca e Filtros

```
Search Page (inicializa)
     │
     ├─► initialSearchTerm? → busca por texto
     │   └─► ilike('nome', termo)
     │
     ├─► initialCategory? → filtra por categoria
     │   └─► eq('categoria', categoria)
     │
     ▼ (executa)
Supabase Query
     │
     ├─► produtos_loja (loja)
     ├─► anuncios_usuarios (marketplace)
     │
     ▼
Mostra resultados combinados
```

## 🔐 Modelo de Segurança

### Row Level Security (RLS)

```sql
-- Profiles
SELECT: Público
INSERT/UPDATE: Apenas o próprio usuário

-- Produtos Loja
SELECT: Público
INSERT/UPDATE/DELETE: Admin only

-- Anúncios Usuários
SELECT: Público
INSERT: Próprio usuário
UPDATE/DELETE: Próprio usuário

-- Pedidos
SELECT: Apenas pedidos do próprio usuário
INSERT: Próprio usuário

-- Itens Pedido
SELECT: Apenas itens de pedidos do próprio usuário
```

## 🎯 Padrões de Design

### 1. Provider Pattern (State Management)

```dart
// Usando Provider para gerenciar estado
final cart = context.watch<CartManager>();
cart.addItem(product);

// Ou sem escutar mudanças
final cart = context.read<CartManager>();
cart.addItem(product);
```

### 2. Stateful Widgets

Usado para telas que precisam manter estado local:
- Controladores de texto (TextField)
- Seleção de abas
- Carregamento assíncrono

### 3. FutureBuilder

Para lidar com operações assíncronas:
```dart
FutureBuilder<List<Product>>(
  future: _fetchProducts(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return Loading();
    }
    if (snapshot.hasError) {
      return Error();
    }
    return Content(snapshot.data);
  },
)
```

## 📊 Modelo de Dados

### Relações entre Tabelas

```
profiles (usuários)
    │
    ├─ anuncios_usuarios (um para muitos)
    │   └─ itens_pedido (um para muitos)
    │
    └─ pedidos (um para muitos)
        └─ itens_pedido (um para muitos)

produtos_loja (loja central)
    └─ itens_pedido (um para muitos)
```

### Tipos de Dados

| Coluna | Tipo | Descrição |
|--------|------|-----------|
| id | UUID/BigInt | Identificador único |
| usuario_id | UUID | Referência ao perfil |
| categoria | String | Categoria do produto |
| preco | Decimal(10,2) | Preço com 2 casas decimais |
| peso | Decimal(8,3) | Peso em kg |
| created_at | Timestamp | Data de criação |

## 🚀 Performance

### Otimizações Implementadas

1. **Lazy Loading**: Carregar dados sob demanda
2. **Caching**: Reutilizar dados já carregados
3. **Image Caching**: Supabase Storage com CDN
4. **Provider Caching**: Reutilizar instâncias

### Boas Práticas

- Use `listen: false` quando não precisa de rebuild
- Use `shrinkWrap: true` em listas aninhadas
- Implemente `SingleChildScrollView` para overflow
- Use `const` para widgets imutáveis

## 🔧 Extensibilidade

### Como Adicionar Nova Feature

1. **Criar a Tabela no Supabase**
   ```sql
   CREATE TABLE nova_tabela (...)
   ```

2. **Criar Model/Entity**
   ```dart
   class NovaEntidade {}
   ```

3. **Criar Service** (se necessário)
   ```dart
   class NovaService {
     Future<List<NovaEntidade>> fetch() {}
   }
   ```

4. **Criar Screen**
   ```dart
   class NovaScreen extends StatefulWidget {}
   ```

5. **Integrar com Provider** (se necessário)
   ```dart
   class NovaManager extends ChangeNotifier {}
   ```

## 📈 Escalabilidade

### Estratégia de Crescimento

- **Pequeno**: Provider é suficiente
- **Médio**: Considere GetX ou Riverpod
- **Grande**: Implemente Clean Architecture

### Recursos Futuros

- Adicionar testes unitários
- Implementar CI/CD
- Setup de Analytics
- Implementar Offline Mode

---

**Última Atualização**: Novembro 2025
