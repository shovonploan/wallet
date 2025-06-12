import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet/components/filepicker.dart';
import 'package:wallet/constants/theme.dart';
import 'package:wallet/models/account.dart';
import 'package:wallet/models/record.dart';
import 'package:wallet/models/kind.dart';
import '../Product/CreateProduct.dart';

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
  String _amountStr = '0';
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  Uint8List? _receipt;
  final List<Map<String, dynamic>> _products = [];
  Kind? _selectedKind;

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
    final kindState = context.read<KindBloc>().state;
    if (kindState is KindLoaded && kindState.kinds.isNotEmpty) {
      _selectedKind = kindState.kinds.first;
    } else {
      _selectedKind = Kind.defaultCtor();
    }
  }

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
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
                                value: _selectedKind?.name ?? '',
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
          // Right panel with form
          SizedBox(
            width: halfWidth,
            child: Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _descController,
                      decoration: const InputDecoration(labelText: 'Description'),
                    ),
                    const SizedBox(height: 10),
                    BlocBuilder<AccountBloc, AccountState>(
                      builder: (context, aState) {
                        final accounts = aState is AccountLoaded ? aState.allAccounts : <Account>[];
                        return DropdownButtonFormField<String>(
                          value: account.id,
                          decoration: const InputDecoration(labelText: 'Account'),
                          items: accounts
                              .map((e) => DropdownMenuItem(value: e.id, child: Text(e.name)))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                account = accounts.firstWhere((a) => a.id == val);
                              });
                            }
                          },
                        );
                      },
                    ),
                    if (selectedRecordType == 'Transfer')
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: BlocBuilder<AccountBloc, AccountState>(
                          builder: (context, aState) {
                            final accounts = aState is AccountLoaded ? aState.allAccounts : <Account>[];
                            return DropdownButtonFormField<String>(
                              value: toAccount.id,
                              decoration: const InputDecoration(labelText: 'To Account'),
                              items: accounts
                                  .map((e) => DropdownMenuItem(value: e.id, child: Text(e.name)))
                                  .toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() {
                                    toAccount = accounts.firstWhere((a) => a.id == val);
                                  });
                                }
                              },
                            );
                          },
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: BlocBuilder<KindBloc, KindState>(
                          builder: (context, kState) {
                            final kinds = kState is KindLoaded ? kState.kinds : <Kind>[];
                            return DropdownButtonFormField<String>(
                              value: _selectedKind?.id,
                              decoration: const InputDecoration(labelText: 'Category'),
                              items: kinds
                                  .map((e) => DropdownMenuItem(value: e.id, child: Text(e.name)))
                                  .toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() {
                                    _selectedKind = kinds.firstWhere((k) => k.id == val);
                                  });
                                }
                              },
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (date != null) {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(_selectedDate),
                          );
                          if (time != null) {
                            setState(() {
                              _selectedDate = DateTime(
                                date.year,
                                date.month,
                                date.day,
                                time.hour,
                                time.minute,
                              );
                            });
                          }
                        }
                      },
                      child: Text(_selectedDate.toString().split('.').first),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            final img = await pickImageSafely();
                            if (img != null) {
                              setState(() {
                                _receipt = img;
                              });
                            }
                          },
                          child: const Text('Add Receipt'),
                        ),
                        const SizedBox(width: 10),
                        if (_receipt != null)
                          Expanded(
                            child: SizedBox(
                              height: 80,
                              child: Image.memory(_receipt!, fit: BoxFit.cover),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CreateProduct()),
                        );
                        if (result != null && mounted) {
                          setState(() {
                            _products.add(Map<String, dynamic>.from(result));
                          });
                        }
                      },
                      child: const Text('Add Product'),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _products.length,
                        itemBuilder: (context, index) {
                          final p = _products[index];
                          return ListTile(
                            title: Text(p['name'] as String),
                            trailing: Text((p['amount'] as double).toStringAsFixed(2)),
                            subtitle: Text('Warranty: ${p['warranty']}m'),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        'Total: ' +
                            _products.fold<double>(0, (s, e) => s + (e['amount'] as double)).toStringAsFixed(2),
                        textAlign: TextAlign.right,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _submit,
                      child: const Text('Create Transaction'),
                    ),
                  ],
                ),
              ),
            ),
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
                    child: _calculatorKey(key, () => _onCalculatorPress(key)),
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
                  child: _calculatorKey(op, () => _onCalculatorPress(op)),
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

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final total =
          _products.fold<double>(0, (s, e) => s + (e['amount'] as double));
      if ((total - amount).abs() > 0.01) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Product total doesn't match amount")),
        );
        return;
      }
      RecordType type;
      if (selectedRecordType == 'Income') {
        type = Income(account.id, _selectedKind?.id ?? '');
      } else if (selectedRecordType == 'Expense') {
        type = Expense(account.id, _selectedKind?.id ?? '');
      } else {
        type = Transfer(account.id, toAccount.id);
      }
      context.read<RecordBloc>().add(
            AddRecord(
              amount,
              _descController.text,
              type,
              0.0,
              const [],
              _receipt,
              _selectedDate.toString(),
            ),
          );
      Navigator.pop(context);
    }
  }

  void _onCalculatorPress(String label) {
    setState(() {
      if (label == '⌫') {
        if (_amountStr.isNotEmpty) {
          _amountStr = _amountStr.substring(0, _amountStr.length - 1);
          if (_amountStr.isEmpty) _amountStr = '0';
        }
      } else if (label == '.') {
        if (!_amountStr.contains('.')) {
          _amountStr += '.';
        }
      } else if (RegExp(r'^[0-9]$').hasMatch(label)) {
        if (_amountStr == '0') {
          _amountStr = label;
        } else {
          _amountStr += label;
        }
      } else if (label == '=') {
        amount = double.tryParse(_amountStr) ?? 0.0;
      }
    });
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
