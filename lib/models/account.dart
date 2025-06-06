library;

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:wallet/bloc/dateRange.dart';
import 'package:wallet/constants/common.dart';
import 'package:wallet/database/database.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet/models/record.dart';

String _tableName = "Account";

abstract class AccountType {
  const AccountType();
  Map<String, dynamic> toJson();
  factory AccountType.fromMap(Map<String, dynamic> map) {
    switch (map['type']) {
      case 'Cash':
        return const Cash();
      case 'Checking':
        return const Checking();
      case 'CreditCard':
        return CreditCard(
          (map['creditLimit'] as num).toDouble(),
          (map['usageLimit'] as num).toDouble(),
        );
      case 'Savings':
        return Savings((map['interestRate'] as num).toDouble());
      default:
        throw Exception('Unknown account type: ${map['type']}');
    }
  }
}

class Cash extends AccountType {
  const Cash() : super();
  @override
  Map<String, dynamic> toJson() => {
        'type': 'Cash',
      };
  @override
  String toString() => 'Cash';
}

class Checking extends AccountType {
  const Checking() : super();
  @override
  Map<String, dynamic> toJson() => {
        'type': 'Checking',
      };
  @override
  String toString() => 'Checking';
}

class CreditCard extends AccountType {
  final double creditLimit;
  final double usageLimit;
  const CreditCard(this.creditLimit, this.usageLimit) : super();

  @override
  Map<String, dynamic> toJson() => {
        'type': 'CreditCard',
        'creditLimit': creditLimit,
        'usageLimit': usageLimit,
      };
  @override
  String toString() => 'CreditCard';
}

class Savings extends AccountType {
  final double interestRate;
  const Savings(this.interestRate) : super();

  @override
  Map<String, dynamic> toJson() => {
        'type': 'Savings',
        'interestRate': interestRate,
      };
}

@immutable
class Account extends DBGrain {
  @override
  final String id;
  final String name;
  final double amount;
  final String currency;
  final AccountType type;
  final String createdAt;
  final String updatedAt;

  Account.Ctor(String name, double amount, String currency, AccountType type,
      String createdAt, String updatedAt)
      : this(
            id: generateNewUuid(),
            name: name,
            amount: amount,
            currency: currency,
            type: type,
            createdAt: createdAt,
            updatedAt: updatedAt);
  Account.defaultCtor()
      : this(
            id: '',
            name: '',
            amount: 0.0,
            currency: '',
            type: const Cash(),
            createdAt: '',
            updatedAt: '');

  Account({
    required this.id,
    required this.name,
    required this.amount,
    required this.currency,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
  });

