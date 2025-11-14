# LanternFox - Marketplace de Hardware

Um aplicativo Flutter moderno e intuitivo para compra, venda e troca de componentes de hardware. LanternFox conecta usuários em um marketplace dinâmico com suporte para múltiplos departamentos, carrinho de compras e sistema de checkout completo.

## 📱 Recursos

- **Marketplace Integrado**: Navegue e compre produtos de hardware de vendedores
- **Sistema de Anúncios**: Venda seus próprios componentes de hardware
- **Múltiplos Departamentos**: Processador, Placas de Vídeo, Memória RAM, Periféricos, Fontes, SSDs, Notebooks e Consoles
- **Carrinho de Compras**: Gerencie itens com facilidade
- **Cálculo de Frete**: Cálculo automático de frete baseado no CEP
- **Sistema de Checkout**: Pagamento simulado (Cartão de Crédito e Pix)
- **Perfil de Usuário**: Gerenciamento de perfil e histórico de pedidos
- **Autenticação**: Login seguro com Supabase
- **Busca Avançada**: Busque produtos e anúncios por categoria

## 🛠 Requisitos

- Flutter 3.0 ou superior
- Dart 3.0 ou superior
- Uma conta Supabase (para banco de dados)

## 📦 Instalação

### 1. Clonar o Repositório

```bash
git clone https://github.com/seu-usuario/lanternfox.git
cd lanternfox
```

### 2. Instalar Dependências

```bash
flutter pub get
```

### 3. Configurar Supabase

