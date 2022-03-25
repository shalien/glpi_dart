import 'package:dotenv/dotenv.dart';
import 'package:glpi_dart/glpi.dart';
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

  group('Get a computer', () {
    setUp(() async {
      await glpiClientLogin?.initSession();
      await glpiClientToken?.initSession();
    });
    test('Get a computer with login', () async {
      final type = GlpiItemType.Computer;
      final id = 1;

      var items = await glpiClientLogin?.getItem(type, id, withSoftwares: true);
      print(items);
      expect(items, isMap);
    });
  });

  group('Get a user and the log ', () {
    setUp(() async {
      await glpiClientLogin?.initSession();
      await glpiClientToken?.initSession();
    });
    test('Get a user and logs with login', () async {
      final mainType = GlpiItemType.User;
      final subType = GlpiItemType.Log;
      final id = 6;

      var items = await glpiClientLogin?.getSubItems(mainType, id, subType);
      print(items);
      expect(items, isList);
    });
  });

  group('Get all computer', () {
    setUp(() async {
      await glpiClientLogin?.initSession();
      await glpiClientToken?.initSession();
    });
    test('Get all computer with login', () async {
      final type = GlpiItemType.Computer;

      var items = await glpiClientLogin?.getAllItem(type);
      expect(items, isList);
    });
  });

  group('Get all api client', () {
    setUp(() async {
      await glpiClientLogin?.initSession();
      await glpiClientToken?.initSession();
    });
    test('Get all api client with login', () async {
      final type = GlpiItemType.APIClient;

      var items = await glpiClientLogin?.getAllItem(type);

      expect(items, isList);
    });
  });

  group('Get all lines', () {
    setUp(() async {
      await glpiClientLogin?.initSession();
      await glpiClientToken?.initSession();
    });
    test('Get all lines with login', () async {
      final type = GlpiItemType.Line;

      var items = await glpiClientLogin?.getAllItem(type);

      expect(items, isList);
    });
  });

  group('Get multiples items', () {
    setUp(() async {
      await glpiClientLogin?.initSession();
      await glpiClientToken?.initSession();
    });
    test('Get multiple items with login', () async {
      final itemsList = [
        {GlpiItemType.Line: 1},
        {GlpiItemType.User: 6},
        {GlpiItemType.Computer: 1},
      ];

      var items = await glpiClientLogin?.getMultipleItems(itemsList);

      print(items);
      expect(items, isList);
    });
  });

  group('Get searchOptions for Line', () {
    setUp(() async {
      await glpiClientLogin?.initSession();
      await glpiClientToken?.initSession();
    });
    test('Get searchOptions for Line with login', () async {
      var items = await glpiClientLogin?.listSearchOptions(GlpiItemType.Line);

      print(items);
      expect(items, isMap);
    });
  });
}
