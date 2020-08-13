import 'package:flutter/material.dart';
import 'package:expense_app/models/category.dart';
import 'package:expense_app/models/period.dart';
import 'package:expense_app/models/preferences.dart';
import 'package:expense_app/models/transaction.dart';
import 'package:expense_app/pages/statistics/balance.dart';
import 'package:expense_app/pages/statistics/categories.dart';
import 'package:expense_app/pages/statistics/periodic.dart';
import 'package:expense_app/pages/statistics/topExpenses.dart';
import 'package:expense_app/shared/constants.dart';
import 'package:expense_app/shared/library.dart';
import 'package:expense_app/shared/styles.dart';
import 'package:expense_app/shared/components.dart';

class Statistics extends StatefulWidget {
  final List<Transaction> allTransactions;
  final List<Category> categories;
  final Period currentPeriod;
  final Preferences prefs;

  Statistics({
    this.allTransactions,
    this.categories,
    this.currentPeriod,
    this.prefs,
  });

  @override
  _StatisticsState createState() => _StatisticsState();
}

class _StatisticsState extends State<Statistics> {
  bool _showAllTimeStats = false;
  bool _showPeriodStats = false;
  bool _showCustomStats = false;

  Widget _body = Center(
    child: Text('No statistics available. Requires at least one transaction.'),
  );

  Widget _limitCustomizer;

