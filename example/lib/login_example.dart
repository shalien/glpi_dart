import 'package:glpi_dart/glpi.dart';

void main() async {
  // We recommend to use a secret management library like dotenv
  // to store your credentials in a file
  String username = 'admin';
  String password = 'admin';
  String baseUrl = 'http://example.com/apirest.php';

  // Create the client BUT doesn't get the session token
  GlpiClient client = GlpiClient.withLogin(baseUrl, username, password);

  // Get the session token
  try {
    await client.initSession();
  } on GlpiException catch (e) {
    // In case of will get the http status code (e.code) and the message (e.reason['error'])
    print('${e.code} - ${e.error} - ${e.message}');
  }

  print(client.sessionToken);
}
