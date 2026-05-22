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

## Android release (APK assinado)

Keystore local em `android/upload-keystore.jks` + `android/key.properties` (não commitados). Build:

```powershell
.\scripts\build-release-apk.ps1
```

APK: `build/app/outputs/flutter-apk/app-release.apk` → envia para Drive (link público) → `web-page/js/config.js` → `.\scripts\deploy-landing.ps1`

**SHA release (regista no Firebase Console → Android app):**

- SHA-1: `40:03:1F:45:F1:72:01:2C:7D:28:BA:41:35:C0:B1:8F:EA:98:B7:D7`
- SHA-256: `61:E6:89:14:92:14:49:52:95:11:1A:AE:6E:95:DE:47:15:47:23:95:AB:73:7C:4F:29:CC:B7:78:19:04:AD:75`