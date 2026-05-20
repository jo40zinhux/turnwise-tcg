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
