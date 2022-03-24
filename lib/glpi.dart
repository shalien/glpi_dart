///  A library to access the GLPI API
///
/// This library is a wrapper around the GLPI API, it provides a simple way to access the API.
/// It is based on the Dart http library so it can be used ont dartvm and dartweb.
/// It was implemented following the [GLPI API documentation](https://github.com/glpi-project/glpi/blob/master/apirest.md)
///
/// ## Usage
/// Before using the library, you need to make sure your GLPI instance is correctly setup to enable the api usage.
///
/// First you need to add the library to your pubspec.yaml file.
/// Either run
/// ```
/// dart pub add glpi_dart
/// ```
/// or manually add
/// ```
///  glpi_dart: ^0.0.1
/// ```
/// to your pubspec.yaml file.
///
/// Then you can use the library by importing the client.
///
/// ```dart
/// import 'package:glpi_dart/glpi_dart.dart';
/// ```
///
/// There's two way to create a client to access the API, either by using the [GlpiClient.withLogin] class or by using the [GlpiClient.withToken] constructor.
///  ```dart
/// import 'package:glpi_dart/glpi_dart.dart';
///
/// void main() async {
///   // Create a client with login and password
///   GlpiClient client = GlpiClient.withLogin('http://localhost/glpi/apirest.php/', 'username', 'password');
///
///   //Get the session token
///   await client.initSession();
///
///   //Then we can start making request for example, gell all the computers
///   try {
///     final computers = await client.getAll(GlpiItemType.Computer);
///   } catch (e) {
///    print(e);
///   }
///
///   //Or get a specific computer
///   try {
///     final computer = await client.getItem(GlpiItemType.Computer, '1');
///   } catch (e) {
///     print(e);
///   }
///
///   //Then we can delete the session
///   await client.killSession();
///```
///
/// Check the `example` directory for more examples.
///
/// ## Errors
/// By design the library will throw an exception if an error occurs.
/// The exception will contain the error code and the error message.
/// The error code is the HTTP status code returned by the server.
/// The error message is the message returned by the server.
///
/// Methods will also throw an exception if the session token is not set using [GlpiClient.initSession].
///
///
library glpi_dart;

export 'src/glpi_item_type.dart';
export 'src/glpi_client.dart';
