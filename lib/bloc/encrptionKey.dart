library encryptionKey;

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../database/database.dart';

//---------------State-----------------------
abstract class EncryptionKeyState extends Equatable {
  const EncryptionKeyState();

  @override
  List<Object?> get props => [];
}

class EncryptionKeyInitial extends EncryptionKeyState {}

class EncryptionKeyLoading extends EncryptionKeyState {}

class EncryptionKeyNotFound extends EncryptionKeyState {}

class EncryptionKeyLoaded extends EncryptionKeyState {}

class EncryptionKeyError extends EncryptionKeyState {
  final String message;
  const EncryptionKeyError(this.message);

  @override
  List<Object?> get props => [message];
}

//--------------Event----------------------
abstract class EncryptionKeyEvent extends Equatable {
  const EncryptionKeyEvent();
  @override
  List<Object?> get props => [];
}

class EncryptionKeyLoad extends EncryptionKeyEvent {}

class EncryptionKeyCatch extends EncryptionKeyEvent {
  final String key;
  const EncryptionKeyCatch(this.key);
  @override
  List<Object?> get props => [key];
}

class EncryptionKeyInvalid extends EncryptionKeyEvent {}

class EncryptionKeyFound extends EncryptionKeyEvent {}

//---------------------bloc----------------
class EncryptionKeyBloc extends Bloc<EncryptionKeyEvent, EncryptionKeyState> {
  final DatabaseHelper _dbHelper;
  EncryptionKeyBloc(this._dbHelper) : super(EncryptionKeyInitial()) {
    on<EncryptionKeyLoad>(_onLoadKey);
    on<EncryptionKeyCatch>(_onCatchKey);
    on<EncryptionKeyInvalid>(_onInvalidKey);
    on<EncryptionKeyFound>(_onKeyFound);
  }

  Future<void> _onLoadKey(
      EncryptionKeyLoad event, Emitter<EncryptionKeyState> emit) async {
    emit(EncryptionKeyLoading());
    if (await _dbHelper.isKeyExist()) {
      await _dbHelper.setKey();
      add(EncryptionKeyFound());
    } else {
      emit(EncryptionKeyNotFound());
    }
  }

  Future<void> _onCatchKey(
      EncryptionKeyCatch event, Emitter<EncryptionKeyState> emit) async {
    await _dbHelper.setNewKey(event.key).then((_) async {
      await _dbHelper.saveKey(event.key);
      add(EncryptionKeyFound());
    });
  }

  Future<void> _onInvalidKey(
      EncryptionKeyInvalid event, Emitter<EncryptionKeyState> emit) async {
    add(EncryptionKeyLoad());
  }

  Future<void> _onKeyFound(
    EncryptionKeyFound event,
    Emitter<EncryptionKeyState> emit,
  ) async {
    try {
      if (!_dbHelper.hasEncryptionKey) {
        await _dbHelper.setKey();
      }
      emit(EncryptionKeyLoaded());
    } catch (e, _) {
      emit(const EncryptionKeyError("Could not load key"));
    }
  }
}
