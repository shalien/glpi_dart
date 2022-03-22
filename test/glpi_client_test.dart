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

    String userToken = env['USER_TOKEN'].toString().trim();
    glpiClientToken = GlpiClient.withToken(baseUrl, userToken, appToken);
  });
  group('Testing the client access using username and', () {
    test('Should get a session token with login', () async {
      await glpiClientLogin?.initSession();

      expect(glpiClientLogin?.sessionToken, isNotNull);
    });

    test('Should get a session token with login in url', () async {
      await glpiClientLogin?.initSession(sendInQuery: true);

      expect(glpiClientLogin?.sessionToken, isNotNull);
    });
  });

  group('Testing client access using user_token', () {
    test('Get session token with user_token', () async {
      await glpiClientToken?.initSession();

      expect(glpiClientToken?.sessionToken, isNotNull);
    });

    test('Get session token with user_token in url', () async {
      await glpiClientToken?.initSession(sendInQuery: true);

      expect(glpiClientToken?.sessionToken, isNotNull);
    });
  });

  group('Testing the passwordLost method', () {
    late String email;

    setUp(() async {
      await glpiClientLogin?.initSession();
      await glpiClientToken?.initSession();
      email = env['ACCOUNT_EMAIL'].toString().trim();
    });

    test('Request a password reset with login client', () async {
      bool? result = await glpiClientLogin?.lostPassword(email);

      expect(result, true);
    });

    test('Request a password reset with token client', () async {
      bool? result = await glpiClientToken?.lostPassword(email);

      expect(result, true);
    });
  });

  group('Testing getMyProfiles', () {
    setUp(() async {
      await glpiClientLogin?.initSession();
      await glpiClientToken?.initSession();
    });

    test('Request my profiles with login client', () async {
      var result = await glpiClientLogin?.getMyProfiles();

      expect(result, isMap);
    });

    test('Request my profiles with token client', () async {
      var result = await glpiClientToken?.getMyProfiles();

      expect(result, isMap);
    });
  });

  group('Testing getFullSession', () {
    setUp(() async {
      await glpiClientLogin?.initSession();
      await glpiClientToken?.initSession();
    });

    test('Get the full session with login', () async {
      await glpiClientLogin?.getFullSession();

      expect(glpiClientLogin?.sessionToken, isNotNull);
    });
  });
}
