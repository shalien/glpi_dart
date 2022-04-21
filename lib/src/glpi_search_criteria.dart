import 'glpi_item_type.dart';
import 'glpi_search_link.dart';
import 'glpi_search_type.dart';

/// Represent a search criteria to be used in a search request with [GlpiClient.searchItems]
class GlpiSearchCriteria {
  /// The logical link between the search criteria
  GlpiSearchLink? link;

  /// id of the search option (See : [GlpiClient.listSearchOptions])
  int field;

  /// Is this criteria a meta one
  bool meta;

  /// Only used if the search option is a meta one
  GlpiItemType? type;

  /// The search type (See : [GlpiSearchType])
  GlpiSearchType searchType;

  /// The value to search for
  dynamic value;

  /// Create a new search criteria for [GlpiClient.searchItems]
  /// [link] is the logical link between the search criteria
  /// [field] is the id of the search option (See : [GlpiClient.listSearchOptions])
  /// [meta] is true if the search option is a meta one
  /// [type] is only used if the search option is a meta one
  /// [searchType] is the search type (See : [GlpiSearchType])
  /// [value] is the value to search for
  /// See [https://github.com/glpi-project/glpi/blob/master/apirest.md#search-items](https://github.com/glpi-project/glpi/blob/master/apirest.md#search-items)
  GlpiSearchCriteria(this.field, this.type, this.value, this.searchType,
      {this.link, this.meta = false});

  /// Format a [GlpiSearchCriteria] to be used in a search request
  Map<String, String> toUrlParameters(int index) {
    Map<String, String> parameters = {
      'criteria[$index][field]': field.toString(),
      'criteria[$index][searchtype]': searchType.name.split('.').last,
      'criteria[$index][value]': value.toString(),
    };

    if (link != null) {
      parameters['criteria[$index][link]'] =
          link!.name.split('.').last.toString();
    }

    if (meta) {
      parameters['criteria[$index][meta]'] = '1';
      parameters['criteria[$index][type]'] =
          type!.name.split('.').last.toString();
    }

    return parameters;
  }
}
