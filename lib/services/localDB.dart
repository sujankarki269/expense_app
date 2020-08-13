import 'package:flutter/material.dart';
import 'package:expense_app/models/category.dart';
import 'package:expense_app/models/period.dart';
import 'package:expense_app/models/preferences.dart';
import 'package:expense_app/models/recurringTransaction.dart';
import 'package:expense_app/models/suggestion.dart';
import 'package:expense_app/models/transaction.dart';
import 'package:expense_app/models/user.dart';
import 'package:expense_app/shared/config.dart';
import 'package:expense_app/shared/constants.dart';
import 'package:expense_app/shared/library.dart';
import 'package:sqflite/sqflite.dart' hide Transaction;

class LocalDBService {
  static final LocalDBService _localDBService = LocalDBService.internal();
  factory LocalDBService() => _localDBService;
  static Database _localDB;

  Future<Database> get db async {
    if (_localDB == null) {
      _localDB = await initializeDBs();
    }

    return _localDB;
  }

  LocalDBService.internal();

  // Database-related
  String getTypeInDB(dynamic column) {
    if (column is String) {
      return 'TEXT';
    } else if (column is int) {
      return 'INTEGER';
    } else if (column is bool) {
      return 'INTEGER'; // 1 - true, 0 - false
    } else if (column is DateTime) {
      return 'TEXT';
    } else if (column is double) {
      return 'REAL';
    } else if (column is DateUnit) {
      return 'INTEGER';
    } else if (column is Color) {
      return 'TEXT';
    } else {
      return 'TEXT';
    }
  }

  Future<Database> initializeDBs() async {
    String directory = await getDatabasesPath();

    return await openDatabase('$directory/$LOCAL_DATABASE_FILENAME.db',
        version: 1, onCreate: _createDB, onUpgrade: _upgradeDB);
  }

  void _createDB(Database db, int version) {
    Map<String, dynamic> tables = {
      'categories': {
        'model': Category.example(),
        'primaryKey': 'cid',
      },
      'transactions': {
        'model': Transaction.example(),
        'primaryKey': 'tid',
      },
      'users': {
        'model': User.example(),
        'primaryKey': 'uid',
      },
      'periods': {
        'model': Period.example(),
        'primaryKey': 'pid',
      },
      'preferences': {
        'model': Preferences.example(),
        'primaryKey': 'pid',
      },
      'recurringTransactions': {
        'model': RecurringTransaction.example(),
        'primaryKey': 'rid',
      },
      'hiddenSuggestions': {
        'model': Suggestion.example(),
        'primaryKey': 'sid',
      },
    };

    tables.forEach((tableName, tableData) async {
      String columnsQuery = '';
      for (MapEntry<String, dynamic> column
          in tableData['model'].toMap().entries) {
        columnsQuery += '${column.key} ${getTypeInDB(column.value)}';
        if (column.key == tableData['primaryKey']) {
          columnsQuery += ' PRIMARY KEY';
        }
        columnsQuery += ', ';
      }
      columnsQuery = columnsQuery.substring(0, columnsQuery.length - 2);
      db.execute('CREATE TABLE $tableName($columnsQuery)');
    });
  }

  void _upgradeDB(Database db, int oldVersion, int newVersion) {}

  // Transactions
  Future<List<Transaction>> getTransactions(String uid) async {
    Database db = await this.db;
    return db
        .query(
          'transactions',
          where: 'uid = ?',
          whereArgs: [uid],
          orderBy: 'datetime(date) DESC',
        )
        .then((transactions) =>
            transactions.map((map) => Transaction.fromMap(map)).toList());
  }

  Future addTransactions(List<Transaction> transactions) async {
    Database db = await this.db;
    Batch batch = db.batch();
    transactions.forEach((tx) {
      batch.insert('transactions', tx.toMap());
    });
    await batch.commit();
  }

  Future updateTransactions(List<Transaction> transactions) async {
    Database db = await this.db;
    Batch batch = db.batch();
    transactions.forEach((tx) {
      batch.update(
        'transactions',
        tx.toMap(),
        where: 'tid = ?',
        whereArgs: [tx.tid],
      );
    });
    await batch.commit();
  }

  Future deleteTransactions(List<Transaction> transactions) async {
    Database db = await this.db;
    Batch batch = db.batch();
    transactions.forEach((tx) {
      batch.delete('transactions', where: 'tid = ?', whereArgs: [tx.tid]);
    });
    await batch.commit();
  }

