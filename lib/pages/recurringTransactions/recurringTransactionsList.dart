import 'package:community_material_icon/community_material_icon.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:expense_app/models/category.dart';
import 'package:expense_app/models/recurringTransaction.dart';
import 'package:expense_app/models/suggestion.dart';
import 'package:expense_app/models/transaction.dart';
import 'package:expense_app/pages/transactions/transactionForm.dart';
import 'package:expense_app/services/databaseWrapper.dart';
import 'package:expense_app/shared/constants.dart';
import 'package:expense_app/shared/library.dart';
import 'package:expense_app/shared/styles.dart';
import 'package:expense_app/shared/components.dart';
import 'package:expense_app/pages/home/mainDrawer.dart';
import 'package:provider/provider.dart';

class RecurringTransactionsList extends StatefulWidget {
  final FirebaseUser user;
  final Function openPage;

  RecurringTransactionsList({this.user, this.openPage});

  @override
  _RecurringTransactionsListState createState() =>
      _RecurringTransactionsListState();
}

class _RecurringTransactionsListState extends State<RecurringTransactionsList> {
  List<RecurringTransaction> _recTxs;
  List<Suggestion> _hiddenSuggestions;

  @override
  void initState() {
    super.initState();
    retrieveNewData(widget.user.uid);
  }

  @override
  Widget build(BuildContext context) {
    Widget _body = Loader();

    if (_recTxs != null) {
      if (_recTxs.length == 0) {
        _body = Center(
          child: Text('Add a recurring transaction using the button below.'),
        );
      } else {
        _body = Container(
          padding: bodyPadding,
          child: ListView.builder(
            itemCount: _recTxs.length,
            itemBuilder: (context, index) => recurringTransactionCard(
              context,
              _recTxs[index],
              () => retrieveNewData(widget.user.uid),
            ),
          ),
        );
      }
    }

    return Scaffold(
      drawer: MainDrawer(user: widget.user, openPage: widget.openPage),
      appBar: AppBar(title: Text('Recurring Transactions')),
      body: _body,
      floatingActionButton: FloatingButton(
        context,
        page: MultiProvider(
          providers: [
            FutureProvider<List<Transaction>>.value(
                value: DatabaseWrapper(widget.user.uid).getTransactions()),
            FutureProvider<List<Category>>.value(
                value: DatabaseWrapper(widget.user.uid).getCategories()),
          ],
          child: TransactionForm(
            hiddenSuggestions: _hiddenSuggestions,
            getTxOrRecTx: () => RecurringTransaction.empty(),
          ),
        ),
        callback: () => retrieveNewData(widget.user.uid),
      ),
    );
  }

  Widget recurringTransactionCard(
    BuildContext context,
    RecurringTransaction recTx,
    Function refreshList,
  ) {
    return Card(
      color: recTx.isExpense ? Colors.red[50] : Colors.green[50],
      child: ListTile(
        onTap: () async {
          await showDialog(
            context: context,
            builder: (context) => MultiProvider(
              providers: [
                FutureProvider<List<Transaction>>.value(
                    value: DatabaseWrapper(widget.user.uid).getTransactions()),
                FutureProvider<List<Category>>.value(
                    value: DatabaseWrapper(widget.user.uid).getCategories()),
              ],
              child: TransactionForm(
                hiddenSuggestions: _hiddenSuggestions,
                getTxOrRecTx: () => recTx,
              ),
            ),
          );
          refreshList();
        },
        title: Wrap(children: <Widget>[
          Text('${recTx.payee}: '),
          Text(
            '${recTx.isExpense ? '-' : '+'}\$${recTx.amount.toStringAsFixed(2)}',
          ),
        ]),
        subtitle: Text(
          'Every ${recTx.frequencyValue} ${getFrequencyUnitStr(recTx.frequencyUnit)}' +
              getEndCondition(recTx),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(CommunityMaterialIcons.chevron_right),
            Text('${getDateStr(recTx.nextDate)}'),
          ],
        ),
      ),
    );
  }

  String getFrequencyUnitStr(DateUnit freqUnit) {
    String unitPlural = freqUnit.toString().split('.')[1];
    String unitSingular = unitPlural.substring(0, unitPlural.length - 1);
    return '$unitSingular(s)';
  }

  String getEndCondition(RecurringTransaction recTx) {
    if (recTx.endDate != null && recTx.endDate.toString().isNotEmpty) {
      return ', ~${getDateStr(recTx.endDate)}';
    } else if (recTx.occurrenceValue != null && recTx.occurrenceValue > 0) {
      return ', ${recTx.occurrenceValue} time(s) left';
    } else {
      return '';
    }
  }

  void retrieveNewData(String uid) async {
    List<Future> dataFutures = [];

    dataFutures.add(DatabaseWrapper(uid).getRecurringTransactions());
    dataFutures.add(DatabaseWrapper(uid).getHiddenSuggestions());

    List<dynamic> data = await Future.wait(dataFutures);

    setState(() {
      _recTxs = data[0];
      _hiddenSuggestions = data[1];
    });
  }
}
