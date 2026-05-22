fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios validate_asc

```sh
[bundle exec] fastlane ios validate_asc
```

Valida API Key e ligação à App Store Connect

### ios build

```sh
[bundle exec] fastlane ios build
```

Gera IPA release (Flutter) sem enviar

### ios upload_testflight

```sh
[bundle exec] fastlane ios upload_testflight
```

Envia IPA existente para TestFlight (App Store Connect)

### ios deploy_testflight

```sh
[bundle exec] fastlane ios deploy_testflight
```

Build IPA + upload para TestFlight

### ios beta

```sh
[bundle exec] fastlane ios beta
```

Alias de deploy_testflight

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
