import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class WXDataBaseUtil {
  /// 每一个钱包对应一个数据表，
  static const String DataPersistenceKey = 'DataPersistenceKey';
  static const String DataPersistenceValue = 'DataPersistenceValue';
  static Map<String, dynamic> _dbUtilCache = {};
  static Database _dataBase;

  /// 插入数据
  /// isReplaced： 是否替换，如果存在且为true则根据key替换，否则直接添加插入
  static insert(String table, String key, dynamic data, {bool isReplaced = true}) async {
    /// 打开数据库
    bool isExist = await isTableExist(table);
    if (!isExist) {
      await createTable(table);
    }

    /// 添加缓存
    if(isReplaced) _addCache(table, key, data);

    Database db = await _openDatabase();
    String jsonString = json.encode(data);

    /// 不替换则直接插入
    if (!isReplaced) {
      db.insert(table, {DataPersistenceKey: key, DataPersistenceValue: jsonString});
      return;
    }

    /// 根据key获取数据库数据
    List<Map<String, dynamic>> list =
        await db.query(table, columns: [DataPersistenceKey], where: '$DataPersistenceKey = ?', whereArgs: [key]);

    if (list.length > 0) {
      /// 存在则更新
      Map<String, dynamic> values = {DataPersistenceValue: jsonString};
      db.update(table, values, where: '$DataPersistenceKey = ?', whereArgs: [key]);
    } else {
      /// 不存在则添加
      db.insert(table, {DataPersistenceKey: key, DataPersistenceValue: jsonString});
    }
    // db.close();
  }

  /// 查询（key为null则查询所以数据）
  static Future query(String table, {String key}) async {
    /// 先去缓存查找，没有则去数据库查找，查找完自动添加进缓存
    dynamic result = _queryCache(table, key);
    if(result != null) return result;

    /// 打开数据库
    bool isExist = await isTableExist(table);
    if (!isExist) {
      _tableAssert(table, isExist);
      return;
    }
    Database db = await _openDatabase();

    /// key为null则查询所以数据
    if (key == null || key.isEmpty) {
      return await db.query(table);
    }

    /// 获取数据库数据
    List queryData =
        await db.query(table, columns: [DataPersistenceValue], where: '$DataPersistenceKey = ?', whereArgs: [key]);

    if (queryData.length > 0) {
      String string = queryData[0][DataPersistenceValue];
      /// 查找结果添加进缓存
      result = json.decode(string);
      _addCache(table, key, result);
      return result;
    }
    // db.close();
    return queryData;
  }

  /// 删除数据
  static delete(String table, String key) async {
    /// 打开数据库
    Database db = await _openDatabase();
    bool isExist = await isTableExist(table);
    if (isExist) {
      await db.delete(table, where: '$DataPersistenceKey = ?', whereArgs: [key]);
      return;
    }
    // db.close();
  }

  /// 创建表
  static Future createTable(String tableName) async {
    bool isExist = await isTableExist(tableName);
    Database db = await _openDatabase();
    if (!isExist) {
      await db.execute(
          'CREATE TABLE $tableName (id INTEGER PRIMARY KEY, $DataPersistenceKey TEXT, $DataPersistenceValue TEXT)');
    }
    // db.close();
  }

  /// 删除表
  static deleteTable(String tableName) async {
    /// 先删除缓存中的表
    if (_dbUtilCache.containsKey(tableName)) _dbUtilCache.remove(tableName);

    /// 删除数据库中的表
    Database db = await _openDatabase();
    bool isExist = await isTableExist(tableName);
    if (isExist) {
      await db.execute('DROP TABLE $tableName');
      return;
    }
    // db.close();
  }

  /// 判断某个表是否存在
  static Future<bool> isTableExist(String tableName) async {
    Database db = await _openDatabase();
    List list = await db.rawQuery("select * from Sqlite_master where type = 'table' and name = '$tableName'");
    // db.close();
    return list.length > 0 ? true : false;
  }

  /// 获取所有列表
  static Future<List<Map<String, dynamic>>> getAllTable() async {
    Database db = await _openDatabase();
    List<Map<String, dynamic>> list = await db.rawQuery('SELECT name FROM sqlite_master WHERE type = "table"');
    return list;
  }

  /// 打开数据库
  static Future<Database> _openDatabase() async {
    if (_dataBase != null && _dataBase.isOpen) return _dataBase;
    String dataBasePath = await getDatabasesPath();
    String path = '$dataBasePath/wallet.db';
    print('path ==== $path');
    _dataBase = await openDatabase(path);
    return _dataBase;
  }

  /// 添加缓存
  static _addCache(String table, String key, dynamic data) {
    /// 数据缓存
    Map<String, dynamic> tableDataCache = _dbUtilCache[table];
    if (tableDataCache != null) {
      tableDataCache[key] = data;
    } else {
      Map<String, dynamic> tableCache = {key: data};
      _dbUtilCache[table] = tableCache;
    }
  }
  /// 查询缓存数据
  static dynamic _queryCache(String table, String key) {
    if (key != null && _dbUtilCache.containsKey(table)) {
      Map<String, dynamic> tableCache = _dbUtilCache[table];
      if(tableCache != null) {
        return tableCache[key];
      }
    }
    return null;
  }

  /// 清除缓存
  static _clearCacheByKey(String table, {String key}) {
    if (key == null) {
      _dbUtilCache.remove(table);
    } else {
      Map<String, dynamic> tableCache = _dbUtilCache[table];
      if (tableCache != null) {
        tableCache.remove(key);
      }
    }
  }

  static _clearAllCache() {
    _dbUtilCache.clear();
  }

  /// 断言
  static _tableAssert(String table, bool isExist) {
    assert(() {
      if (!isExist) {
        print('$table表不存在');
      }
      return true;
    }());
  }
}
