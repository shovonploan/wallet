import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keychain/flutter_keychain.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wallet/constants/common.dart';
import 'package:wallet/models/account.dart';
import 'package:wallet/models/authenticator.dart';
import 'package:wallet/models/jobs.dart';

final Map<String, DBGrain> _allTables = {
  "Authenticate": Authenticate.defaultCtor(),
  "Account": Account.defaultCtor(),
  "Job": Job.defaultCtor()
};

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  static const _keyStorageName = 'aes_encryption_key';

  late encrypt.Key _encryptionKey;
  final encrypt.Key _masterKey =
      encrypt.Key.fromUtf8("01234567890123456789012345678901");

  DatabaseHelper._internal();

  Future<bool> isKeyExist() async {
    if (Platform.isWindows) {
      final keyFile = File(join(appPath, 'secure_encryption_key.dat'));
      return await keyFile.exists();
    } else if (Platform.isMacOS) {
      String? storedKey = await FlutterKeychain.get(key: _keyStorageName);
      return storedKey != null;
    } else if (Platform.isLinux) {
      final keyFile = File(join(appPath, 'secure_encryption_key.dat'));
      return await keyFile.exists();
    } else {
      String? storedKey = await _secureStorage.read(key: _keyStorageName);
      return storedKey != null;
    }
  }

  bool get hasEncryptionKey {
    try {
      final key = _encryptionKey;
      return true;
    } on Exception {
      return false;
    }
  }

  Future<void> saveKey(String key) async {
    final directory = Directory(appPath);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    if (Platform.isWindows) {
      final keyFile = File(join(appPath, 'secure_encryption_key.dat'));
      final encryptedKey = await _encryptWithDPAPI(key);
      await keyFile.writeAsBytes(encryptedKey);
    } else if (Platform.isMacOS) {
      await FlutterKeychain.put(key: _keyStorageName, value: key);
    } else if (Platform.isLinux) {
      final keyFile = File(join(appPath, 'secure_encryption_key.dat'));
      final encryptedKey = await _encryptWithLinuxSecret(key);
      await keyFile.writeAsBytes(encryptedKey);
    } else {
      await _secureStorage.write(key: _keyStorageName, value: key);
    }
  }

  Future<encrypt.Key> setKey() async {
    try {
      encrypt.Key key;
      if (Platform.isWindows) {
        final keyFile = File(join(appPath, 'secure_encryption_key.dat'));
        if (!await keyFile.exists()) {
          throw Exception("Encryption key file not found on Windows.");
        }
        final encryptedKeyBytes = await keyFile.readAsBytes();
        final decryptedKey = await _decryptWithDPAPI(encryptedKeyBytes);
        key = encrypt.Key.fromBase64(decryptedKey);
      } else if (Platform.isMacOS) {
        final storedKey = await FlutterKeychain.get(key: _keyStorageName);
        if (storedKey == null) {
          throw Exception("Key not found in MacOS Keychain.");
        }
        key = encrypt.Key.fromBase64(storedKey);
      } else if (Platform.isLinux) {
        final keyFile = File(join(appPath, 'secure_encryption_key.dat'));
        if (!await keyFile.exists()) {
          throw Exception("Encryption key file not found on Linux.");
        }
        final encryptedKeyBytes = await keyFile.readAsBytes();
        final decryptedKey = await _decryptWithLinuxSecret(encryptedKeyBytes);
        key = encrypt.Key.fromBase64(decryptedKey);
      } else {
        final storedKey = await _secureStorage.read(key: _keyStorageName);
        if (storedKey == null) {
          throw Exception("Encryption key not found in secure storage.");
        }
        key = encrypt.Key.fromBase64(storedKey);
      }

      _encryptionKey = key;
      return key;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> setNewKey(String key) async {
    _encryptionKey = encrypt.Key.fromBase64(key);
    await saveKey(key);
  }

  Future<List<int>> _encryptWithLinuxSecret(String plainTextKey) async {
    final algorithm = AesGcm.with256bits();
    final secretKey = SecretKey(_encryptionKey.bytes);

    final nonce = algorithm.newNonce();
    final secretBox = await algorithm.encrypt(
      plainTextKey.codeUnits,
      secretKey: secretKey,
      nonce: nonce,
    );

    return [...nonce, ...secretBox.cipherText, ...secretBox.mac.bytes];
  }

  Future<String> _decryptWithLinuxSecret(List<int> encryptedBytes) async {
    final algorithm = AesGcm.with256bits();

    final nonce = encryptedBytes.sublist(0, 12);
    final cipherText = encryptedBytes.sublist(12, encryptedBytes.length - 16);
    final mac = Mac(encryptedBytes.sublist(encryptedBytes.length - 16));

    final secretKey = SecretKey(_encryptionKey.bytes);

    final decrypted = await algorithm.decrypt(
      SecretBox(cipherText, nonce: nonce, mac: mac),
      secretKey: secretKey,
    );

    return String.fromCharCodes(decrypted);
  }

  Future<List<int>> _encryptWithDPAPI(String plainTextKey) async {
    final algorithm = AesGcm.with256bits();
    final secretKey = SecretKey(_masterKey.bytes); // Use the master key
    final nonce = algorithm.newNonce();

    final secretBox = await algorithm.encrypt(
      utf8.encode(plainTextKey),
      secretKey: secretKey,
      nonce: nonce,
    );

    return [...nonce, ...secretBox.cipherText, ...secretBox.mac.bytes];
  }

  Future<String> _decryptWithDPAPI(List<int> encryptedBytes) async {
    final algorithm = AesGcm.with256bits();

    final nonce = encryptedBytes.sublist(0, 12);
    final cipherText = encryptedBytes.sublist(12, encryptedBytes.length - 16);
    final mac = Mac(encryptedBytes.sublist(encryptedBytes.length - 16));

    final secretKey = SecretKey(_masterKey.bytes); // Use the master key

    final decrypted = await algorithm.decrypt(
      SecretBox(cipherText, nonce: nonce, mac: mac),
      secretKey: secretKey,
    );

    return utf8.decode(decrypted);
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final String path = appPath;
    bool exists = await Directory(path).exists();
    if (!exists) {
      await Directory(path).create(recursive: true);
    }

    final dbPath = join(path, 'primary.db');
    bool dbExists = await File(dbPath).exists();

    if (!dbExists) {
      await File(dbPath).create(recursive: true);
    }

    return await openDatabase(
      dbPath,
      version: 1,
      onOpen: _onOpen,
    );
  }

  Future<void> _onOpen(Database db) async {
    final sql = '${_allTables.values.map((table) {
      return table.createTable();
    }).join('\n')}\nCREATE TABLE IF NOT EXISTS blob (id TEXT, data BLOB);\n';
    await db.execute(sql);
  }

  Future<void> rawExecute(String sql) async {
    final db = await database;
    await db.execute(sql);
  }

  Future<void> rawDelete(String tableName, String id) async {
    final db = await database;

    await db.transaction((txn) async {
      await txn
          .rawDelete('DELETE FROM $tableName WHERE ${tableName}_id = ?', [id]);
      await txn.rawDelete(
          'DELETE FROM ${tableName}_cIdx WHERE ${tableName}_id = ?', [id]);
      await txn.rawDelete(
          'DELETE FROM ${tableName}_history WHERE ${tableName}_id = ?', [id]);

      List<Map<String, dynamic>> blobEntries = await txn.rawQuery(
          'SELECT blobId FROM ${tableName}_blob_primary WHERE ${tableName}_id = ?',
          [id]);

      await txn.rawDelete(
          'DELETE FROM ${tableName}_blob_primary WHERE ${tableName}_id = ?',
          [id]);

      if (blobEntries.isNotEmpty) {
        List<String> blobIds =
            blobEntries.map((e) => e['blobId'] as String).toList();
        String blobIdPlaceholders = List.filled(blobIds.length, '?').join(', ');
        await txn.rawDelete(
            'DELETE FROM blob WHERE id IN ($blobIdPlaceholders)', blobIds);
      }
    });
  }

  Future<void> generateSqlScript() async {
    final db = await database;
    final tables = await db
        .rawQuery('SELECT name FROM sqlite_master WHERE type = "table"');
    final indexes = await db.rawQuery(
        'SELECT name, sql FROM sqlite_master WHERE type = "index" AND name NOT LIKE "sqlite_%"');

    StringBuffer sqlScript = StringBuffer();

    for (var table in tables) {
      final tableName = table['name'] as String;
      if (tableName == 'android_metadata' || tableName == 'sqlite_sequence') {
        continue;
      }
      sqlScript.writeln('DROP TABLE IF EXISTS $tableName;');
    }

    for (var table in tables) {
      final tableName = table['name'] as String;
      if (tableName == 'android_metadata' || tableName == 'sqlite_sequence') {
        continue;
      }

      final schemaResult = await db.rawQuery(
          'SELECT sql FROM sqlite_master WHERE type = "table" AND name = "$tableName"');
      if (schemaResult.isNotEmpty) {
        sqlScript.writeln(schemaResult.first['sql'] as String);
        sqlScript.writeln(';');
      }
    }

    for (var table in tables) {
      final tableName = table['name'] as String;
      if (tableName == 'android_metadata' || tableName == 'sqlite_sequence') {
        continue;
      }

      final data = await db.rawQuery('SELECT * FROM $tableName');
      for (var row in data) {
        final columns = row.keys.map((k) => k.toString()).join(', ');
        final values = row.values
            .map((v) =>
                v is String ? "'${v.replaceAll("'", "''")}'" : v.toString())
            .join(', ');

        sqlScript
            .writeln('INSERT INTO $tableName ($columns) VALUES ($values);');
      }
    }

    for (var index in indexes) {
      final indexSql = index['sql'] as String?;
      if (indexSql != null) {
        sqlScript.writeln(indexSql);
        sqlScript.writeln(';');
      }
    }

    final String path = appPath;
    bool exists = await Directory(path).exists();
    if (!exists) {
      await Directory(path).create(recursive: true);
    }

    final sqlPath = join(path, 'dl_dlas');
    final file = File(sqlPath);
    String base64String = base64Encode(utf8.encode(sqlScript.toString()));
    List<int> bytes = base64Decode(base64String);
    List<int> data = utf8.encode(
        bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join());
    await file.writeAsBytes(data, flush: true);
  }

  Future<void> executeSqlScript() async {
    final db = await database;
    final String path = appPath;
    bool exists = await Directory(path).exists();
    if (!exists) {
      print("SQL file doesn't exist.");
    }

    final sqlPath = join(path, 'dl_dlas');
    List<int> bytes = await File(sqlPath).readAsBytes();
    final data = utf8.decode(bytes);
    final script = _getDecryptedObject(data);
    final sqlCommands = script.split(';');

    for (var command in sqlCommands) {
      final trimmedCommand = command.trim();
      if (trimmedCommand.isNotEmpty) {
        await db.execute(trimmedCommand);
      }
    }
  }

  String _getEncryptedObject(String jsonData) {
    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(
        encrypt.AES(_encryptionKey, mode: encrypt.AESMode.cbc));

    final encrypted = encrypter.encrypt(jsonData, iv: iv);

    return '${base64Encode(iv.bytes)}:${encrypted.base64}';
  }

  String _getDecryptedObject(String encryptedData) {
    final parts = encryptedData.split(':');
    if (parts.length != 2) throw Exception('Invalid encrypted data format');

    final iv = encrypt.IV.fromBase64(parts[0]);
    final encryptedText = encrypt.Encrypted.fromBase64(parts[1]);

    final encrypter = encrypt.Encrypter(
        encrypt.AES(_encryptionKey, mode: encrypt.AESMode.cbc));

    return encrypter.decrypt(encryptedText, iv: iv);
  }

  Future<String?> getAGrain(String table, String id) async {
    for (var entry in _allTables.entries) {
      if (entry.key == table) {
        final db = await database;
        final tableName = entry.value.tableName;
        final primaryKey = entry.value.primaryKey;
        final data = await db.query(
          tableName,
          columns: ['object'],
          where: '$primaryKey = ?',
          whereArgs: [id],
        );

        if (data.isNotEmpty) {
          final object = _getDecryptedObject(data.first['object'] as String);
          return object;
        } else {
          return null;
        }
      }
    }
    throw Exception('Table not found');
  }

  Future<List<String>> getPagedGrain(String table,
      [int pageSize = 100, int offset = 0]) async {
    for (var entry in _allTables.entries) {
      if (entry.key == table) {
        final db = await database;
        final tableName = entry.value.tableName;
        final data = await db.query(
          tableName,
          columns: ['object'],
          limit: pageSize,
          offset: offset,
        );

        return data
            .map((e) => _getDecryptedObject(e['object'] as String))
            .toList();
      }
    }
    throw Exception('Table not found');
  }

  Future<List<String>> getAllGrain(String table) async {
    return getPagedGrain(table, 999999, 0);
  }

  Future<List<String>> getIndexedGrain(
      String table,
      List<Map<String, dynamic>>
          conditions, //! Example: [{'key': 'key1', 'value': 'value1', 'operator': 'AND', 'comparison': '>'}, ...]
      [int pageSize = 100,
      int offset = 0]) async {
    for (var entry in _allTables.entries) {
      if (entry.key == table) {
        final db = await database;
        final tableInstance = entry.value;
        final tableName = tableInstance.tableName;
        final primaryKey = tableInstance.primaryKey;

        String whereClause = '';
        List<String> whereArgs = [];

        for (var i = 0; i < conditions.length; i++) {
          final condition = conditions[i];
          final comparison = condition.containsKey('comparison')
              ? condition['comparison'] as String
              : '=';
          final operator = condition.containsKey('operator') && i > 0
              ? condition['operator'] as String
              : '';

          if (i > 0) {
            whereClause += ' $operator ';
          }

          if (condition.containsKey('key')) {
            final key = condition['key'] as String;
            final value = condition['value'] as String;
            whereClause += '(key = ? AND value $comparison ?)';
            whereArgs.add(key);
            whereArgs.add(value);
          } else if (condition.containsKey('value')) {
            final value = condition['value'] as String;
            whereClause += '(value $comparison ?)';
            whereArgs.add(value);
          }
        }

        final indexedData = await db.query(
          '${tableName}_cIdx',
          columns: [primaryKey],
          where: whereClause,
          whereArgs: whereArgs,
          limit: pageSize,
          offset: offset,
        );

        final primaryKeys =
            indexedData.map((e) => e[primaryKey] as String).toList();

        if (primaryKeys.isEmpty) {
          return [];
        }

        final data = await db.query(
          tableName,
          columns: ['object'],
          where:
              '$primaryKey IN (${List.filled(primaryKeys.length, '?').join(', ')})',
          whereArgs: primaryKeys,
        );

        return data
            .map((e) => _getDecryptedObject(e['object'] as String))
            .toList();
      }
    }
    throw Exception('Table not found');
  }
}

