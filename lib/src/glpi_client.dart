import 'dart:async';
import 'dart:convert';
import 'package:glpi_dart/src/glpi_item_type.dart';
import 'package:http/http.dart' as http;

/// A client used to communicate with the GLPI API.
/// To create a client you may use either [GlpiClient.withLogin] or [GlpiClient.withToken].
/// The former will create a client with a username and password, the latter with a user token and an app token.
abstract class GlpiClient {
  /// The base url of the GLPI API.
  /// Example https//example.com/glpi/apirest.php/
  final String baseUrl;

  /// The app token used to authenticate the client.
  /// It's mandatory when using the [GlpiClient.withToken] constructor.
  /// Also if you have setup a AppToken within your GLPI configuration, the token **will be mandatory** for all your requests.
  String? appToken;

  /// The session token get whe using [initSession].
  String? _sessionToken;

  /// The session token get whe using [initSession].
  /// The session token is managed by the client automatically.
  String get sessionToken => _sessionToken!;

  /// The session data for the current [GlpiClient]
  /// Can be set using [initSession] with `getFullSession` parameter set to true or [getFullSession]
  /// If trying to get the session **before** calling [initSession] or [getFullSession] will throw an exception.
  Future<Map<String, dynamic>> get session async =>
      _session ?? await getFullSession();

  /// The session data of the client.
  Map<String, dynamic>? _session;

  /// Private constructor for the [GlpiClient] class.
  /// Only the [GlpiClient.withLogin] and [GlpiClient.withToken] constructors should be used.
  GlpiClient._(this.baseUrl, {this.appToken});

  /// Return a new instance of [GlpiClient] using the given [baseUrl] and credentials ([username] / [password]).
  factory GlpiClient.withLogin(
    String baseUrl,
    String username,
    String password, {
    String? appToken,
  }) {
    final glpiClient =
        _GlpiLoginClient(baseUrl, username, password, appToken: appToken);
    return glpiClient;
  }

  /// Return a new instance of [GlpiClient] using the given [baseUrl] and user_token [userToken] and app_token [appToken].
  /// Unlike [GlpiClient.withLogin], this method **require** an app_token to work.
  factory GlpiClient.withToken(
      String baseUrl, String userToken, String appToken) {
    final glpiClient = _GlpiTokenClient(baseUrl, userToken, appToken);
    return glpiClient;
  }

  /// Retrieve the session token.
  /// The token will be stored in the [sessionToken] field automatically.
  /// If [getFullSession] is set to true, will also return the session details in session.
  /// If [sendInQuery] is set to true, will send the credentials in the query string instead of the header.
  /// Will throw an [Exception] if the session can't be initialized.
  /// Reference: [https://github.com/glpi-project/glpi/blob/master/apirest.md#init-session](https://github.com/glpi-project/glpi/blob/master/apirest.md#init-session).
  Future<String> initSession(
      {bool getFullSession = false, bool sendInQuery = false});

  /// Return `true` if the client is successfully disconnected from the API.
  /// Will throw an [Exception] if the session can't be disconnected.
  /// Reference: [https://github.com/glpi-project/glpi/blob/master/apirest.md#kill-session](https://github.com/glpi-project/glpi/blob/master/apirest.md#kill-session).
  Future<bool> killSession() async {
    if (_sessionToken == null) {
      throw Exception('No session token, initSession first');
    }

    final Map<String, String> headers = {
      'Session-Token': _sessionToken!,
      'Content-Type': 'application/json',
      ...?appToken != null ? {'App-Token': appToken!} : null,
    };

    final _response =
        await http.get(Uri.parse('$baseUrl/killSession'), headers: headers);

    if (_response.statusCode != 200) {
      throw Exception('${_response.statusCode} ${_response.body}');
    }

    _sessionToken = null;
    return true;
  }

