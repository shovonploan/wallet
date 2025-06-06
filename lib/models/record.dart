import 'dart:convert';
import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet/constants/common.dart';
import 'package:wallet/database/database.dart';
import 'package:wallet/models/account.dart';
import 'package:wallet/models/product.dart';

import 'kind.dart';

abstract class RecordType {
  const RecordType();
  Map<String, dynamic> toJson();
  factory RecordType.fromMap(Map<String, dynamic> map) {
    switch (map['type']) {
      case 'Income':
        return Income(map['accountId']);
      case 'Expense':
        return Expense(map['accountId']);
      case 'Transfer':
        return Transfer(
          map['fromAccountId'],
          map['toAccountId'],
        );
      default:
        throw Exception('Unknown record type: ${map['type']}');
    }
  }
}

class Income extends RecordType {
  final String accountId;
  const Income(this.accountId) : super();
  @override
  Map<String, dynamic> toJson() => {
        'type': 'Income',
        'accountId': accountId,
      };
  @override
  String toString() => 'Income ($accountId)';
}

class Expense extends RecordType {
  final String accountId;
  const Expense(this.accountId) : super();
  @override
  Map<String, dynamic> toJson() => {
        'type': 'Expense',
        'accountId': accountId,
      };
  @override
  String toString() => 'Expense ($accountId)';
}

class Transfer extends RecordType {
  final String fromAccountId;
  final String toAccountId;
  const Transfer(this.fromAccountId, this.toAccountId) : super();
  @override
  Map<String, dynamic> toJson() => {
        'type': 'Transfer',
        'fromAccountId': fromAccountId,
        'toAccountId': toAccountId,
      };
  @override
  String toString() => 'Transfer ($fromAccountId -> $toAccountId)';
}

enum RecordIndexKeyOperator {
  OR('OR'),
  AND('AND'),
  LAST('LAST');

  final String operator;
  const RecordIndexKeyOperator(this.operator);
}

abstract class RecordIndexKey {
  final String value;
  final RecordIndexKeyOperator operator;
  const RecordIndexKey(this.value, this.operator);
}

class AccountId extends RecordIndexKey {
  const AccountId(super.value, super.operator);
}

class RecordIndexType extends RecordIndexKey {
  const RecordIndexType(super.value, super.operator);
}

class KindKey extends RecordIndexKey {
  const KindKey(super.value, super.operator);
}

class Date extends RecordIndexKey {
  const Date(super.value, super.operator);
}

String _tableName = "Record";

@immutable
class Record extends DBGrain {
  @override
  final String id;
  final double amount;
  final RecordType type;
  final Kind? kind;
  final double stockValue;
  final List<String> productIds;
  final String imageId;
  final String date;

  Record.Ctor(double amount, RecordType type, Kind? kind,
      List<String> productIds, String imageId, String date)
      : this(
            id: generateNewUuid(),
            amount: amount,
            type: type,
            kind: kind,
            stockValue: 0.0,
            productIds: productIds,
            imageId: imageId,
            date: date);

  Record.defaultCtor()
      : this(
            id: '',
            amount: 0.0,
            type: const Income(''),
            kind: null,
            stockValue: 0.0,
            productIds: [],
            imageId: '',
            date: '');
  Record(
      {required this.id,
      required this.amount,
      required this.type,
      required this.kind,
      required this.stockValue,
      required this.productIds,
      required this.imageId,
      required this.date});

  Record copyWith(
      {String? id,
      double? amount,
      RecordType? type,
      Kind? kind,
      double? stockValue,
      List<String>? productIds,
      String? imageId,
      String? date}) {
    return Record(
        id: id ?? this.id,
        amount: amount ?? this.amount,
        type: type ?? this.type,
        kind: kind ?? this.kind,
        stockValue: this.stockValue,
        productIds: productIds ?? this.productIds,
        imageId: imageId ?? this.imageId,
        date: date ?? this.date);
  }

  Map<String, dynamic> _toMap() {
    return <String, dynamic>{
      'id': id,
      'amount': amount,
      'type': type.toJson(),
      'kind': kind?.toJson(),
      'stockValue': stockValue,
      'productIds': productIds,
      'imageId': imageId,
      'date': date,
      'codecVersion': codecVersion,
    };
  }

  factory Record._fromMap(Map<String, dynamic> map) {
    final int dbCodecVersion = map['codecVersion'] as int;
    if (dbCodecVersion == 1) {
      return Record(
          id: map['id'] as String,
          amount: map['amount'] as double,
          type: RecordType.fromMap(map['type']),
          kind: map['kind'] != null ? Kind.fromJson(map['kind']) : null,
          stockValue: map['stockValue'] as double,
          productIds: List<String>.from(map['productIds']),
          imageId: map['imageId'] as String,
          date: map['date'] as String);
    } else {
      return Record.defaultCtor();
    }
  }

