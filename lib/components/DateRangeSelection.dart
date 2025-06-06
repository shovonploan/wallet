import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show BlocBuilder, ReadContext;
import 'package:wallet/bloc/dateRange.dart';

class DateRangeSelection extends StatelessWidget {
  const DateRangeSelection({
    super.key,
    required this.dateRangeNode,
  });

  final FocusNode dateRangeNode;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        dropdownMenuTheme: const DropdownMenuThemeData(
          menuStyle: MenuStyle(
            padding: WidgetStatePropertyAll<EdgeInsets>(
              EdgeInsets.symmetric(horizontal: 20),
            ),
          ),
        ),
      ),
      child:
          BlocBuilder<DateRangeBloc, DateRangeState>(builder: (context, state) {
        return DropdownButtonFormField<String>(
          value: state.range.duration.inDays.toString(),
          focusNode: dateRangeNode,
          decoration: InputDecoration(
            labelText: dateRangeNode.hasFocus ? null : "Date Range",
            border: const OutlineInputBorder(),
          ),
          items: AllRange.map((s) {
            return DropdownMenuItem<String>(
              value: s.duration.inDays.toString(),
              child: Text(
                  "${s.duration.inDays} ${s.duration.inDays == 1 ? "Day" : "Days"}"),
            );
          }).toList(),
          onChanged: (value) {
            context
                .read<DateRangeBloc>()
                .add(SelectedDateRange(Duration(days: int.parse(value!))));
          },
          validator: (value) =>
              value == null ? 'Please select a Date Range' : null,
        );
      }),
    );
  }
}