  /// Allow to request a password reset for the account using the [email] address.
  /// Return true if the request is successful BUT this doesn't mean that your glpi is configured to send emails.
  /// Check the glpi's configuration to see the prerequisites (notifications need to be enabled).
  /// If [passwordForgetToken] AND [newPassword] are set, the password will be changed with the value of [newPassword] instead.
  /// Sending [passwordForgetToken] without [newPassword] and the opposite will throw an [ArgumentError].
  /// Reference: [https://github.com/glpi-project/glpi/blob/master/apirest.md#lost-password](https://github.com/glpi-project/glpi/blob/master/apirest.md#lost-password).
  Future<bool> lostPassword(String email,
      {String? passwordForgetToken, String? newPassword}) async {
    if (_sessionToken == null) {
      throw Exception('No session token, initSession first');
    }

    // Unlike ALL the other method this one doesn't require any kind of authentication.
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    final body = {
      'email': email,
    };

    late http.Response response;

    // Because I'm sure someone will try to use this method with a newPassword without passwordForgetToken.
    if (passwordForgetToken!.isNotEmpty && newPassword!.isEmpty) {
      throw ArgumentError(
          'newPassword is required if passwordForgetToken is set');
      // Because I'm sure someone will try to use this method with a passwordForgetToken without newPassword.
    } else if (passwordForgetToken.isEmpty && newPassword!.isNotEmpty) {
      throw ArgumentError(
          'passwordForgetToken is required if newPassword is set');
    } else if (passwordForgetToken.isNotEmpty && newPassword!.isNotEmpty) {
      body['passwordForgetToken'] = passwordForgetToken;
      body['newPassword'] = newPassword;
      response = await http.put(
        Uri.parse('$baseUrl/lostPassword'),
        headers: headers,
        body: jsonEncode(body),
      );
    } else {
      response = await http.put(Uri.parse('$baseUrl/lostPassword'),
          body: json.encode(body), headers: headers);
    }

    if (response.statusCode != 200) {
      throw Exception('${response.statusCode} ${response.body}');
    }

    return true;
  }

  /// Return a [Map] of all the profil for the current user
  /// Profiles are under the key `myprofiles`
  /// Reference: [https://github.com/glpi-project/glpi/blob/master/apirest.md#get-my-profiles](https://github.com/glpi-project/glpi/blob/master/apirest.md#get-my-profiles).
  Future<Map<String, dynamic>> getMyProfiles() async {
    if (_sessionToken == null) {
      throw Exception('No session token, initSession first');
    }

    final Map<String, String> headers = {
      'Session-Token': _sessionToken!,
      'Content-Type': 'application/json',
      ...?appToken != null ? {'App-Token': appToken!} : null,
    };

    final _response =
        await http.get(Uri.parse('$baseUrl/getMyProfiles'), headers: headers);

    if (_response.statusCode != 200) {
      throw Exception('${_response.statusCode} ${_response.body}');
    }

    return json.decode(_response.body);
  }

  /// Return the current active profile for the current user as a [Map]
  /// Reference: [https://github.com/glpi-project/glpi/blob/master/apirest.md#get-active-profile](https://github.com/glpi-project/glpi/blob/master/apirest.md#get-active-profile)
  Future<Map<String, dynamic>> getActiveProfile() async {
    if (_sessionToken == null) {
      throw Exception('No session token, initSession first');
    }

    final Map<String, String> headers = {
      'Session-Token': _sessionToken!,
      'Content-Type': 'application/json',
      ...?appToken != null ? {'App-Token': appToken!} : null,
    };

    final _response = await http.get(Uri.parse('$baseUrl/getActiveProfile'),
        headers: headers);

    if (_response.statusCode != 200) {
      throw Exception('${_response.statusCode} ${_response.body}');
    }

    return json.decode(_response.body);
  }

  /// Change the active profile for the current user.
  /// Will throw an [Exception] if the request fails or if the selected id is incorrect.
  /// Reference: [https://github.com/glpi-project/glpi/blob/master/apirest.md#change-active-profile](https://github.com/glpi-project/glpi/blob/master/apirest.md#change-active-profile).
  Future<bool> changeActiveProfile(int profilesId) async {
    if (_sessionToken == null) {
      throw Exception('No session token, initSession first');
    }

    final Map<String, String> headers = {
      'Session-Token': _sessionToken!,
      'Content-Type': 'application/json',
      ...?appToken != null ? {'App-Token': appToken!} : null,
    };

    final _response = await http.post(
      Uri.parse('$baseUrl/changeActiveProfile'),
      headers: headers,
      body: json.encode({'profiles_id': profilesId}),
    );

    if (_response.statusCode != 200) {
      throw Exception('${_response.statusCode} ${_response.body}');
    }

    return true;
  }

