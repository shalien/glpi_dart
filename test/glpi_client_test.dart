import 'package:dotenv/dotenv.dart';
import 'package:glpi_dart/src/glpi_client.dart';
import 'package:test/test.dart';

void main() {
  late GlpiClient? glpiClientLogin;
  late GlpiClient? glpiClientToken;

  setUp(() {
    load();
    String appToken = env['APP_TOKEN'].toString().trim();
    String baseUrl = env['BASE_URL'].toString().trim();
    String username = env['API_USERNAME'].toString().trim();
    String password = env['API_PASSWORD'].toString().trim();

    glpiClientLogin =
        GlpiClient.withLogin(baseUrl, username, password, appToken: appToken);

    String userToken = env['USER_API_TOKEN'].toString().trim();
    glpiClientToken =
        GlpiClient.withToken(baseUrl, userToken, appToken: appToken);
  });
  group('Testing the glpiClient', () {
    test('Should get a session token with login', () async {
      await glpiClientLogin?.initSession();

      expect(glpiClientLogin?.sessionToken, isNotNull);
    });

    test('Should get a session token with login in url', () async {
      await glpiClientLogin?.initSession(sendInQuery: true);

      expect(glpiClientLogin?.sessionToken, isNotNull);
    });

    test('Get session token with user_token', () async {
      await glpiClientToken?.initSession();

      expect(glpiClientToken?.sessionToken, isNotNull);
    });

    test('Get session token with user_token in url', () async {
      await glpiClientToken?.initSession(sendInQuery: true);

      expect(glpiClientToken?.sessionToken, isNotNull);
    });
  });
}
