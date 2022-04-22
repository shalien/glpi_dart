import 'package:glpi_dart/glpi_dart.dart';

void main() async {
  // We recommend to use a secret management library like dotenv
  // to store your credentials in a file
  String username = 'admin';
  String password = 'admin';
  String baseUrl = 'http://example.com/apirest.php';
  GlpiClient client = GlpiClient(baseUrl);
  String? sessionToken;

  // Get the session token
  try {
    final response =
        await client.initSessionUsernamePassword(username, password);
    sessionToken = response['session_token'];

    client.sessionToken = sessionToken;
  } on GlpiException catch (e) {
    // In case of will get the http status code (e.code) and the message (e.reason['error'])
    print('${e.code} - ${e.error} - ${e.message}');
  }

  print(sessionToken);
}