  /// Return the entities list for the current user.
  /// Setting [isRecursive] to true will get the list of all the entities and sub-entities.
  /// Entities are under the key `myentities`
  /// Reference: [https://github.com/glpi-project/glpi/blob/master/apirest.md#get-my-entities](https://github.com/glpi-project/glpi/blob/master/apirest.md#get-my-entities)
  Future<Map<String, dynamic>> getMyEntities({bool isRecursive = false}) async {
    if (_sessionToken == null) {
      throw Exception('No session token, initSession first');
    }

    final Map<String, String> headers = {
      'Session-Token': _sessionToken!,
      'Content-Type': 'application/json',
      ...?appToken != null ? {'App-Token': appToken!} : null,
    };

    final _response = await http.get(
        Uri.parse('$baseUrl/getMyEntities?is_recursive=$isRecursive'),
        headers: headers);

    if (_response.statusCode != 200) {
      throw Exception('${_response.statusCode} ${_response.body}');
    }

    return json.decode(_response.body);
  }

  /// Return the current active entity for the current user as a [Map]
  /// Reference: [https://github.com/glpi-project/glpi/blob/master/apirest.md#get-active-entities](https://github.com/glpi-project/glpi/blob/master/apirest.md#get-active-entities)
  Future<Map<String, dynamic>> getActiveEntities() async {
    if (_sessionToken == null) {
      throw Exception('No session token, initSession first');
    }

    final Map<String, String> headers = {
      'Session-Token': _sessionToken!,
      'Content-Type': 'application/json',
      ...?appToken != null ? {'App-Token': appToken!} : null,
    };

    final _response = await http.get(Uri.parse('$baseUrl/getActiveEntities'),
        headers: headers);

    if (_response.statusCode != 200) {
      throw Exception('${_response.statusCode} ${_response.body}');
    }

    return json.decode(_response.body);
  }

  /// Allow to change the active entity for the current user.
  /// [entitiesId] can either be the numerical id of the entity or `all` to load all the entities.
  /// [recursive] can be set to true to load all the sub-entities.
  /// Will throw an [Exception] if the request fails or if the selected id is incorrect.
  /// Reference: [https://github.com/glpi-project/glpi/blob/master/apirest.md#change-active-entities](https://github.com/glpi-project/glpi/blob/master/apirest.md#change-active-entities)
  Future<bool> changeActiveEntities(dynamic entitiesId,
      {bool recursive = false}) async {
    if (_sessionToken == null) {
      throw Exception('No session token, initSession first');
    }

    final Map<String, String> headers = {
      'Session-Token': _sessionToken!,
      'Content-Type': 'application/json',
      ...?appToken != null ? {'App-Token': appToken!} : null,
    };

    final _response = await http.post(
      Uri.parse('$baseUrl/changeActiveEntities'),
      headers: headers,
      body: json.encode({'entities_id': entitiesId, 'is_recursive': recursive}),
    );

    if (_response.statusCode != 200) {
      throw Exception('${_response.statusCode} ${_response.body}');
    }

    return true;
  }

  /// Return the session data include in the php $_SESSION.
  /// For the moment it's just a [Map] of the json response.
  /// Reference: [https://github.com/glpi-project/glpi/blob/master/apirest.md#get-full-session](https://github.com/glpi-project/glpi/blob/master/apirest.md#get-full-session).
  Future<Map<String, dynamic>> getFullSession() async {
    if (_sessionToken!.isEmpty) {
      throw Exception('No session token, initSession first');
    }

    final Map<String, String> headers = {
      'Session-Token': _sessionToken!,
      'Content-Type': 'application/json',
      ...?appToken != null ? {'App-Token': appToken!} : null,
    };

    final response =
        await http.get(Uri.parse('$baseUrl/getFullSession'), headers: headers);

    if (response.statusCode != 200) {
      throw Exception('${response.statusCode} ${response.body}');
    }

    _session = json.decode(response.body);
    return Future.value(_session);
  }

  /// Return the Glpi instance configuration data inside a [Map].
  /// Reference: [https://github.com/glpi-project/glpi/blob/master/apirest.md#get-glpi-config](https://github.com/glpi-project/glpi/blob/master/apirest.md#get-glpi-config)
  Future<Map<String, dynamic>> getGlpiConfig() async {
    if (_sessionToken!.isEmpty) {
      throw Exception('No session token, initSession first');
    }

    final Map<String, String> headers = {
      'Session-Token': _sessionToken!,
      'Content-Type': 'application/json',
      ...?appToken != null ? {'App-Token': appToken!} : null,
    };

    final response =
        await http.get(Uri.parse('$baseUrl/getGlpiConfig'), headers: headers);

    if (response.statusCode != 200) {
      throw Exception('${response.statusCode} ${response.body}');
    }

    return json.decode(response.body);
  }

