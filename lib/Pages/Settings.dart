import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet/bloc/settings.dart';
import 'package:wallet/components/MainDrawer.dart';
import 'package:wallet/constants/theme.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Settings",
          style: Theme.of(context).textTheme.titleMedium,
        ),
        centerTitle: true,
        backgroundColor: CustomColor.primary.shade900,
      ),
      drawer: const MainDrawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: BlocBuilder<SettingsBloc, SettingsState>(
              builder: (context, state) {
            return Column(
              children: [
                (!state.isDummyDataAdded && state.isDeveloperMode)
                    ? listTile("Add Dummy Data", () {
                        context.read<SettingsBloc>().add(AddDummyData());
                      })
                    : Container(),
                (!state.isDummyDataAdded && state.isDeveloperMode)
                    ? SizedBox(
                        height: 20,
                      )
                    : Container(),
                // TODO: SQL Backup Option
                // TODO: Show encryption key Qr.
              ],
            );
          }),
        ),
      ),
    );
  }

  GestureDetector listTile(String text, void Function() onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        height: 80,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white70,
        ),
        child: Row(
          children: [
            Text(
              text,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
