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
