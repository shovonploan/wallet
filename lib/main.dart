import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet/Pages/Home.dart';
import 'package:wallet/bloc/mainNavigation.dart';
import 'package:wallet/constants/common.dart';
import 'package:wallet/constants/theme.dart';
import 'package:wallet/database/database.dart';
import 'package:wallet/models/account.dart';
import 'package:wallet/models/authenticator.dart';
import 'package:wallet/models/jobs.dart';
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
            create: (context) =>
                EncryptionKeyBloc(databaseHelper)..add(EncryptionKeyLoad()),
          ),
          BlocProvider(
            create: (context) => JobBloc(databaseHelper)..add(LoadJobs()),
          ),
          BlocProvider(
            create: (context) =>
                AuthenticateBloc(databaseHelper)..add(LoadAuthenticate()),
          ),
          BlocProvider(
            create: (context) => DataRangeBloc()
              ..add(const SelectedDataRange(Duration(days: 7))),
          ),
          BlocProvider(
            create: (context) =>
                NavigationBloc()..add(const NavigationUpdate(HomeScreen())),
          ),
          BlocProvider(
            create: (context) =>
                KindBloc(databaseHelper)..add(const LoadKinds()),
          ),
          BlocProvider(
            create: (context) =>
                AccountBloc(databaseHelper)..add(LoadAccounts()),
          ),
          BlocProvider(
            create: (context) {
              final now = DateTime.now();
              final target = now
                  .subtract(context.read<DataRangeBloc>().state.range.duration);
              final value =
                  DateTime(target.year, target.month, target.day).toString();
              return RecordBloc(databaseHelper, context.read<ProductBloc>(), context.read<AccountBloc>(),)
                ..add(LoadRecords(Date(value)));
            },
          ),
          BlocProvider(
            create: (context) =>
                ProductBloc(databaseHelper, context.read<RecordBloc>(),)
                  ..add(LoadProductsList()),
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
          }),
        ),
      ),
    ),
  );
}
