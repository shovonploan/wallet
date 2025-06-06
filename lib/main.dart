import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet/Pages/Home.dart';
import 'package:wallet/bloc/mainNavigation.dart';
import 'package:wallet/bloc/settings.dart';
import 'package:wallet/constants/common.dart';
import 'package:wallet/constants/theme.dart';
import 'package:wallet/database/database.dart';
import 'package:wallet/models/account.dart';
import 'package:wallet/models/authenticator.dart';
import 'package:wallet/models/kind.dart';
import 'package:wallet/models/product.dart';
import 'package:wallet/models/record.dart';
import 'package:window_size/window_size.dart';

import 'Pages/Authenticate.dart';
import 'Pages/Loading.dart';
import 'bloc/dateRange.dart';
import 'bloc/encrptionKey.dart';
import 'database/EncryptionKeySetupScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (isNative()) {
    await requestManageExternalStoragePermission();
  }

  if (isDesktop()) {
    initializeDatabaseFactory();
    const size = Size(2120, 1395);
    final frame = Rect.fromLTWH(200, 200, size.width, size.height);
    setWindowTitle('Accountant');
    setWindowFrame(frame);
    setWindowMinSize(size);
    setWindowMaxSize(size);
  }

  final DatabaseHelper databaseHelper = DatabaseHelper();

  runApp(
    RepositoryProvider<DatabaseHelper>(
      create: (context) => databaseHelper,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => EncryptionKeyBloc(databaseHelper)
              ..add(
                EncryptionKeyLoad(),
              ),
          ),
          BlocProvider(
            create: (context) => AuthenticateBloc(databaseHelper)
              ..add(
                LoadAuthenticate(),
              ),
          ),
          BlocProvider(
            create: (context) => KindBloc(databaseHelper)
              ..add(
                const LoadKinds(),
              ),
          ),
        ],
        child: Builder(
          builder: (context) {
            RecordBloc recordBloc = RecordBloc(
              databaseHelper,
              ProductBloc(databaseHelper, null),
              AccountBloc(databaseHelper, null, null),
            );

            final fullProductBloc = ProductBloc(databaseHelper, recordBloc);

            final accountBloc = AccountBloc(databaseHelper, recordBloc, null);

            final fullDateRangeBloc = DateRangeBloc(recordBloc, accountBloc);

            final fullRecordBloc = RecordBloc(
              databaseHelper,
              fullProductBloc,
              accountBloc,
            );

            final fullAccountBloc = AccountBloc(
              databaseHelper,
              fullRecordBloc,
              fullDateRangeBloc,
            );

            return MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (_) => fullProductBloc
                    ..add(
                      LoadProductsList(),
                    ),
                ),
                BlocProvider(
                  create: (_) => fullAccountBloc
                    ..add(
                      LoadAccounts(),
                    ),
                ),
                BlocProvider(
                  create: (_) => fullDateRangeBloc
                    ..add(
                      const SelectedDateRange(
                        Duration(days: 7),
                      ),
                    ),
                ),
                BlocProvider(
                  create: (_) => fullRecordBloc
                    ..add(
                      LoadRecords(
                        defaultRecordQuarry(fullDateRangeBloc, fullAccountBloc),
                      ),
                    ),
                ),
                BlocProvider(
                  create: (_) => NavigationBloc()
                    ..add(
                      const NavigationUpdate(
                        HomeScreen(),
                      ),
                    ),
                ),
                BlocProvider(
                  create: (context) => SettingsBloc(context, databaseHelper,),
                ),
              ],
              child: MaterialApp(
                debugShowCheckedModeBanner: false,
                theme: appTheme,
                home: BlocBuilder<EncryptionKeyBloc, EncryptionKeyState>(
                  builder: (context, state) {
                    switch (state) {
                      case EncryptionKeyLoading() || EncryptionKeyInitial():
                        return const Loading();
                      case EncryptionKeyNotFound():
                        return const EncryptionKeySetupScreen();
                      case EncryptionKeyError():
                        return SafeArea(
                            child: Scaffold(
                          body: Center(
                            child: Text(
                              state.message,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                          backgroundColor: Colors.red,
                        ));
                      default:
                        return const AuthenticationScreen();
                    }
                  },
                ),
              ), // or your next widget
            );
          },
        ),
      ),
    ),
  );
}
