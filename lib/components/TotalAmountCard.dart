import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet/models/account.dart';

import '../constants/common.dart';

class TotalAmountCard extends StatelessWidget {
  const TotalAmountCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(25),
      height: MediaQuery.of(context).size.height * (isNative() ? 0.3 : 0.15),
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.9),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 15,
            spreadRadius: 5,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: isNative()
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                netAmount(context),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    inAmount(context),
                    const SizedBox(width: 15),
                    outAmount(context),
                  ],
                ),
              ],
            )
          : Row(
              children: [
                Expanded(
                  child: netAmount(context),
                ),
                inAmount(context),
                outAmount(context),
              ],
            ),
    );
  }

  Expanded outAmount(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.arrow_upward,
                color: Colors.redAccent,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                "Out",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white.withOpacity(0.8),
                    ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            "3000",
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Expanded inAmount(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.arrow_downward,
                color: Colors.greenAccent,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                "In",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white.withOpacity(0.8),
                    ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            "3000",
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.greenAccent,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Column netAmount(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Net Amount",
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white.withOpacity(0.8),
              ),
        ),
        const SizedBox(height: 8),
        BlocBuilder<AccountBloc, AccountState>(builder: (context, state) {
          String amountText;
          if (state is AccountLoaded) {
            amountText = "${state.totalAmount}";
          } else {
            amountText = "0.0";
          }

          return Text(
            amountText,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          );
        }),
      ],
    );
  }
}
