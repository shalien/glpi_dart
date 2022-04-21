import 'dart:convert';

import 'package:http/http.dart';

import '../../glpi_dart.dart';

/// Represent the base client for all GLPI API calls.
abstract class GlpiClientBase implements GlpiClient {
  /// The server host should either end with `apirest.php` or redirect on it.
  final String _host;

  /// The server host should either end with `apirest.php` or redirect on it.
  @override
  String get host => _host;

  /// The [_innerClient] [Client] used to make the HTTP requests.
  /// On the browser, it is a [BrowserClient].
  /// On the server, it is a [IOClient].
  final Client _innerClient;

  /// The [appToken] used to authenticate the requests.
  /// Can be set either a construction or later
  @override
  String? appToken;

  /// The [sessionToken] used to authenticate the requests.
  /// Can be stored between session and used to construct a new client without calling [initSessionUserToken] or [initSessionUserToken].
  /// Can be set either a construction or later
  @override
  String? sessionToken;

  /// The constructor used in subclasses
  GlpiClientBase(this._innerClient, this._host,
      {this.appToken, this.sessionToken});

  /// Request a session token to uses other API endpoints using a [username] and [password].
  /// If [getFullSession] is set to true, will also return the session details in session.
  /// If [sendInQuery] is set to true, will send the credentials in the query string instead of the header.
  /// Will throw an [Exception] if the session can't be initialized.
  /// Reference: [https://github.com/glpi-project/glpi/blob/master/apirest.md#init-session](https://github.com/glpi-project/glpi/blob/master/apirest.md#init-session).
  @override
  Future<Map<String, dynamic>> initSessionUsernamePassword(
      String username, String password,
      {bool getFullSession = false, bool sendInQuery = false}) async {
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      ...?appToken != null ? {'App-Token': appToken!} : null,
      ...?!sendInQuery
          ? {
              'Authorization':
                  'Basic ${base64Encode(utf8.encode('$username:$password'))}'
            }
          : null,
    };

    final uri = sendInQuery
        ? '$host/initSession?get_full_session=$getFullSession&login=$username&password=$password'
        : '$host/initSession?get_full_session=$getFullSession';

    final response = await _innerClient.get(Uri.parse(uri), headers: headers);

    if (response.statusCode != 200) {
      throw GlpiException.fromResponse(
          response.statusCode, json.decode(response.body));
    }

