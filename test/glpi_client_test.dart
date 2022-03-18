import 'package:dotenv/dotenv.dart';
import 'package:glpi_dart/src/glpi_client.dart';
import 'package:test/test.dart';

void main() {
  late GlpiClient? glpiClientLogin;

  setUp(() {
    load();
    String appToken = env['APP_TOKEN'].toString();
    String baseUrl = env['BASE_URL'].toString();
    String username = env['API_USERNAME'].toString();
    String password = env['API_PASSWORD'].toString();

    glpiClientLogin =
        GlpiClient.withLogin(baseUrl, username, password, appToken: appToken);
  });
  group('Testing the glpiClient', () {
    test('Should get a session token', () async {
      await glpiClientLogin?.initSession();

      expect(glpiClientLogin?.sessionToken, isNotNull);
    });
  });
}
