import 'dart:convert';

import 'package:dotenv/dotenv.dart';
import 'package:glpi_dart/glpi_dart.dart';
import 'package:test/test.dart';

void main() {
  late GlpiClient? glpiClient;
  String? username, password, userToken;

  setUp(() {
    load();
    String appToken = env['APP_TOKEN'].toString().trim();
    String baseUrl = env['BASE_URL'].toString().trim();
    username = env['API_USERNAME'].toString().trim();
    password = env['API_PASSWORD'].toString().trim();
    userToken = env['USER_TOKEN'].toString().trim();

    glpiClient = GlpiClient(baseUrl, appToken: appToken);
  });
  group('Testing the client access using username and', () {
    test('Should get a session token with login', () async {
      final response =
          await glpiClient!.initSessionUsernamePassword(username!, password!);

      expect(response['session_token'], isNotNull);
    });

    test('Should get a session token using the user_token', () async {
      final response = await glpiClient!.initSessionUserToken(userToken!);

      expect(response['session_token'], isNotNull);
    });
  });
}
