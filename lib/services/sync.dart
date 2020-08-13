import 'package:expense_app/models/period.dart';
import 'package:expense_app/models/recurringTransaction.dart';
import 'package:expense_app/models/suggestion.dart';
import 'package:expense_app/models/transaction.dart';
import 'package:expense_app/services/fireDB.dart';
import 'package:expense_app/services/localDB.dart';

class SyncService {
  final String uid;
  FireDBService _fireDBService;
  LocalDBService _localDBService;

  SyncService(this.uid) {
    this._fireDBService = FireDBService(this.uid);
    this._localDBService = LocalDBService();
  }

  void syncTransactions() async {
    List<Transaction> cloudTransactions =
        await _fireDBService.getTransactions();
    List<Transaction> localTransactions =
        await _localDBService.getTransactions(uid);
    List<Transaction> transactionsOnlyInCloud = cloudTransactions
        .where((cloud) =>
            localTransactions.where((local) => local.equalTo(cloud)).length ==
            0)
        .toList();
    List<Transaction> transactionsOnlyInLocal = localTransactions
        .where((local) =>
            cloudTransactions.where((cloud) => cloud.equalTo(local)).length ==
            0)
        .toList();
    _fireDBService.deleteTransactions(transactionsOnlyInCloud);
    _fireDBService.addTransactions(transactionsOnlyInLocal);
  }

  void syncCategories() async {
    await _fireDBService.deleteAllCategories();
    _localDBService
        .getCategories(uid)
        .then((categories) => _fireDBService.addCategories(categories));
  }

  void syncPeriods() async {
    List<Period> cloudPeriods = await _fireDBService.getPeriods();
    List<Period> localPeriods = await _localDBService.getPeriods(uid);

    List<Period> periodsOnlyInCloud = cloudPeriods
        .where((cloud) =>
            localPeriods.where((local) => local.equalTo(cloud)).length == 0)
        .toList();
    List<Period> periodsOnlyInLocal = localPeriods
        .where((local) =>
            cloudPeriods.where((cloud) => cloud.equalTo(local)).length == 0)
        .toList();

    _fireDBService.deletePeriods(periodsOnlyInCloud);
    _fireDBService.addPeriods(periodsOnlyInLocal);
  }

  void syncRecurringTransactions() async {
    List<RecurringTransaction> cloudRecTxs =
        await _fireDBService.getRecurringTransactions();
    List<RecurringTransaction> localRecTxs =
        await _localDBService.getRecurringTransactions(uid);
    List<RecurringTransaction> recTxsOnlyInCloud = cloudRecTxs
        .where((cloud) =>
            localRecTxs.where((local) => local.equalTo(cloud)).length == 0)
        .toList();
    List<RecurringTransaction> recTxsOnlyInLocal = localRecTxs
        .where((local) =>
            cloudRecTxs.where((cloud) => cloud.equalTo(local)).length == 0)
        .toList();
    _fireDBService.deleteRecurringTransactions(recTxsOnlyInCloud);
    _fireDBService.addRecurringTransactions(recTxsOnlyInLocal);
  }

  void syncPreferences() async {
    await _fireDBService.deletePreferences();
    _localDBService
        .getPreferences(uid)
        .then((preferences) => _fireDBService.addPreferences(preferences));
  }

  void syncHiddenSuggestions() async {
    List<Suggestion> cloudHiddenSuggestions =
        await _fireDBService.getHiddenSuggestions();
    List<Suggestion> localHiddenSuggestions =
        await _localDBService.getHiddenSuggestions(uid);
    List<Suggestion> hiddenSuggestionsOnlyInCloud = cloudHiddenSuggestions
        .where((cloud) =>
            localHiddenSuggestions
                .where((local) => local.equalTo(cloud))
                .length ==
            0)
        .toList();
    List<Suggestion> hiddenSuggestionsOnlyInLocal = localHiddenSuggestions
        .where((local) =>
            cloudHiddenSuggestions
                .where((cloud) => cloud.equalTo(local))
                .length ==
            0)
        .toList();
    _fireDBService.deleteHiddenSuggestions(hiddenSuggestionsOnlyInCloud);
    _fireDBService.addHiddenSuggestions(hiddenSuggestionsOnlyInLocal);
  }

  void syncToCloud() {
    syncTransactions();
    syncCategories();
    syncPeriods();
    syncRecurringTransactions();
    syncPreferences();
    syncHiddenSuggestions();
  }

  Future syncToLocal() async {
    if (await _localDBService.getUser(uid) == null) {
      final List<Future> getThenAdd = [
        _fireDBService.getUser().then((user) => _localDBService.addUser(user)),
        _fireDBService.getTransactions().then((cloudTransactions) =>
            _localDBService.addTransactions(cloudTransactions)),
        _fireDBService.getCategories().then((cloudCategories) =>
            _localDBService.addCategories(cloudCategories)),
        _fireDBService
            .getPeriods()
            .then((cloudPeriods) => _localDBService.addPeriods(cloudPeriods)),
        _fireDBService.getRecurringTransactions().then(
            (cloudRecurringTransactions) => _localDBService
                .addRecurringTransactions(cloudRecurringTransactions)),
        _fireDBService.getPreferences().then((cloudPreferences) =>
            _localDBService.addPreferences(cloudPreferences)),
        _fireDBService.getHiddenSuggestions().then((cloudHiddenSuggestions) =>
            _localDBService.addHiddenSuggestions(cloudHiddenSuggestions)),
      ];
      await Future.wait(getThenAdd);
    }
  }
}
