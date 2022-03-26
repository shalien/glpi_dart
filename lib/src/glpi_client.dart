import 'dart:async';
import 'dart:convert';
import 'package:glpi_dart/glpi.dart';
import 'package:http/http.dart' as http;

import 'dart:io' if (dart.library.js) 'dart:html';

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

  /// Request a session token to uses other API endpoints.
  /// The token will be stored in the [sessionToken] field automatically and used for all the following requests.
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
      throw GlpiException.fromResponse(
          response.statusCode, json.decode(response.body));
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
      throw GlpiException.fromResponse(
          response.statusCode, json.decode(response.body));
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
      throw GlpiException.fromResponse(
          response.statusCode, json.decode(response.body));
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
    if (_sessionToken!.isEmpty) {
      throw Exception('No session token, initSession first');
    }

    final Map<String, String> headers = {
      'Session-Token': _sessionToken!,
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
        '$baseUrl/getMultipleItems?${itemsUrl}expand_dropdowns=$expandDropdowns&get_hateoas=$getHateoas&get_sha1=$getSha1&with_networkports=$withNetworkPorts&';

    uriStr =
        '$uriStr&with_devices=$withDevices&with_disks=$withDisks&with_softwares=$withSoftwares&with_connections=$withConnections';

    print(uriStr);

    final uri = Uri.parse(uriStr);

    if (addKeysNames != null) {
      for (var key in addKeysNames) {
        uri.queryParameters.addAll({'add_keys_names[]': key});
      }
    }

    final response = await http.get(uri, headers: headers);

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
  Future<Map<String, dynamic>> listSearchOptions(GlpiItemType itemType) async {
    if (_sessionToken!.isEmpty) {
      throw Exception('No session token, initSession first');
    }

    final Map<String, String> headers = {
      'Session-Token': _sessionToken!,
      'Content-Type': 'application/json',
      ...?appToken != null ? {'App-Token': appToken!} : null,
    };

    final uri = Uri.parse(
        '$baseUrl/listSearchOptions/${itemType.toString().split('.').last}');

    final response = await http.get(uri, headers: headers);

    if (response.statusCode != 200 && response.statusCode != 206) {
      throw GlpiException.fromResponse(
          response.statusCode, json.decode(response.body));
    }

    return Future.value(json.decode(response.body));
  }

  /// ** This method is untested for the moment **
  /// Return items found using the GLPI searchEngine
  /// Reference: [https://github.com/glpi-project/glpi/blob/master/apirest.md#search-items](https://github.com/glpi-project/glpi/blob/master/apirest.md#search-items)
  Future<Map<String, dynamic>> searchItems(
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
    if (_sessionToken!.isEmpty) {
      throw Exception('No session token, initSession first');
    }

    final Map<String, String> headers = {
      'Session-Token': _sessionToken!,
      'Content-Type': 'application/json',
      ...?appToken != null ? {'App-Token': appToken!} : null,
    };

    final uri = Uri.parse(
        '$baseUrl/searchItems/${itemType.toString().split('.').last}?sort=$sort&order=$order&range_start=$rangeStart&range_limit=$rangeLimit&raw_data=$rawData&with_indexes=$withIndexes&uid_cols=$uidCols&give_items=$giveItems');

    if (criteria != null) {
      for (var i = 0; i < criteria.length; i++) {
        uri.queryParameters.addAll(criteria[i].toUrlParameters(i));
      }
    }

    if (metaCriteria != null) {
      for (var i = 0; i < metaCriteria.length; i++) {
        uri.queryParameters.addAll(metaCriteria[i].toUrlParameters(i));
      }
    }

    if (forceDisplay != null) {
      for (var i = 0; i < forceDisplay.length; i++) {
        uri.queryParameters.addAll({'force_display[$i]': forceDisplay[i]});
      }
    }

    final response = await http.get(uri, headers: headers);

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
  Future<List<Map<String, String>>> addItems(
      GlpiItemType itemType, String data) async {
    if (_sessionToken!.isEmpty) {
      throw Exception('No session token, initSession first');
    }

    final Map<String, String> headers = {
      'Session-Token': _sessionToken!,
      'Content-Type': 'application/json',
      ...?appToken != null ? {'App-Token': appToken!} : null,
    };

    final uri = Uri.parse('$baseUrl/${itemType.toString().split('.').last}');

    final response = await http.post(uri, headers: headers, body: data);

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

  /// Return an arrray with the updated item [id] and a message.
  /// To correctly format the data, see the examples and the documentation.
  /// Reference: [https://github.com/glpi-project/glpi/blob/master/apirest.md#update-items](https://github.com/glpi-project/glpi/blob/master/apirest.md#update-items)
  Future<Map<String, String>> updateItem(
      GlpiItemType itemType, int id, Map<String, dynamic> data) async {
    if (_sessionToken!.isEmpty) {
      throw Exception('No session token, initSession first');
    }

    final Map<String, String> headers = {
      'Session-Token': _sessionToken!,
      'Content-Type': 'application/json',
      ...?appToken != null ? {'App-Token': appToken!} : null,
    };

    final uri =
        Uri.parse('$baseUrl/${itemType.toString().split('.').last}/$id');

    final response =
        await http.put(uri, headers: headers, body: json.encode(data));

    if (response.statusCode != 200 && response.statusCode != 207) {
      throw GlpiException.fromResponse(
          response.statusCode, json.decode(response.body));
    }

    return Future.value(json.decode(response.body));
  }

  /// Return the id(s) of the item(s) updated using the [data] as input.
  /// To correctly format the data, see the examples and the documentation.
  /// Reference: [https://github.com/glpi-project/glpi/blob/master/apirest.md#update-items](https://github.com/glpi-project/glpi/blob/master/apirest.md#update-items)
  Future<List<Map<String, String>>> updateItems(
      GlpiItemType itemType, String data) async {
    if (_sessionToken!.isEmpty) {
      throw Exception('No session token, initSession first');
    }

    final Map<String, String> headers = {
      'Session-Token': _sessionToken!,
      'Content-Type': 'application/json',
      ...?appToken != null ? {'App-Token': appToken!} : null,
    };

    final uri = Uri.parse('$baseUrl/${itemType.toString().split('.').last}');

    final response = await http.put(uri, headers: headers, body: data);

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
  Future<Map<String, String>> deleteItem(GlpiItemType itemType, int id,
      {bool forcePurge = false, bool history = true}) async {
    if (_sessionToken!.isEmpty) {
      throw Exception('No session token, initSession first');
    }

    final Map<String, String> headers = {
      'Session-Token': _sessionToken!,
      'Content-Type': 'application/json',
      ...?appToken != null ? {'App-Token': appToken!} : null,
    };

    final uri = Uri.parse(
        '$baseUrl/${itemType.toString().split('.').last}/$id?force_purge=$forcePurge&history=$history');

    final response = await http.delete(uri, headers: headers);

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
  Future<List<Map<String, String>>> deleteItems(
      GlpiItemType itemType, String data) async {
    if (_sessionToken!.isEmpty) {
      throw Exception('No session token, initSession first');
    }

    final Map<String, String> headers = {
      'Session-Token': _sessionToken!,
      'Content-Type': 'application/json',
      ...?appToken != null ? {'App-Token': appToken!} : null,
    };

    final uri = Uri.parse('$baseUrl/${itemType.toString().split('.').last}');

    final response = await http.delete(uri, headers: headers, body: data);

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

  /// Return the availables massive actions for a given [itemtype]
  /// [isDeleted] (default false): Show specific actions for items in the trashbin
  /// Reference: [https://github.com/glpi-project/glpi/blob/master/apirest.md#get-available-massive-actions-for-an-itemtype](https://github.com/glpi-project/glpi/blob/master/apirest.md#get-available-massive-actions-for-an-itemtype)
  Future<List<Map<String, String>>> getMassiveActions(GlpiItemType itemType,
      {bool isDeleted = false}) async {
    if (_sessionToken!.isEmpty) {
      throw Exception('No session token, initSession first');
    }

    final Map<String, String> headers = {
      'Session-Token': _sessionToken!,
      'Content-Type': 'application/json',
      ...?appToken != null ? {'App-Token': appToken!} : null,
    };

    final uri = Uri.parse(
        '$baseUrl/getMassiveActions/${itemType.toString().split('.').last}?is_deleted=$isDeleted');

    final response = await http.get(uri, headers: headers);

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

  /// Return the availables massive actions for a given [itemType] and [id].
  /// Reference: [https://github.com/glpi-project/glpi/blob/master/apirest.md#get-available-massive-actions-for-an-item](https://github.com/glpi-project/glpi/blob/master/apirest.md#get-available-massive-actions-for-an-item)
  Future<List<Map<String, String>>> getMassiveActionsItem(
      GlpiItemType itemType, int id) async {
    if (_sessionToken!.isEmpty) {
      throw Exception('No session token, initSession first');
    }

    final Map<String, String> headers = {
      'Session-Token': _sessionToken!,
      'Content-Type': 'application/json',
      ...?appToken != null ? {'App-Token': appToken!} : null,
    };

    final uri = Uri.parse(
        '$baseUrl/getMassiveActions/${itemType.toString().split('.').last}/$id');

    final response = await http.get(uri, headers: headers);

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

  /// Show the availables parameters for a given massive action
  /// **Warning: experimental endpoint, some required parameters may be missing from the returned content.**
  /// Reference: [https://github.com/glpi-project/glpi/blob/master/apirest.md#get-massive-action-parameters](https://github.com/glpi-project/glpi/blob/master/apirest.md#get-massive-action-parameters)
  Future<List<Map<String, String>>> getMassiveActionParameters(
      GlpiItemType itemType, String massiveActionName) async {
    if (_sessionToken!.isEmpty) {
      throw Exception('No session token, initSession first');
    }

    final Map<String, String> headers = {
      'Session-Token': _sessionToken!,
      'Content-Type': 'application/json',
      ...?appToken != null ? {'App-Token': appToken!} : null,
    };

    final uri = Uri.parse(
        '$baseUrl/getMassiveActionParameters/${itemType.toString().split('.').last}/$massiveActionName');

    final response = await http.get(uri, headers: headers);

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
  Future<Map<String, dynamic>> applyMassiveActions(
      GlpiItemType itemType, String massiveActionName, String payload) async {
    if (_sessionToken!.isEmpty) {
      throw Exception('No session token, initSession first');
    }

    final Map<String, String> headers = {
      'Session-Token': _sessionToken!,
      'Content-Type': 'application/json',
      ...?appToken != null ? {'App-Token': appToken!} : null,
    };

    final uri = Uri.parse(
        '$baseUrl/applyMassiveActions/${itemType.toString().split('.').last}/$massiveActionName');

    final response = await http.post(uri, headers: headers, body: payload);

    if (response.statusCode != 200 && response.statusCode != 207) {
      throw GlpiException.fromResponse(
          response.statusCode, json.decode(response.body));
    }

    Map<String, dynamic> decodedJson = json.decode(response.body);

    return Future.value(decodedJson);
  }

  /// Allow to upload a [GlpiItemType.Document].
  /// [file] must be a [File] object.
  /// Reference: [https://github.com/glpi-project/glpi/blob/master/apirest.md#upload-a-document-file](https://github.com/glpi-project/glpi/blob/master/apirest.md#upload-a-document-file)
  Future<Map<String, dynamic>> uploadDocument(
    File file,
  ) async {
    if (_sessionToken!.isEmpty) {
      throw Exception('No session token, initSession first');
    }

    final Map<String, String> headers = {
      'Session-Token': _sessionToken!,
      'Content-Type': 'multipart/form-data',
      ...?appToken != null ? {'App-Token': appToken!} : null,
    };

    final uri = Uri.parse('$baseUrl/Document');

    final payload = json.encode({
      'input': {
        'name': file.path.split('/').last,
        '_filename': [base64Encode(file.readAsBytesSync())],
      }
    });

    final uploadManifest = '$payload;type=application/json';

    final request = http.MultipartRequest('POST', uri)
      ..headers.addAll(headers)
      ..fields['uploadManifest'] = uploadManifest
      ..files.add(http.MultipartFile.fromBytes(
        'file',
        file.readAsBytesSync(),
        filename: file.path.split('/').last,
      ));

    final response = await request.send();

    final body = await response.stream.transform(utf8.decoder).join();

    if (response.statusCode != 200 && response.statusCode != 207) {
      throw Exception('${response.statusCode} $body');
    }

    Map<String, dynamic> decodedJson = json.decode(body);

    return Future.value(decodedJson);
  }

  /// Allow to download a [GlpiItemType.Document].
  /// [id] must be the id of the document to download.
  /// Reference: [https://github.com/glpi-project/glpi/blob/master/apirest.md#download-a-document-file](https://github.com/glpi-project/glpi/blob/master/apirest.md#download-a-document-file)
  Future<String> downloadDocument(int id) async {
    if (_sessionToken!.isEmpty) {
      throw Exception('No session token, initSession first');
    }

    final Map<String, String> headers = {
      'Session-Token': _sessionToken!,
      'Content-Type': 'application/json',
      'Accept': 'application/octet-stream',
      ...?appToken != null ? {'App-Token': appToken!} : null,
    };

    final uri = Uri.parse('$baseUrl/Document/$id');

    final response = await http.get(uri, headers: headers);

    if (response.statusCode != 200 && response.statusCode != 207) {
      throw GlpiException.fromResponse(
          response.statusCode, json.decode(response.body));
    }

    return Future.value(response.body);
  }

  /// Get a user's profile picture.
  /// [id] must be the id of the user to get the picture.
  /// Reference: [https://github.com/glpi-project/glpi/blob/master/apirest.md#get-a-users-profile-picture](https://github.com/glpi-project/glpi/blob/master/apirest.md#get-a-users-profile-picture)
  Future<String> getUserProfilePicture(int id) async {
    if (_sessionToken!.isEmpty) {
      throw Exception('No session token, initSession first');
    }

    final Map<String, String> headers = {
      'Session-Token': _sessionToken!,
      'Content-Type': 'application/json',
      ...?appToken != null ? {'App-Token': appToken!} : null,
    };

    final uri = Uri.parse('$baseUrl/User/$id/Picture');

    final response = await http.get(uri, headers: headers);

    if (response.statusCode != 200 && response.statusCode != 207) {
      throw GlpiException.fromResponse(
          response.statusCode, json.decode(response.body));
    }

    return Future.value(response.body);
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
      throw GlpiException.fromResponse(
          response.statusCode, json.decode(response.body));
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
      throw GlpiException.fromResponse(
          response.statusCode, json.decode(response.body));
    }
    final _json = json.decode(response.body);

    _sessionToken = _json['session_token'] as String;

    if (getFullSession) {
      _session = jsonDecode(_json['session'] as String);
    }

    return Future.value(_sessionToken);
  }
}
