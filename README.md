# TurnWise TCG

Assistente de turno para mesas presenciais de TCG (Flutter + Firebase).

## Requisitos

- Flutter SDK `>=3.4.0`
- Conta Firebase no projeto `turnwise-tcg`
- Apple Developer (Sign in with Apple)

## Configuração Firebase

1. `flutterfire configure` (gera `firebase_options.dart`, `google-services.json`, `GoogleService-Info.plist`)
2. **Authentication**: ativar Anonymous, Google e Apple
3. **Android SHA** (já configurado no teu projeto):
   - SHA-1 e SHA-256 no [Firebase Console](https://console.firebase.google.com/project/turnwise-tcg/settings/general)
4. **Apple Return URL** (Apple Developer → Services ID):
   - `https://turnwise-tcg.firebaseapp.com/__/auth/handler`
5. Deploy das regras Firestore:
   ```bash
   firebase deploy --only firestore:rules
   ```
6. **Landing page** (download TestFlight / APK): pasta `web-page/`, deploy com `firebase deploy --only hosting` ou `.\scripts\deploy-landing.ps1` → https://turnwise-tcg.web.app

## Executar

```bash
flutter pub get
flutter run
```

## Testes

```bash
flutter test
flutter analyze
```

## Arquitetura (resumo)

- `presentation` → `domain` → `data`
- Offline-first: Hive local + sync Firestore (`lib/features/sync/`)
- Auth: guest, Google, Apple (`lib/features/auth/`)

## Publicação nas lojas (Fastlane)

**Fastlane só faz upload** dos binários para as consolas. TestFlight / testes internos Play ficam disponíveis após o processamento. **Enviar para produção** (App Store / Play Store) é **manual** nas respetivas consolas.

| Plataforma | Fastlane envia para | Publicação produção |
|------------|---------------------|---------------------|
| iOS | App Store Connect → **TestFlight** | Manual no [App Store Connect](https://appstoreconnect.apple.com) |
| Android | Google Play → faixa **internal** (ou `beta`) | Manual no [Play Console](https://play.google.com/console) |

### iOS (TestFlight)

Pré-requisitos: Mac, Xcode, certificado Distribution + profile **Turnwise - profile**, app na App Store Connect, [API Key](https://appstoreconnect.apple.com/access/integrations/api).

```bash
cd ios
bundle install
cp fastlane/.env.example fastlane/.env
cd ..
./scripts/upload-ios-testflight.sh
```

`bundle install` só na pasta `ios` (não em `ios/fastlane`). Não copies comentários para a linha de comando.

Opcional: `cd ios && bundle exec fastlane validate_asc`

**Erro CocoaPods** (`CocoaPods not installed or not in valid state`):

```bash
brew install cocoapods
chmod +x scripts/setup-ios-pods.sh
./scripts/setup-ios-pods.sh
```

Usa o `pod` do Homebrew (`/opt/homebrew/bin/pod`). Se `pod install` falhar com gems do Fastlane, corre sem `BUNDLE_GEMFILE`:

```bash
cd ios
env -u BUNDLE_GEMFILE -u RUBYOPT pod install
```

| Lane | Descrição |
|------|-----------|
| `deploy_testflight` | Build IPA + upload TestFlight |
| `upload_testflight` | Só upload (IPA já gerado) |
| `build` | Só gera IPA |
| `beta` | Alias de `deploy_testflight` |

### Android (Google Play)

Pré-requisitos: `android/key.properties` + `upload-keystore.jks`, app no Play Console, [Service Account JSON](https://developer.android.com/studio/publish/app-signing#api) com acesso à app.

```bash
cd android && bundle install
cp fastlane/.env.example fastlane/.env   # PLAY_STORE_JSON_KEY_PATH
bundle exec fastlane validate_play       # opcional (com JSON configurado)
./scripts/upload-android-play.sh         # build AAB + upload faixa internal
./scripts/upload-android-play.sh --track beta   # faixa beta (testes)
```

| Lane | Descrição |
|------|-----------|
| `internal` | Build AAB + upload faixa **internal** |
| `upload_internal` | Só upload (AAB já gerado) |
| `upload_beta` | Upload faixa **beta** |
| `build` | Só gera AAB |

### Android — APK para landing (sem Play Store)

Keystore em `android/upload-keystore.jks` + `android/key.properties` (não commitados):

```powershell
.\scripts\build-release-apk.ps1
```

APK: `build/app/outputs/flutter-apk/app-release.apk` → Drive → `web-page/js/config.js` → `.\scripts\deploy-landing.ps1`

**SHA release (Firebase Console → Android app):**

- SHA-1: `40:03:1F:45:F1:72:01:2C:7D:28:BA:41:35:C0:B1:8F:EA:98:B7:D7`
- SHA-256: `61:E6:89:14:92:14:49:52:95:11:1A:AE:6E:95:DE:47:15:47:23:95:AB:73:7C:4F:29:CC:B7:78:19:04:AD:75`