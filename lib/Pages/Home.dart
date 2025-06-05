import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet/components/DateRangeSelection.dart';
import 'package:wallet/components/DropDownSelectMultiple.dart';
import 'package:wallet/components/MainDrawer.dart';
import 'package:wallet/components/TotalAmountCard.dart';
import 'package:wallet/components/filepicker.dart';
import 'package:wallet/constants/common.dart';
import 'package:wallet/models/account.dart';

import '../constants/theme.dart';
import 'Account/CreateAccount.dart';
import 'Transaction/CreateTransaction.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  FocusNode dateRangeNode = FocusNode();

  @override
  void initState() {
    super.initState();
    dateRangeNode.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Accountant",
          style: Theme.of(context).textTheme.titleMedium,
        ),
        centerTitle: true,
        backgroundColor: CustomColor.primary.shade900,
      ),
      drawer: const MainDrawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Center(
                child: TotalAmountCard(),
              ),
              const SizedBox(height: 20),
              Center(
                child: Row(
                  children: [
                    BlocBuilder<AccountBloc, AccountState>(
                      builder: (context, state) {
                        switch (state) {
                          case AccountLoaded():
                            if (state.allAccounts.isEmpty) {
                              return Container();
                            } else {
                              return Expanded(
                                  child: dropDown(
                                state,
                                context.read<AccountBloc>(),
                              ));
                            }
                          case AccountLoading():
                            return const CircularProgressIndicator();
                          default:
                            return Container();
                        }
                      },
                    ),
                    BlocBuilder<AccountBloc, AccountState>(
                      builder: (context, state) {
                        if (state is AccountLoaded) {
                          if (state.allAccounts.isEmpty) {
                            return Expanded(
                              child: addAccount(context),
                            );
                          }
                          return addAccount(context);
                        } else {
                          return Container();
                        }
                      },
                    )
                  ],
                ),
              ),
              const SizedBox(height: 20),
              DateRangeSelection(dateRangeNode: dateRangeNode),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  Uint8List? imageBytes = (await pickImageSafely()) as Uint8List?;
                  if (imageBytes != null) {
                    // setState(() {
                    //   _selectedImageBytes = imageBytes;
                    // });
                  }
                },
                child: Text('Pick Image'),
              ),

            ],
          ),
        ),
      ),
      floatingActionButton: BlocBuilder<AccountBloc, AccountState>(
        builder: (context, state) {
          return (state is AccountLoaded)
              ? (state.allAccounts.isNotEmpty)
                  ? FloatingActionButton(
                      onPressed: () {
                        pushPopIn(
                          context,
                          const Createtransaction(),
                        );
                      },
                      backgroundColor: CustomColor.primary.shade900,
                      child: const Icon(Icons.add),
                    )
                  : Container()
              : Container();
        },
      ),
    );
  }

  GestureDetector addAccount(BuildContext context) {
    return GestureDetector(
      child: BlocBuilder<AccountBloc, AccountState>(builder: (context, state) {
        return Container(
          margin: (state is AccountLoaded)
              ? state.selectedAccounts.isEmpty
                  ? const EdgeInsets.only(right: 20, left: 20)
                  : const EdgeInsets.only(right: 20)
              : null,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF0F6E32),
            borderRadius: BorderRadius.circular(10),
          ),
          height: 50,
          child: const Center(
            child: Icon(Icons.add),
          ),
        );
      }),
      onTap: () {
        pushPopIn(
          context,
          const CreateAccount(),
        );
      },
    );
  }

  DropDownSelectMultiple dropDown(AccountLoaded state, AccountBloc bloc) {
    return DropDownSelectMultiple(
      heading: 'Accounts',
      allItems: state.allAccounts
          .map((account) => {'key': account.name, 'value': account.id})
          .toList(),
      selectedItems: state.allAccounts
          .where(
            (account) => state.selectedAccounts.contains(account.id),
          )
          .map((account) => {'key': account.name, 'value': account.id})
          .toList(),
      onSelected: (selectedItems) {
        List<String> ids =
            selectedItems.map((e) => e['value'] as String).toList();
        bloc.add(
          SelectedAccounts(ids),
        );
      },
    );
  }
}
