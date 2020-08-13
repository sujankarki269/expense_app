import 'package:expense_app/models/category.dart';
import 'package:expense_app/models/period.dart';
import 'package:expense_app/models/preferences.dart';
import 'package:expense_app/models/recurringTransaction.dart';
import 'package:expense_app/models/suggestion.dart';
import 'package:expense_app/models/transaction.dart';
import 'package:expense_app/models/user.dart';
import 'package:expense_app/pages/categories/categoriesRegistry.dart';
import 'package:expense_app/services/fireDB.dart';
import 'package:expense_app/services/localDB.dart';
import 'package:expense_app/shared/config.dart';
import 'package:expense_app/shared/constants.dart';
import 'package:uuid/uuid.dart';

class DatabaseWrapper {
  final String uid;
  FireDBService _fireDBService;
  LocalDBService _localDBService;

  DatabaseWrapper(this.uid) {
    this._fireDBService = FireDBService(this.uid);
    this._localDBService = LocalDBService();
  }

  // Transactions
  Future<List<Transaction>> getTransactions() {
    return DATABASE_TYPE == DatabaseType.Firebase
        ? _fireDBService.getTransactions()
        : _localDBService.getTransactions(uid);
  }

  Future addTransactions(List<Transaction> transactions) async {
    DATABASE_TYPE == DatabaseType.Firebase
        ? await _fireDBService.addTransactions(transactions)
        : await _localDBService.addTransactions(transactions);
  }

  Future updateTransactions(List<Transaction> transactions) async {
    DATABASE_TYPE == DatabaseType.Firebase
        ? await _fireDBService.updateTransactions(transactions)
        : await _localDBService.updateTransactions(transactions);
  }

  Future deleteTransactions(List<Transaction> transactions) async {
    DATABASE_TYPE == DatabaseType.Firebase
        ? await _fireDBService.deleteTransactions(transactions)
        : await _localDBService.deleteTransactions(transactions);
  }

  Future deleteAllTransactions() async {
    DATABASE_TYPE == DatabaseType.Firebase
        ? await _fireDBService.deleteAllTransactions()
        : await _localDBService.deleteAllTransactions(uid);
  }

  // Categories
  Future<List<Category>> getCategories() {
    return DATABASE_TYPE == DatabaseType.Firebase
        ? _fireDBService.getCategories()
        : _localDBService.getCategories(uid);
  }

  Future addDefaultCategories() async {
    List<Category> categories = [];
    categoriesRegistry.asMap().forEach((index, category) async {
      String cid = Uuid().v1();
      categories.add(Category(
        cid: cid,
        name: category['name'],
        icon: category['icon'],
        iconColor: category['color'],
        enabled: true,
        unfiltered: true,
        orderIndex: index,
        uid: uid,
      ));
    });
    await _fireDBService.addCategories(categories);
    await _localDBService.addCategories(categories);
  }

  Future addCategories(List<Category> categories) async {
    return DATABASE_TYPE == DatabaseType.Firebase
        ? _fireDBService.addCategories(categories)
        : _localDBService.addCategories(categories);
  }

  Future updateCategories(List<Category> categories) async {
    DATABASE_TYPE == DatabaseType.Firebase
        ? await _fireDBService.updateCategories(categories)
        : await _localDBService.updateCategories(categories);
  }

  Future deleteCategories(List<Category> categories) async {
    DATABASE_TYPE == DatabaseType.Firebase
        ? await _fireDBService.deleteCategories(categories)
        : await _localDBService.deleteCategories(categories);
  }

  Future deleteAllCategories() async {
    DATABASE_TYPE == DatabaseType.Firebase
        ? await _fireDBService.deleteAllCategories()
        : await _localDBService.deleteAllCategories(uid);
  }

  // Future resetCategories() async {
  //   DATABASE_TYPE == DatabaseType.Firebase
  //       ? await _fireDBService.deleteAllCategories()
  //       : await _localDBService.deleteAllCategories(uid);

  //   DATABASE_TYPE == DatabaseType.Firebase
  //       ? await _fireDBService.addDefaultCategories()
  //       : await _localDBService.addDefaultCategories(uid);
  // }

  // User Info
  Future<User> getUser() {
    return DATABASE_TYPE == DatabaseType.Firebase
        ? _fireDBService.getUser()
        : _localDBService.getUser(uid);
  }

  Future addUser(User user) async {
    await _fireDBService.addUser(user);
    await _localDBService.addUser(user);
  }

  // Periods
  Future<List<Period>> getPeriods() {
    return DATABASE_TYPE == DatabaseType.Firebase
        ? _fireDBService.getPeriods()
        : _localDBService.getPeriods(uid);
  }

  Future<Period> getDefaultPeriod() {
    return DATABASE_TYPE == DatabaseType.Firebase
        ? _fireDBService.getDefaultPeriod()
        : _localDBService.getDefaultPeriod(uid);
  }