abstract class DBGrain {
  String get tableName;
  String get primaryKey => '${tableName}_id';
  String get id;
  int get codecVersion;

  Map<String, String> get indexs;
  String insert();

  String createTable() {
    String sql = 'CREATE TABLE IF NOT EXISTS $tableName (\n';
    sql += '  $primaryKey TEXT PRIMARY KEY,\n';
    sql += '  object TEXT,\n';
    sql += '  createdOn DATETIME DEFAULT CURRENT_TIMESTAMP,\n';
    sql += '  lastUpdatedOn DATETIME DEFAULT CURRENT_TIMESTAMP\n);';
    sql +=
        '\nCREATE INDEX IF NOT EXISTS ${primaryKey}_idx ON $tableName($primaryKey);\n';
    sql +=
        'CREATE TABLE IF NOT EXISTS ${tableName}_cIdx ($primaryKey TEXT, key TEXT, value TEXT);\n';
    sql +=
        'CREATE TABLE IF NOT EXISTS ${tableName}_history ($primaryKey TEXT, object TEXT, createdOn DATETIME);\n';
    sql +=
        'CREATE TABLE IF NOT EXISTS ${tableName}_blob_primary ($primaryKey TEXT, blobId TEXT, key TEXT, createdOn DATETIME);\n';
    return sql;
  }

