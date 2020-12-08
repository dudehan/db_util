import 'package:sp_util/sp_util.dart';

class WXDataUtil {
  static shareInstance() async{
      await SpUtil.getInstance();
  }

  /// put object.
  static Future<bool> putObject(String key, Object value) {
      return SpUtil.putObject(key, value);
  }

   /// get obj.
  static T getObj<T>(String key, T f(Map v), {T defValue}) {
      return SpUtil.getObj(key, f);
  }

  /// get object.
  static Map getObject(String key) {
      return SpUtil.getObject(key);
  }

  /// put object list.
  static Future<bool> putObjectList(String key, List<Object> list) {
      return SpUtil.putObjectList(key, list);
  }

  /// get obj list.
  static List<T> getObjList<T>(String key, T f(Map v)) {
      return SpUtil.getObjList(key, f);
  }

  /// get object list.
  static List<Map> getObjectList(String key) {
     return SpUtil.getObjectList(key);
  }

  /// get string.
  static String getString(String key) {
      return SpUtil.getString(key);
  }

  /// put string.
  static Future<bool> putString(String key, String value) {
      return SpUtil.putString(key, value);
  }
  /// get bool.
  static bool getBool(String key, {bool defValue = false}) {
      return SpUtil.getBool(key) ?? defValue;
  }

  /// put bool.
  static Future<bool> putBool(String key, bool value) {
      return SpUtil.putBool(key, value);
  }

  /// get int.
  static int getInt(String key, {int defValue = 0}) {
      return SpUtil.getInt(key,defValue: defValue);
  }

  /// put int.
  static Future<bool> putInt(String key, int value) {
      return SpUtil.putInt(key, value);
  }
  /// get double.
  static double getDouble(String key, {double defValue = 0.0}) {
      return SpUtil.getDouble(key, defValue: defValue);
  }
  /// put double.
  static Future<bool> putDouble(String key, double value) {
      return SpUtil.putDouble(key, value);
  }

  /// get string list.
  static List<String> getStringList(String key,
          {List<String> defValue = const []}) {
      return SpUtil.getStringList(key,defValue: defValue);
  }

  /// put string list.
  static Future<bool> putStringList(String key, List<String> value) {
      return SpUtil.putStringList(key, value);
  }

  /// get dynamic.
  static dynamic getDynamic(String key, {Object defValue}) {
      return SpUtil.getDynamic(key,defValue:defValue);
  }

  /// have key.
  static bool haveKey(String key) {
      return SpUtil.getKeys().contains(key);
  }

  /// get keys.
  static Set<String> getKeys() {
      return SpUtil.getKeys();
  }

  /// remove.
  static Future<bool> remove(String key) {
      return SpUtil.remove(key);
  }

  /// clear.
  static Future<bool> clear() {
      return SpUtil.clear();
  }

}
