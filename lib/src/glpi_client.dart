import 'client/glpi_client_stub.dart'
    if (dart.library.io) 'client/glpi_client_io.dart'
    if (dart.library.js) 'client/glpi_client_html.dart';

import 'glpi_item_type.dart';
import 'glpi_search_criteria.dart';

/// An abstract client which hold the common clients methods and parameters.
abstract class GlpiClient {
  /// The server host should either end with `apirest.php` or redirect on it.
  String get host;

  /// The [appToken] used to authenticate the requests.
  /// Can be set either a construction or later
  String? appToken;

  /// The [sessionToken] used to authenticate the requests.
  /// Can be stored between session and used to construct a new client without calling [initSessionUserToken] or [initSessionUserToken].
  /// Can be set either a construction or later
  String? sessionToken;

  /// Create a [GlpiClient] .
  /// [host] is the server address, it should end with `/apirest.php/` or be redirected to it.
  /// [appToken] is the app token used to authenticate the client.
  /// [sessionToken] is the session token used to authenticate the client which can be used from a previous session.
  factory GlpiClient(String host, {String? appToken, String? sessionToken}) =>
      createGlpiClient(host, appToken, sessionToken);

  /// Request a session token to uses other API endpoints using a [username] and [password].
  /// If [getFullSession] is set to true, will also return the session details in session.
  /// If [sendInQuery] is set to true, will send the credentials in the query string instead of the header.
  /// Will throw an [Exception] if the session can't be initialized.
  /// Reference: [https://github.com/glpi-project/glpi/blob/master/apirest.md#init-session](https://github.com/glpi-project/glpi/blob/master/apirest.md#init-session).
  Future<Map<String, dynamic>> initSessionUsernamePassword(
      String username, String password,
      {bool getFullSession = false, bool sendInQuery = false});

  /// Request a session token to uses other API endpoints using a [userToken].
  /// If [getFullSession] is set to true, will also return the session details in session.
  /// If [sendInQuery] is set to true, will send the credentials in the query string instead of the header.
  /// Will throw an [Exception] if the session can't be initialized.
  /// Reference: [https://github.com/glpi-project/glpi/blob/master/apirest.md#init-session](https://github.com/glpi-project/glpi/blob/master/apirest.md#init-session).
  Future<Map<String, dynamic>> initSessionUserToken(String userToken,
      {bool getFullSession = false, bool sendInQuery = false});

  /// Return `true` if the client is successfully disconnected from the API.
  /// Will throw an [Exception] if the session can't be disconnected.
  /// Reference: [https://github.com/glpi-project/glpi/blob/master/apirest.md#kill-session](https://github.com/glpi-project/glpi/blob/master/apirest.md#kill-session).
  Future<bool> killSession();

  /// Allow to request a password reset for the account using the [email] address.
  /// Return true if the request is successful BUT this doesn't mean that your glpi is configured to send emails.
  /// Check the glpi's configuration to see the prerequisites (notifications need to be enabled).
  /// If [passwordForgetToken] AND [newPassword] are set, the password will be changed with the value of [newPassword] instead.
  /// Sending [passwordForgetToken] without [newPassword] and the opposite will throw an [ArgumentError].
  /// Reference: [https://github.com/glpi-project/glpi/blob/master/apirest.md#lost-password](https://github.com/glpi-project/glpi/blob/master/apirest.md#lost-password).
  Future<bool> lostPassword(String email,
      {String? passwordForgetToken, String? newPassword});

  /// Return a [Map] of all the profile for the current user
  /// Profiles are under the key `myprofiles`
  /// Reference: [https://github.com/glpi-project/glpi/blob/master/apirest.md#get-my-profiles](https://github.com/glpi-project/glpi/blob/master/apirest.md#get-my-profiles).
  Future<Map<String, dynamic>> getMyProfiles();

  /// Return the current active profile for the current user as a [Map]
  /// Reference: [https://github.com/glpi-project/glpi/blob/master/apirest.md#get-active-profile](https://github.com/glpi-project/glpi/blob/master/apirest.md#get-active-profile)
  Future<Map<String, dynamic>> getActiveProfile();

