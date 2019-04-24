import 'package:meta/meta.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: non_constant_identifier_names
var Settings = (SettingsManager._wasInitialized ? new _Settings() as dynamic : throw new Exception("Tried to use Settings before the SettingsManager ran onInit check. You must call SettingsManager.onAppInit() in your main function!"));

class SettingsManager {

  static bool _wasInitialized = false;

  ///
  /// Every time [_Settings._settingDefinitions] is updated irreversibly, this
  /// variable should be updated.
  ///
  /// This WILL CAUSE LOCAL STORAGE TO BE WIPED should the previously installed
  /// version number be lower than this version number.
  ///
  static int _lastMajorRevision = 104001;

  static Future<bool> _checkNeedsWipe(SharedPreferences sharedPreferences) async {
    if(!sharedPreferences.getKeys().contains("__kaminoVersion")) return true;
    if(sharedPreferences.getInt("__kaminoVersion") < _lastMajorRevision) return true;

    return false;
  }

  static Future<void> onAppInit() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if(await _checkNeedsWipe(sharedPreferences)) await sharedPreferences.clear();

    PackageInfo info = await PackageInfo.fromPlatform();
    await sharedPreferences.setInt("__kaminoVersion", int.parse(info.buildNumber));

    _wasInitialized = true;
  }

  static bool hasKey(String key){
    return _Settings._settingDefinitions.containsKey(key);
  }

  static Future<void> deleteKey(String key) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.remove(key);
  }

  static Future<void> dumpFromStorage() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.getKeys().forEach((String key){
      print("$key -> " + sharedPreferences.get(key).toString());
    });
  }

}

class _Settings {

  /////// ATTENTION ///////
  // MAKING MAJOR POTENTIALLY VERSION-BREAKING CHANGES TO SETTINGS?
  // Remember to update SettingsManager._lastMajorRevision!!!

  /// NOTE: 'List' will be automatically cast to List<String>
  ///
  /// Valid Types:
  /// - String
  /// - int
  /// - double
  /// - bool
  /// - List<String>
  static const Map<String, $> _settingDefinitions = {
    "initialSetupComplete": $(type: bool, defaultValue: false),

    "activeTheme": $(type: String),
    "primaryColorOverride": $(type: String),

    "manuallySelectSourcesEnabled": $(type: bool, defaultValue: true),
    "detailedContentInfoEnabled": $(type: bool, defaultValue: true),
    "locale": $(type: List, defaultValue: <String>["en", ""]),

    "serverURLOverride": $(type: String),
    "serverKeyOverride": $(type: String),

    ///
    ///   ----------------------------------
    ///   Trakt Credentials Array Structure:
    ///   ----------------------------------
    ///   0 - access token
    ///   1 - refresh token
    ///   2 - expiry date
    ///
    "traktCredentials": $(type: List, defaultValue: <String>[]),

    ///
    ///   ----------------------------------
    ///   RealDebrid Credentials Array Structure:
    ///   ----------------------------------
    ///   0 - access token
    ///   1 - refresh token
    ///   2 - expiry date
    ///

    "rdCredentials": $(type: List, defaultValue: <String>[]),
    "rdClientInfo": $(type: List, defaultValue: <String>[]),

    // TODO: Remove old launchpad code.
    "launchpadItems": $(type: String),
    "homepageCategories": $(type: String, defaultValue: "{}"),

    "clawsToken": $(type: String),
    "clawsTokenSetTime": $(type: double),

    "maxConcurrentRequests": $(type: int, defaultValue: 5),
    "requestTimeout": $(type: int, defaultValue: 10),

    "contentSortSettings": $(type: List, defaultValue: <String>[]),

    // This is the third party player that should be used.
    "playerInfo": $(type: List, defaultValue: <String>[]),
  };

  Future<PlayerSettings> get playerInfo async {
    return PlayerSettings(await this.noSuchMethod(Invocation.getter(Symbol('playerInfo'))));
  }

  Future<void> setPlayerInfo(PlayerSettings info) async {
    return await this.noSuchMethod(Invocation.setter(Symbol('playerInfo='), info.asList()));
  }

  Future<TraktSettings> get traktCredentials async {
    return TraktSettings(await this.noSuchMethod(Invocation.getter(Symbol('traktCredentials'))));
  }

