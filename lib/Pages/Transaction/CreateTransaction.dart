import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet/constants/theme.dart';
import 'package:wallet/models/account.dart';

class CreateTransaction extends StatefulWidget {
  const CreateTransaction({super.key});

  @override
  State<CreateTransaction> createState() => _CreateTransactionState();
}

class _CreateTransactionState extends State<CreateTransaction> {
  String selectedRecordType = 'Income';
  late Account account;
  late Account toAccount;
  double amount = 0.0;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final state = context.read<AccountBloc>().state;
    if (state is AccountLoaded && state.allAccounts.isNotEmpty) {
      account = state.selectedAccounts.isNotEmpty
          ? state.allAccounts
              .firstWhere((a) => a.id == state.selectedAccounts.first)
          : state.allAccounts.first;
      toAccount = state.allAccounts.length > 1 ? state.allAccounts[1] : account;
    } else {
      account = Account.defaultCtor();
      toAccount = Account.defaultCtor();
    }
  }

  @override
  Widget build(BuildContext context) {
    final halfWidth = MediaQuery.of(context).size.width * 0.5;
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Transaction',
            style: Theme.of(context).textTheme.titleMedium),
        centerTitle: true,
        backgroundColor: CustomColor.primary.shade900,
      ),
      body: Row(
        children: [
          SizedBox(
            width: halfWidth,
            child: Column(
              children: [
                Row(
                  children: ['Income', 'Expense', 'Transfer'].map((type) {
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => selectedRecordType = type),
                        child: Container(
                          height: 50,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: selectedRecordType == type
                                ? CustomColor.primary.shade700
                                : (type == 'Income'
                                    ? Colors.green
                                    : type == 'Expense'
                                        ? Colors.red
                                        : Colors.blue),
                            border: Border.all(color: Colors.black),
                          ),
                          child: Text(
                            type,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Colors.white),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                // Display and account info
                Container(
                  padding: const EdgeInsets.all(20),
                  height: MediaQuery.of(context).size.height * 0.35,
                  color: CustomColor.primary.shade700,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Amount display
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            selectedRecordType == 'Income'
                                ? '+'
                                : selectedRecordType == 'Expense'
                                    ? '-'
                                    : '<>',
                            style: amountStyle(),
                          ),
                          Row(
                            children: [
                              Text(
                                amount.toStringAsFixed(2),
                                style: amountStyle(),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                account.currency,
                                style: amountStyle(),
                              ),
                            ],
                          ),
                        ],
                      ),
                      // Account/Category row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          accountInfo(
                            label: selectedRecordType == 'Transfer'
                                ? 'From account'
                                : 'Account',
                            value: account.name,
                            onTap: () {},
                          ),
                          if (selectedRecordType == 'Transfer')
                            accountInfo(
                                label: 'To account',
                                value: toAccount.name,
                                onTap: () {})
                          else
                            accountInfo(
                                label: 'Category',
                                value: account.name,
                                onTap: () {}),
                        ],
                      ),
                    ],
                  ),
                ),

                // Calculator keys: last row takes remaining height
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: _buildCalculatorColumns(),
                  ),
                ),
              ],
            ),
          ),

          // Right panel placeholder
          SizedBox(
            width: halfWidth,
            child: Container(),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCalculatorColumns() {
    final keysByColumn = [
      ['7', '4', '1', '.'],
      ['8', '5', '2', '0'],
      ['9', '6', '3', '⌫'],
    ];

    return [
      for (var columnKeys in keysByColumn)
        Expanded(
          child: Column(
            children: columnKeys
                .map(
                  (key) => Expanded(
                    child: _calculatorKey(key, () {}),
                  ),
                )
                .toList(),
          ),
        ),
      // Wide action buttons
      Expanded(
        child: Column(
          children: ['+', '-', '*', '/','=']
              .map(
                (op) => Expanded(
                  child: _calculatorKey(op, () {}),
                ),
              )
              .toList(),
        ),
      ),
    ];
  }

  Widget _calculatorKey(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: Colors.blueGrey,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
      ),
    );
  }

  TextStyle amountStyle() {
    return const TextStyle(
        fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white);
  }

  Widget accountInfo(
      {required String label, required String value, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w600,
                fontSize: 14),
          ),
          Text(
            value,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18),
          ),
        ],
      ),
    );
  }
}