  Future setRemainingNotDefault(Period period) async {
    DATABASE_TYPE == DatabaseType.Firebase
        ? await _fireDBService.setRemainingNotDefault(period)
        : await _localDBService.setRemainingNotDefault(period);
  }

  Future addPeriods(List<Period> periods) async {
    DATABASE_TYPE == DatabaseType.Firebase
        ? await _fireDBService.addPeriods(periods)
        : await _localDBService.addPeriods(periods);
  }

  Future updatePeriods(List<Period> periods) async {
    DATABASE_TYPE == DatabaseType.Firebase
        ? await _fireDBService.updatePeriods(periods)
        : await _localDBService.updatePeriods(periods);
  }

  Future deletePeriods(List<Period> periods) async {
    DATABASE_TYPE == DatabaseType.Firebase
        ? await _fireDBService.deletePeriods(periods)
        : await _localDBService.deletePeriods(periods);
  }

  Future deleteAllPeriods() async {
    DATABASE_TYPE == DatabaseType.Firebase
        ? await _fireDBService.deleteAllPeriods()
        : await _localDBService.deleteAllPeriods(uid);
  }

  // Recurring Transactions
  Future<List<RecurringTransaction>> getRecurringTransactions() {
    return DATABASE_TYPE == DatabaseType.Firebase
        ? _fireDBService.getRecurringTransactions()
        : _localDBService.getRecurringTransactions(uid);
  }

  Future<RecurringTransaction> getRecurringTransaction(String rid) {
    return DATABASE_TYPE == DatabaseType.Firebase
        ? _fireDBService.getRecurringTransaction(rid)
        : _localDBService.getRecurringTransaction(rid);
  }

  Future addRecurringTransactions(
    List<RecurringTransaction> recTxs,
  ) async {
    DATABASE_TYPE == DatabaseType.Firebase
        ? await _fireDBService.addRecurringTransactions(recTxs)
        : await _localDBService.addRecurringTransactions(recTxs);
  }

  Future updateRecurringTransactions(
    List<RecurringTransaction> recTxs,
  ) async {
    DATABASE_TYPE == DatabaseType.Firebase
        ? await _fireDBService.updateRecurringTransactions(recTxs)
        : await _localDBService.updateRecurringTransactions(recTxs);
  }

  Future incrementRecurringTransactionsNextDate(
    List<RecurringTransaction> recTxs,
  ) async {
    DATABASE_TYPE == DatabaseType.Firebase
        ? await _fireDBService.incrementRecurringTransactionsNextDate(recTxs)
        : await _localDBService.incrementRecurringTransactionsNextDate(recTxs);
  }

  Future deleteRecurringTransactions(
    List<RecurringTransaction> recTxs,
  ) async {
    DATABASE_TYPE == DatabaseType.Firebase
        ? await _fireDBService.deleteRecurringTransactions(recTxs)
        : await _localDBService.deleteRecurringTransactions(recTxs);
  }

  Future deleteAllRecurringTransactions() async {
    DATABASE_TYPE == DatabaseType.Firebase
        ? await _fireDBService.deleteAllRecurringTransactions()
        : await _localDBService.deleteAllRecurringTransactions(uid);
  }

  // Preferences
  Future<Preferences> getPreferences() {
    return DATABASE_TYPE == DatabaseType.Firebase
        ? _fireDBService.getPreferences()
        : _localDBService.getPreferences(uid);
  }

  Future addDefaultPreferences() async {
    await _fireDBService.addDefaultPreferences();
    await _localDBService.addDefaultPreferences(uid);
  }

  Future updatePreferences(Preferences prefs) async {
    DATABASE_TYPE == DatabaseType.Firebase
        ? await _fireDBService.updatePreferences(prefs)
        : await _localDBService.updatePreferences(prefs);
  }

  Future resetPreferences() async {
    DATABASE_TYPE == DatabaseType.Firebase
        ? await _fireDBService.deletePreferences()
        : await _localDBService.deletePreferences(uid);

    DATABASE_TYPE == DatabaseType.Firebase
        ? await _fireDBService.addDefaultPreferences()
        : await _localDBService.addDefaultPreferences(uid);
  }

// Hidden Suggestions
  Future<List<Suggestion>> getHiddenSuggestions() {
    return DATABASE_TYPE == DatabaseType.Firebase
        ? _fireDBService.getHiddenSuggestions()
        : _localDBService.getHiddenSuggestions(uid);
  }

  Future addHiddenSuggestions(List<Suggestion> suggestions) async {
    DATABASE_TYPE == DatabaseType.Firebase
        ? await _fireDBService.addHiddenSuggestions(suggestions)
        : await _localDBService.addHiddenSuggestions(suggestions);
  }

  Future deleteHiddenSuggestions(List<Suggestion> suggestions) async {
    DATABASE_TYPE == DatabaseType.Firebase
        ? await _fireDBService.deleteHiddenSuggestions(suggestions)
        : await _localDBService.deleteHiddenSuggestions(suggestions);
  }
}
