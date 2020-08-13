import 'package:expense_app/models/recurringTransaction.dart';
import 'package:expense_app/services/databaseWrapper.dart';

class RecurringTransactionsService {
  static Future<void> checkRecurringTransactions(String uid) async {
    List<RecurringTransaction> recTxs =
        await DatabaseWrapper(uid).getRecurringTransactions();
    DateTime now = DateTime.now();
    for (RecurringTransaction recTx in recTxs) {
      RecurringTransaction iteratingRecTx = recTx;
      while (iteratingRecTx != null && iteratingRecTx.nextDate.isBefore(now)) {
        DatabaseWrapper(uid).addTransactions([iteratingRecTx.toTransaction()]);
        DatabaseWrapper(uid)
            .incrementRecurringTransactionsNextDate([iteratingRecTx]);
        iteratingRecTx = await DatabaseWrapper(uid)
            .getRecurringTransaction(iteratingRecTx.rid);
      }
    }
  }
}
