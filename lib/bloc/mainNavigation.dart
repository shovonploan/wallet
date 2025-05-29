import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet/Pages/Home.dart';

//---------------State-----------------------
abstract class NavigationState extends Equatable {
  final Widget screen;
  const NavigationState(this.screen);
  @override
  List<Object?> get props => [];
}

class NavigationInitial extends NavigationState {
  const NavigationInitial(super.screen);
  @override
  List<Object?> get props => [screen];
}

class NavigationLoaded extends NavigationState {
  const NavigationLoaded(super.screen);
  @override
  List<Object?> get props => [screen];
}

//--------------Event----------------------
abstract class NavigationEvent extends Equatable {
  const NavigationEvent();
  @override
  List<Object?> get props => [];
}

class NavigationUpdate extends NavigationEvent {
  final Widget screen;
  const NavigationUpdate(this.screen);
  @override
  List<Object?> get props => [screen];
}
//---------------------bloc----------------

class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  NavigationBloc() : super(const NavigationLoaded(HomeScreen())) {
    on<NavigationUpdate>(_onNavigationUpdate);
  }
  Future<void> _onNavigationUpdate(
      NavigationUpdate event, Emitter<NavigationState> emit) async {
    emit(NavigationInitial(state.screen));
    emit(NavigationLoaded(event.screen));
  }
}
