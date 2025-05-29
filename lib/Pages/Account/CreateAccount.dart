import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet/constants/theme.dart';
import 'package:wallet/models/account.dart';

class CreateAccount extends StatefulWidget {
  final Account? account;
  const CreateAccount({this.account, super.key});

  @override
  State<CreateAccount> createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _creditLimitController = TextEditingController();
  final _usageLimitController = TextEditingController();
  final _interestRateController = TextEditingController();
  final String _error = '';
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _amountFocusNode = FocusNode();
  final FocusNode _currencyFocusNode = FocusNode();
  final FocusNode _typeFocusNode = FocusNode();
  final FocusNode _creditLimitFocusNode = FocusNode();
  final FocusNode _usageLimitFocusNode = FocusNode();
  final FocusNode _interestRateFocusNode = FocusNode();
  final List<String> _types = ['Cash', 'Checking', 'Credit Card', 'Savings'];
  String _selectedType = 'Cash';
  final List<String> _currencies = ['USD', 'CAD', 'BDT'];
  String _selectedCurrency = 'USD';

  void _submitForm() {
    if (widget.account != null) {
      String name = _nameController.text;
      context.read<AccountBloc>().add(
            UpdateAccount(
              widget.account!,
              name,
            ),
          );
      Navigator.pop(context);
    } else if (_formKey.currentState!.validate()) {
      String name = _nameController.text;
      double amount = double.parse(_amountController.text);
      final AccountType type = switch (_selectedType) {
        'Cash' => const Cash(),
        'Checking' => const Checking(),
        'Savings' => Savings(double.parse(_interestRateController.text)),
        'Credit Card' => CreditCard(
            double.parse(_creditLimitController.text),
            double.parse(_usageLimitController.text),
          ),
        _ => throw Exception('Invalid account type'),
      };
      context
          .read<AccountBloc>()
          .add(AddAccount(name, amount, _selectedCurrency, type));
      Navigator.pop(context);
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.account != null) {
      _nameController.text = widget.account!.name;
    }
    _nameFocusNode.addListener(() {
      setState(() {});
    });
    _amountFocusNode.addListener(() {
      setState(() {});
    });
    _currencyFocusNode.addListener(() {
      setState(() {});
    });
    _typeFocusNode.addListener(() {
      setState(() {});
    });
    _creditLimitFocusNode.addListener(() {
      setState(() {});
    });
    _usageLimitFocusNode.addListener(() {
      setState(() {});
    });
    _interestRateFocusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _creditLimitController.dispose();
    _usageLimitController.dispose();
    _interestRateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Create Account",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          centerTitle: true,
          backgroundColor: CustomColor.primary.shade900,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: TextFormField(
                      controller: _nameController,
                      keyboardType: TextInputType.name,
                      focusNode: _nameFocusNode,
                      autofocus: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a value';
                        }
                        return null;
                      },
                      inputFormatters: [
                        FilteringTextInputFormatter.singleLineFormatter,
                      ],
                      decoration: inputDecoration(_nameFocusNode, "Name"),
                      style: textInputStyle(),
                    ),
                  ),
                  widget.account != null
                      ? Container()
                      : const SizedBox(
                          height: 20,
                        ),
                  widget.account != null
                      ? Container()
                      : doubleTextInputType(context, _amountController,
                          _amountFocusNode, 'Amount', (value) {
                          if (value.isEmpty) {
                            return 'Please enter a number';
                          }
                          if (!RegExp(r'^\d+(\.\d+)?$').hasMatch(value)) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        }),
                  widget.account != null
                      ? Container()
                      : const SizedBox(height: 20),
                  widget.account != null
                      ? Container()
                      : dropDown(context, _currencyFocusNode, 'Currency',
                          _currencies, _selectedCurrency),
                  widget.account != null
                      ? Container()
                      : const SizedBox(height: 20),
                  widget.account != null
                      ? Container()
                      : dropDown(context, _typeFocusNode, 'Account Type',
                          _types, _selectedType),
                  widget.account != null
                      ? Container()
                      : const SizedBox(height: 20),
                  widget.account != null
                      ? Container()
                      : switch (_selectedType) {
                          'Credit Card' => Column(
                              children: [
                                doubleTextInputType(
                                    context,
                                    _creditLimitController,
                                    _creditLimitFocusNode,
                                    'Credit Limit', (value) {
                                  if (_selectedType == 'Credit Card') {
                                    if (value.isEmpty) {
                                      return 'Please enter a number';
                                    }
                                    if (!RegExp(r'^\d+(\.\d+)?$')
                                        .hasMatch(value)) {
                                      return 'Please enter a valid number';
                                    }
                                  }
                                  return null;
                                }),
                                const SizedBox(height: 20),
                                doubleTextInputType(
                                    context,
                                    _usageLimitController,
                                    _usageLimitFocusNode,
                                    'Usage Limit', (value) {
                                  if (_selectedType == 'Credit Card') {
                                    if (value.isEmpty) {
                                      return 'Please enter a number';
                                    }
                                    if (!RegExp(r'^\d+(\.\d+)?$')
                                        .hasMatch(value)) {
                                      return 'Please enter a valid number';
                                    }
                                  }
                                  return null;
                                }),
                              ],
                            ),
                          'Savings' => doubleTextInputType(
                                context,
                                _interestRateController,
                                _interestRateFocusNode,
                                'Interest Rate', (value) {
                              if (_selectedType == 'Savings') {
                                if (value.isEmpty) {
                                  return 'Please enter a number';
                                }
                                if (!RegExp(r'^\d+(\.\d+)?$').hasMatch(value)) {
                                  return 'Please enter a valid number';
                                }
                              }
                              return null;
                            }),
                          _ => Container(),
                        },
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _submitForm,
                    child: const Text('Create'),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  SizedBox doubleTextInputType(
      BuildContext context,
      TextEditingController controller,
      FocusNode focusNode,
      String labelText,
      Function(String) validate) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: TextFormField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        focusNode: focusNode,
        validator: (value) {
          return validate(value!);
        },
        inputFormatters: [
          FilteringTextInputFormatter.singleLineFormatter,
        ],
        decoration: inputDecoration(focusNode, labelText),
        style: textInputStyle(),
      ),
    );
  }

  TextStyle textInputStyle() {
    return const TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 20,
    );
  }

  InputDecoration inputDecoration(FocusNode node, String labelText) {
    return InputDecoration(
      labelText: node.hasFocus ? null : labelText,
      counterText: '',
      errorText: (_error == '') ? null : _error,
      border: const OutlineInputBorder(),
    );
  }

  Widget dropDown(BuildContext context, FocusNode node, String labelText,
      List<String> items, String selectedValue) {
    return Theme(
      data: Theme.of(context).copyWith(
        dropdownMenuTheme: const DropdownMenuThemeData(
          menuStyle: MenuStyle(
            padding: WidgetStatePropertyAll<EdgeInsets>(
              EdgeInsets.symmetric(horizontal: 20),
            ),
          ),
        ),
      ),
      child: DropdownButtonFormField<String>(
        value: selectedValue,
        focusNode: node,
        decoration: InputDecoration(
          labelText: node.hasFocus ? null : labelText,
          border: const OutlineInputBorder(),
        ),
        items: items.map((String s) {
          return DropdownMenuItem<String>(
            value: s,
            child: Text(s),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            if (labelText == 'Currency') {
              _selectedCurrency = value!;
            } else if (labelText == 'Account Type') {
              _selectedType = value!;
            }
          });
        },
        validator: (value) =>
            value == null ? 'Please select a $labelText' : null,
      ),
    );
  }
}
