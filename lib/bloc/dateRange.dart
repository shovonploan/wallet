import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet/constants/common.dart';
import 'package:wallet/models/account.dart';
import 'package:wallet/models/record.dart';

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
abstract class DateRangeState extends Equatable {
  final Range range;
  const DateRangeState(this.range);
  @override
  List<Object?> get props => [];
}

class DateRangeInitial extends DateRangeState {
  const DateRangeInitial(super.range);
  @override
  List<Object?> get props => [range];
}

class DateRangeLoaded extends DateRangeState {
  const DateRangeLoaded(super.range);
  @override
  List<Object?> get props => [range];
}

//--------------Event----------------------
class DateRangeEvent extends Equatable {
  const DateRangeEvent();
  @override
  List<Object?> get props => [];
}

class SelectedDateRange extends DateRangeEvent {
  final Duration days;
  const SelectedDateRange(this.days);
  @override
  List<Object?> get props => [days];
}

//---------------------bloc----------------
class DateRangeBloc extends Bloc<DateRangeEvent, DateRangeState> {
  final RecordBloc? _recordBloc;
  final AccountBloc? _accountBloc;

  DateRangeBloc(this._recordBloc, this._accountBloc)
      : super(DateRangeLoaded(AllRange[0])) {
    on<SelectedDateRange>(_onSelectedDateRange);
  }

  Future<void> _onSelectedDateRange(
      SelectedDateRange event, Emitter<DateRangeState> emit) async {
    emit(DateRangeInitial(state.range));
    Range? selectedRange;
    for (Range range in AllRange) {
      if (range.duration == event.days) {
        selectedRange = range;
      }
    }
    selectedRange ??= AllRange[0];
    emit(DateRangeLoaded(selectedRange));
    _recordBloc?.add(
      LoadRecords(
        defaultRecordQuarry(
          this,
          _accountBloc!,
        ),
      ),
    );
  }
}
