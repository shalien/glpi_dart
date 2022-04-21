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
 glpi_dart: ^0.1.2
```
to your pubspec.yaml file.


Then you can use the library by importing the client.

```dart
import 'package:glpi_dart/glpi_dart.dart';
```

## Usage
There's two way to create a client to access the API, either by using the lpiClient.withLogin or by using the GlpiClient.withToken constructor.

```dart
import 'package:glpi_dart/glpi_dart.dart';
void main() async {
  // Create a client with login and password
  GlpiClient client = GlpiClient.withLogin('http://localhost/glpi/apirest.php/', 'username', 'password');
  //Get the session token
  await client.initSession();
  //Then we can start making request for example, get all the computers
  try {
    final computers = await client.getAll(GlpiItemType.Computer);
  } catch (GlpiException e) {
      print('${e.code} - ${e.error} - ${e.message}');
  }
  //Or get a specific computer
  try {
    final computer = await client.getItem(GlpiItemType.Computer, '1');
  } catch (e) {
      print('${e.code} - ${e.error} - ${e.message}');
  }
  //Then we can delete the session
  await client.killSession();
```

Check the `example` directory for more examples.

## Errors
By design the library will throw an GlpiException if an error occurs during the request.
The exception will contain the http response code and a Map with the error code and the error localized message.
Methods will also throw an exception if the session token is not set using  GlpiClient.initSession.

## Testing
Right now all the tests aren't written and/or cleaned

## License
See LICENSE.md

## Additional information

This package is still in development
