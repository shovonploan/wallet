import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet/Pages/Account/Accounts.dart';
import 'package:wallet/Pages/Home.dart';
import 'package:wallet/Pages/Settings.dart';
import 'package:wallet/bloc/mainNavigation.dart';

import '../constants/theme.dart';
import '../models/authenticator.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({
    super.key,
  });

  void _navigateTo(BuildContext context, NavigationState state, Widget screen) {
    if (state.screen.runtimeType != screen.runtimeType) {
      context.read<NavigationBloc>().add(
            NavigationUpdate(screen),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              CustomColor.primary.shade900,
              CustomColor.primary.shade500
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: BlocBuilder<NavigationBloc, NavigationState>(
            builder: (context, state) {
          return ListView(
            padding: EdgeInsets.zero,
            children: [
              Material(
                elevation: 8,
                color: Colors.black45,
                child: UserAccountsDrawerHeader(
                  decoration:
                      BoxDecoration(color: CustomColor.primary.shade800),
                  accountName: Text('User Account',
                      style: Theme.of(context).textTheme.titleMedium),
                  accountEmail: const Text(''),
                  currentAccountPicture: const CircleAvatar(
                    backgroundImage: NetworkImage(
                      'https://i.pravatar.cc/150?img=3',
                    ),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home, color: Colors.white),
                title:
                    const Text('Home', style: TextStyle(color: Colors.white)),
                onTap: () => _navigateTo(context, state, const HomeScreen()),
              ),
              ListTile(
                leading: const Icon(Icons.account_balance, color: Colors.white),
                title: const Text('Accounts',
                    style: TextStyle(color: Colors.white)),
                onTap: () => _navigateTo(context, state, const AccountsPage()),
              ),
              // TODO: Add record pages
              ListTile(
                leading: const Icon(Icons.settings, color: Colors.white),
                title: const Text('Settings',
                    style: TextStyle(color: Colors.white)),
                onTap: () => _navigateTo(context, state, const SettingsPage()),
              ),
              const Divider(color: Colors.white54),
              ListTile(
                leading: const Icon(Icons.exit_to_app, color: Colors.white),
                title:
                    const Text('Logout', style: TextStyle(color: Colors.white)),
                onTap: () {
                  context.read<AuthenticateBloc>().add(
                        LogoutAuthenticate(),
                      );
                },
              ),
            ],
          );
        }),
      ),
    );
  }
}
