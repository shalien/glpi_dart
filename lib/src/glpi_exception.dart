/// A special [Exception] class is used to handle the errors.
/// It contains the error [code] and the error code [error] and message [message] from GLPI's API response.
/// The [code] will be a HTTP status code.
/// The [error] will be the error code and [message] the error message.
class GlpiException implements Exception {
  /// The error code
  final int code;

  /// The GLPI's API error code
  /// Reference: [https://github.com/glpi-project/glpi/blob/master/apirest.md#errors](https://github.com/glpi-project/glpi/blob/master/apirest.md#errors)
  String get error => _reason['error']!;

  /// The GLPI's API error message
  /// Should be localized by the GLPI's engine
  String get message => _reason['message']!;

  /// The error in two parts a code and a localized message
  // @shalien
  // I changed the implementation midway of the dev
  // I keept the map because I don't want to go again rewriting all the method
  final Map<String, String> _reason;

  /// Create a new [GlpiException]
  GlpiException._(this.code, this._reason);

  @override
  String toString() => error.toString();

  /// Create a new [GlpiException] from a http response
  factory GlpiException.fromResponse(int code, List<dynamic> json) {
    final reason = {
      'error': json.first.toString(),
      'message': json.last.toString()
    };
    return GlpiException._(code, reason);
  }
}