  /// Return an item identified by the [id] and of type [itemType]
  /// Will throw an [Exception] if the request fails or if the selected id is incorrect.
  /// [withDevices] will be ignored if the [itemtype] isn't [GlpiItemType.Computer],[GlpiItemType.NetworkEquipment],[GlpiItemType.Peripheral],[GlpiItemType.Phone] or [GlpiItemType.Printer].
  /// [withDisks], [withSoftwares], [withConnections] will be ignored if the [itemtype] isn't [GlpiItemType.Computer].
  /// Reference: [https://github.com/glpi-project/glpi/blob/master/apirest.md#get-an-item](https://github.com/glpi-project/glpi/blob/master/apirest.md#get-an-item)
  Future<Map<String, dynamic>> getItem(GlpiItemType itemtype, int id,
      {bool expandDropdowns = false,
      bool getHateoas = true,
      bool getSha1 = false,
      bool withDevices = false,
      bool withDisks = false,
      bool withSoftwares = false,
      bool withConnections = false,
      bool withNetworkPorts = false,
      bool withInfoComs = false,
      bool withContracts = false,
      bool withDocuments = false,
      bool withTickets = false,
      bool withProblems = false,
      bool withChanges = false,
      bool withNotes = false,
      bool withLogs = false,
      List<String>? addKeysNames}) async {
    if (_sessionToken!.isEmpty) {
      throw Exception('No session token, initSession first');
    }

    final Map<String, String> headers = {
      'Session-Token': _sessionToken!,
      'Content-Type': 'application/json',
      ...?appToken != null ? {'App-Token': appToken!} : null,
    };

    String uriStr =
        '$baseUrl/${itemtype.toString().split('.').last}/$id?expand_dropdowns=$expandDropdowns&get_hateoas=$getHateoas&get_sha1=$getSha1&with_networkports=$withNetworkPorts&';

    if (itemtype == GlpiItemType.Computer) {
      uriStr =
          '$uriStr&with_devices=$withDevices&with_disks=$withDisks&with_softwares=$withSoftwares&with_connections=$withConnections';
    } else if (itemtype == GlpiItemType.NetworkEquipment ||
        itemtype == GlpiItemType.Peripheral ||
        itemtype == GlpiItemType.Phone ||
        itemtype == GlpiItemType.Printer) {
      uriStr = '$uriStr&with_devices=$withDevices';
    }

    final uri = Uri.parse(uriStr);

    if (addKeysNames != null) {
      for (var key in addKeysNames) {
        uri.queryParameters.addAll({'add_keys_names[]': key});
      }
    }

    final response = await http.get(uri, headers: headers);

    if (response.statusCode != 200) {
      throw Exception('${response.statusCode} ${response.body}');
    }

    return Future.value(json.decode(response.body));
  }

  /// Return **ALL** the items of the given type the current user can see, depending on your server configuration and the number of items proceeded it may have unexpected results.
  /// [GlpiItemType] contains all the available item types according to the latest GLPI documentation.
  /// By default, only the 50 firts item will be returned. This can be changed by setting the [rangeStart] parameter and [rangeLimit] parameters.
  /// Reference: [https://github.com/glpi-project/glpi/blob/master/apirest.md#get-all-items](https://github.com/glpi-project/glpi/blob/master/apirest.md#get-all-items)
  Future<List<dynamic>> getAllItem(GlpiItemType itemType,
      {bool expandDropdowns = false,
      bool getHateoas = true,
      bool onlyId = false,
      int rangeStart = 0,
      int rangeLimit = 50,
      String sort = 'id',
      String order = 'ASC',
      String searchText = 'NULL',
      bool isDeleted = false,
      List? addKeysNames}) async {
    if (_sessionToken!.isEmpty) {
      throw Exception('No session token, initSession first');
    }

    final Map<String, String> headers = {
      'Session-Token': _sessionToken!,
      'Content-Type': 'application/json',
      ...?appToken != null ? {'App-Token': appToken!} : null,
    };

    final range = '$rangeStart-$rangeLimit';

    final uri = Uri.parse(
        '$baseUrl/${itemType.toString().split('.').last}?expand_dropdowns=$expandDropdowns&get_hateoas=$getHateoas&only_id=$onlyId&range=$range&sort=$sort&order=$order&searchText=$searchText&is_deleted=$isDeleted');

    if (addKeysNames != null) {
      for (var key in addKeysNames) {
        uri.queryParameters.addAll({'add_keys_names[]': key});
      }
    }

    final response = await http.get(uri, headers: headers);

    if (response.statusCode != 200 && response.statusCode != 206) {
      throw Exception('${response.statusCode} ${response.body}');
    }

    List<dynamic> decodedJson = json.decode(response.body);

    List<Map<String, dynamic>> formatted = decodedJson.map((element) {
      return element as Map<String, dynamic>;
    }).toList();

    return Future.value(formatted);
  }

