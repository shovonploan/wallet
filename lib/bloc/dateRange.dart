import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class Range {
  Duration duration;
  Range(this.duration);
}

class DayRange extends Range {
  DayRange() : super(const Duration(days: 1));
}

class WeekRange extends Range {
  WeekRange() : super(const Duration(days: 7));
}

class HalfMonthRange extends Range {
  HalfMonthRange() : super(const Duration(days: 15));
}

class MonthRange extends Range {
  MonthRange() : super(const Duration(days: 30));
}

class QuarterRange extends Range {
  QuarterRange() : super(const Duration(days: 90));
}

class HalfYearRange extends Range {
  HalfYearRange() : super(const Duration(days: 180));
}

class YearRange extends Range {
  YearRange() : super(const Duration(days: 365));
}

final List<Range> AllRange = [
  DayRange(),
  WeekRange(),
  HalfMonthRange(),
  MonthRange(),
  QuarterRange(),
  HalfYearRange(),
  YearRange()
];

//---------------State-----------------------
abstract class DataRangeState extends Equatable {
  final Range range;
  const DataRangeState(this.range);
  @override
  List<Object?> get props => [];
}

class DateRangeInitial extends DataRangeState {
  const DateRangeInitial(super.range);
  @override
  List<Object?> get props => [range];
}

class DataRangeLoaded extends DataRangeState {
  const DataRangeLoaded(super.range);
  @override
  List<Object?> get props => [range];
}

//--------------Event----------------------
class DataRangeEvent extends Equatable {
  const DataRangeEvent();
  @override
  List<Object?> get props => [];
}

class SelectedDataRange extends DataRangeEvent {
  final Duration days;
  const SelectedDataRange(this.days);
  @override
  List<Object?> get props => [days];
}

//---------------------bloc----------------
class DataRangeBloc extends Bloc<DataRangeEvent, DataRangeState> {
  DataRangeBloc() : super(DataRangeLoaded(AllRange[0])) {
    on<SelectedDataRange>(_onSelectedDataRange);
  }

  Future<void> _onSelectedDataRange(
      SelectedDataRange event, Emitter<DataRangeState> emit) async {
    emit(DateRangeInitial(state.range));
    Range? selectedRange;
    for (Range range in AllRange) {
      if (range.duration == event.days) {
        selectedRange = range;
      }
    }
    selectedRange ??= AllRange[0];
    emit(DataRangeLoaded(selectedRange));
  }
}
