# 📋 Checklist para GitHub - LanternFox

Documentação completa para preparar seu projeto para o GitHub.

## ✅ Arquivos Criados/Atualizados

### Documentação Principal
- [x] **README.md** - Documentação principal do projeto
- [x] **CHANGELOG.md** - Histórico de mudanças e versões
- [x] **CONTRIBUTING.md** - Guia para contribuidores
- [x] **LICENSE** - Licença MIT do projeto
- [x] **CODE_OF_CONDUCT.md** - Código de conduta
- [x] **SETUP.md** - Guia detalhado de configuração
- [x] **ARCHITECTURE.md** - Documentação da arquitetura

### Configuração do Git
- [x] **.gitignore** - Arquivo aprimorado para ignorar arquivos sensíveis

### Configuração do GitHub
- [x] **.github/workflows/flutter-build.yml** - CI/CD Pipeline (Build & Test)
- [x] **.github/FUNDING.yml** - Configuração de patrocínios
- [x] **.github/pull_request_template.md** - Template para Pull Requests
- [x] **.github/ISSUE_TEMPLATE/bug_report.md** - Template para Bug Reports
- [x] **.github/ISSUE_TEMPLATE/feature_request.md** - Template para Feature Requests

### Configuração do Projeto
- [x] **pubspec.yaml** - Atualizado com descrição e links úteis

## 🚀 Próximos Passos

### 1. Crie um Repositório no GitHub

```bash
# Se criou um novo repositório vazio
git init
git add .
git commit -m "Initial commit: LanternFox v1.0.0"
git branch -M main
git remote add origin https://github.com/seu-usuario/lanternfox.git
git push -u origin main
```

### 2. Configure as Secrets do GitHub (se usar CI/CD)

Vá para: Repository Settings → Secrets and variables → Actions

Adicione:
- `SUPABASE_URL` (sua URL do Supabase)
- `SUPABASE_ANON_KEY` (sua chave anônima)

### 3. Ative Branch Protections

Settings → Branches → Add rule

Configurações recomendadas:
- ✓ Require pull request reviews before merging
- ✓ Require status checks to pass before merging
- ✓ Require branches to be up to date before merging

### 4. Configure Actions (Workflows)

O arquivo `.github/workflows/flutter-build.yml` já está pronto!

Ele executará automaticamente quando:
- Houver push para `main` ou `develop`
- Houver pull request para essas branches

### 5. Customize os Arquivos

**README.md**: Atualize os links com seu usuário GitHub
```markdown
Troque:
- https://github.com/seu-usuario/lanternfox

Por:
- https://github.com/seu-usuario-real/lanternfox
```

**CONTRIBUTING.md**: Mesma coisa

**pubspec.yaml**: Atualize homepage e repository

## 📱 Verificação Final

Antes de fazer push:

```bash
# 1. Verifique o .gitignore
git check-ignore -v <arquivo>  # Para verificar um arquivo específico

# 2. Rode os testes localmente
flutter test

# 3. Rode a análise
flutter analyze

# 4. Formate o código
flutter format .

# 5. Limpe o projeto
flutter clean

# 6. Verifique se não há credentials expostas
git diff --cached  # Verificar staged changes
grep -r "SUPABASE_URL\|SUPABASE_ANON_KEY" lib/

# 7. Faça o commit
git add .
git commit -m "docs: add GitHub documentation and CI/CD"

# 8. Faça push
git push origin main
```

## 🔐 Segurança

### IMPORTANTE: Informações Sensíveis

**NUNCA commite:**
- Chaves de API
- Senhas
- Tokens de autenticação
- URLs com credenciais

**Como proteger:**
```bash
# Use variáveis de ambiente
export SUPABASE_URL="..."
export SUPABASE_ANON_KEY="..."

# Ou crie um arquivo .env (que está no .gitignore)
# lib/.env
# SUPABASE_URL=...
# SUPABASE_ANON_KEY=...
```

## 📊 Badges para README (Opcional)

Adicione ao início do README.md:

```markdown
[![Flutter](https://img.shields.io/badge/flutter-%2302569B.svg?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
```

## 🎯 Estratégia de Desenvolvimento

### Branches
- `main` - Produção (merge apenas via PR)
- `develop` - Desenvolvimento (merge apenas via PR)
- `feature/*` - Novas features
- `bugfix/*` - Correções de bugs
- `hotfix/*` - Correções urgentes

### Workflow de Feature

```bash
# 1. Crie uma branch
git checkout -b feature/nova-funcionalidade

# 2. Faça commits pequenos e descritivos
git commit -m "feat: adicionar novo recurso"

# 3. Push para GitHub
git push origin feature/nova-funcionalidade

# 4. Crie um Pull Request no GitHub
# - Descreva as mudanças
# - Referencie issues: Fixes #123
# - Aguarde review

# 5. Após aprovação, merge no GitHub
```

## 📚 Recursos Úteis

- [GitHub Docs](https://docs.github.com/)
- [Flutter Best Practices](https://flutter.dev/docs/testing/best-practices)
- [Dart Style Guide](https://dart.dev/guides/language/effective-dart)
- [Conventional Commits](https://www.conventionalcommits.org/)

## ✨ Boas Práticas

### Commits
```bash
# ✅ BOM
git commit -m "feat(checkout): add shipping fee calculation"

# ❌ RUIM
git commit -m "Updated stuff"
```

### Pull Requests
```markdown
## Descrição
Adiciona cálculo de frete ao checkout

## Tipo de Mudança
- [x] Bug fix
- [x] New feature

## Testes
- [x] Teste unitário adicionado
- [x] Teste manual no dispositivo

Fixes #123
```

### Issues
```markdown
## Descrição do Bug
O botão de checkout não funciona

## Para Reproduzir
1. Abra o app
2. Adicione um produto ao carrinho
3. Clique em "Ir para Checkout"

## Esperado
Deve abrir a página de checkout

## Atual
Dá erro de "null"
```

## 🎉 Pronto!

Seu projeto está pronto para GitHub! 

Próximas ações:
1. Configure URLs nos templates
2. Faça push inicial
3. Configure branch protections
4. Comece a aceitar contribuições

---

**Última Atualização**: Novembro 2025

Obrigado por usar este checklist! 🚀
