import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show BlocBuilder;
import 'package:wallet/components/MainDrawer.dart';
import 'package:wallet/constants/common.dart';
import 'package:wallet/constants/theme.dart';
import 'package:wallet/models/account.dart';

import 'CreateAccount.dart';

class AccountsPage extends StatefulWidget {
  const AccountsPage({super.key});

  @override
  State<AccountsPage> createState() => _AccountsPageState();
}

class _AccountsPageState extends State<AccountsPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Accounts",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          centerTitle: true,
          backgroundColor: CustomColor.primary.shade900,
        ),
        drawer: const MainDrawer(),
        body: SingleChildScrollView(
          child:
              BlocBuilder<AccountBloc, AccountState>(builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  switch (state) {
                    AccountLoading() => const CircularProgressIndicator(),
                    AccountLoaded() => state.totalAmount == 0
                        ? Center(
                            child: Text(
                              "No Accounts Yet",
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          )
                        : Column(
                            children: state.allAccounts
                                .map(
                                  (item) => Container(
                                    decoration: BoxDecoration(
                                      color: CustomColor.primary.shade900,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    margin: (state.allAccounts.last == item)
                                        ? null
                                        : const EdgeInsets.only(bottom: 20),
                                    height: 100,
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Center(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              item.name,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 26,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  "${item.currency} ${item.amount}",
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.grey[500],
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            CreateAccount(
                                                              account: item,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              100),
                                                    ),
                                                  ),
                                                  child: const Icon(Icons.edit),
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                    _ => Container(),
                  },
                  const SizedBox(height: 20),
                  GestureDetector(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F6E32),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      height: 50,
                      child: const Center(
                        child: Icon(Icons.add),
                      ),
                    ),
                    onTap: () {
                      pushPopIn(context, const CreateAccount());
                    },
                  )
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