  Account copyWith({
    String? id,
    String? name,
    double? amount,
    String? currency,
    AccountType? type,
    String? createdAt,
    String? updatedAt,
  }) {
    return Account(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> _toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'amount': amount,
      'currency': currency,
      'type': type.toJson(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'codecVersion': codecVersion,
    };
  }

  factory Account._fromMap(Map<String, dynamic> map) {
    final int dbCodecVersion = map['codecVersion'] as int;

    if (dbCodecVersion == 1) {
      return Account(
        id: map['id'] as String,
        name: map['name'] as String,
        amount: map['amount'] as double,
        currency: map['currency'] as String,
        type: AccountType.fromMap(map['type']),
        createdAt: map['createdAt'] as String,
        updatedAt: map['updatedAt'] as String,
      );
    } else {
      return Account.defaultCtor();
    }
  }

  String toJson() => json.encode(_toMap());

  factory Account.fromJson(String source) =>
      Account._fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'Account(id: $id, name: $name, amount: $amount, currency: $currency, type: $type, createdAt: $createdAt, updatedAt: $updatedAt)';

  @override
  bool operator ==(covariant Account other) {
    if (identical(this, other)) return true;
    return other.id == id &&
        other.name == name &&
        other.currency == currency &&
        other.amount == amount &&
        other.type == type &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      currency.hashCode ^
      amount.hashCode ^
      type.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode;

  @override
  final String tableName = _tableName;
  @override
  Map<String, String> get indexs => {};

  @override
  String insert() {
    return super.DBInsert(toJson());
  }

  @override
  String customInsert() {
    return '';
  }

  String update(Account newGrain) {
    return super.DBUpdate(newGrain.toJson());
  }

  @override
  final int codecVersion = 1;
}

//---------------State-----------------------
abstract class AccountState extends Equatable {
  const AccountState();

  @override
  List<Object?> get props => [];
}

class AccountInitial extends AccountState {}

class AccountLoading extends AccountState {}

class AccountLoaded extends AccountState {
  final List<Account> allAccounts;
  final List<String> selectedAccounts;
  final double totalAmount;

  AccountLoaded(this.allAccounts, this.selectedAccounts)
      : totalAmount = allAccounts
            .where((account) => selectedAccounts.contains(account.id))
            .map((account) => account.amount)
            .fold(0.0, (sum, e) => sum + e);

  @override
  List<Object?> get props => [allAccounts, selectedAccounts, totalAmount];
}

class AccountError extends AccountState {
  final String message;

  const AccountError(this.message);

  @override
  List<Object?> get props => [message];
}

//--------------Event----------------------
abstract class AccountEvent extends Equatable {
  const AccountEvent();

  @override
  List<Object?> get props => [];
}

class LoadAccounts extends AccountEvent {}

class AddAccount extends AccountEvent {
  final String name;
  final double amount;
  final String currency;
  final AccountType type;

  const AddAccount(this.name, this.amount, this.currency, this.type);

  @override
  List<Object?> get props => [name, amount, currency, type];
}

class SelectedAccounts extends AccountEvent {
  final List<String> selectedIds;

  const SelectedAccounts(this.selectedIds);
  @override
  List<Object?> get props => [selectedIds];
}

class UpdateAccount extends AccountEvent {
  final Account account;
  final String newName;

  const UpdateAccount(this.account, this.newName);

  @override
  List<Object?> get props => [account, newName];
}

class UpdateAccountAmount extends AccountEvent {
  final Account account;
  final double newAmount;
  const UpdateAccountAmount(this.account, this.newAmount);
  @override
  List<Object?> get props => [account, newAmount];
}

class DeleteAccount extends AccountEvent {
  final Account account;

  const DeleteAccount(this.account);

  @override
  List<Object?> get props => [account];
}

//---------------------bloc----------------
class AccountBloc extends Bloc<AccountEvent, AccountState> {
  final DatabaseHelper _dbHelper;
  final RecordBloc _recordBloc;
  final DateRangeBloc _dateRangeBloc;

  AccountBloc(this._dbHelper, this._recordBloc, this._dateRangeBloc)
      : super(AccountInitial()) {
    on<LoadAccounts>(_onLoadAccounts);
    on<SelectedAccounts>(_onSelectedAccounts);
    on<AddAccount>(_onAddAccount);
    on<UpdateAccount>(_onUpdateAccount);
    on<UpdateAccountAmount>(_onUpdateAccountAmount);
    on<DeleteAccount>(_onDeleteAccount);
  }

  Future<void> _onLoadAccounts(
      LoadAccounts event, Emitter<AccountState> emit) async {
    emit(AccountLoading());
    try {
      final dbData = await _dbHelper.getAllGrain(_tableName);
      final accounts = dbData.map((e) => Account.fromJson(e)).toList();
      final currentState = state;
      if ((currentState is AccountLoaded)) {
        if (currentState.selectedAccounts.isEmpty) {
          emit(AccountInitial());
          emit(AccountLoaded(
              accounts, accounts.map((account) => account.id).toList()));
        } else {
          final selected = currentState.selectedAccounts
              .where((id) =>
                  accounts.map((account) => account.id).toList().contains(id))
              .toList();
          emit(AccountInitial());
          emit(AccountLoaded(accounts, selected));
        }
        _recordBloc.add(
          LoadRecords(
            defaultRecordQuarry(_dateRangeBloc, this),
          ),
        );
      } else {
        final selected = accounts.map((account) => account.id).toList();
        emit(AccountLoaded(accounts, selected));
      }
    } catch (e) {
      emit(const AccountError('Failed to load accounts.'));
    }
  }

  Future<void> _onSelectedAccounts(
      SelectedAccounts event, Emitter<AccountState> emit) async {
    final currentState = state;
    if (currentState is AccountLoaded) {
      emit(AccountInitial());
      emit(AccountLoaded(currentState.allAccounts, event.selectedIds));
    } else {
      add(LoadAccounts());
    }
  }

  Future<void> _onAddAccount(
      AddAccount event, Emitter<AccountState> emit) async {
    try {
      final newAccount = Account.Ctor(event.name, event.amount, event.currency,
          event.type, DateTime.now().toString(), DateTime.now().toString());
      await _dbHelper.rawExecute(newAccount.insert()).then((_) {
        add(LoadAccounts());
      });
    } catch (e) {
      add(LoadAccounts());
    }
  }

  Future<void> _onUpdateAccount(
      UpdateAccount event, Emitter<AccountState> emit) async {
    try {
      await _dbHelper
          .rawExecute(event.account.update(event.account.copyWith(
        name: event.newName,
        updatedAt: DateTime.now().toString(),
      )))
          .then((_) {
        add(LoadAccounts());
      });
    } catch (e) {
      add(LoadAccounts());
    }
  }

  Future<void> _onUpdateAccountAmount(
      UpdateAccountAmount event, Emitter<AccountState> emit) async {
    try {
      await _dbHelper
          .rawExecute(event.account.update(event.account.copyWith(
        amount: event.newAmount,
        updatedAt: DateTime.now().toString(),
      )))
          .then((_) {
        add(LoadAccounts());
      });
    } catch (e) {
      add(LoadAccounts());
    }
  }

  Future<void> _onDeleteAccount(
      DeleteAccount event, Emitter<AccountState> emit) async {
    try {
      await _dbHelper
          .rawDelete(event.account.tableName, event.account.id)
          .then((_) {
        add(LoadAccounts());
      });
    } catch (e) {
      add(LoadAccounts());
    }
  }
}