  String _getEncryptedObject(String jsonData) {
    return DatabaseHelper()._getEncryptedObject(jsonData);
  }

  String DBInsert(String jsonData) {
    String object = _getEncryptedObject(jsonData);

    String sql =
        'INSERT INTO $tableName ($primaryKey, object, createdOn, lastUpdatedOn) '
        'VALUES (\'$id\', \'$object\', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);\n';

    if (indexs.isNotEmpty) {
      sql += 'INSERT INTO ${tableName}_cIdx (id, key, value) VALUES ';
      for (var entry in indexs.entries) {
        sql += '($id, \'${entry.key}\', \'${entry.value}\'),';
      }
      sql = sql.substring(0, sql.length - 1);
      sql += ';';
    }

    return sql;
  }

  String DBInsertCIdx(String key, String value) {
    // TODO : Remove me
    return 'INSERT INTO ${tableName}_cIdx ($primaryKey, key, value) '
        'VALUES (\'$id\', \'$key\', \'$value\');\n';
  }

  String insertImageAsBlob(Uint8List data, String key) {
    String blobId = generateNewUuid();
    String hexData =
        data.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();

    String sql = '''
      INSERT INTO blob (id, data) VALUES ('$blobId', x'$hexData');
      INSERT INTO ${tableName}_blob_primary (id, blobId, key, createdOn) 
      VALUES ('$id', '$blobId', '$key', CURRENT_TIMESTAMP);
    ''';

    return sql;
  }