  Future deleteAllTransactions(String uid) async {
    Database db = await this.db;
    await db.delete('transactions', where: 'uid = ?', whereArgs: [uid]);
  }

  // Categories
  Future<List<Category>> getCategories(String uid) async {
    Database db = await this.db;
    return db
        .query(
          'categories',
          where: 'uid = ?',
          whereArgs: [uid],
          orderBy: 'orderIndex ASC',
        )
        .then((categories) =>
            categories.map((map) => Category.fromMap(map)).toList());
  }

  Future addCategories(List<Category> categories) async {
    Database db = await this.db;
    Batch batch = db.batch();
    categories.forEach((category) {
      batch.insert('categories', category.toMap());
    });
    await batch.commit();
  }

  Future updateCategories(List<Category> categories) async {
    Database db = await this.db;
    Batch batch = db.batch();
    categories.forEach((category) {
      batch.update(
        'categories',
        category.toMap(),
        where: 'cid = ?',
        whereArgs: [category.cid],
      );
    });
    await batch.commit();
  }

  Future deleteCategories(List<Category> categories) async {
    Database db = await this.db;
    Batch batch = db.batch();
    categories.forEach((category) {
      batch.delete(
        'categories',
        where: 'cid = ?',
        whereArgs: [category.cid],
      );
    });
    await batch.commit();
  }

  Future deleteAllCategories(String uid) async {
    Database db = await this.db;
    await db.delete('categories', where: 'uid = ?', whereArgs: [uid]);
  }

  // User
  Future<User> getUser(String uid) async {
    Database db = await this.db;
    return db.query(
      'users',
      where: 'uid = ?',
      whereArgs: [uid],
    ).then((map) => map.length == 1 ? User.fromMap(map[0]) : null);
  }

  Future addUser(User user) async {
    Database db = await this.db;
    await db.insert('users', user.toMap());
  }

  // Periods
  Future<List<Period>> getPeriods(String uid) async {
    Database db = await this.db;
    return db
        .query(
          'periods',
          where: 'uid = ?',
          whereArgs: [uid],
          orderBy: 'isDefault DESC',
        )
        .then((periods) => periods.map((map) => Period.fromMap(map)).toList());
  }

  Future<Period> getDefaultPeriod(String uid) async {
    Database db = await this.db;
    return db.query(
      'periods',
      where: 'uid = ? AND isDefault = 1',
      whereArgs: [uid],
    ).then((period) =>
        period.length > 0 ? Period.fromMap(period[0]) : Period.monthly());
  }

  Future setRemainingNotDefault(Period period) async {
    Database db = await this.db;
    await db.update('periods', {'isDefault': 0});
    await db.update(
      'periods',
      {'isDefault': 1},
      where: 'pid = ?',
      whereArgs: [period.pid],
    );
  }

  Future addPeriods(List<Period> periods) async {
    Database db = await this.db;
    Batch batch = db.batch();
    periods.forEach((period) {
      batch.insert('periods', period.toMap());
    });
    await batch.commit();
  }

  Future updatePeriods(List<Period> periods) async {
    Database db = await this.db;
    Batch batch = db.batch();
    periods.forEach((period) {
      batch.update(
        'periods',
        period.toMap(),
        where: 'pid = ?',
        whereArgs: [period.pid],
      );
    });
    await batch.commit();
  }

  Future deletePeriods(List<Period> periods) async {
    Database db = await this.db;
    Batch batch = db.batch();
    periods.forEach((period) {
      batch.delete(
        'periods',
        where: 'pid = ?',
        whereArgs: [period.pid],
      );
    });
    await batch.commit();
  }

  Future deleteAllPeriods(String uid) async {
    Database db = await this.db;
    await db.delete('periods', where: 'uid = ?', whereArgs: [uid]);
  }

  // Recurring Transactions
  Future<List<RecurringTransaction>> getRecurringTransactions(
    String uid,
  ) async {
    Database db = await this.db;
    return db
        .query(
          'recurringTransactions',
          where: 'uid = ?',
          whereArgs: [uid],
          orderBy: 'nextDate ASC',
        )
        .then((recTxs) =>
            recTxs.map((map) => RecurringTransaction.fromMap(map)).toList());
  }

  Future<RecurringTransaction> getRecurringTransaction(String rid) async {
    Database db = await this.db;
    return db.query(
      'recurringTransactions',
      where: 'rid = ?',
      whereArgs: [rid],
    ).then((map) =>
        map.length > 0 ? RecurringTransaction.fromMap(map.first) : null);
  }

