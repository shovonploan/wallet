import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:wallet/constants/theme.dart';
import 'package:wallet/database/database.dart';
import 'package:wallet/models/account.dart';
import 'package:wallet/models/kind.dart';
import 'package:wallet/models/record.dart';

class RecordTile extends StatefulWidget {
  Record record;
  RecordTile({super.key, required this.record});

  @override
  State<RecordTile> createState() => _RecordTileState();
}

class _RecordTileState extends State<RecordTile> {
  Kind? kind;
  Account? fromAccount;
  Account? toAccount;
  String? currency;
  @override
  void initState() {
    super.initState();
    final currentType = widget.record.type;
    if (currentType is Income) {
      context
          .read<DatabaseHelper>()
          .getAGrain("Kind", currentType.kindId)
          .then((kindJson) {
        context
            .read<DatabaseHelper>()
            .getAGrain("Account", currentType.accountId)
            .then((accountJson) {
          fromAccount = Account.fromJson(accountJson!);
          setState(() {
            kind = Kind.fromJson(kindJson!);
            currency = fromAccount!.currency;
          });
        });
      });
    } else if (currentType is Expense) {
      context
          .read<DatabaseHelper>()
          .getAGrain("Kind", currentType.kindId)
          .then((value) {
        context
            .read<DatabaseHelper>()
            .getAGrain("Account", currentType.accountId)
            .then((accountJson) {
          fromAccount = Account.fromJson(accountJson!);
          setState(() {
            kind = Kind.fromJson(value!);
            currency = fromAccount!.currency;
          });
        });
      });
    } else if (currentType is Transfer) {
      final fromAccountJson = context
          .read<DatabaseHelper>()
          .getAGrain("Account", currentType.fromAccountId);
      final toAccountJson = context
          .read<DatabaseHelper>()
          .getAGrain("Account", currentType.toAccountId);
      Future.wait([fromAccountJson, toAccountJson]).then((value) {
        setState(() {
          fromAccount = Account.fromJson(value[0]!);
          toAccount = Account.fromJson(value[1]!);
          currency = fromAccount!.currency;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kind?.color ?? CustomColor.primary.shade900,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        kind?.icon ?? FontAwesomeIcons.rightLeft,
                        color: CustomColor.primary.shade500,
                        size: 20,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        (widget.record.type is Transfer)
                            ? 'Transfer'
                            : kind?.name ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  (fromAccount != null && toAccount != null)
                      ? SizedBox(
                          height: 5,
                        )
                      : Container(),
                  (fromAccount != null && toAccount != null)
                      ? Text(
                          "${fromAccount!.name} to ${toAccount!.name}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : Container(),
                ],
              ),
              Text(
                "$currency ${widget.record.amount}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
