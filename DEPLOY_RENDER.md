# 🚀 Guia de Deploy - Render (Static Site)

## ✅ Configuração Local Completa

### 1. Arquivo de Configuração ✅
- ✅ `lib/config/config.dart` criado
- ✅ URLs da API configuradas (dev: localhost, prod: Render)

### 2. Rotas Atualizadas ✅
- ✅ Todas as rotas usam `Config.apiUrl`
- ✅ Detecção automática de ambiente

### 3. GitIgnore Atualizado ✅
- ✅ Pasta `/build` será enviada para o repositório

### 4. Build Executado ✅
- ✅ `flutter build web --release` executado

---

## 🌐 Deploy no Render

### Passo 1: Fazer commit do build

```bash
git add .
git commit -m "Build para deploy no Render"
git push origin felipe
```

### Passo 2: Criar Static Site no Render

1. **Acesse** [render.com](https://render.com)
2. **Faça login** com GitHub
3. **Clique** em "New +"
4. **Selecione** "Static Site"

### Passo 3: Configurar o Serviço

**Configurações:**

| Campo | Valor |
|-------|-------|
| **Name** | `portifolio-front` (ou nome de sua escolha) |
| **Repository** | Selecione seu repositório `portifolio_front` |
| **Branch** | `felipe` |
| **Build Command** | _(deixe vazio)_ |
| **Publish Directory** | `build/web` |

### Passo 4: Deploy

1. **Clique** em "Create Static Site"
2. **Aguarde** o deploy ser concluído
3. **Copie** a URL gerada (ex: `https://portifolio-front.onrender.com`)

---

## 🔧 Configurações Importantes

### Rewrites para SPA (Single Page Application)

No Render, adicione um arquivo `render.yaml` na raiz do projeto (OPCIONAL):

```yaml
services:
  - type: web
    name: portifolio-front
    env: static
    buildCommand: echo "Build já está pronto"
    staticPublishPath: ./build/web
    routes:
      - type: rewrite
        source: /*
        destination: /index.html
```

**OU** configure manualmente no painel do Render:
- Em "Redirects/Rewrites", adicione:
  - **Source**: `/*`
  - **Destination**: `/index.html`
  - **Type**: `rewrite`

---

## ✅ Verificações Pós-Deploy

- [ ] Site está acessível via HTTPS
- [ ] Todas as páginas carregam
- [ ] Login funciona
- [ ] Cadastro funciona
- [ ] Admin pode acessar painel
- [ ] Sem erros no console do navegador
- [ ] API está respondendo

---

## 🔄 Atualizações Futuras

Para atualizar o site após mudanças:

```bash
# 1. Fazer alterações no código
# 2. Executar novo build
flutter build web --release

# 3. Commit e push
git add build/
git commit -m "Atualização do frontend"
git push origin felipe

# 4. Render fará o redeploy automaticamente
```

---

## 🐛 Troubleshooting

### Site não carrega
- Verifique se "Publish Directory" está como `build/web`
- Verifique se o build foi commitado e enviado ao repositório

### Erro 404 ao navegar
- Configure redirects/rewrites para SPA
- Adicione arquivo `render.yaml` ou configure no painel

### API não responde
- Verifique URL da API em `lib/config/config.dart`
- Verifique CORS no backend
- Verifique se backend está online

### Deploy falha
- Verifique logs no painel do Render
- Certifique-se que a pasta `build/web` está no repositório
- Tente fazer novo commit

---

## 📊 Informações Úteis

### URLs
- **Frontend no Render**: `https://seu-site.onrender.com`
- **Backend no Render**: `https://programacaiii-api.onrender.com`

### Estrutura do Repositório
```
portifolio_front/
├── build/
│   └── web/              ← Pasta que será deployada
│       ├── index.html
│       ├── main.dart.js
│       ├── flutter.js
│       └── ...
├── lib/
│   └── config/
│       └── config.dart   ← Configuração da API
└── .gitignore            ← /build/ comentado
```

---

## 🎉 Pronto!

Seu portfólio frontend está no ar! 🚀

**Próximos passos:**
- Configurar domínio customizado (opcional)
- Configurar SSL (automático no Render)
- Adicionar conteúdo ao portfólio
- Testar todas as funcionalidades

---

**Data:** 16 de outubro de 2025