  List<Transaction> _transactions;
  List<Map<String, dynamic>> _dividedTransactions = [];
  int _daysLeft;
  DateTime _customLimitByDate;
  Map<String, dynamic> _customPeriod;
  bool _showStatistics = true;

  ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    if (widget.allTransactions != null &&
        widget.currentPeriod != null &&
        widget.prefs != null &&
        widget.allTransactions.length > 0) {
      _showStatistics = true;
      if (!_showAllTimeStats && !_showPeriodStats && !_showCustomStats) {
        if (widget.prefs.defaultCustomLimitTab == LimitTab.AllTime) {
          _showAllTimeStats = true;
        } else if (widget.prefs.defaultCustomLimitTab == LimitTab.Period) {
          _showPeriodStats = true;
        } else if (widget.prefs.defaultCustomLimitTab == LimitTab.Custom) {
          _showCustomStats = true;
        } else {
          _showPeriodStats = true;
        }
      }

      _dividedTransactions = divideTransactionsIntoPeriods(
          widget.allTransactions, widget.currentPeriod);

      Map<String, dynamic> _currentPeriodTransactions =
          findCurrentPeriod(_dividedTransactions);

      if (_currentPeriodTransactions.containsKey('transactions')) {
        _daysLeft = _currentPeriodTransactions['endDate']
                .difference(DateTime.now())
                .inDays +
            1;
      } else {
        _daysLeft = 0;
      }

      if (_showAllTimeStats) {
        _transactions = widget.allTransactions;
        _limitCustomizer = SizedBox(height: 48.0);
      }

      if (_showPeriodStats) {
        if (_customPeriod != null) {
          _transactions = _customPeriod['transactions'];
          if (_customPeriod['startDate'] ==
              _currentPeriodTransactions['startDate']) {
            _customPeriod = null;
          }
        }
        if (_customPeriod == null) {
          if (_currentPeriodTransactions.containsKey('transactions')) {
            _transactions = _currentPeriodTransactions['transactions'];
          } else {
            _transactions = [];
          }
        }

        _limitCustomizer = DropdownButton<Map<String, dynamic>>(
          items: _dividedTransactions.map((map) {
            return DropdownMenuItem<Map<String, dynamic>>(
              value: map,
              child: Center(
                child: Text(
                  '${getDateStr(map['startDate'])} - ${getDateStr(map['endDate'])}',
                ),
              ),
            );
          }).toList(),
          onChanged: (val) {
            setState(() => _customPeriod = val);
          },
          hint: Center(
            child: Text(
              _customPeriod != null
                  ? '${getDateStr(_customPeriod['startDate'])} - ${getDateStr(_customPeriod['endDate'])}'
                  : '${getDateStr(_currentPeriodTransactions['startDate'])} - ${getDateStr(_currentPeriodTransactions['endDate'])}',
            ),
          ),
          isExpanded: true,
        );
      }

      List<Map<String, dynamic>> _customDividedTransactions;
      if (_showCustomStats) {
        if (widget.allTransactions.length > 0 &&
                widget.prefs.isLimitDaysEnabled ||
            widget.prefs.isLimitByDateEnabled) {
          Preferences customPrefs = Preferences(
            pid: widget.prefs.pid,
            limitDays: widget.prefs.limitDays,
            isLimitDaysEnabled: widget.prefs.isLimitDaysEnabled,
            limitPeriods: widget.prefs.limitPeriods,
            isLimitPeriodsEnabled: widget.prefs.isLimitPeriodsEnabled,
            limitByDate: widget.prefs.limitByDate,
            isLimitByDateEnabled: widget.prefs.isLimitByDateEnabled,
            defaultCustomLimitTab: widget.prefs.defaultCustomLimitTab,
            incomeUnfiltered: widget.prefs.incomeUnfiltered,
            expensesUnfiltered: widget.prefs.expensesUnfiltered,
          );
          if (_customLimitByDate != null) {
            customPrefs =
                customPrefs.setPreference('limitByDate', _customLimitByDate);
          }
          _transactions =
              filterTransactionsByLimit(widget.allTransactions, customPrefs);
          _customDividedTransactions = divideTransactionsIntoPeriods(
              _transactions, widget.currentPeriod);
        } else {
          _customDividedTransactions = filterPeriodsWithLimit(
              _dividedTransactions, widget.prefs.limitPeriods);
          _transactions = _customDividedTransactions
              .map<List<Transaction>>((map) => map['transactions'])
              .expand((x) => x)
              .toList();
        }

        DateTime limitFirstDate;
        if (widget.prefs.isLimitByDateEnabled) {
          limitFirstDate = widget.prefs.limitByDate;
        } else if (widget.prefs.isLimitDaysEnabled) {
          limitFirstDate = getDateNotTime(DateTime.now().add(Duration(days: 1)))
              .subtract(Duration(days: widget.prefs.limitDays));
        } else if (widget.prefs.isLimitPeriodsEnabled) {
          limitFirstDate = findStartDateOfGivenNumPeriodsAgo(
              widget.prefs.limitPeriods, widget.currentPeriod);
        }

        _limitCustomizer = DatePicker(
          context,
          leading: getDateStr(_customLimitByDate ?? limitFirstDate),
          updateDateState: (date) =>
              setState(() => _customLimitByDate = getDateNotTime(date)),
          openDate: limitFirstDate,
        );
        if (_customLimitByDate != null &&
            _customLimitByDate.isAfter(widget.allTransactions.first.date)) {
          _showStatistics = false;
        } else {
          _showStatistics = true;
        }
      }

      final List<Transaction> onlyExpenses =
          _transactions.where((tx) => tx.isExpense).toList();

      _body = ListView(
        controller: _scrollController,
        padding: bodyPadding,
        children: <Widget>[
          TabSelector(
            context,
            tabs: [
              {
                'enabled': _showAllTimeStats,
                'title': 'All-Time',
                'onPressed': () => setState(() {
                      _showAllTimeStats = true;
                      _showPeriodStats = false;
                      _showCustomStats = false;
                    }),
              },
              {
                'enabled': _showPeriodStats,
                'title': 'Period',
                'onPressed': () => setState(() {
                      _showAllTimeStats = false;
                      _showPeriodStats = true;
                      _showCustomStats = false;
                    }),
              },
              {
                'enabled': _showCustomStats,
                'title': 'Custom',
                'onPressed': () => setState(() {
                      _showAllTimeStats = false;
                      _showPeriodStats = false;
                      _showCustomStats = true;
                    }),
              },
            ],
          ),
          _limitCustomizer,
          if (_showStatistics) ...[
            Balance(
              transactions: _transactions,
              showPeriodStats: _customPeriod == null ? _showPeriodStats : false,
              daysLeft: _daysLeft,
            ),
            SizedBox(height: 20.0),
            Categories(
              transactions: _transactions,
              categories: widget.categories,
              prefs: widget.prefs,
            ),
            if (_showAllTimeStats || _showCustomStats) ...[
              SizedBox(height: 20.0),
              Periodic(
                dividedTransactions: _showAllTimeStats
                    ? _dividedTransactions.reversed.toList()
                    : _customDividedTransactions.reversed.toList(),
              ),
            ],
            SizedBox(height: 20.0),
            TopExpenses(
              transactions: onlyExpenses,
              categories: widget.categories,
              totalIncome: _transactions
                  .where((tx) => !tx.isExpense)
                  .fold(0.0, (a, b) => a + b.amount),
              totalExpenses: _transactions
                  .where((tx) => tx.isExpense)
                  .fold(0.0, (a, b) => a + b.amount),
              scrollController: _scrollController,
            ),
          ] else ...[
            Center(
              child: Text('No transactions available after this date.'),
            ),
          ]
        ],
      );
    }

    return _body;
  }
}
