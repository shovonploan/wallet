//---------------State-----------------------
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet/database/database.dart';
import 'package:wallet/models/account.dart';
import 'package:wallet/models/kind.dart';
import 'package:wallet/models/record.dart';

abstract class SettingsState extends Equatable {
  final isDeveloperMode;
  final isDummyDataAdded;
  const SettingsState({
    required this.isDeveloperMode,
    required this.isDummyDataAdded,
  });
}

class SettingsInitial extends SettingsState {
  const SettingsInitial({
    required super.isDeveloperMode,
    required super.isDummyDataAdded,
  });
  @override
  List<Object?> get props => [
        isDeveloperMode,
        isDummyDataAdded,
      ];
}

//--------------Event----------------------
abstract class SettingsEvent extends Equatable {
  const SettingsEvent();
  @override
  List<Object?> get props => [];
}

class AddDummyData extends SettingsEvent {
  const AddDummyData();
  @override
  List<Object?> get props => [];
}

//---------------------bloc----------------
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final DatabaseHelper _dbHelper;
  final BuildContext context;
  SettingsBloc(this.context, this._dbHelper)
      : super(const SettingsInitial(
            isDeveloperMode: true, isDummyDataAdded: false)) {
    on<AddDummyData>(_onAddDummyData);
  }

  Future<List<Kind>> getAllKinds() async {
    final kindJson = await _dbHelper.getAllGrain("Kind");
    return kindJson.map((e) => Kind.fromJson(e)).toList();
  }

  Future<List<Account>> getAllAccounts() async {
    final accountJson = await _dbHelper.getAllGrain("Account");
    return accountJson.map((e) => Account.fromJson(e)).toList();
  }

  Future<void> _onAddDummyData(
      AddDummyData event, Emitter<SettingsState> emit) async {
    final kinds = await getAllKinds();

    context
        .read<AccountBloc>()
        .add(AddAccount("Cash", 1000.0, "USD", const Cash()));
    context
        .read<AccountBloc>()
        .add(AddAccount("Checking", 500.0, "USD", const Checking()));
    context.read<AccountBloc>().add(AddAccount(
        "CreditCard", 2000.0, "USD", const CreditCard(5000.0, 3000.0)));
    context
        .read<AccountBloc>()
        .add(AddAccount("Savings", 10000.0, "USD", const Savings(0.05)));

    await context.read<AccountBloc>().stream.firstWhere((state) {
      final currentState = state;
      if (currentState is AccountLoaded) {
        return currentState.allAccounts.length == 4;
      }
      return false;
    });

    final accounts = await getAllAccounts();

    context.read<RecordBloc>().add(
          AddRecord(
            200,
            '',
            Transfer(accounts.first.id, accounts.last.id),
            0,
            [],
            null,
            DateTime.now().toString(),
          ),
        );

    context.read<RecordBloc>().add(
          AddRecord(
            200,
            '',
            Income(
                accounts.first.id,
                kinds
                    .where((element) => element.name == "Wage, invoices")
                    .first
                    .id),
            0,
            [],
            null,
            DateTime.now().toString(),
          ),
        );

    context.read<RecordBloc>().add(
          AddRecord(
            100,
            '',
            Expense(accounts.first.id,
                kinds.where((element) => element.name == "Rent").first.id),
            0,
            [],
            null,
            DateTime.now().toString(),
          ),
        );

    emit(SettingsInitial(
        isDeveloperMode: state.isDeveloperMode, isDummyDataAdded: true));
  }
}