  /// Change the active profile for the current user.
  /// Will throw an [Exception] if the request fails or if the selected id is incorrect.
  /// Reference: [https://github.com/glpi-project/glpi/blob/master/apirest.md#change-active-profile](https://github.com/glpi-project/glpi/blob/master/apirest.md#change-active-profile).
  Future<bool> changeActiveProfile(int profilesId);

  /// Return the entities list for the current user.
  /// Setting [isRecursive] to true will get the list of all the entities and sub-entities.
  /// Entities are under the key `myentities`
  /// Reference: [https://github.com/glpi-project/glpi/blob/master/apirest.md#get-my-entities](https://github.com/glpi-project/glpi/blob/master/apirest.md#get-my-entities)
  Future<Map<String, dynamic>> getMyEntities({bool isRecursive = false});

  /// Return the current active entity for the current user as a [Map]
  /// Reference: [https://github.com/glpi-project/glpi/blob/master/apirest.md#get-active-entities](https://github.com/glpi-project/glpi/blob/master/apirest.md#get-active-entities)
  Future<Map<String, dynamic>> getActiveEntities();

  /// Allow to change the active entity for the current user.
  /// [entitiesId] can either be the numerical id of the entity or `all` to load all the entities.
  /// [recursive] can be set to true to load all the sub-entities.
  /// Will throw an [Exception] if the request fails or if the selected id is incorrect.
  /// Reference: [https://github.com/glpi-project/glpi/blob/master/apirest.md#change-active-entities](https://github.com/glpi-project/glpi/blob/master/apirest.md#change-active-entities)
  Future<bool> changeActiveEntities(dynamic entitiesId,
      {bool recursive = false});

  /// Return the session data include in the php $_SESSION.
  /// For the moment it's just a [Map] of the json response.
  /// Reference: [https://github.com/glpi-project/glpi/blob/master/apirest.md#get-full-session](https://github.com/glpi-project/glpi/blob/master/apirest.md#get-full-session).
  Future<Map<String, dynamic>> getFullSession();

