import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:expense_app/models/category.dart';
import 'package:expense_app/models/suggestion.dart';
import 'package:expense_app/models/transaction.dart';
import 'package:expense_app/pages/transactions/transactionForm.dart';
import 'package:expense_app/services/databaseWrapper.dart';
import 'package:expense_app/shared/library.dart';
import 'package:provider/provider.dart';

class TransactionTile extends StatelessWidget {
  final Transaction transaction;
  final Category category;
  final List<Suggestion> hiddenSuggestions;
  final Function refreshList;

  TransactionTile({
    this.transaction,
    this.category,
    this.hiddenSuggestions,
    this.refreshList,
  });

  @override
  Widget build(BuildContext context) {
    final _user = Provider.of<FirebaseUser>(context);

    return Padding(
      padding: EdgeInsets.only(top: 5.0),
      child: Card(
        margin: EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 0.0),
        child: ListTile(
          onTap: () async {
            await showDialog(
              context: context,
              builder: (context) {
                return MultiProvider(
                  providers: [
                    FutureProvider<List<Transaction>>.value(
                        value: DatabaseWrapper(_user.uid).getTransactions()),
                    FutureProvider<List<Category>>.value(
                        value: DatabaseWrapper(_user.uid).getCategories()),
                  ],
                  child: TransactionForm(
                    hiddenSuggestions: hiddenSuggestions,
                    getTxOrRecTx: () => transaction,
                  ),
                );
              },
            );
            refreshList();
          },
          leading: CircleAvatar(
            radius: 25.0,
            backgroundColor: Theme.of(context).backgroundColor,
            child: Icon(
              IconData(
                category.icon,
                fontFamily: 'MaterialDesignIconFont',
                fontPackage: 'community_material_icon',
              ),
              color: category.iconColor,
            ),
          ),
          title: Text(transaction.payee),
          subtitle: Text(category.name),
          trailing: Column(
            children: <Widget>[
              Text(
                '${transaction.isExpense ? '-' : '+'}\$${transaction.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  color: transaction.isExpense ? Colors.red : Colors.green,
                ),
              ),
              Text(getDateStr(transaction.date)),
            ],
          ),
        ),
      ),
    );
  }
}
