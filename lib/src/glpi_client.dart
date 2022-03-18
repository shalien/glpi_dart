import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

abstract class GlpiClient {
  final String baseUrl;

//App token
  String? appToken;

  //Session Token
  String? sessionToken;

  GlpiClient._(this.baseUrl, {this.appToken});

  /// Return a new instance of [GlpiClient] using the given [baseUrl] and credentials.
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

  factory GlpiClient.withToken(String baseUrl, String userToken,
      {String? appToken}) {
    final glpiClient = _GlpiTokenClient(baseUrl, userToken, appToken: appToken);
    return glpiClient;
  }

  /// Retrieve the session token.
  /// [getFullSession] if true will get the full session detail.
  FutureOr<void> initSession(
      {bool getFullSession = false, bool sendInQuery = false});

  Future<bool> killSession() async {
    if (sessionToken == null) {
      throw Exception('No session token, initSession first');
    }

    final Map<String, String> headers = appToken!.isNotEmpty
        ? {
            'Session-Token': sessionToken!,
            HttpHeaders.contentTypeHeader: 'application/json',
            'App-Token': appToken!,
          }
        : {
            'Session-Token': sessionToken!,
            HttpHeaders.contentTypeHeader: 'application/json',
          };

    final _response =
        await http.get(Uri.parse('$baseUrl/killSession'), headers: headers);

    if (_response.statusCode != 200) {
      throw Exception(
          'Failed to get session token ${_response.statusCode} ${_response.body}');
    }

    return true;
  }
}

/// GlpiClient implementation using the login method.
class _GlpiLoginClient extends GlpiClient {
  final String username;
  final String password;

  _GlpiLoginClient(String baseUrl, this.username, this.password,
      {String? appToken})
      : super._(baseUrl, appToken: appToken);

  /// This method will encode the login credentials in base64 format
  String _encodeLogin() => base64Encode(utf8.encode('$username:$password'));

  @override
  Future<void> initSession(
      {bool getFullSession = false, bool sendInQuery = false}) async {
    http.Response response;
    final Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
    };

    if (appToken != null) {
      headers['App-Token'] = appToken!;
    }

    if (sendInQuery) {
      response = await http.get(
          Uri.parse(
              '$baseUrl/initSession?get_full_session=$getFullSession&login=$username&password=$password'),
          headers: headers);
    } else {
      headers.putIfAbsent(
          HttpHeaders.authorizationHeader, () => 'Basic ${_encodeLogin()}');

      response = await http.get(
          Uri.parse('$baseUrl/initSession?get_full_session=$getFullSession'),
          headers: headers);
    }

    if (response.statusCode != 200) {
      throw Exception(
          'Failed to get session token ${response.statusCode} ${response.body}');
    }

    final _json = json.decode(response.body);

    sessionToken = _json['session_token'] as String;
    if (getFullSession) {}
  }
}

/// This class will use the user token to get the session token.
class _GlpiTokenClient extends GlpiClient {
  final String userToken;

  _GlpiTokenClient(String baseUrl, this.userToken, {String? appToken})
      : super._(baseUrl, appToken: appToken);

  @override
  Future<void> initSession(
      {bool getFullSession = false, bool sendInQuery = false}) async {
    http.Response response;

    final Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
    };

    if (sendInQuery) {
      response = await http.get(
          Uri.parse(
              '$baseUrl/initSession?get_full_session=$getFullSession&user_token=$userToken'),
          headers: headers);
    } else {
      headers.putIfAbsent(
          HttpHeaders.authorizationHeader, () => 'user_token $userToken');

      response = await http.get(
          Uri.parse('$baseUrl/initSession?get_full_session=$getFullSession'),
          headers: headers);
    }

    if (response.statusCode != 200) {
      throw Exception(
          'Failed to get session token ${response.statusCode} ${response.body}');
    }
    final _json = json.decode(response.body);

    sessionToken = _json['session_token'] as String;
  }
}
