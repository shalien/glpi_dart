import 'dart:html';

import 'package:http/browser_client.dart';

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
    throw UnsupportedError('Not supported in browser');
  }
}