  /// Return the Glpi instance configuration data inside a [Map].
  /// Reference: [https://github.com/glpi-project/glpi/blob/master/apirest.md#get-glpi-config](https://github.com/glpi-project/glpi/blob/master/apirest.md#get-glpi-config)
  Future<Map<String, dynamic>> getGlpiConfig();

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
      List<String>? addKeysNames});

  /// Return **ALL** the items of the given type the current user can see, depending on your server configuration and the number of items proceeded it may have unexpected results.
  /// [GlpiItemType] contains all the available item types according to the latest GLPI documentation.
  /// By default, only the 50 firsts item will be returned. This can be changed by setting the [rangeStart] parameter and [rangeLimit] parameters.
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
      List? addKeysNames});

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
      List? addKeysNames});

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
      List<String>? addKeysNames});

  /// Return all the searchOptions usable in [searchItems] criteria for a given [GlpiItemType].
  Future<Map<String, dynamic>> listSearchOptions(GlpiItemType itemType);

  /// ** This method is untested for the moment **
  /// Return items found using the GLPI searchEngine
  /// Reference: [https://github.com/glpi-project/glpi/blob/master/apirest.md#search-items](https://github.com/glpi-project/glpi/blob/master/apirest.md#search-items)
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
  });

  /// Return the id(s) of the item(s) added using the [data] as input.
  /// **Don't use this method to upload a document**
  /// To correctly format the data, see the examples and the documentation.
  /// Reference: [https://github.com/glpi-project/glpi/blob/master/apirest.md#add-items](https://github.com/glpi-project/glpi/blob/master/apirest.md#add-items)
  Future<List<Map<String, String>>> addItems(
      GlpiItemType itemType, String data);

  /// Return an array with the updated item [id] and a message.
  /// To correctly format the data, see the examples and the documentation.
  /// Reference: [https://github.com/glpi-project/glpi/blob/master/apirest.md#update-items](https://github.com/glpi-project/glpi/blob/master/apirest.md#update-items)
  Future<Map<String, String>> updateItem(
      GlpiItemType itemType, int id, Map<String, dynamic> data);

  /// Return the id(s) of the item(s) updated using the [data] as input.
  /// To correctly format the data, see the examples and the documentation.
  /// Reference: [https://github.com/glpi-project/glpi/blob/master/apirest.md#update-items](https://github.com/glpi-project/glpi/blob/master/apirest.md#update-items)
  Future<List<Map<String, String>>> updateItems(
      GlpiItemType itemType, String data);

  /// Return the [id] of the item deleted with true is the deletion is complete.
  /// [forcePurge] will delete the item permanently.
  /// [history] set to false will prevent the deletion from being added to the global history.
  Future<Map<String, String>> deleteItem(GlpiItemType itemType, int id,
      {bool forcePurge = false, bool history = true});

  /// Return the ids of the items deleted with true is the deletion is complete.
  /// Reference: [https://github.com/glpi-project/glpi/blob/master/apirest.md#delete-items](https://github.com/glpi-project/glpi/blob/master/apirest.md#delete-items)
  Future<List<Map<String, String>>> deleteItems(
      GlpiItemType itemType, String data);

  /// Return the available massive actions for a given [itemtype]
  /// [isDeleted] (default false): Show specific actions for items in the trash bin
  /// Reference: [https://github.com/glpi-project/glpi/blob/master/apirest.md#get-available-massive-actions-for-an-itemtype](https://github.com/glpi-project/glpi/blob/master/apirest.md#get-available-massive-actions-for-an-itemtype)
  Future<List<Map<String, String>>> getMassiveActions(GlpiItemType itemType,
      {bool isDeleted = false});

  /// Return the awaitables massive actions for a given [itemType] and [id].
  /// Reference: [https://github.com/glpi-project/glpi/blob/master/apirest.md#get-available-massive-actions-for-an-item](https://github.com/glpi-project/glpi/blob/master/apirest.md#get-available-massive-actions-for-an-item)
  Future<List<Map<String, String>>> getMassiveActionsItem(
      GlpiItemType itemType, int id);

  /// Show the awaitables parameters for a given massive action
  /// **Warning: experimental endpoint, some required parameters may be missing from the returned content.**
  /// Reference: [https://github.com/glpi-project/glpi/blob/master/apirest.md#get-massive-action-parameters](https://github.com/glpi-project/glpi/blob/master/apirest.md#get-massive-action-parameters)
  Future<List<Map<String, String>>> getMassiveActionParameters(
      GlpiItemType itemType, String massiveActionName);

  /// Run the given massive action
  /// [payload] Must be a json string with the parameters for the action and the ids of the items to apply the action to.
  /// Reference: [https://github.com/glpi-project/glpi/blob/master/apirest.md#apply-massive-action](https://github.com/glpi-project/glpi/blob/master/apirest.md#apply-massive-action)
  Future<Map<String, dynamic>> applyMassiveActions(
      GlpiItemType itemType, String massiveActionName, String payload);

  /// Allow to download a [GlpiItemType.Document].
  /// [id] must be the id of the document to download.
  /// Reference: [https://github.com/glpi-project/glpi/blob/master/apirest.md#download-a-document-file](https://github.com/glpi-project/glpi/blob/master/apirest.md#download-a-document-file)
  Future<String> downloadDocument(int id);

  /// Allow to upload a [GlpiItemType.Document].
  /// [file] must be a [File] object.
  /// Unsupported on the web.
  /// Reference: [https://github.com/glpi-project/glpi/blob/master/apirest.md#upload-a-document-file](https://github.com/glpi-project/glpi/blob/master/apirest.md#upload-a-document-file)
  Future<Map<String, dynamic>> uploadDocument(covariant dynamic file);

  /// Get a user's profile picture.
  /// [id] must be the id of the user to get the picture.
  /// Reference: [https://github.com/glpi-project/glpi/blob/master/apirest.md#get-a-users-profile-picture](https://github.com/glpi-project/glpi/blob/master/apirest.md#get-a-users-profile-picture)
  Future<String> getUserProfilePicture(int id);
}