  Future<List<Map<String, dynamic>>> getSubItems(
      GlpiItemType mainItemtype, int mainItemId, GlpiItemType subItemType,
      {bool expandDropdowns = false,
      bool getHateoas = true,
      bool onlyId = false,
      int rangeStart = 0,
      int rangeLimit = 50,
      String sort = 'id',
      String order = 'ASC',
      List? addKeysNames}) async {
    if (_sessionToken!.isEmpty) {
      throw Exception('No session token, initSession first');
    }

    final Map<String, String> headers = {
      'Session-Token': _sessionToken!,
      'Content-Type': 'application/json',
      ...?appToken != null ? {'App-Token': appToken!} : null,
    };

    final range = '$rangeStart-$rangeLimit';

    final uri = Uri.parse(
        '$baseUrl/${mainItemtype.toString().split('.').last}/$mainItemId/${subItemType.toString().split('.').last}?expand_dropdowns=$expandDropdowns&get_hateoas=$getHateoas&only_id=$onlyId&range=$range&sort=$sort&order=$order');

    if (addKeysNames != null) {
      for (var key in addKeysNames) {
        uri.queryParameters.addAll({'add_keys_names[]': key});
      }
    }

    final response = await http.get(uri, headers: headers);

    if (response.statusCode != 200 && response.statusCode != 206) {
      throw Exception('${response.statusCode} ${response.body}');
    }

    List<dynamic> decodedJson = json.decode(response.body);

    List<Map<String, dynamic>> formatted = decodedJson.map((element) {
      return element as Map<String, dynamic>;
    }).toList();

    return Future.value(formatted);
  }
}

/// GlpiClient implementation using the login method.
class _GlpiLoginClient extends GlpiClient {
  /// The username used for the login.
  final String username;

  /// The password used for the login.
  final String password;

  _GlpiLoginClient(String baseUrl, this.username, this.password,
      {String? appToken})
      : super._(baseUrl, appToken: appToken);

  /// This method will encode the login credentials in base64 format
  String _encodeLogin() => base64Encode(utf8.encode('$username:$password'));

  @override
  Future<String> initSession(
      {bool getFullSession = false, bool sendInQuery = false}) async {
    http.Response response;
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      ...?appToken != null ? {'App-Token': appToken!} : null,
    };

    if (sendInQuery) {
      response = await http.get(
          Uri.parse(
              '$baseUrl/initSession?get_full_session=$getFullSession&login=$username&password=$password'),
          headers: headers);
    } else {
      headers.putIfAbsent('Authorization', () => 'Basic ${_encodeLogin()}');

      response = await http.get(
          Uri.parse('$baseUrl/initSession?get_full_session=$getFullSession'),
          headers: headers);
    }

    if (response.statusCode != 200) {
      throw Exception('${response.statusCode} ${response.body}');
    }

    final _json = json.decode(response.body);

    _sessionToken = _json['session_token'] as String;

    if (getFullSession) {
      _session = jsonDecode(_json['session'] as String);
    }

    return Future.value(_sessionToken);
  }
}

/// This class will use the user token to get the session token.
class _GlpiTokenClient extends GlpiClient {
  final String userToken;

  _GlpiTokenClient(String baseUrl, this.userToken, String appToken)
      : super._(baseUrl, appToken: appToken);

  @override
  Future<String> initSession(
      {bool getFullSession = false, bool sendInQuery = false}) async {
    http.Response response;

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'App-Token': appToken!,
    };

    if (sendInQuery) {
      response = await http.get(
          Uri.parse(
              '$baseUrl/initSession?get_full_session=$getFullSession&user_token=$userToken'),
          headers: headers);
    } else {
      headers.putIfAbsent('Authorization', () => 'user_token $userToken');

      response = await http.get(
          Uri.parse('$baseUrl/initSession?get_full_session=$getFullSession'),
          headers: headers);
    }

    if (response.statusCode != 200) {
      throw Exception('${response.statusCode} ${response.body}');
    }
    final _json = json.decode(response.body);

    _sessionToken = _json['session_token'] as String;

    if (getFullSession) {
      _session = jsonDecode(_json['session'] as String);
    }

    return Future.value(_sessionToken);
  }
}
