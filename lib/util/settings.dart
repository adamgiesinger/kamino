import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: non_constant_identifier_names
var Settings = (new _Settings() as dynamic);

class SettingsManager {

  static bool hasKey(String key){
    return _Settings._settingDefinitions.containsKey(key);
  }

}

class _Settings {

  /// NOTE: 'List' will be automatically cast to List<String>
  ///
  /// Valid Types:
  /// - String
  /// - int
  /// - double
  /// - bool
  /// - List<String>
  static const Map<String, $> _settingDefinitions = {
    "activeTheme": $(type: String),
    "primaryColorOverride": $(type: String),

    "manuallySelectSourcesEnabled": $(type: bool),
    "detailedContentInfoEnabled": $(type: bool),
    "locale": $(type: String, defaultValue: "en"),

    "serverURLOverride": $(type: String),
    "searchHistory": $(type: List)
  };

  noSuchMethod(Invocation invocation) {
    if(invocation.isGetter){
      var key = invocation.memberName.toString().substring(8, invocation.memberName.toString().length - 2);
      if(!_settingDefinitions.containsKey(key)) throw new Exception("Tried to get undefined settings key: $key");

      return Future<dynamic>(() async {
        SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
        var result = await sharedPreferences.get(key);
        if(result != null || _settingDefinitions[key].defaultValue == null) return result;
        return _settingDefinitions[key].defaultValue;
      });
    }

    if(invocation.isSetter){
      var key = invocation.memberName.toString().substring(8, invocation.memberName.toString().length - 3);
      var value = invocation.positionalArguments.first;

      if(!_settingDefinitions.containsKey(key)) throw new Exception("Tried to set undefined settings key: $key");

      var type = _settingDefinitions[key].type.toString();
      if(type == "List<dynamic>") type = "List<String>";
      if(value.runtimeType.toString() != type) throw new Exception("Type of the value of settings key $key (${value.runtimeType}) does not match the defined type of that settings key: ${_settingDefinitions[key].type}.");

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