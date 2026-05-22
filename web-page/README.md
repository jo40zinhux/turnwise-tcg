# TurnWise — Landing Page

Página estática de apresentação e download do app (TestFlight + APK Android).

## Estrutura

```
web-page/
├── index.html
├── css/styles.css
├── js/
│   ├── config.js    ← URLs de download e contacto
│   └── main.js
├── assets/logo.svg
└── README.md
```

## Configurar links de download

Edita `js/config.js`:

```js
window.TURNWISE_DOWNLOADS = {
  testflightUrl: 'https://testflight.apple.com/join/XXXXXX',
  androidApkUrl: 'https://teu-dominio.com/turnwise-latest.apk',
  supportEmail: 'suporte@turnwise.app',
};
```

### TestFlight (iOS)

1. App Store Connect → a tua app → **TestFlight**
2. Cria um grupo externo e ativa **Public Link**
3. Copia o URL `https://testflight.apple.com/join/...` para `testflightUrl`

### Android (release assinado + link externo)

O APK **não** fica no Firebase Hosting (o plano Spark bloqueia `.apk`). Usa um link público externo (ex.: Google Drive):

1. `.\scripts\build-release-apk.ps1` → gera `build/app/outputs/flutter-apk/app-release.apk`
2. Envia o APK para o Drive → partilha como **qualquer pessoa com o link**
3. Em `js/config.js`, define `androidApkUrl` com o link de download direto:
   - URL de partilha: `https://drive.google.com/file/d/FILE_ID/view?usp=sharing`
   - Link de download: `https://drive.google.com/uc?export=download&id=FILE_ID`
4. `.\scripts\deploy-landing.ps1` (só publica HTML/CSS/JS da LP)

## Pré-visualizar localmente

```bash
cd web-page
npx --yes serve .
# ou: python -m http.server 8080
```

Abre `http://localhost:3000` (serve) ou `http://localhost:8080`.

## Publicar (Firebase Hosting — configurado)

O projeto já aponta `firebase.json` → `public: web-page` e `.firebaserc` → `turnwise-tcg`.

### Primeiro deploy (ou após `firebase login`)

Na raiz do repositório:

```powershell
firebase deploy --only hosting
```

Ou o atalho:

```powershell
.\scripts\deploy-landing.ps1
```

### URLs de produção

- https://turnwise-tcg.web.app
- https://turnwise-tcg.firebaseapp.com

### Atualizar links TestFlight / APK

1. Edita `js/config.js` com os URLs finais.
2. Na raiz do repo: `firebase deploy --only hosting` (ou `.\scripts\deploy-landing.ps1`).

O ficheiro `config.js` tem `Cache-Control: no-cache` no Hosting para que alterações de link apareçam logo após o deploy, sem cache antigo no browser.

## Branding

Cores alinhadas ao app Flutter (`lib/core/theme/app_theme.dart`):

- Primary: `#7C5CFF`
- Background: `#121212`
- Surface: `#1E1E1E`

Substitui `assets/logo.svg` pelo ícone oficial da app quando estiver disponível.