  Future<void> setTraktCredentials(TraktSettings credentials) async {
    return await this.noSuchMethod(Invocation.setter(Symbol('traktCredentials='), credentials.asList()));
  }

  /*Future<RealDebridCredentials> get rdCredentials async {
    return RealDebridCredentials(await this.noSuchMethod(Invocation.getter(Symbol('rdCredentials'))));
  }*/

  Future<void> setRdCredentials(RealDebridCredentials credentials) async {
    return await this.noSuchMethod(Invocation.setter(Symbol('rdCredentials='), credentials.asList()));
  }

  noSuchMethod(Invocation invocation) {
    if(invocation.isGetter){
      var key = invocation.memberName.toString().substring(8, invocation.memberName.toString().length - 2);
      if(!_settingDefinitions.containsKey(key)) throw new Exception("Tried to get undefined settings key: $key");

      return Future<dynamic>(() async {
        SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
        var result = await sharedPreferences.get(key);

        if(result != null || _settingDefinitions[key].defaultValue == null) {
          if(result is List) return result.cast<String>().toList( growable: true );
          return result;
        }

        return _settingDefinitions[key].defaultValue;
      });
    }

    if(invocation.isSetter){
      var key = invocation.memberName.toString().substring(8, invocation.memberName.toString().length - 3);
      var value = invocation.positionalArguments.first;
      if(value is List) value = new List<String>.from(value, growable: false);

      if(!_settingDefinitions.containsKey(key)) throw new Exception("Tried to set undefined settings key: $key");

      String type = _settingDefinitions[key].type.toString();
      if(type == "List<dynamic>") type = "List<String>";

      assert((){
        if(value.runtimeType.toString() != type){
          throw new Exception("Type mismatch: tried to set setting $key (of type $type) to a value of type ${value.runtimeType}.");
        }
        return true;
      }());

      return Future<void>(() async {
        SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
        if(value is bool) return await sharedPreferences.setBool(key, value);
        if(value is double) return await sharedPreferences.setDouble(key, value);
        if(value is int) return await sharedPreferences.setInt(key, value);
        if(value is List<String>) return await sharedPreferences.setStringList(key, value);

        return await sharedPreferences.setString(key, value.toString());
      });
    }

    return super.noSuchMethod(invocation);
  }
}

class $ {
  final Type type;
  final dynamic defaultValue;
  const $({@required this.type, this.defaultValue});
}

/* Setting Objects */
class PlayerSettings {

  String activity;
  String package;
  String name;

  PlayerSettings(List<String> data){
    this.activity = data.length > 0 ? data[0] : null;
    this.package = data.length > 1 ? data[1] : null;
    this.name = data.length > 2 ? data[2] : null;
  }

  static PlayerSettings defaultPlayer() {
    return new PlayerSettings([]);
  }

  List<String> asList(){
    return [activity, package, name];
  }

  bool isValid(){
    return activity != null && package != null && name != null;
  }

}

class TraktSettings {

  String accessToken;
  String refreshToken;
  String expiryDate;

  TraktSettings(List<String> data){
    this.accessToken = data.length > 0 ? data[0] : null;
    this.refreshToken = data.length > 1 ? data[1] : null;
    this.expiryDate = data.length > 2 ? data[2] : null;
  }

  TraktSettings.named({
    @required this.accessToken,
    @required this.refreshToken,
    @required this.expiryDate
  });

  static TraktSettings unauthenticated(){
    return new TraktSettings([]);
  }

  List<String> asList(){
    return [accessToken, refreshToken, expiryDate];
  }

  bool isValid(){
    return accessToken != null && refreshToken != null && expiryDate != null;
  }

}

class RealDebridCredentials {

  String accessToken;
  String refreshToken;
  String expiryDate;

  RealDebridCredentials(List<String> data){
    this.accessToken = data.length > 0 ? data[0] : null;
    this.refreshToken = data.length > 1 ? data[1] : null;
    this.expiryDate = data.length > 2 ? data[2] : null;
  }

  RealDebridCredentials.named({
    @required this.accessToken,
    @required this.refreshToken,
    @required this.expiryDate
  });

  static RealDebridCredentials unauthenticated(){
    return new RealDebridCredentials([]);
  }

  List<String> asList(){
    return [accessToken, refreshToken, expiryDate];
  }

  bool isValid(){
    return accessToken != null && refreshToken != null && expiryDate != null;
  }

}