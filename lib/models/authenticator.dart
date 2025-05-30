library Authtenticator;

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet/constants/common.dart';
import 'package:wallet/database/database.dart';

String _tableName = "Authenticate";

@immutable
class Authenticate extends DBGrain {
  @override
  final String id;
  final String pin;
  final String createdOn;
  final String lastLoggedIn;
  final String lastLoggedOut;

  Authenticate.Ctor(
      String pin, String createdOn, String lastLoggedIn, String lastLoggedOut)
      : this(
            id: generateNewUuid(),
            pin: pin,
            createdOn: createdOn,
            lastLoggedIn: lastLoggedIn,
            lastLoggedOut: lastLoggedOut);
  Authenticate.defaultCtor()
      : this(
            id: '',
            pin: '',
            createdOn: '',
            lastLoggedIn: '',
            lastLoggedOut: '');

  Authenticate(
      {required this.id,
      required this.pin,
      required this.createdOn,
      required this.lastLoggedIn,
      required this.lastLoggedOut});

  Authenticate copyWith(
      {String? id,
      String? pin,
      String? createdOn,
      String? lastLoggedIn,
      String? lastLoggedOut}) {
    return Authenticate(
        id: id ?? this.id,
        pin: pin ?? this.pin,
        createdOn: createdOn ?? this.createdOn,
        lastLoggedIn: lastLoggedIn ?? this.lastLoggedIn,
        lastLoggedOut: lastLoggedOut ?? this.lastLoggedOut);
  }

  Map<String, dynamic> _toMap() {
    return <String, dynamic>{
      'id': id,
      'pin': pin,
      'createdOn': createdOn,
      'lastLoggedIn': lastLoggedIn,
      'lastLoggedOut': lastLoggedOut,
      'codecVersion': codecVersion
    };
  }

  factory Authenticate._fromMap(Map<String, dynamic> map) {
    final int dbCodecVersion = map['codecVersion'] as int;

    if (dbCodecVersion == 1) {
      return Authenticate(
          id: map['id'] as String,
          pin: map['pin'] as String,
          createdOn: map['createdOn'] as String,
          lastLoggedIn: map['lastLoggedIn'] as String,
          lastLoggedOut: map['lastLoggedOut'] as String);
    } else {
      return Authenticate.defaultCtor();
    }
  }

  String toJson() => json.encode(_toMap());

  factory Authenticate.fromJson(String source) =>
      Authenticate._fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'Authenticate(id: $id, pin: $pin)';

  @override
  bool operator ==(covariant Authenticate other) {
    if (identical(this, other)) return true;

    return other.id == id && other.pin == pin;
  }

  @override
  int get hashCode => id.hashCode ^ pin.hashCode;

  @override
  final String tableName = _tableName;
  @override
  final Map<String, String> indexs = {};

  @override
  String insert() {
    return super.DBInsert(toJson());
  }

  @override
  String customInsert() {
    return '';
  }

  String update(Authenticate newGrain) {
    return super.DBUpdate(newGrain.toJson());
  }

  @override
  final int codecVersion = 1;
}

//---------------State-----------------------
abstract class AuthenticateState extends Equatable {
  const AuthenticateState();

  @override
  List<Object?> get props => [];
}

class AuthenticateInitial extends AuthenticateState {}

class AuthenticateLoaded extends AuthenticateState {
  final String message;
  const AuthenticateLoaded(this.message);

  @override
  List<Object?> get props => [message];
}

class Authenticated extends AuthenticateState {
  final Authenticate authenticate;
  const Authenticated(this.authenticate);

  @override
  List<Object?> get props => [authenticate];
}

class AuthenticateError extends AuthenticateState {
  final String message;

  const AuthenticateError(this.message);

  @override
  List<Object?> get props => [message];
}

class CreatingAuthenticate extends AuthenticateState {
  final String typedPin;

  const CreatingAuthenticate(this.typedPin);

  @override
  List<Object?> get props => [typedPin];
}

//---------------Event----------------------
abstract class AuthenticateEvent extends Equatable {
  const AuthenticateEvent();

  @override
  List<Object?> get props => [];
}

class LoadAuthenticate extends AuthenticateEvent {}

class CreateAuthenticate extends AuthenticateEvent {
  final String pin;

  const CreateAuthenticate(this.pin);

  @override
  List<Object?> get props => [pin];
}

class OnCreatingAuthenticate extends AuthenticateEvent {
  final String typedPin;

  const OnCreatingAuthenticate(this.typedPin);

  @override
  List<Object?> get props => [typedPin];
}

class UpdatePinAuthenticate extends AuthenticateEvent {
  final Authenticate authenticate;
  final String newPin;

  const UpdatePinAuthenticate(this.authenticate, this.newPin);

  @override
  List<Object?> get props => [authenticate, newPin];
}

class LoginAuthenticate extends AuthenticateEvent {
  final String pin;

  const LoginAuthenticate(this.pin);

  @override
  List<Object?> get props => [pin];
}

class LogoutAuthenticate extends AuthenticateEvent {}

class OnAuthenticateError extends AuthenticateEvent {
  final String message;

