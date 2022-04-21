import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:http/io_client.dart';

import '../glpi_client.dart';
import 'glpi_client_base.dart';

GlpiClient createGlpiClient(
        String host, String? appToken, String? sessionToken) =>
    GlpiClientIo(host, appToken: appToken, sessionToken: sessionToken);

/// A client used to communicate with the GLPI API.
class GlpiClientIo extends GlpiClientBase {
  /// Constructor using a [IOClient] to communicate with the API.
  GlpiClientIo(String host,
      {String? appToken, String? sessionToken, HttpClient? client})
      : super(IOClient(client), host,
            appToken: appToken, sessionToken: sessionToken);

  /// Allow to upload a [GlpiItemType.Document].
  /// [file] must be a [File] object.
  /// Unsupported on the web.
  /// Reference: [https://github.com/glpi-project/glpi/blob/master/apirest.md#upload-a-document-file](https://github.com/glpi-project/glpi/blob/master/apirest.md#upload-a-document-file)
  @override
  Future<Map<String, dynamic>> uploadDocument(
    File file,
  ) async {
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
        'name': file.path.split('/').last,
        '_filename': [base64Encode(file.readAsBytesSync())],
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
  }
}
