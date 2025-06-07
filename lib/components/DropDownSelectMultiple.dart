import 'package:flutter/material.dart';
import 'package:wallet/constants/types.dart';

class DropDownSelectMultiple extends StatefulWidget {
  final String heading;
  final List<StringListPair> allItems;
  final List<StringListPair> selectedItems;
  final Function(List<StringListPair>) onSelected;
  final String? Function(List<StringListPair>)? validate;

  const DropDownSelectMultiple({
    required this.heading,
    required this.allItems,
    required this.selectedItems,
    required this.onSelected,
    this.validate,
    super.key,
  });

  @override
  State<DropDownSelectMultiple> createState() => _DropDownSelectMultipleState();
}

class _DropDownSelectMultipleState extends State<DropDownSelectMultiple> {
  ValueNotifier<List<StringListPair>> selectedItems = ValueNotifier([]);

  @override
  void initState() {
    super.initState();
    selectedItems.value = List.from(widget.selectedItems);
  }

  void _showMultiSelectDialog() async {
    final List<StringListPair>? result = await showDialog<List<StringListPair>>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return MultiSelectDialog(
          heading: widget.heading,
          items: widget.allItems,
          selectedItems: selectedItems.value,
        );
      },
    );

    bool validate() {
      String? message = widget.validate?.call(selectedItems.value);
      if (message != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text(message),
          ),
        );
        return false;
      }
      return true;
    }

    if (result != null) {
      if (validate()) {
        selectedItems.value = result;
        widget.onSelected(selectedItems.value);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showMultiSelectDialog,
      child: ValueListenableBuilder<List<StringListPair>>(
        valueListenable: selectedItems,
        builder: (_, value, __) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
              color: const Color(0xFF0F6E32),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value.isEmpty
                      ? widget.heading
                      : selectedItems.value
                          .map((item) => item.first.toString())
                          .join(', '),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const Icon(
                  Icons.arrow_drop_down,
                  color: Colors.teal,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class MultiSelectDialog extends StatefulWidget {
  final String heading;
  final List<StringListPair> items;
  final List<StringListPair> selectedItems;

  const MultiSelectDialog({
    super.key,
    required this.heading,
    required this.items,
    required this.selectedItems,
  });

  @override
  _MultiSelectDialogState createState() => _MultiSelectDialogState();
}

class _MultiSelectDialogState extends State<MultiSelectDialog> {
  late ValueNotifier<List<StringListPair>> tempSelectedItems;

  @override
  void initState() {
    super.initState();
    tempSelectedItems = ValueNotifier(List.from(widget.selectedItems));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.heading),
      content: SingleChildScrollView(
        child: ValueListenableBuilder<List<StringListPair>>(
          valueListenable: tempSelectedItems,
          builder: (_, value, __) {
            return ListBody(
              children: widget.items.map((StringListPair item) {
                return CheckboxListTile(
                  value: value.any((element) => element.first == item.first),
                  title: Text(item.first.toString()),
                  onChanged: (bool? selected) {
                    if (selected == true) {
                      if (!value
                          .any((element) => element.first == item.first)) {
                        tempSelectedItems.value =
                            List.from(tempSelectedItems.value)..add(item);
                      }
                    } else {
                      tempSelectedItems
                          .value = List.from(tempSelectedItems.value)
                        ..removeWhere((element) => element.first == item.first);
                    }
                  },
                );
              }).toList(),
            );
          },
        ),
      ),
      actions: [
        ElevatedButton(
          child: const Text('OK'),
          onPressed: () {
            if (tempSelectedItems.value.isNotEmpty) {
              Navigator.of(context).pop(tempSelectedItems.value);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: Colors.redAccent,
                  content: Text('Please select at least one item.'),
                ),
              );
            }
          },
        ),
      ],
    );
  }
}
