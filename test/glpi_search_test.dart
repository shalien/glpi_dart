import 'package:dotenv/dotenv.dart';
import 'package:glpi_dart/glpi_dart.dart';
import 'package:test/test.dart';

void main() {
  late GlpiClient? glpiClientLogin;

  setUp(() {
    load();
    String appToken = env['APP_TOKEN'].toString().trim();
    String baseUrl = env['BASE_URL'].toString().trim();
    String username = env['API_USERNAME'].toString().trim();
    String password = env['API_PASSWORD'].toString().trim();

    glpiClientLogin =
        GlpiClient.withLogin(baseUrl, username, password, appToken: appToken);
  });
  group('Testing to search all item computer starting with tec6', () {
    test('Find computer named tec6', () async {
      await glpiClientLogin?.initSession();

      final criteria = [
        GlpiSearchCriteria(1, null, 'tec6', GlpiSearchType.contains)
      ].toList();

      final computer = await glpiClientLogin!
          .search(GlpiItemType.Computer, criteria: criteria);

      expect(computer, isMap);
    });
  });
}
