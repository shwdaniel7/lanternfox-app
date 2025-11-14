# Changelog

Todas as mudanças notáveis do projeto LanternFox serão documentadas neste arquivo.

O formato é baseado em [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
e este projeto segue [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-11-14

### Adicionado
- Sistema de autenticação com Supabase
- Marketplace integrado para compra e venda de hardware
- Suporte a múltiplos departamentos (Processador, Placas de Vídeo, Memória RAM, etc)
- Carrinho de compras funcional com Provider para gerenciamento de estado
- Sistema de checkout com cálculo de frete automático
- Busca avançada com filtros por categoria
- Criação e gerenciamento de anúncios pelos usuários
- Sistema de perfil de usuário
- Histórico de pedidos
- Interface responsiva para múltiplos dispositivos

### Corrigido
- Filtros de categoria não funcionavam corretamente (botões de departamentos)
- Sobreposição de botões com barra de navegação do sistema
- Erros de type 'null' no checkout
- Validação de CEP

### Conhecimento Técnico
- Arquitetura com Provider para gerenciamento de estado
- Integração com Supabase para backend
- Implementação de serviços customizados (ShippingService)
- Design responsivo com widgets Flutter

## [0.9.0] - 2025-11-08

### Em Desenvolvimento
- Métodos de pagamento reais
- Integração com API dos Correios para cálculo de frete real
- Sistema de avaliações e comentários
- Chat entre vendedor e comprador
- Notificações push

## [Planejado]

### Futuras Funcionalidades
- [ ] Integração com múltiplas transportadoras
- [ ] Sistema de avaliações de produtos
- [ ] Filtros avançados de busca
- [ ] Modo offline
- [ ] Suporte a múltiplos idiomas
- [ ] Dark mode
- [ ] Wishlist de produtos
- [ ] Compartilhamento de produtos via redes sociais
- [ ] AR para visualização de produtos
- [ ] Sistema de pontos/recompensas

---

### Convenções de Commit

Os commits deste projeto seguem a convenção Conventional Commits:

```
<tipo>[escopo opcional]: <descrição>

<corpo opcional>

<rodapé opcional>
```

#### Tipos:
- `feat`: Uma nova funcionalidade
- `fix`: Uma correção de bug
- `docs`: Mudanças apenas em documentação
- `style`: Mudanças que não afetam o significado do código (espaçamento, formatação)
- `refactor`: Uma mudança de código que não corrige bug ou adiciona feature
- `perf`: Uma mudança de código que melhora performance
- `test`: Adição de testes ou correção de testes existentes
- `chore`: Mudanças em dependências, ferramentas, etc

#### Exemplos:
```
feat(checkout): adicionar cálculo de frete

fix(busca): corrigir filtro de categoria não funcionando

docs: atualizar README com instruções de instalação

refactor(cart): simplificar lógica de cálculo de total
```

---

## Versioning

Este projeto usa [Semantic Versioning](https://semver.org/):

- **MAJOR**: Mudanças incompatíveis na API
- **MINOR**: Novas funcionalidades com compatibilidade reversa
- **PATCH**: Correções de bugs

Exemplo: v1.2.3 = v1 (MAJOR).2 (MINOR).3 (PATCH)

---

## Como Relatar Mudanças

Ao submeter um Pull Request, inclua:

1. Descrição clara das mudanças
2. Motivação e contexto
3. Tipo de mudança (feature/bugfix/etc)
4. Screenshots (se aplicável)
5. Checkup de testes

Obrigado por contribuir! 🎉
