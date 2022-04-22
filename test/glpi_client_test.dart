import 'package:dotenv/dotenv.dart';
import 'package:glpi_dart/glpi_dart.dart';
import 'package:test/test.dart';

void main() {
  late GlpiClient? glpiClient, glpiPrjClient;
  String? username,
      password,
      userToken,
      prjUserToken,
      prjHost,
      prjAppToken,
      appToken;

  setUp(() {
    load();
    appToken = env['APP_TOKEN'].toString().trim();
    String baseUrl = env['BASE_URL'].toString().trim();
    username = env['API_USERNAME'].toString().trim();
    password = env['API_PASSWORD'].toString().trim();
    userToken = env['USER_API_TOKEN'].toString().trim();
    prjUserToken = env['PRJ_USER_TOKEN'].toString().trim();
    prjHost = env['PRJ_HOST'].toString().trim();
    prjAppToken = env['PRJ_APP_TOKEN'].toString().trim();

    glpiClient = GlpiClient(baseUrl, appToken: appToken);
    glpiPrjClient = GlpiClient(prjHost!, appToken: prjAppToken);
  });
  group('Testing initSession', () {
    test('initSessionUsernamePassword', () async {
      final response =
          await glpiClient!.initSessionUsernamePassword(username!, password!);

      expect(response['session_token'], isNotNull);
    });

    test('initSessionUsernamePassword in query', () async {
      final response = await glpiClient!
          .initSessionUsernamePassword(username!, password!, sendInQuery: true);

      expect(response['session_token'], isNotNull);
    });

    test('initSessionUserToken', () async {
      late Map<String, dynamic> response;

      try {
        response = await glpiClient!.initSessionUserToken(userToken!);
      } on GlpiException catch (e) {
        print('${e.error} ${e.message}');
        rethrow;
      }

      expect(response['session_token'], isNotNull);
    });

    test('initSessionUserToken in query', () async {
      late Map<String, dynamic> response;

      try {
        response = await glpiClient!
            .initSessionUserToken(userToken!, sendInQuery: true);
      } on GlpiException catch (e) {
        print('${e.error} ${e.message}');
      }

      expect(response['session_token'], isNotNull);
    });
  });
}
