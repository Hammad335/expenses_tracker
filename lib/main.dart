// ignore_for_file: use_key_in_widget_constructors

import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:personal_expenses_flutter/models/transaction.dart';
import 'package:personal_expenses_flutter/widgets/chart.dart';
import 'package:personal_expenses_flutter/widgets/new_transaction.dart';
import 'package:personal_expenses_flutter/widgets/transaction_list.dart';

void main() {
  // setting portrait mode only
  // WidgetsFlutterBinding.ensureInitialized();
  // SystemChrome.setPreferredOrientations(
  //     [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Expenses Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        accentColor: Colors.blue.shade400,
        fontFamily: 'Quicksand',
        textTheme: const TextTheme(
          headline1: TextStyle(
            fontFamily: 'OpenSans',
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          button: TextStyle(
            color: Colors.white,
          ),
        ),
        appBarTheme: const AppBarTheme(
          titleTextStyle: TextStyle(
            fontFamily: 'OpenSans',
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Transaction> _userTransactions = [];
  bool _showChart = false;

  @override
  Widget build(BuildContext context) {
    final PreferredSizeWidget appBar = Platform.isIOS
        ? CupertinoNavigationBar(
            middle: const Text('Expenses Tracker'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                GestureDetector(
                  child: const Icon(CupertinoIcons.add),
                  onTap: () => _startAddNewTransaction(context),
                ),
              ],
            ),
          ) as PreferredSizeWidget
        : AppBar(
            title: const Text('Expenses Tracker'),
            actions: <Widget>[
              IconButton(
                onPressed: () => _startAddNewTransaction(context),
                icon: const Icon(Icons.add),
              ),
            ],
          );
    final bool _isLandscapeMode =
        MediaQuery.of(context).orientation == Orientation.landscape;

    final pageBody = SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (_isLandscapeMode)
              ..._buildLandscapeContext(appBar, transactionsListWidget),
            if (!_isLandscapeMode)
              ..._buildPortraitContent(
                  appBar, _recentTransactions, transactionsListWidget),
          ],
        ),
      ),
    );

    return Platform.isIOS
        ? CupertinoPageScaffold(
            child: pageBody,
            navigationBar: appBar as ObstructingPreferredSizeWidget,
          )
        : Scaffold(
            appBar: appBar,
            floatingActionButton: Platform.isIOS
                ? Container()
                : FloatingActionButton(
                    onPressed: () => _startAddNewTransaction(context),
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                    ),
                  ),
            body: pageBody,
          );
  }

  Widget transactionsListWidget(
      PreferredSizeWidget appBar, double heightPercent) {
    return SizedBox(
      height: (MediaQuery.of(context).size.height -
              appBar.preferredSize.height -
              MediaQuery.of(context).padding.top) *
          heightPercent,
      child: TransactionList(
        transactions: _userTransactions,
        deleteTxCallBack: _deleteTransaction,
      ),
    );
  }

  List<Widget> _buildLandscapeContext(
      PreferredSizeWidget appBar, Function transactionsListWidget) {
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text('Show Chart'),
          Switch.adaptive(
            value: _showChart,
            onChanged: (bool value) {
              setState(() {
                _showChart = value;
              });
            },
          ),
        ],
      ),
      _showChart
          ? CreateChart(
              appBar: appBar,
              recentTransaction: _recentTransactions,
              heightFactor: 0.7,
            )
          : transactionsListWidget(appBar, 0.88)
    ];
  }

  List<Widget> _buildPortraitContent(PreferredSizeWidget appBar,
      List<Transaction> recentTransactions, Function transactionsListWidget) {
    return [
      CreateChart(
        appBar: appBar,
        recentTransaction: recentTransactions,
        heightFactor: 0.3,
      ),
      transactionsListWidget(appBar, 0.7)
    ];
  }

  void _startAddNewTransaction(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return GestureDetector(
          child: NewTransaction(newTxCallBack: _addNewTransaction),
          onTap: () {},
          behavior: HitTestBehavior.opaque,
        );
      },
    );
  }

  void _deleteTransaction(String id) {
    setState(() {
      _userTransactions.removeWhere((element) => element.id == id);
    });
  }

  void _addNewTransaction(String title, double amount, DateTime chosenDate) {
    final Transaction newTransaction = Transaction(
      id: DateTime.now().toString(),
      title: title,
      amount: amount,
      dateTime: chosenDate,
    );
    setState(() {
      _userTransactions.add(newTransaction);
    });
  }

  List<Transaction> get _recentTransactions {
    return _userTransactions.where((transaction) {
      return transaction.dateTime.isAfter(
        DateTime.now().subtract(
          const Duration(days: 7),
        ),
      );
    }).toList();
  }
}

class CreateChart extends StatelessWidget {
  final PreferredSizeWidget appBar;
  final List<Transaction> recentTransaction;
  final double heightFactor;

  const CreateChart(
      {required this.appBar,
      required this.recentTransaction,
      required this.heightFactor});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: (MediaQuery.of(context).size.height -
              appBar.preferredSize.height -
              MediaQuery.of(context).padding.top) *
          heightFactor,
      child: Chart(recentTransactions: recentTransaction),
    );
  }
}
