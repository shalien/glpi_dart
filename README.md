# GLPI DART

glpi_dart is a dart library to interact with the GLPI's REST API.

## Features

This library allow to communicate with the glpi's REST API.

It's still in development 

## Getting started

Either run :
 `dart pub add glpi_dart`

Or add this in your package.yaml :

```yml
glpi_dart: ^0.0.1
```

## Usage

```dart
    final GlpiClient glpiClient = GlpiClient.withToken(url, token);
    await glpiClient.initSession();
```

## License
See LICENSE.md

## Additional information

This package is still in development