  const OnAuthenticateError(this.message);

  @override
  List<Object?> get props => [message];
}

//---------------------bloc----------------
class AuthenticateBloc extends Bloc<AuthenticateEvent, AuthenticateState> {
  final DatabaseHelper _dbHelper;
  AuthenticateBloc(this._dbHelper)
      : super(AuthenticateInitial()) {
    on<LoadAuthenticate>(_onLoadAuthenticate);
    on<CreateAuthenticate>(_onCreateAuthenticate);
    on<OnCreatingAuthenticate>(_onCreatingAuthenticate);
    on<UpdatePinAuthenticate>(_onUpdatePinAuthenticate);
    on<LoginAuthenticate>(_onLoginAuthenticate);
    on<LogoutAuthenticate>(_onLogoutAuthenticate);
    on<OnAuthenticateError>(_onAuthenticateError);

    // eventBus.on<LogOutEvent>().listen((event) {
    //   print("Received LogOutEvent with reason: ${event.reason}");
    //   add(LogoutAuthenticate());
    // });
  }

  Future<void> _onLoadAuthenticate(
      LoadAuthenticate event, Emitter<AuthenticateState> emit) async {
    try {
      final dbData = await _dbHelper.getAllGrain(_tableName);
      if (dbData.isNotEmpty) {
        final authenticate = Authenticate.fromJson(dbData.first);
        final isLogged = (DateTime.now().difference(DateTime.parse(authenticate.lastLoggedIn)) < const Duration(days: 5));

        if (isLogged) {
          emit(Authenticated(authenticate));
        } else{
          add(LogoutAuthenticate());
        }
      } else {
        emit(const CreatingAuthenticate(''));
      }
    } catch (e) {
      print("Error $e");
      emit(const AuthenticateError('Failed to load authentication data.'));
    }
  }

  Future<void> _onCreateAuthenticate(
    CreateAuthenticate event,
    Emitter<AuthenticateState> emit,
  ) async {
    try {
      final now = DateTime.now().toString();
      final newAuth = Authenticate.Ctor(event.pin, now, now, '');

      _dbHelper.rawExecute(newAuth.insert()).then((_) {
        add(LoadAuthenticate());
      }).catchError((error) {
        emit(const AuthenticateError('Failed to create authentication data.'));
      });
    } catch (e) {
      emit(const AuthenticateError('Failed to create authentication data.'));
    }
  }

  Future<void> _onCreatingAuthenticate(
      OnCreatingAuthenticate event, Emitter<AuthenticateState> emit) async {
    try {
      if (state is CreatingAuthenticate) {
        final currentState = state as CreatingAuthenticate;
        if (currentState.typedPin.isEmpty) {
          emit(CreatingAuthenticate(event.typedPin));
        } else if (currentState.typedPin == event.typedPin) {
          add(CreateAuthenticate(event.typedPin));
        }
      }
    } catch (e) {
      emit(const AuthenticateError('Failed to create authentication data.'));
    }
  }

  Future<void> _onUpdatePinAuthenticate(
      UpdatePinAuthenticate event, Emitter<AuthenticateState> emit) async {
    try {
      await _dbHelper.rawExecute(event.authenticate
          .update(event.authenticate.copyWith(pin: event.newPin)));
      add(LoadAuthenticate());
    } catch (e) {
      emit(const AuthenticateError('Failed to update authentication data.'));
    }
  }

  Future<void> _onLoginAuthenticate(
      LoginAuthenticate event, Emitter<AuthenticateState> emit) async {
    try {
      final dbData = await _dbHelper.getAllGrain(_tableName);
      if (dbData.isNotEmpty) {
        final authenticate = Authenticate.fromJson(dbData.first);
        if (authenticate.pin == event.pin) {
          final updatedAuthenticate =
              authenticate.copyWith(lastLoggedIn: DateTime.now().toString());
          await _dbHelper
              .rawExecute(updatedAuthenticate.update(updatedAuthenticate));
          emit(Authenticated(updatedAuthenticate));
        } else {
          emit(const AuthenticateLoaded('Invalid PIN.'));
        }
      } else {
        emit(const CreatingAuthenticate(''));
      }
    } catch (e) {
      emit(const AuthenticateError('Failed to verify authentication data.'));
    }
  }

  Future<void> _onLogoutAuthenticate(
      LogoutAuthenticate event, Emitter<AuthenticateState> emit) async {
    try {
      final currentState = state;
      if (currentState is Authenticated) {
        final updatedAuthenticate = currentState.authenticate
            .copyWith(lastLoggedOut: DateTime.now().toString());
        await _dbHelper
            .rawExecute(updatedAuthenticate.update(updatedAuthenticate));
        emit(const AuthenticateLoaded('Session Timeout'));
      }
      else {
        emit(const AuthenticateLoaded(''));
      }
    } catch (e) {
      emit(const AuthenticateError('Failed to log out.'));
    }
  }

  Future<void> _onAuthenticateError(
      OnAuthenticateError event, Emitter<AuthenticateState> emit) async {
    emit(AuthenticateError(event.message));
  }
}
