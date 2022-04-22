import 'dart:convert';
import 'dart:html';

import 'package:http/browser_client.dart';
import 'package:http/http.dart';

import '../glpi_client.dart';
import 'glpi_client_base.dart';

/// Static factory to create a [GlpiClient] with a [BrowserClient].
GlpiClient createGlpiClient(String host,
        {String? appToken, String? sessionToken}) =>
    GlpiClientHtml(host, appToken: appToken, sessionToken: sessionToken);

/// GlpiClient implementation for the browser.
class GlpiClientHtml extends GlpiClientBase {
  /// Constructor using a [BrowserClient] to communicate with the API.
  GlpiClientHtml(String host, {String? appToken, String? sessionToken})
      : super(BrowserClient(), host,
            appToken: appToken, sessionToken: sessionToken);

  /// Allow to upload a [GlpiItemType.Document].
  /// [file] must be a [File] object.
  /// Unsupported on the web.
  /// Reference: [https://github.com/glpi-project/glpi/blob/master/apirest.md#upload-a-document-file](https://github.com/glpi-project/glpi/blob/master/apirest.md#upload-a-document-file)
  @override
  Future<Map<String, dynamic>> uploadDocument(
    File file,
  ) async {
    /*
    if (sessionToken!.isEmpty) {
      throw Exception('No session token, initSession first');
    }

    final Map<String, String> headers = {
      'Session-Token': sessionToken!,
      'Content-Type': 'multipart/form-data',
      ...?appToken != null || appToken!.isEmpty
          ? {'App-Token': appToken!}
          : null,
    };

    final uri = Uri.parse('$host/Document');

    final payload = json.encode({
      'input': {
        'name': file.name,
        '_filename': file.name,
      }
    });

    final uploadManifest = '$payload;type=application/json';

    final request = MultipartRequest('POST', uri)
      ..headers.addAll(headers)
      ..fields['uploadManifest'] = uploadManifest
      ..files.add(MultipartFile.fromBytes(
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
    */
    throw UnsupportedError('Not supported on the web');
  }
}