  String getBlobData(String key) {
    return '''
        SELECT b.data 
        FROM blob b
        INNER JOIN ${tableName}_blob_primary bp ON b.id = bp.blobId
        WHERE bp.id = '$id' AND bp.key = '$key';
      ''';
  }

  String deleteBlobData(String blobId) {
    return '''
      DELETE FROM ${tableName}_blob_primary WHERE blobId = $blobId;
      DELETE FROM blob WHERE id = $blobId;
    ''';
  }

  String DBUpdate(String newJsonData) {
    final object = _getEncryptedObject(newJsonData);

    String sql = '''
      INSERT INTO ${tableName}_history ($primaryKey, object, createdOn)
      SELECT $primaryKey, object, lastUpdatedOn FROM $tableName WHERE $primaryKey = '$id';

      UPDATE $tableName SET object = '$object', lastUpdatedOn = CURRENT_TIMESTAMP WHERE $primaryKey = '$id';
  ''';

    if (indexs.isNotEmpty) {
      sql += '''
      DELETE FROM ${tableName}_cIdx WHERE $primaryKey = '$id';
      INSERT INTO ${tableName}_cIdx ($primaryKey, key, value) VALUES 
    ''';

      List<String> values = [];
      for (var entry in indexs.entries) {
        values.add('(\'$id\', \'${entry.key}\', \'${entry.value}\')');
      }

      sql += '${values.join(', ')};';
    }

    return sql;
  }
}
