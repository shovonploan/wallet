import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet/constants/common.dart';
import 'package:wallet/database/database.dart';
import 'dart:typed_data';

import 'package:wallet/models/record.dart';

abstract class ProductCondition {
  const ProductCondition();
  Map<String, dynamic> toJson();
  factory ProductCondition.fromMap(Map<String, dynamic> map) {
    switch (map['state']) {
      case 'Expired':
        return const Expired();
      case 'WillExpire':
        return WillExpire(map['date']);
      case 'Healthy':
        return const Healthy();
      case 'Lost':
        return const Lost();
      default:
        throw Exception('Unknown product state: ${map['state']}');
    }
  }
  @override
  String toString();
}

class Expired extends ProductCondition {
  const Expired() : super();
  @override
  Map<String, dynamic> toJson() => {
        'state': 'Expired',
      };
  @override
  String toString() {
    return 'Expired';
  }
}

class WillExpire extends ProductCondition {
  final String date;
  WillExpire(this.date);
  @override
  Map<String, dynamic> toJson() => {
        'state': 'WillExpire',
        'date': date,
      };

  @override
  String toString() {
    return 'WillExpire';
  }
}

class Healthy extends ProductCondition {
  const Healthy() : super();
  @override
  Map<String, dynamic> toJson() => {
        'state': 'Healthy',
      };
  @override
  String toString() {
    return 'Healthy';
  }
}

class Lost extends ProductCondition {
  const Lost() : super();
  @override
  Map<String, dynamic> toJson() => {
        'state': 'Lost',
      };
  @override
  String toString() {
    return 'Lost';
  }
}

String _tableName = "Product";

@immutable
class Product extends DBGrain {
  @override
  final String id;
  final String name;
  final ProductCondition state;
  final String recordId;
  final double amount;
  final String imageId;
  final String createdAt;
  final String updatedAt;

  Product.Ctor(String name, ProductCondition state, String recordId,
      double amount, String imageId, String createdAt, String updatedAt)
      : this(
            id: generateNewUuid(),
            name: name,
            state: state,
            recordId: recordId,
            amount: amount,
            imageId: imageId,
            createdAt: createdAt,
            updatedAt: updatedAt);
  Product.defaultCtor()
      : this(
            id: '',
            name: '',
            state: const Healthy(),
            recordId: '',
            amount: 0.0,
            imageId: '',
            createdAt: '',
            updatedAt: '');
  Product({
    required this.id,
    required this.name,
    required this.state,
    required this.recordId,
    required this.amount,
    required this.imageId,
    required this.createdAt,
    required this.updatedAt,
  });

  Product copyWith({
    String? id,
    String? name,
    ProductCondition? state,
    String? recordId,
    double? amount,
    String? imageId,
    String? createdAt,
    String? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      state: state ?? this.state,
      recordId: recordId ?? this.recordId,
      amount: amount ?? this.amount,
      imageId: imageId ?? this.imageId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> _toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'state': state.toJson(),
      'recordId': recordId,
      'amount': amount,
      'imageId': imageId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'codecVersion': codecVersion,
    };
  }

  factory Product._fromMap(Map<String, dynamic> map) {
    final int dbCodecVersion = map['codecVersion'] as int;
    if (dbCodecVersion == 1) {
      return Product(
        id: map['id'] as String,
        name: map['name'] as String,
        state: ProductCondition.fromMap(map['state']),
        recordId: map['recordId'] as String,
        amount: map['amount'] as double,
        imageId: map['imageId'] as String,
        createdAt: map['createdAt'] as String,
        updatedAt: map['updatedAt'] as String,
      );
    } else {
      return Product.defaultCtor();
    }
  }

  String toJson() => json.encode(_toMap());

  factory Product.fromJson(String source) =>
      Product._fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'Product(id: $id, name: $name, state: $state, recordId: $recordId, amount: $amount, imageId: $imageId, createdAt: $createdAt, updatedAt: $updatedAt)';

