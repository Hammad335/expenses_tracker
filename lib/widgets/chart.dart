import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:personal_expenses_flutter/widgets/chart_bar.dart';
import '../models/transaction.dart';

class Chart extends StatelessWidget {
  final List<Transaction> recentTransactions;

  const Chart({required this.recentTransactions});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.all(20),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: groupedTransactionValues.map((e) {
            return Flexible(
              fit: FlexFit.tight,
              child: ChartBar(
                weekDay: e['day'] as String,
                spentAmount: e['amount'] as double,
                percentSpentAmount: maxSpending == 0.0
                    ? 0.0
                    : (e['amount'] as double) / maxSpending,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  double get maxSpending {
    return groupedTransactionValues.fold(0.0, (sum, element) {
      double weekDayTotal = element['amount'] as double;
      return sum + weekDayTotal;
    });
  }

  List<Map<String, Object>> get groupedTransactionValues {
    return List.generate(7, (index) {
      final weekDay = DateTime.now().subtract(Duration(days: index));

      double totalSum = 0.0;
      for (Transaction t in recentTransactions) {
        if (t.dateTime.day == weekDay.day &&
            t.dateTime.month == weekDay.month &&
            t.dateTime.year == weekDay.year) {
          totalSum += t.amount;
        }
      }
      return {
        'day': DateFormat.E().format(weekDay).substring(0, 1),
        'amount': totalSum,
      };
    }).reversed.toList();
  }
}