  String toJson() => json.encode(_toMap());
  factory Record.fromJson(String source) =>
      Record._fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'Record(id: $id, amount: $amount, type: $type, kind: $kind,stockValue: $stockValue , productIds: $productIds, imageId: $imageId, date: $date)';

  @override
  bool operator ==(covariant Record other) {
    if (identical(this, other)) return true;
    return other.id == id &&
        other.amount == amount &&
        other.type == type &&
        other.kind == kind &&
        other.stockValue == stockValue &&
        other.productIds == productIds &&
        other.imageId == imageId &&
        other.date == date;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      amount.hashCode ^
      type.hashCode ^
      kind.hashCode ^
      stockValue.hashCode ^
      productIds.hashCode ^
      imageId.hashCode ^
      date.hashCode;

  @override
  final String tableName = _tableName;
  @override
  Map<String, String> get indexs => {
        'type': type.toString(),
        'kindId': kind?.id ?? '',
        'date': date,
      };

  @override
  String insert() {
    return super.DBInsert(toJson());
  }

  @override
  String customInsert() {
    return '';
  }

  String update(Record newGrain) {
    return super.DBUpdate(newGrain.toJson());
  }

  @override
  final int codecVersion = 1;
}

//---------------State-----------------------
abstract class RecordState extends Equatable {
  const RecordState();

  @override
  List<Object?> get props => [];
}

class RecordInitial extends RecordState {}

class RecordLoading extends RecordState {}

class RecordListLoaded extends RecordState {
  final List<Record> records;
  final List<RecordIndexKey> keyValues;
  const RecordListLoaded(this.records, this.keyValues);
  @override
  List<Object?> get props => [records, keyValues];
}

class RecordError extends RecordState {
  final String message;

  const RecordError(this.message);

  @override
  List<Object?> get props => [message];
}

//--------------Event----------------------
abstract class RecordEvent extends Equatable {
  const RecordEvent();
  @override
  List<Object?> get props => [];
}

class LoadRecords extends RecordEvent {
  final List<RecordIndexKey> keyValues;
  const LoadRecords(this.keyValues);
  @override
  List<Object?> get props => [keyValues];
}

class AddRecord extends RecordEvent {
  final double amount;
  final RecordType type;
  final Kind? kind;
  final double stockValue;
  final List<String> productIds;
  final Uint8List? image;
  final String date;
  const AddRecord(this.amount, this.type, this.kind, this.stockValue,
      this.productIds, this.image, this.date);
  @override
  List<Object?> get props =>
      [amount, type, kind, stockValue, productIds, image, date];
}

class UpdateRecord extends RecordEvent {
  final Record record;
  final double newAmount;
  final RecordType newType;
  final Kind? newKind;
  final double newStockValue;
  final List<String> newProductIds;
  final Uint8List? newImage;
  final String newDate;
  const UpdateRecord(this.record, this.newAmount, this.newType, this.newKind,
      this.newStockValue, this.newProductIds, this.newImage, this.newDate);
  @override
  List<Object?> get props => [
        record,
        newAmount,
        newType,
        newKind,
        newStockValue,
        newProductIds,
        newImage,
        newDate
      ];
}

class DeleteRecord extends RecordEvent {
  final Record record;
  const DeleteRecord(this.record);
  @override
  List<Object?> get props => [record];
}

class InitializeRecords extends RecordEvent {
  const InitializeRecords();
  @override
  List<Object?> get props => [];
}

//---------------------bloc----------------
class RecordBloc extends Bloc<RecordEvent, RecordState> {
  final DatabaseHelper _dbHelper;
  final ProductBloc productBloc;
  final AccountBloc accountBloc;
  RecordBloc(this._dbHelper, this.productBloc, this.accountBloc)
      : super(RecordInitial()) {
    on<LoadRecords>(_onLoadRecords);
    on<AddRecord>(_onAddRecord);
    on<UpdateRecord>(_onUpdateRecord);
    on<DeleteRecord>(_onDeleteRecord);
    on<InitializeRecords>(_onInitializeRecords);
  }