  @override
  bool operator ==(covariant Object other) {
    if (identical(this, other)) return true;
    return other is Product &&
        other.id == id &&
        other.name == name &&
        other.state == state &&
        other.recordId == recordId &&
        other.amount == amount &&
        other.imageId == imageId &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      state.hashCode ^
      recordId.hashCode ^
      amount.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode;

  @override
  final String tableName = _tableName;

  @override
  Map<String, String> get indexs => {
        'name': name,
        'state': state.toString(),
        'recordId': recordId,
      };

  @override
  String insert() {
    return super.DBInsert(toJson());
  }

  @override
  String customInsert() {
    return '';
  }

  String update(Product newGrain) {
    return super.DBUpdate(newGrain.toJson());
  }

  @override
  final int codecVersion = 1;
}

//---------------State-----------------------
abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object?> get props => [];
}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductListLoaded extends ProductState {
  final Map<Product, int> availableProducts;
  final List<Product> unavailableProducts;
  const ProductListLoaded(this.availableProducts, this.unavailableProducts);
}

class ProductRecordLoaded extends ProductState {
  final List<Product> products;
  const ProductRecordLoaded(this.products);
}

class ProductError extends ProductState {
  final String message;
  const ProductError(this.message);
  @override
  List<Object?> get props => [message];
}

//--------------Event----------------------
abstract class ProductEvent extends Equatable {
  const ProductEvent();
  @override
  List<Object?> get props => [];
}

class LoadProductsList extends ProductEvent {}

class LoadProductsRecord extends ProductEvent {
  final String recordId;
  const LoadProductsRecord(this.recordId);
  @override
  List<Object?> get props => [recordId];
}

class AddProduct extends ProductEvent {
  final String name;
  final ProductCondition state;
  final String recordId;
  final double amount;
  final Uint8List? image;
  const AddProduct(
      this.name, this.state, this.recordId, this.amount, this.image);
  @override
  List<Object?> get props => [name, state, recordId, amount, image];
}

class UpdateProduct extends ProductEvent {
  final Product product;
  final String newName;
  final ProductCondition newState;
  final String recordId;
  final double amount;
  final Uint8List? image;
  const UpdateProduct(this.product, this.newName, this.newState, this.recordId,
      this.amount, this.image);
  @override
  List<Object?> get props =>
      [product, newName, newState, recordId, amount, image];
}

class DeleteProduct extends ProductEvent {
  final Product product;
  final String from;

  const DeleteProduct(this.product, this.from);

  @override
  List<Object?> get props => [product, from];
}

class InitializeProducts extends ProductEvent {
  const InitializeProducts();
  @override
  List<Object?> get props => [];
}