    return Future.value(json.decode(response.body));
  }

  /// Request a session token to uses other API endpoints using a [userToken].
  /// If [getFullSession] is set to true, will also return the session details in session.
  /// If [sendInQuery] is set to true, will send the credentials in the query string instead of the header.
  /// Will throw an [Exception] if the session can't be initialized.
  /// Reference: [https://github.com/glpi-project/glpi/blob/master/apirest.md#init-session](https://github.com/glpi-project/glpi/blob/master/apirest.md#init-session).
  @override
  Future<Map<String, dynamic>> initSessionUserToken(String userToken,
      {bool getFullSession = false, bool sendInQuery = false}) async {
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      ...?appToken != null ? {'App-Token': appToken!} : null,
      ...?sendInQuery ? {'Authorization': 'user_token $userToken'} : null,
    };

    final uri = sendInQuery
        ? '$host/initSession?get_full_session=$getFullSession&user_token=$userToken'
        : '$host/initSession?get_full_session=$getFullSession';

    final response = await _innerClient.get(Uri.parse(uri), headers: headers);

    if (response.statusCode != 200) {
      throw GlpiException.fromResponse(
          response.statusCode, json.decode(response.body));
    }

    return Future.value(json.decode(response.body));
  }

  /// Return `true` if the client is successfully disconnected from the API.
  /// Will throw an [Exception] if the session can't be disconnected.
  /// Reference: [https://github.com/glpi-project/glpi/blob/master/apirest.md#kill-session](https://github.com/glpi-project/glpi/blob/master/apirest.md#kill-session).
  @override
  Future<bool> killSession() async {
    if (sessionToken == null) {
      throw Exception('No session token, initSession first');
    }

    final Map<String, String> headers = {
      'Session-Token': sessionToken!,
      'Content-Type': 'application/json',
      ...?appToken != null ? {'App-Token': appToken!} : null,
    };

    final _response = await _innerClient.get(Uri.parse('$host/killSession'),
        headers: headers);

    if (_response.statusCode != 200) {
      throw Exception('${_response.statusCode} ${_response.body}');
    }

    sessionToken = null;
    return true;
  }

  /// Allow to request a password reset for the account using the [email] address.
  /// Return true if the request is successful BUT this doesn't mean that your glpi is configured to send emails.
  /// Check the glpi's configuration to see the prerequisites (notifications need to be enabled).
  /// If [passwordForgetToken] AND [newPassword] are set, the password will be changed with the value of [newPassword] instead.
  /// Sending [passwordForgetToken] without [newPassword] and the opposite will throw an [ArgumentError].
  /// Reference: [https://github.com/glpi-project/glpi/blob/master/apirest.md#lost-password](https://github.com/glpi-project/glpi/blob/master/apirest.md#lost-password).
  @override
  Future<bool> lostPassword(String email,
      {String? passwordForgetToken, String? newPassword}) async {
    if (sessionToken == null) {
      throw Exception('No session token, initSession first');
    }

    // Unlike ALL the other method this one doesn't require any kind of authentication.
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    final body = {
      'email': email,
    };

    late Response response;

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
      response = await _innerClient.put(
        Uri.parse('$host/lostPassword'),
        headers: headers,
        body: json.encode(body),
      );
    } else {
      response = await _innerClient.put(Uri.parse('$host/lostPassword'),
          body: json.encode(body), headers: headers);
    }

    if (response.statusCode != 200) {
      throw GlpiException.fromResponse(
          response.statusCode, json.decode(response.body));
    }

    return true;
  }

  /// Return a [Map] of all the profile for the current user
  /// Profiles are under the key `myprofiles`
  /// Reference: [https://github.com/glpi-project/glpi/blob/master/apirest.md#get-my-profiles](https://github.com/glpi-project/glpi/blob/master/apirest.md#get-my-profiles).
  @override
  Future<Map<String, dynamic>> getMyProfiles() async {
    if (sessionToken == null) {
      throw Exception('No session token, initSession first');
    }

    final Map<String, String> headers = {
      'Session-Token': sessionToken!,
      'Content-Type': 'application/json',
      ...?appToken != null ? {'App-Token': appToken!} : null,
    };

    final _response = await _innerClient.get(Uri.parse('$host/getMyProfiles'),
        headers: headers);

    if (_response.statusCode != 200) {
      throw Exception('${_response.statusCode} ${_response.body}');
    }

    return json.decode(_response.body);
  }

  /// Return the current active profile for the current user as a [Map]
  /// Reference: [https://github.com/glpi-project/glpi/blob/master/apirest.md#get-active-profile](https://github.com/glpi-project/glpi/blob/master/apirest.md#get-active-profile)
  @override
  Future<Map<String, dynamic>> getActiveProfile() async {
    if (sessionToken == null) {
      throw Exception('No session token, initSession first');
    }

    final Map<String, String> headers = {
      'Session-Token': sessionToken!,
      'Content-Type': 'application/json',
      ...?appToken != null ? {'App-Token': appToken!} : null,
    };

    final _response = await _innerClient
        .get(Uri.parse('$host/getActiveProfile'), headers: headers);

    if (_response.statusCode != 200) {
      throw Exception('${_response.statusCode} ${_response.body}');
    }

    return json.decode(_response.body);
  }

  /// Change the active profile for the current user.
  /// Will throw an [Exception] if the request fails or if the selected id is incorrect.
  /// Reference: [https://github.com/glpi-project/glpi/blob/master/apirest.md#change-active-profile](https://github.com/glpi-project/glpi/blob/master/apirest.md#change-active-profile).
  @override
  Future<bool> changeActiveProfile(int profilesId) async {
    if (sessionToken == null) {
      throw Exception('No session token, initSession first');
    }

    final Map<String, String> headers = {
      'Session-Token': sessionToken!,
      'Content-Type': 'application/json',
      ...?appToken != null ? {'App-Token': appToken!} : null,
    };

    final _response = await _innerClient.post(
      Uri.parse('$host/changeActiveProfile'),
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
  @override
  Future<Map<String, dynamic>> getMyEntities({bool isRecursive = false}) async {
    if (sessionToken == null) {
      throw Exception('No session token, initSession first');
    }

    final Map<String, String> headers = {
      'Session-Token': sessionToken!,
      'Content-Type': 'application/json',
      ...?appToken != null ? {'App-Token': appToken!} : null,
    };

    final _response = await _innerClient.get(
        Uri.parse('$host/getMyEntities?is_recursive=$isRecursive'),
        headers: headers);

    if (_response.statusCode != 200) {
      throw Exception('${_response.statusCode} ${_response.body}');
    }

    return json.decode(_response.body);
  }

  /// Return the current active entity for the current user as a [Map]
  /// Reference: [https://github.com/glpi-project/glpi/blob/master/apirest.md#get-active-entities](https://github.com/glpi-project/glpi/blob/master/apirest.md#get-active-entities)
  @override
  Future<Map<String, dynamic>> getActiveEntities() async {
    if (sessionToken == null) {
      throw Exception('No session token, initSession first');
    }

    final Map<String, String> headers = {
      'Session-Token': sessionToken!,
      'Content-Type': 'application/json',
      ...?appToken != null ? {'App-Token': appToken!} : null,
    };

    final _response = await _innerClient
        .get(Uri.parse('$host/getActiveEntities'), headers: headers);

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
  @override
  Future<bool> changeActiveEntities(dynamic entitiesId,
      {bool recursive = false}) async {
    if (sessionToken == null) {
      throw Exception('No session token, initSession first');
    }

    final Map<String, String> headers = {
      'Session-Token': sessionToken!,
      'Content-Type': 'application/json',
      ...?appToken != null ? {'App-Token': appToken!} : null,
    };

    final _response = await _innerClient.post(
      Uri.parse('$host/changeActiveEntities'),
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
  @override
  Future<Map<String, dynamic>> getFullSession() async {
    if (sessionToken!.isEmpty) {
      throw Exception('No session token, initSession first');
    }

    final Map<String, String> headers = {
      'Session-Token': sessionToken!,
      'Content-Type': 'application/json',
      ...?appToken != null ? {'App-Token': appToken!} : null,
    };

    final response = await _innerClient.get(Uri.parse('$host/getFullSession'),
        headers: headers);

    if (response.statusCode != 200) {
      throw GlpiException.fromResponse(
          response.statusCode, json.decode(response.body));
    }

    return Future.value(json.decode(response.body));
  }

  /// Return the Glpi instance configuration data inside a [Map].
  /// Reference: [https://github.com/glpi-project/glpi/blob/master/apirest.md#get-glpi-config](https://github.com/glpi-project/glpi/blob/master/apirest.md#get-glpi-config)
  @override
  Future<Map<String, dynamic>> getGlpiConfig() async {
    if (sessionToken!.isEmpty) {
      throw Exception('No session token, initSession first');
    }

    final Map<String, String> headers = {
      'Session-Token': sessionToken!,
      'Content-Type': 'application/json',
      ...?appToken != null ? {'App-Token': appToken!} : null,
    };

    final response = await _innerClient.get(Uri.parse('$host/getGlpiConfig'),
        headers: headers);

    if (response.statusCode != 200) {
      throw GlpiException.fromResponse(
          response.statusCode, json.decode(response.body));
    }

    return json.decode(response.body);
  }

  /// Return an item identified by the [id] and of type [itemType]
  /// Will throw an [Exception] if the request fails or if the selected id is incorrect.
  /// [withDevices] will be ignored if the [itemtype] isn't [GlpiItemType.Computer],[GlpiItemType.NetworkEquipment],[GlpiItemType.Peripheral],[GlpiItemType.Phone] or [GlpiItemType.Printer].
  /// [withDisks], [withSoftwares], [withConnections] will be ignored if the [itemtype] isn't [GlpiItemType.Computer].
  /// Reference: [https://github.com/glpi-project/glpi/blob/master/apirest.md#get-an-item](https://github.com/glpi-project/glpi/blob/master/apirest.md#get-an-item)
  @override
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
    if (sessionToken!.isEmpty) {
      throw Exception('No session token, initSession first');
    }

    final Map<String, String> headers = {
      'Session-Token': sessionToken!,
      'Content-Type': 'application/json',
      ...?appToken != null ? {'App-Token': appToken!} : null,
    };

    String uriStr =
        '$host/${itemtype.toString().split('.').last}/$id?expand_dropdowns=$expandDropdowns&get_hateoas=$getHateoas&get_sha1=$getSha1&with_networkports=$withNetworkPorts&';

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

    final response = await _innerClient.get(uri, headers: headers);

    if (response.statusCode != 200) {
      throw GlpiException.fromResponse(
          response.statusCode, json.decode(response.body));
    }

    return Future.value(json.decode(response.body));
  }

  /// Return **ALL** the items of the given type the current user can see, depending on your server configuration and the number of items proceeded it may have unexpected results.
  /// [GlpiItemType] contains all the available item types according to the latest GLPI documentation.
  /// By default, only the 50 firsts item will be returned. This can be changed by setting the [rangeStart] parameter and [rangeLimit] parameters.
  /// Reference: [https://github.com/glpi-project/glpi/blob/master/apirest.md#get-all-items](https://github.com/glpi-project/glpi/blob/master/apirest.md#get-all-items)
  @override
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
    if (sessionToken!.isEmpty) {
      throw Exception('No session token, initSession first');
    }

    final Map<String, String> headers = {
      'Session-Token': sessionToken!,
      'Content-Type': 'application/json',
      ...?appToken != null ? {'App-Token': appToken!} : null,
    };

    final range = '$rangeStart-$rangeLimit';

    final uri = Uri.parse(
        '$host/${itemType.toString().split('.').last}?expand_dropdowns=$expandDropdowns&get_hateoas=$getHateoas&only_id=$onlyId&range=$range&sort=$sort&order=$order&searchText=$searchText&is_deleted=$isDeleted');

    if (addKeysNames != null) {
      for (var key in addKeysNames) {
        uri.queryParameters.addAll({'add_keys_names[]': key});
      }
    }

    final response = await _innerClient.get(uri, headers: headers);

    if (response.statusCode != 200 && response.statusCode != 206) {
      throw GlpiException.fromResponse(
          response.statusCode, json.decode(response.body));
    }

    List<dynamic> decodedJson = json.decode(response.body);

    List<Map<String, dynamic>> formatted = decodedJson.map((element) {
      return element as Map<String, dynamic>;
    }).toList();

    return Future.value(formatted);
  }

  /// Return the sub-items of [subItemType] the item identified by the [mainItemId] and of type [mainItemtype]
  /// Will throw an [Exception] if the request fails or if the selected id is incorrect.
  /// Reference: [https://github.com/glpi-project/glpi/blob/master/apirest.md#get-sub-items](https://github.com/glpi-project/glpi/blob/master/apirest.md#get-sub-items)
  @override
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
    if (sessionToken!.isEmpty) {
      throw Exception('No session token, initSession first');
    }

    final Map<String, String> headers = {
      'Session-Token': sessionToken!,
      'Content-Type': 'application/json',
      ...?appToken != null ? {'App-Token': appToken!} : null,
    };

    final range = '$rangeStart-$rangeLimit';

    final uri = Uri.parse(
        '$host/${mainItemtype.toString().split('.').last}/$mainItemId/${subItemType.toString().split('.').last}?expand_dropdowns=$expandDropdowns&get_hateoas=$getHateoas&only_id=$onlyId&range=$range&sort=$sort&order=$order');

    if (addKeysNames != null) {
      for (var key in addKeysNames) {
        uri.queryParameters.addAll({'add_keys_names[]': key});
      }
    }

    final response = await _innerClient.get(uri, headers: headers);

    if (response.statusCode != 200 && response.statusCode != 206) {
      throw GlpiException.fromResponse(
          response.statusCode, json.decode(response.body));
    }

    List<dynamic> decodedJson = json.decode(response.body);

    List<Map<String, dynamic>> formatted = decodedJson.map((element) {
      return element as Map<String, dynamic>;
    }).toList();

    return Future.value(formatted);
  }

  /// Return multiples items from many types.
  /// You must pass a [List] of [Map] with the following structure a [GlpiItemType] as the key and the id of the item as the value.
  /// Reference: [https://github.com/glpi-project/glpi/blob/master/apirest.md#get-multiple-items](https://github.com/glpi-project/glpi/blob/master/apirest.md#get-multiple-items).
  @override
  Future<List<Map<String, dynamic>>> getMultipleItems(
      List<Map<GlpiItemType, int>> items,
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
    if (sessionToken!.isEmpty) {
      throw Exception('No session token, initSession first');
    }

    final Map<String, String> headers = {
      'Session-Token': sessionToken!,
      'Content-Type': 'application/json',
      ...?appToken != null ? {'App-Token': appToken!} : null,
    };

    String itemsUrl = '';

    for (var i = 0; i < items.length; i++) {
      final type = items[i].keys.first.name.split('.').last;
      final id = items[i].values.first;

      itemsUrl += 'items[$i][itemtype]=$type&items[$i][items_id]=$id&';
    }

    String uriStr =
        '$host/getMultipleItems?${itemsUrl}expand_dropdowns=$expandDropdowns&get_hateoas=$getHateoas&get_sha1=$getSha1&with_networkports=$withNetworkPorts&';

    uriStr =
        '$uriStr&with_devices=$withDevices&with_disks=$withDisks&with_softwares=$withSoftwares&with_connections=$withConnections';

    print(uriStr);

    final uri = Uri.parse(uriStr);

    if (addKeysNames != null) {
      for (var key in addKeysNames) {
        uri.queryParameters.addAll({'add_keys_names[]': key});
      }
    }

    final response = await _innerClient.get(uri, headers: headers);

    if (response.statusCode != 200 && response.statusCode != 206) {
      throw GlpiException.fromResponse(
          response.statusCode, json.decode(response.body));
    }

    List<dynamic> decodedJson = json.decode(response.body);

    List<Map<String, dynamic>> formatted = decodedJson.map((element) {
      return element as Map<String, dynamic>;
    }).toList();

    return Future.value(formatted);
  }

  /// Return all the searchOptions usable in [searchItems] criteria for a given [GlpiItemType].
  @override
  Future<Map<String, dynamic>> listSearchOptions(GlpiItemType itemType) async {
    if (sessionToken!.isEmpty) {
      throw Exception('No session token, initSession first');
    }

    final Map<String, String> headers = {
      'Session-Token': sessionToken!,
      'Content-Type': 'application/json',
      ...?appToken != null ? {'App-Token': appToken!} : null,
    };

    final uri = Uri.parse(
        '$host/listSearchOptions/${itemType.toString().split('.').last}');

    final response = await _innerClient.get(uri, headers: headers);

    if (response.statusCode != 200 && response.statusCode != 206) {
      throw GlpiException.fromResponse(
          response.statusCode, json.decode(response.body));
    }

    return Future.value(json.decode(response.body));
  }

  /// ** This method is untested for the moment **
  /// Return items found using the GLPI searchEngine
  /// Reference: [https://github.com/glpi-project/glpi/blob/master/apirest.md#search-items](https://github.com/glpi-project/glpi/blob/master/apirest.md#search-items)
  @override
  Future<Map<String, dynamic>> search(
    GlpiItemType itemType, {
    List<GlpiSearchCriteria>? criteria,
    List<GlpiSearchCriteria>? metaCriteria,
    int sort = 1,
    String order = 'ASC',
    int rangeStart = 0,
    int rangeLimit = 50,
    List<String>? forceDisplay = const [],
    bool rawData = false,
    bool withIndexes = false,
    bool uidCols = false,
    bool giveItems = false,
  }) async {
    if (sessionToken!.isEmpty) {
      throw Exception('No session token, initSession first');
    }

    final Map<String, String> headers = {
      'Session-Token': sessionToken!,
      'Content-Type': 'application/json',
      ...?appToken != null ? {'App-Token': appToken!} : null,
    };

    final queryParameters = <String, String>{};
    if (criteria != null) {
      for (var i = 0; i < criteria.length; i++) {
        queryParameters.addAll(criteria[i].toUrlParameters(i));
      }
    }

    if (metaCriteria != null) {
      for (var i = 0; i < metaCriteria.length; i++) {
        queryParameters.addAll(metaCriteria[i].toUrlParameters(i));
      }
    }

    if (forceDisplay != null) {
      for (var i = 0; i < forceDisplay.length; i++) {
        queryParameters.addAll({'force_display[$i]': forceDisplay[i]});
      }
    }

    final queryUrl = queryParameters.isNotEmpty
        ? '&${queryParameters.keys.map((key) => '$key=${queryParameters[key]}').join('&')}'
        : '';

    final uri = Uri.parse(
        '$host/search/${itemType.toString().split('.').last}?sort=$sort&order=$order&range$rangeStart-$rangeLimit&raw_data=$rawData&with_indexes=$withIndexes&uid_cols=$uidCols&give_items=$giveItems$queryUrl');

    final response = await _innerClient.get(uri, headers: headers);

    if (response.statusCode != 200 && response.statusCode != 206) {
      throw GlpiException.fromResponse(
          response.statusCode, json.decode(response.body));
    }

    return Future.value(json.decode(response.body));
  }

  /// Return the id(s) of the item(s) added using the [data] as input.
  /// **Don't use this method to upload a document**
  /// To correctly format the data, see the examples and the documentation.
  /// Reference: [https://github.com/glpi-project/glpi/blob/master/apirest.md#add-items](https://github.com/glpi-project/glpi/blob/master/apirest.md#add-items)
  @override
  Future<List<Map<String, String>>> addItems(
      GlpiItemType itemType, String data) async {
    if (sessionToken!.isEmpty) {
      throw Exception('No session token, initSession first');
    }

    final Map<String, String> headers = {
      'Session-Token': sessionToken!,
      'Content-Type': 'application/json',
      ...?appToken != null ? {'App-Token': appToken!} : null,
    };

    final uri = Uri.parse('$host/${itemType.toString().split('.').last}');

    final response = await _innerClient.post(uri, headers: headers, body: data);

    if (response.statusCode != 200 && response.statusCode != 207) {
      throw GlpiException.fromResponse(
          response.statusCode, json.decode(response.body));
    }

    List<dynamic> decodedJson = json.decode(response.body);

    List<Map<String, String>> formatted = decodedJson.map((element) {
      return element as Map<String, String>;
    }).toList();

    return Future.value(formatted);
  }

  /// Return an array with the updated item [id] and a message.
  /// To correctly format the data, see the examples and the documentation.
  /// Reference: [https://github.com/glpi-project/glpi/blob/master/apirest.md#update-items](https://github.com/glpi-project/glpi/blob/master/apirest.md#update-items)
  @override
  Future<Map<String, String>> updateItem(
      GlpiItemType itemType, int id, Map<String, dynamic> data) async {
    if (sessionToken!.isEmpty) {
      throw Exception('No session token, initSession first');
    }

    final Map<String, String> headers = {
      'Session-Token': sessionToken!,
      'Content-Type': 'application/json',
      ...?appToken != null ? {'App-Token': appToken!} : null,
    };

    final uri = Uri.parse('$host/${itemType.toString().split('.').last}/$id');

    final response =
        await _innerClient.put(uri, headers: headers, body: json.encode(data));

    if (response.statusCode != 200 && response.statusCode != 207) {
      throw GlpiException.fromResponse(
          response.statusCode, json.decode(response.body));
    }

    return Future.value(json.decode(response.body));
  }

  /// Return the id(s) of the item(s) updated using the [data] as input.
  /// To correctly format the data, see the examples and the documentation.
  /// Reference: [https://github.com/glpi-project/glpi/blob/master/apirest.md#update-items](https://github.com/glpi-project/glpi/blob/master/apirest.md#update-items)
  @override
  Future<List<Map<String, String>>> updateItems(
      GlpiItemType itemType, String data) async {
    if (sessionToken!.isEmpty) {
      throw Exception('No session token, initSession first');
    }

    final Map<String, String> headers = {
      'Session-Token': sessionToken!,
      'Content-Type': 'application/json',
      ...?appToken != null ? {'App-Token': appToken!} : null,
    };

    final uri = Uri.parse('$host/${itemType.toString().split('.').last}');

    final response = await _innerClient.put(uri, headers: headers, body: data);

    if (response.statusCode != 200 && response.statusCode != 207) {
      throw GlpiException.fromResponse(
          response.statusCode, json.decode(response.body));
    }

    List<dynamic> decodedJson = json.decode(response.body);

    List<Map<String, String>> formatted = decodedJson.map((element) {
      return element as Map<String, String>;
    }).toList();

    return Future.value(formatted);
  }

  /// Return the [id] of the item deleted with true is the deletion is complete.
  /// [forcePurge] will delete the item permanently.
  /// [history] set to false will prevent the deletion from being added to the global history.
  @override
  Future<Map<String, String>> deleteItem(GlpiItemType itemType, int id,
      {bool forcePurge = false, bool history = true}) async {
    if (sessionToken!.isEmpty) {
      throw Exception('No session token, initSession first');
    }

    final Map<String, String> headers = {
      'Session-Token': sessionToken!,
      'Content-Type': 'application/json',
      ...?appToken != null ? {'App-Token': appToken!} : null,
    };

    final uri = Uri.parse(
        '$host/${itemType.toString().split('.').last}/$id?force_purge=$forcePurge&history=$history');

    final response = await _innerClient.delete(uri, headers: headers);

    if (response.statusCode != 200 &&
        response.statusCode != 204 &&
        response.statusCode != 207) {
      throw GlpiException.fromResponse(
          response.statusCode, json.decode(response.body));
    }

    return Future.value(json.decode(response.body));
  }

  /// Return the ids of the items deleted with true is the deletion is complete.
  /// Reference: [https://github.com/glpi-project/glpi/blob/master/apirest.md#delete-items](https://github.com/glpi-project/glpi/blob/master/apirest.md#delete-items)
  @override
  Future<List<Map<String, String>>> deleteItems(
      GlpiItemType itemType, String data) async {
    if (sessionToken!.isEmpty) {
      throw Exception('No session token, initSession first');
    }

    final Map<String, String> headers = {
      'Session-Token': sessionToken!,
      'Content-Type': 'application/json',
      ...?appToken != null ? {'App-Token': appToken!} : null,
    };

    final uri = Uri.parse('$host/${itemType.toString().split('.').last}');

    final response =
        await _innerClient.delete(uri, headers: headers, body: data);

    if (response.statusCode != 200 &&
        response.statusCode != 204 &&
        response.statusCode != 207) {
      throw GlpiException.fromResponse(
          response.statusCode, json.decode(response.body));
    }

    List<dynamic> decodedJson = json.decode(response.body);

    List<Map<String, String>> formatted = decodedJson.map((element) {
      return element as Map<String, String>;
    }).toList();

    return Future.value(formatted);
  }

  /// Return the available massive actions for a given [itemtype]
  /// [isDeleted] (default false): Show specific actions for items in the trash bin
  /// Reference: [https://github.com/glpi-project/glpi/blob/master/apirest.md#get-available-massive-actions-for-an-itemtype](https://github.com/glpi-project/glpi/blob/master/apirest.md#get-available-massive-actions-for-an-itemtype)
  @override
  Future<List<Map<String, String>>> getMassiveActions(GlpiItemType itemType,
      {bool isDeleted = false}) async {
    if (sessionToken!.isEmpty) {
      throw Exception('No session token, initSession first');
    }

    final Map<String, String> headers = {
      'Session-Token': sessionToken!,
      'Content-Type': 'application/json',
      ...?appToken != null ? {'App-Token': appToken!} : null,
    };

    final uri = Uri.parse(
        '$host/getMassiveActions/${itemType.toString().split('.').last}?is_deleted=$isDeleted');

    final response = await _innerClient.get(uri, headers: headers);

    if (response.statusCode != 200 && response.statusCode != 207) {
      throw GlpiException.fromResponse(
          response.statusCode, json.decode(response.body));
    }

    List<dynamic> decodedJson = json.decode(response.body);

    List<Map<String, String>> formatted = decodedJson.map((element) {
      return element as Map<String, String>;
    }).toList();

    return Future.value(formatted);
  }

  /// Return the awaitables massive actions for a given [itemType] and [id].
  /// Reference: [https://github.com/glpi-project/glpi/blob/master/apirest.md#get-available-massive-actions-for-an-item](https://github.com/glpi-project/glpi/blob/master/apirest.md#get-available-massive-actions-for-an-item)
  @override
  Future<List<Map<String, String>>> getMassiveActionsItem(
      GlpiItemType itemType, int id) async {
    if (sessionToken!.isEmpty) {
      throw Exception('No session token, initSession first');
    }

    final Map<String, String> headers = {
      'Session-Token': sessionToken!,
      'Content-Type': 'application/json',
      ...?appToken != null ? {'App-Token': appToken!} : null,
    };

    final uri = Uri.parse(
        '$host/getMassiveActions/${itemType.toString().split('.').last}/$id');

    final response = await _innerClient.get(uri, headers: headers);

    if (response.statusCode != 200 && response.statusCode != 207) {
      throw GlpiException.fromResponse(
          response.statusCode, json.decode(response.body));
    }

    List<dynamic> decodedJson = json.decode(response.body);

    List<Map<String, String>> formatted = decodedJson.map((element) {
      return element as Map<String, String>;
    }).toList();

    return Future.value(formatted);
  }

  /// Show the awaitables parameters for a given massive action
  /// **Warning: experimental endpoint, some required parameters may be missing from the returned content.**
  /// Reference: [https://github.com/glpi-project/glpi/blob/master/apirest.md#get-massive-action-parameters](https://github.com/glpi-project/glpi/blob/master/apirest.md#get-massive-action-parameters)
  @override
  Future<List<Map<String, String>>> getMassiveActionParameters(
      GlpiItemType itemType, String massiveActionName) async {
    if (sessionToken!.isEmpty) {
      throw Exception('No session token, initSession first');
    }

    final Map<String, String> headers = {
      'Session-Token': sessionToken!,
      'Content-Type': 'application/json',
      ...?appToken != null ? {'App-Token': appToken!} : null,
    };

    final uri = Uri.parse(
        '$host/getMassiveActionParameters/${itemType.toString().split('.').last}/$massiveActionName');

    final response = await _innerClient.get(uri, headers: headers);

    if (response.statusCode != 200 && response.statusCode != 207) {
      throw GlpiException.fromResponse(
          response.statusCode, json.decode(response.body));
    }

    List<dynamic> decodedJson = json.decode(response.body);

    List<Map<String, String>> formatted = decodedJson.map((element) {
      return element as Map<String, String>;
    }).toList();

    return Future.value(formatted);
  }

  /// Run the given massive action
  /// [payload] Must be a json string with the parameters for the action and the ids of the items to apply the action to.
  /// Reference: [https://github.com/glpi-project/glpi/blob/master/apirest.md#apply-massive-action](https://github.com/glpi-project/glpi/blob/master/apirest.md#apply-massive-action)
  @override
  Future<Map<String, dynamic>> applyMassiveActions(
      GlpiItemType itemType, String massiveActionName, String payload) async {
    if (sessionToken!.isEmpty) {
      throw Exception('No session token, initSession first');
    }

    final Map<String, String> headers = {
      'Session-Token': sessionToken!,
      'Content-Type': 'application/json',
      ...?appToken != null ? {'App-Token': appToken!} : null,
    };

    final uri = Uri.parse(
        '$host/applyMassiveActions/${itemType.toString().split('.').last}/$massiveActionName');

    final response =
        await _innerClient.post(uri, headers: headers, body: payload);

    if (response.statusCode != 200 && response.statusCode != 207) {
      throw GlpiException.fromResponse(
          response.statusCode, json.decode(response.body));
    }

    Map<String, dynamic> decodedJson = json.decode(response.body);

    return Future.value(decodedJson);
  }

  /// Allow to download a [GlpiItemType.Document].
  /// [id] must be the id of the document to download.
  /// Reference: [https://github.com/glpi-project/glpi/blob/master/apirest.md#download-a-document-file](https://github.com/glpi-project/glpi/blob/master/apirest.md#download-a-document-file)
  @override
  Future<String> downloadDocument(int id) async {
    if (sessionToken!.isEmpty) {
      throw Exception('No session token, initSession first');
    }

    final Map<String, String> headers = {
      'Session-Token': sessionToken!,
      'Content-Type': 'application/json',
      'Accept': 'application/octet-stream',
      ...?appToken != null ? {'App-Token': appToken!} : null,
    };

    final uri = Uri.parse('$host/Document/$id');

    final response = await _innerClient.get(uri, headers: headers);

    if (response.statusCode != 200 && response.statusCode != 207) {
      throw GlpiException.fromResponse(
          response.statusCode, json.decode(response.body));
    }

    return Future.value(response.body);
  }

  /// Get a user's profile picture.
  /// [id] must be the id of the user to get the picture.
  /// Reference: [https://github.com/glpi-project/glpi/blob/master/apirest.md#get-a-users-profile-picture](https://github.com/glpi-project/glpi/blob/master/apirest.md#get-a-users-profile-picture)
  @override
  Future<String> getUserProfilePicture(int id) async {
    if (sessionToken!.isEmpty) {
      throw Exception('No session token, initSession first');
    }

    final Map<String, String> headers = {
      'Session-Token': sessionToken!,
      'Content-Type': 'application/json',
      ...?appToken != null ? {'App-Token': appToken!} : null,
    };

    final uri = Uri.parse('$host/User/$id/Picture');

    final response = await _innerClient.get(uri, headers: headers);

    if (response.statusCode != 200 && response.statusCode != 207) {
      throw GlpiException.fromResponse(
          response.statusCode, json.decode(response.body));
    }

    return Future.value(response.body);
  }
}
