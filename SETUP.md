# Guia Completo de Configuração - LanternFox

Este guia fornece instruções detalhadas para configurar o projeto LanternFox em seu ambiente local.

## 📋 Pré-requisitos

- **Flutter**: 3.0 ou superior
- **Dart**: 3.0 ou superior
- **Git**: Qualquer versão recente
- **Supabase Account**: Gratuito em [supabase.com](https://supabase.com)
- **Android Studio** (para Android) ou **Xcode** (para iOS) - opcional
- **Visual Studio Code** ou qualquer editor de texto

## 🚀 Início Rápido

### Passo 1: Verificar Instalação do Flutter

```bash
flutter --version
dart --version
```

Se não tiver Flutter instalado, siga [este guia](https://flutter.dev/docs/get-started/install).

### Passo 2: Clonar o Repositório

```bash
git clone https://github.com/seu-usuario/lanternfox.git
cd lanternfox
```

### Passo 3: Instalar Dependências

```bash
flutter pub get
```

### Passo 4: Configurar Supabase

#### 4.1 Criar Projeto no Supabase

1. Acesse [supabase.com](https://supabase.com)
2. Clique em "Start your project"
3. Faça login ou crie uma conta
4. Clique em "New Project"
5. Preencha os dados:
   - Project name: "LanternFox" (ou seu nome)
   - Database password: Defina uma senha forte
   - Region: Escolha a mais próxima (ex: São Paulo para Brasil)
6. Clique em "Create new project" e aguarde

#### 4.2 Obter Credenciais

1. No painel do Supabase, vá para "Settings" → "API"
2. Copie:
   - **Project URL**: `https://xxxx.supabase.co`
   - **Anon Key**: A chave pública (anon, public)

#### 4.3 Configurar no Projeto

1. Abra `lib/main.dart`
2. Localize a seção de inicialização do Supabase:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_SUPABASE_ANON_KEY',
  );
  
  runApp(const MyApp());
}
```

3. Substitua `YOUR_SUPABASE_URL` e `YOUR_SUPABASE_ANON_KEY` pelas suas credenciais

### Passo 5: Criar Tabelas no Banco de Dados

No painel do Supabase, vá para "SQL Editor" e execute os seguintes scripts:

#### Script 1: Tabela de Profiles (Usuários)

```sql
create table if not exists profiles (
  id uuid references auth.users on delete cascade,
  full_name text,
  avatar_url text,
  created_at timestamp default now(),
  primary key (id)
);

alter table profiles enable row level security;

create policy "Public profiles are viewable by everyone."
  on profiles for select
  using ( true );

create policy "Users can insert their own profile."
  on profiles for insert
  with check ( auth.uid() = id );

create policy "Users can update own profile."
  on profiles for update
  using ( auth.uid() = id );
```

#### Script 2: Tabela de Produtos da Loja

```sql
create table if not exists produtos_loja (
  id bigint primary key generated always as identity,
  nome text not null,
  descricao text,
  categoria text not null,
  preco decimal(10,2) not null,
  preco_promocional decimal(10,2),
  em_promocao boolean default false,
  estoque integer default 0,
  imagem_url text,
  peso decimal(8,3) default 0.5,
  created_at timestamp default now()
);

alter table produtos_loja enable row level security;

create policy "Public products are viewable by everyone."
  on produtos_loja for select
  using ( true );
```

#### Script 3: Tabela de Anúncios de Usuários

```sql
create table if not exists anuncios_usuarios (
  id bigint primary key generated always as identity,
  usuario_id uuid references profiles on delete cascade not null,
  titulo text not null,
  descricao text,
  categoria text not null,
  preco_sugerido decimal(10,2) not null,
  imagem_url text,
  status text default 'disponivel',
  created_at timestamp default now()
);

alter table anuncios_usuarios enable row level security;

create policy "Public ads are viewable by everyone."
  on anuncios_usuarios for select
  using ( true );

create policy "Users can create their own ads."
  on anuncios_usuarios for insert
  with check ( auth.uid() = usuario_id );

create policy "Users can update own ads."
  on anuncios_usuarios for update
  using ( auth.uid() = usuario_id );
```

#### Script 4: Tabela de Pedidos

```sql
create table if not exists pedidos (
  id bigint primary key generated always as identity,
  usuario_id uuid references profiles on delete cascade not null,
  valor_total decimal(10,2) not null,
  valor_frete decimal(10,2),
  status text default 'pendente',
  created_at timestamp default now()
);

alter table pedidos enable row level security;

create policy "Users can view their own orders."
  on pedidos for select
  using ( auth.uid() = usuario_id );

create policy "Users can create orders."
  on pedidos for insert
  with check ( auth.uid() = usuario_id );
```

#### Script 5: Tabela de Itens do Pedido

```sql
create table if not exists itens_pedido (
  id bigint primary key generated always as identity,
  pedido_id bigint references pedidos on delete cascade not null,
  produto_loja_id bigint references produtos_loja,
  anuncio_usuario_id bigint references anuncios_usuarios,
  quantidade integer not null,
  preco_unitario decimal(10,2) not null
);

alter table itens_pedido enable row level security;

create policy "Users can view order items from their orders."
  on itens_pedido for select
  using ( 
    (select usuario_id from pedidos where id = pedido_id) = auth.uid()
  );
```

### Passo 6: Executar o Aplicativo

```bash
flutter run
```

Ou escolha um dispositivo/emulador específico:

```bash
flutter devices                    # List available devices
flutter run -d <device-id>        # Run on specific device
```

## 🔧 Configuração Avançada

### Variáveis de Ambiente

Para manter suas credenciais seguras, crie um arquivo `.env`:

```bash
# .env
SUPABASE_URL=https://xxxx.supabase.co
SUPABASE_ANON_KEY=your_anon_key_here
```

Depois use um package como `flutter_dotenv` para carregar essas variáveis.

### Build para Produção

#### Android

```bash
flutter build apk --release
flutter build appbundle --release
```

#### iOS

```bash
flutter build ios --release
```

## 🧪 Testes

### Executar Todos os Testes

```bash
flutter test
```

### Executar Teste Específico

```bash
flutter test test/widget_test.dart
```

## 📊 Estrutura de Dados

### Fluxo de Dados

```
User Authentication (Supabase Auth)
         ↓
    Profiles (usuários)
         ↓
    ├─ Produtos da Loja
    ├─ Anúncios de Usuários
    └─ Pedidos
         ├─ Itens do Pedido
         └─ Cálculo de Frete
```

## 🔐 Segurança

### Checklist de Segurança

- [ ] Nunca comita credenciais de banco de dados
- [ ] Use RLS (Row Level Security) em todas as tabelas
- [ ] Valide entrada em todos os formulários
- [ ] Use HTTPS para todas as comunicações
- [ ] Implemente rate limiting em APIs
- [ ] Mantenha dependências atualizadas

### Variáveis Sensíveis

Sempre use variáveis de ambiente para dados sensíveis:

```dart
// ❌ NÃO FAÇA ISSO
const String apiKey = 'sk_live_123456';

// ✅ FAÇA ISSO
const String apiKey = String.fromEnvironment('API_KEY');
```

## 📱 Dispositivos de Teste

### Emulador Android

```bash
flutter emulators
flutter emulators launch <emulator-id>
flutter run
```

### Simulator iOS

```bash
open -a Simulator
flutter run
```

## 🐛 Troubleshooting

### Erro: "Could not find the plugin"

Solução:
```bash
flutter clean
flutter pub get
flutter run
```

### Erro: "Bad state: no element"

Solução: Certifique-se de que as tabelas foram criadas no Supabase

### Erro de Conexão com Supabase

Solução:
- Verifique suas credenciais
- Verifique sua conexão com a internet
- Certifique-se de que o projeto está ativo no Supabase

### Erro ao Fazer Build

Solução:
```bash
flutter clean
flutter pub get
flutter pub upgrade
flutter run
```

## 📚 Recursos Úteis

- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Documentation](https://dart.dev/guides)
- [Supabase Documentation](https://supabase.com/docs)
- [Provider Package](https://pub.dev/packages/provider)

## 🚀 Próximos Passos

1. Configure o seu IDE/Editor favorito
2. Leia a documentação em README.md
3. Explore a estrutura do projeto
4. Execute os testes
5. Comece a desenvolver!

## 💬 Precisa de Ajuda?

- Abra uma [issue](https://github.com/seu-usuario/lanternfox/issues)
- Consulte [CONTRIBUTING.md](CONTRIBUTING.md)
- Verifique exemplos em `lib/`

---

**Última atualização**: Novembro 2025