  Future<void> _onAddRecord(AddRecord event, Emitter<RecordState> emit) async {
    try {
      emit(RecordLoading());
      String imageId = generateNewUuid();
      final record = Record.Ctor(event.amount, event.type, event.kind,
          event.productIds, (event.image == null) ? '' : imageId, event.date);

      if (event.image != null) {
        await _dbHelper.rawExecute(record.insertImageAsBlob(
            imageId, event.image as Uint8List, 'receipt'));
      }

      await _dbHelper.rawExecute(record.insert());

      final currentState = state;
      if (currentState is RecordListLoaded) {
        add(LoadRecords(currentState.keyValues));
      } else {
        emit(RecordInitial());
      }

      final transactionType = event.type;

      if (transactionType is Income) {
        final accountJson =
            await _dbHelper.getAGrain("Account", transactionType.accountId);
        if (accountJson != null) {
          final account = Account.fromJson(accountJson);
          accountBloc
              .add(UpdateAccountAmount(account, account.amount + event.amount));
        }
      } else if (transactionType is Expense) {
        final accountJson =
            await _dbHelper.getAGrain("Account", transactionType.accountId);
        if (accountJson != null) {
          final account = Account.fromJson(accountJson);
          accountBloc
              .add(UpdateAccountAmount(account, account.amount - event.amount));
        }
      } else if (transactionType is Transfer) {
        final fromAccountJson =
            await _dbHelper.getAGrain("Account", transactionType.fromAccountId);
        if (fromAccountJson != null) {
          final fromAccount = Account.fromJson(fromAccountJson);
          accountBloc.add(UpdateAccountAmount(
              fromAccount, fromAccount.amount - event.amount));
        }
        final toAccountJson =
            await _dbHelper.getAGrain("Account", transactionType.toAccountId);
        if (toAccountJson != null) {
          final toAccount = Account.fromJson(toAccountJson);
          accountBloc.add(
              UpdateAccountAmount(toAccount, toAccount.amount + event.amount));
        }
      }
    } catch (e) {
      emit(const RecordError('Failed to add record.'));
    }
  }

  Future<void> _onLoadRecords(
      LoadRecords event, Emitter<RecordState> emit) async {
    try {
      emit(RecordLoading());

      List<Map<String, dynamic>> conditions = [];

      for (var keyValue in event.keyValues) {
        Map<String, dynamic> condition = {};

        if (keyValue is AccountId) {
          condition = {
            'comparison': 'LIKE',
            'value': "%${keyValue.value}%",
          };
        } else if (keyValue is RecordIndexType) {
          condition = {
            'comparison': 'LIKE',
            'value': "%${keyValue.value}%",
          };
        } else if (keyValue is KindKey) {
          condition = {
            'key': 'kindId',
            'value': keyValue.value,
          };
        } else if (keyValue is Date) {
          condition = {
            'key': 'date',
            'value': keyValue.value,
            'comparison': '>='
          };
        } else {
          continue;
        }

        if (keyValue.operator.operator == 'OR') {
          condition['operator'] = 'OR';
        } else if (keyValue.operator.operator == 'AND') {
          condition['operator'] = 'AND';
        }
        conditions.add(condition);
      }

      final recordJson = await _dbHelper.getIndexedGrain(
        _tableName,
        conditions,
      );

      final records = recordJson.map((e) => Record.fromJson(e)).toList();
      emit(RecordListLoaded(records, event.keyValues));
    } catch (e) {
      emit(const RecordError('Failed to load records.'));
    }
  }

  Future<void> _onUpdateRecord(
      UpdateRecord event, Emitter<RecordState> emit) async {
    try {
      emit(RecordLoading());
      String imageId = generateNewUuid();
      final record = event.record.copyWith(
          amount: event.newAmount,
          type: event.newType,
          kind: event.newKind,
          stockValue: event.newStockValue,
          productIds: event.newProductIds,
          imageId: (event.newImage == null) ? '' : imageId);
      if (event.newImage != null) {
        await _dbHelper.rawExecute(record.deleteBlobData(event.record.imageId));
        await _dbHelper.rawExecute(record.insertImageAsBlob(
            imageId, event.newImage as Uint8List, 'receipt'));
      }
      await _dbHelper.rawExecute(record.update(record));
      final currentState = state;
      if (currentState is RecordListLoaded) {
        add(LoadRecords(currentState.keyValues));
      } else {
        emit(RecordInitial());
      }
    } catch (e) {
      emit(const RecordError('Failed to update record.'));
    }
  }

  Future<void> _onDeleteRecord(
      DeleteRecord event, Emitter<RecordState> emit) async {
    await _dbHelper.rawDelete(_tableName, event.record.id);
    await _dbHelper
        .rawExecute(event.record.deleteBlobData(event.record.imageId));

    if (event.record.productIds.isNotEmpty) {
      for (var productId in event.record.productIds) {
        final productJson = await _dbHelper.getAGrain("Product", productId);
        if (productJson != null) {
          final product = Product.fromJson(productJson);
          productBloc.add(DeleteProduct(product, "record"));
        }
      }
    }
    final currentState = state;
    if (currentState is RecordListLoaded) {
      add(LoadRecords(currentState.keyValues));
    } else {
      emit(RecordInitial());
    }
  }

  Future<void> _onInitializeRecords(
      InitializeRecords event, Emitter<RecordState> emit) async {
    emit(RecordInitial());
  }
}
