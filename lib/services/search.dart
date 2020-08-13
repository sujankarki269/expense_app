import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:expense_app/models/category.dart';
import 'package:expense_app/models/period.dart';
import 'package:expense_app/models/preferences.dart';
import 'package:expense_app/models/suggestion.dart';
import 'package:expense_app/models/transaction.dart';
import 'package:expense_app/pages/transactions/transactionsList.dart';

class SearchService extends SearchDelegate {
  final List<Transaction> transactions;
  final List<Category> categories;
  final Period currentPeriod;
  final Preferences prefs;
  final List<Suggestion> hiddenSuggestions;
  final Function refreshList;

  SearchService({
    this.transactions,
    this.categories,
    this.currentPeriod,
    this.prefs,
    this.hiddenSuggestions,
    this.refreshList,
  });

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(CommunityMaterialIcons.close),
        onPressed: () => query = '',
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return null;
  }

  @override
  Widget buildResults(BuildContext context) {
    return null;
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return Center(child: Text('Start typing to find transactions.'));
    } else {
      final List<Transaction> searchedTransactions = transactions
          .where((tx) => tx.payee.toLowerCase().contains(query.toLowerCase()))
          .toList();
      return TransactionsList(
        transactions: searchedTransactions,
        categories: categories,
        currentPeriod: currentPeriod,
        hiddenSuggestions: hiddenSuggestions,
        refreshList: () => refreshList(query),
      );
    }
  }
}
