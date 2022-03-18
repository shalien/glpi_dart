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

  Future<void> initSession({bool getFullSession = false});
}

class _GlpiLoginClient extends GlpiClient {
  final String username;
  final String password;

  _GlpiLoginClient(String baseUrl, this.username, this.password,
      {String? appToken})
      : super._(baseUrl, appToken: appToken);

  /// This method will encode the login credentials in base64 format
  String _encodeLogin() => base64Encode(utf8.encode('$username:$password'));

  @override
  Future<void> initSession({bool getFullSession = false}) async {
    final Map<String, String> headers = appToken!.isNotEmpty
        ? {
            HttpHeaders.authorizationHeader: 'Basic ${_encodeLogin()}',
            HttpHeaders.contentTypeHeader: 'application/json',
            'App-Token': appToken!,
          }
        : {
            HttpHeaders.authorizationHeader: 'Basic ${_encodeLogin()}',
            HttpHeaders.contentTypeHeader: 'application/json',
          };

    final _response = await http.get(
        Uri.parse('$baseUrl/initSession?get_full_session=$getFullSession'),
        headers: headers);

    if (_response.statusCode != 200) {
      throw Exception(
          'Failed to get session token ${_response.statusCode} ${_response.body}');
    }

    final _json = json.decode(_response.body);

    sessionToken = _json['session_token'] as String;
  }
}

class _GlpiTokenClient extends GlpiClient {
  final String userToken;

  _GlpiTokenClient(String baseUrl, this.userToken, {String? appToken})
      : super._(baseUrl, appToken: appToken);

  @override
  Future<void> initSession({bool getFullSession = false}) {
    // TODO: implement initSession
    throw UnimplementedError();
  }
}