  Future addRecurringTransactions(List<RecurringTransaction> recTxs) async {
    Database db = await this.db;
    Batch batch = db.batch();
    recTxs.forEach((recTx) {
      batch.insert('recurringTransactions', recTx.toMap());
    });
    await batch.commit();
  }

  Future updateRecurringTransactions(List<RecurringTransaction> recTxs) async {
    Database db = await this.db;
    Batch batch = db.batch();
    recTxs.forEach((recTx) {
      batch.update(
        'recurringTransactions',
        recTx.toMap(),
        where: 'rid = ?',
        whereArgs: [recTx.rid],
      );
    });
    await batch.commit();
  }

  Future incrementRecurringTransactionsNextDate(
    List<RecurringTransaction> recTxs,
  ) async {
    Database db = await this.db;
    Batch batch = db.batch();
    recTxs.forEach((recTx) {
      RecurringTransaction nextRecTx = recTx.incrementNextDate();
      if ((nextRecTx.endDate == null && nextRecTx.occurrenceValue == null) ||
          (nextRecTx.endDate != null &&
              getDateNotTime(nextRecTx.nextDate)
                  .subtract(Duration(milliseconds: 1))
                  .isBefore(nextRecTx.endDate)) ||
          (nextRecTx.occurrenceValue != null &&
              nextRecTx.occurrenceValue > 0)) {
        batch.update(
          'recurringTransactions',
          nextRecTx.toMap(),
          where: 'rid = ?',
          whereArgs: [recTx.rid],
        );
      } else {
        batch.delete(
          'recurringTransactions',
          where: 'rid = ?',
          whereArgs: [recTx.rid],
        );
      }
    });
    await batch.commit();
  }

  Future deleteRecurringTransactions(
    List<RecurringTransaction> recTxs,
  ) async {
    Database db = await this.db;
    Batch batch = db.batch();
    recTxs.forEach((recTx) {
      batch.delete(
        'recurringTransactions',
        where: 'rid = ?',
        whereArgs: [recTx.rid],
      );
    });
    await batch.commit();
  }

  Future deleteAllRecurringTransactions(String uid) async {
    Database db = await this.db;
    await db
        .delete('recurringTransactions', where: 'uid = ?', whereArgs: [uid]);
  }

  // Preferences
  Future<Preferences> getPreferences(String pid) async {
    Database db = await this.db;
    return db.query(
      'preferences',
      where: 'pid = ?',
      whereArgs: [pid],
    ).then((prefs) => prefs.length > 0 ? Preferences.fromMap(prefs[0]) : null);
  }

  Future addDefaultPreferences(String pid) async {
    Database db = await this.db;
    await db.insert(
      'preferences',
      Preferences.original().setPreference('pid', pid).toMap(),
    );
  }

  Future addPreferences(Preferences prefs) async {
    Database db = await this.db;
    await db.insert('preferences', prefs.toMap());
  }

  Future updatePreferences(Preferences prefs) async {
    Database db = await this.db;
    await db.update(
      'preferences',
      prefs.toMap(),
      where: 'pid = ?',
      whereArgs: [prefs.pid],
    );
  }

  Future deletePreferences(String pid) async {
    Database db = await this.db;
    await db.delete(
      'preferences',
      where: 'pid = ?',
      whereArgs: [pid],
    );
  }

  // Hidden Suggestions
  Future<List<Suggestion>> getHiddenSuggestions(String uid) async {
    Database db = await this.db;
    return db.query(
      'hiddenSuggestions',
      where: 'uid = ?',
      whereArgs: [uid],
    ).then((suggestions) =>
        suggestions.map((map) => Suggestion.fromMap(map)).toList());
  }

  Future addHiddenSuggestions(List<Suggestion> suggestions) async {
    Database db = await this.db;
    Batch batch = db.batch();
    suggestions.forEach((suggestion) {
      batch.insert('hiddenSuggestions', suggestion.toMap());
    });
    await batch.commit();
  }

  Future deleteHiddenSuggestions(List<Suggestion> suggestions) async {
    Database db = await this.db;
    Batch batch = db.batch();
    suggestions.forEach((suggestion) {
      batch.delete('hiddenSuggestions',
          where: 'sid = ?', whereArgs: [suggestion.sid]);
    });
    await batch.commit();
  }
}