//---------------------bloc----------------
class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final DatabaseHelper _dbHelper;
  final RecordBloc recordBloc;
  ProductBloc(this._dbHelper, this.recordBloc) : super(ProductInitial()) {
    on<LoadProductsList>(_onLoadProducts);
    on<LoadProductsRecord>(_onLoadProductsRecord);
    on<AddProduct>(_onAddProduct);
    on<UpdateProduct>(_onUpdateProduct);
    on<DeleteProduct>(_onDeleteProduct);
    on<InitializeProducts>(_onInitializeProducts);
  }

  Future<void> _onLoadProducts(
      LoadProductsList event, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    try {
      emit(ProductLoading());
      final dbData = await _dbHelper.getAllGrain(_tableName);
      final products = dbData.map((e) => Product.fromJson(e)).toList();
      final availableProductsList = products
          .where((product) =>
              product.state is Healthy || product.state is WillExpire)
          .map((product) {
        int secondsLeft = 0;
        if (product.state is WillExpire) {
          final willExpire = product.state as WillExpire;
          secondsLeft = DateTime.parse(willExpire.date)
              .difference(DateTime.now())
              .inSeconds;
        }
        return MapEntry(product, secondsLeft);
      }).toList();

      availableProductsList.sort((a, b) {
        final aDate = DateTime.parse(a.key.updatedAt);
        final bDate = DateTime.parse(b.key.updatedAt);
        return bDate.compareTo(aDate);
      });

      final Map<Product, int> availableProducts = {
        for (var entry in availableProductsList) entry.key: entry.value,
      };

      final unavailableProducts = products
          .where((product) => product.state is Expired || product.state is Lost)
          .toList();

      final deletedProducts = products
          .where((product) =>
              DateTime.parse(product.updatedAt)
                  .difference(DateTime.now())
                  .inDays >
              5)
          .toList();

      Future.microtask(() {
        for (var product in deletedProducts) {
          add(DeleteProduct(product, "bloc"));
        }
      });

      unavailableProducts.removeWhere((product) =>
          deletedProducts.any((deleted) => deleted.id == product.id));

      unavailableProducts.sort((a, b) {
        final aDate = DateTime.parse(a.updatedAt);
        final bDate = DateTime.parse(b.updatedAt);
        return bDate.compareTo(aDate);
      });

      emit(ProductListLoaded(availableProducts, unavailableProducts));
    } catch (e) {
      emit(const ProductError('Failed to load products.'));
    }
  }

  Future<void> _onLoadProductsRecord(
      LoadProductsRecord event, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    try {
      emit(ProductLoading());
      List<Map<String, dynamic>> conditions = [
        {
          'key': 'recordId',
          'value': event.recordId,
        },
      ];

      final productsJson = await _dbHelper.getIndexedGrain(
        _tableName,
        conditions,
      );

      final products = productsJson.map((e) => Product.fromJson(e)).toList();
      emit(ProductRecordLoaded(products));
    } catch (e) {
      emit(const ProductError('Failed to load products.'));
    }
  }

  Future<void> _onAddProduct(
      AddProduct event, Emitter<ProductState> emit) async {
    try {
      emit(ProductLoading());
      String imageId = generateNewUuid();
      final newProduct = Product.Ctor(
          event.name,
          event.state,
          event.recordId,
          event.amount,
          (event.image == null) ? '' : imageId,
          DateTime.now().toString(),
          DateTime.now().toString());

      if (event.image != null) {
        await _dbHelper.rawExecute(newProduct.insertImageAsBlob(
            imageId, event.image as Uint8List, 'productImage'));
      }

      await _dbHelper.rawExecute(newProduct.insert());

      final currentState = state;
      if (currentState is ProductRecordLoaded) {
        add(LoadProductsRecord(event.recordId));
      } else if (currentState is ProductListLoaded) {
        add(LoadProductsList());
      }
    } catch (e) {
      emit(const ProductError('Failed to load products.'));
    }
  }

  Future<void> _onUpdateProduct(
      UpdateProduct event, Emitter<ProductState> emit) async {
    try {
      emit(ProductLoading());
      String imageId = generateNewUuid();

      final updatedProduct = event.product.copyWith(
        name: event.newName,
        state: event.newState,
        recordId: event.recordId,
        amount: event.amount,
        imageId: (event.image == null) ? '' : imageId,
        updatedAt: DateTime.now().toString(),
      );

      if (event.image != null) {
        await _dbHelper
            .rawExecute(updatedProduct.deleteBlobData(event.product.imageId));
        await _dbHelper.rawExecute(updatedProduct.insertImageAsBlob(
            imageId, event.image as Uint8List, 'productImage'));
      }

      await _dbHelper.rawExecute(event.product.update(updatedProduct));
      final currentState = state;
      if (currentState is ProductRecordLoaded) {
        add(LoadProductsRecord(event.recordId));
      } else if (currentState is ProductListLoaded) {
        add(LoadProductsList());
      }
    } catch (e) {
      emit(const ProductError('Failed to load products.'));
    }
  }

  Future<void> _onDeleteProduct(
      DeleteProduct event, Emitter<ProductState> emit) async {
    await _dbHelper.rawDelete(_tableName, event.product.id);
    await _dbHelper
        .rawExecute(event.product.deleteBlobData(event.product.imageId));
    if (event.product.recordId.isNotEmpty && event.from != "record") {
      final recordJson =
          await _dbHelper.getAGrain("Record", event.product.recordId);
      if (recordJson != null) {
        final record = Record.fromJson(recordJson);

        Uint8List? recordImage;
        if (event.product.imageId.isNotEmpty) {
          final result =
              await _dbHelper.rawQuery(record.getBlobData('receipt'));
          recordImage = result.first['data'] as Uint8List;
        }
        recordBloc.add(UpdateRecord(
            record,
            record.amount,
            record.type,
            record.kind,
            record.stockValue + event.product.amount,
            record.productIds,
            recordImage,
            record.date));
      }
    }

    if (event.from == "bloc") {
    } else if (event.from == "record") {
      final currentState = state;
      if (currentState is ProductRecordLoaded) {
        final updatedProducts = currentState.products
            .where((product) => product.id != event.product.id)
            .toList();
        emit(ProductRecordLoaded(updatedProducts));
      } else {
        add(LoadProductsList());
      }
    } else {
      add(LoadProductsList());
    }
  }

  Future<void> _onInitializeProducts(
      InitializeProducts event, Emitter<ProductState> emit) async {
    emit(ProductInitial());
  }
}
