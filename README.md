# GLPI DART
A library to access the GLPI API

This library is a wrapper around the GLPI API, it provides a simple way to access he API.

It is based on the Dart http library so it can be used ont dartvm and dartweb.
It was implemented following the [GLPI API documentation](https://github.com/lpi-project/glpi/blob/master/apirest.md)


## First step
Before using the library, you need to make sure your GLPI instance is correctly setup to enable the api usage.

First you need to add the library to your pubspec.yaml file.

Either run
```
dart pub add glpi_dart
```
or manually add
```
 glpi_dart: ^0.2.0
```
to your pubspec.yaml file.


Then you can use the library by importing the client.

```dart
import 'package:glpi_dart/glpi_dart.dart';
```

## Usage
Import the library and create a client using `Glpiclient()`
You can either also create a client with a stored session token to avoid calling `initSessionUsernamePassword` or  `initSessionToken` every time.


```dart
import 'package:glpi_dart/glpi_dart.dart';

void main() async {
  // We recommend to use a secret management library like dotenv
  // to store your credentials in a file
  String userToken = 'abcedfghijklmnopqrstuvwxyz123467890';
  String appToken = '0987654321zyxwvutsrqponmlkjihgfedcba';
  String baseUrl = 'http://example.com/apirest.php';

  // Create the client BUT doesn't get the session token
  GlpiClient client = GlpiClient(baseUrl, appToken: appToken);
  String? sessionToken;

  // Get the session token
  try {
    final response = await client.initSessionUserToken(userToken);
    sessionToken = response['session_token'];

    client.sessionToken = sessionToken;
  } on GlpiException catch (e) {
    // In case of will get the http status code (e.code) and the message (e.reason['error'])
    print('${e.code} - ${e.error} - ${e.message}');
  }

  print(sessionToken);
}
```

Check the `example` directory for more examples.

## Errors
By design the library will throw an GlpiException if an error occurs during the request.
The exception will contain the http response code and a Map with the error code and the error localized message.
Methods will also throw an exception if the session token is not set.

## Testing
Right now all the tests aren't written and/or cleaned

## License
See LICENSE.md

## Additional information

This package is still in development