1. Crie uma conta em [supabase.com](https://supabase.com)
2. Crie um novo projeto
3. Copie sua URL e chave anônima
4. Configure em `lib/main.dart`:

```dart
const String supabaseUrl = 'YOUR_SUPABASE_URL';
const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
```

### 4. Configurar Banco de Dados

Você precisa criar as seguintes tabelas no Supabase:

#### Tabela `usuarios` (profiles)
```sql
create table profiles (
  id uuid references auth.users on delete cascade,
  full_name text,
  avatar_url text,
  created_at timestamp default now(),
  primary key (id)
);
```

#### Tabela `produtos_loja`
```sql
create table produtos_loja (
  id bigint primary key generated always as identity,
  nome text not null,
  descricao text,
  categoria text not null,
  preco decimal(10,2) not null,
  preco_promocional decimal(10,2),
  em_promocao boolean default false,
  estoque integer default 0,
  imagem_url text,
  peso decimal(8,3),
  created_at timestamp default now()
);
```

#### Tabela `anuncios_usuarios`
```sql
create table anuncios_usuarios (
  id bigint primary key generated always as identity,
  usuario_id uuid references profiles on delete cascade,
  titulo text not null,
  descricao text,
  categoria text not null,
  preco_sugerido decimal(10,2) not null,
  imagem_url text,
  status text default 'disponivel',
  created_at timestamp default now()
);
```

#### Tabela `pedidos`
```sql
create table pedidos (
  id bigint primary key generated always as identity,
  usuario_id uuid references profiles on delete cascade,
  valor_total decimal(10,2) not null,
  valor_frete decimal(10,2),
  status text default 'pendente',
  created_at timestamp default now()
);
```

#### Tabela `itens_pedido`
```sql
create table itens_pedido (
  id bigint primary key generated always as identity,
  pedido_id bigint references pedidos on delete cascade,
  produto_loja_id bigint references produtos_loja,
  anuncio_usuario_id bigint references anuncios_usuarios,
  quantidade integer not null,
  preco_unitario decimal(10,2) not null
);
```

### 5. Executar o Aplicativo

```bash
flutter run
```

## 📁 Estrutura do Projeto

```
lib/
├── main.dart                    # Arquivo principal
├── screens/                     # Telas do aplicativo
│   ├── home_page.dart          # Navegação principal
│   ├── store_page.dart         # Loja de produtos
│   ├── marketplace_page.dart   # Marketplace de usuários
│   ├── product_detail_page.dart
│   ├── checkout_page.dart      # Checkout com cálculo de frete
│   ├── cart_page.dart          # Carrinho de compras
│   ├── profile_page.dart       # Perfil do usuário
│   ├── search_page.dart        # Busca e filtros
│   ├── create_ad_page.dart     # Criar anúncio
│   ├── my_ads_page.dart        # Meus anúncios
│   └── auth_page.dart          # Autenticação
├── widgets/                     # Widgets reutilizáveis
│   ├── product_card.dart
│   └── gradient_background.dart
├── managers/                    # Gerenciadores de estado
│   └── cart_manager.dart       # Provider para carrinho
├── services/                    # Serviços
│   └── shipping_service.dart   # Cálculo de frete
└── assets/                     # Imagens e recursos
```

## 🚀 Como Usar

### Como Comprador

1. **Navegar na Loja**: Explore produtos por departamento
2. **Buscar Produtos**: Use a barra de busca para encontrar itens específicos
3. **Adicionar ao Carrinho**: Clique em um produto e adicione ao carrinho
4. **Ir ao Checkout**: Revise seu carrinho e prossiga para o checkout
5. **Calcular Frete**: Digite seu CEP (8 dígitos) para calcular o frete
6. **Pagar**: Escolha seu método de pagamento (Cartão ou Pix)

### Como Vendedor

1. **Criar Anúncio**: Vá para "Meus Anúncios" e clique em "Novo Anúncio"
2. **Preencher Detalhes**: 
   - Título do produto
   - Descrição detalhada
   - Categoria (Processador, Placas de Vídeo, etc.)
   - Preço sugerido
   - Imagem do produto
3. **Publicar**: Clique em "Publicar" para que seu anúncio fique ativo

### Busca Avançada

- Digite palavras-chave para buscar produtos
- Clique nos botões de departamento para filtrar por categoria
- Combine busca de texto com filtros de categoria

## 🔧 Configurações

### Categorias de Produtos

- Processador
- Placas de Vídeo
- Memória RAM
- Periféricos
- Fontes
- SSDs
- Notebooks
- Consoles

### Cálculo de Frete

O frete é calculado automaticamente baseado em:
- **Peso Total do Pedido**: R$ 0,50 por kg
- **Taxa Base**: R$ 15,00
- **Região do CEP**: Multiplicador por região
- **Prazo Estimado**: 5-8 dias úteis

## 📦 Dependências Principais

```yaml
provider: ^6.0.0              # Gerenciamento de estado
supabase_flutter: ^1.10.0     # Backend e banco de dados
google_fonts: ^4.0.0          # Fontes customizadas
```

Veja `pubspec.yaml` para a lista completa de dependências.

## 🔐 Segurança

- Autenticação segura via Supabase Auth
- Senhas com hash criptográfico
- Row Level Security (RLS) no banco de dados
- Validação de entrada em todos os formulários
- HTTPS para todas as comunicações

## ⚙️ Troubleshooting

### "CEP inválido"
- Certifique-se de digitar 8 dígitos
- Apenas números são aceitos

### "Nenhum resultado encontrado"
- Verifique a ortografia da busca
- Tente com palavras-chave mais genéricas
- Certifique-se de que existem produtos naquela categoria

### Erro ao conectar ao Supabase
- Verifique as credenciais em `lib/main.dart`
- Certifique-se de que as tabelas existem no banco de dados
- Verifique sua conexão com a internet

## 🐛 Problemas Conhecidos

- O cálculo de frete é simulado (não conectado aos Correios reais)
- Métodos de pagamento são simulados (não processa pagamentos reais)
- Imagens são hospedadas em URLs externas

## 🤝 Contribuição

Contribuições são bem-vindas! Por favor:

1. Faça um fork do repositório
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

Consulte [CONTRIBUTING.md](CONTRIBUTING.md) para mais detalhes.

## 📄 Licença

Este projeto está sob a licença MIT. Veja [LICENSE](LICENSE) para detalhes.

## 📞 Suporte

Para reportar bugs ou sugerir features, abra uma [issue](https://github.com/seu-usuario/lanternfox/issues).

## 👨‍💻 Desenvolvido com

- [Flutter](https://flutter.dev/)
- [Supabase](https://supabase.com/)
- [Dart](https://dart.dev/)

---

**Versão Atual**: 1.0.0  
**Última Atualização**: Novembro 2025
