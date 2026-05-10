# LocalSend WeChat UI

[![CI status][ci-badge]][ci-workflow]

[ci-badge]: https://github.com/TraeAI/localsend-wechat/actions/workflows/build_apk.yml/badge.svg
[ci-workflow]: https://github.com/TraeAI/localsend-wechat/actions/workflows/build_apk.yml

LocalSend with WeChat-style UI - A cross-platform file sharing app with WeChat-like interface.

- [About](#about)
- [Features](#features)
- [Building](#building)
- [Contributing](#contributing)

## About

LocalSend is a free, open-source app that allows you to securely share files and messages with nearby devices over your local network without needing an internet connection. This version features a WeChat-style UI.

## Features

- WeChat-style tab navigation (微信/通讯录/发现/我的)
- Chat-like interface for device discovery
- Send files, images, and messages
- Secure HTTPS encryption
- Cross-platform support

## Building

### Android

```bash
cd app
flutter pub get
dart run build_runner build -d
flutter build apk
```

### iOS

```bash
cd app
flutter build ipa
```

### macOS

```bash
cd app
flutter build macos
```

### Windows

```bash
cd app
flutter build windows
```

### Linux

```bash
cd app
flutter build linux
```

## Contributing

Contributions are welcome! Please feel free to submit issues and pull requests.

## Author

Trae - ai@ai.com
