import 'package:flutter/material.dart';

class DropDownSelectMultiple extends StatefulWidget {
  final String heading;
  final List<Map<String, dynamic>> allItems;
  final List<Map<String, dynamic>> selectedItems;
  final Function(List<Map<String, dynamic>>) onSelected;

  const DropDownSelectMultiple({
    required this.heading,
    required this.allItems,
    required this.selectedItems,
    required this.onSelected,
    super.key,
  });

  @override
  State<DropDownSelectMultiple> createState() => _DropDownSelectMultipleState();
}

class _DropDownSelectMultipleState extends State<DropDownSelectMultiple> {
  ValueNotifier<List<Map<String, dynamic>>> selectedItems = ValueNotifier([]);

  @override
  void initState() {
    super.initState();
    selectedItems.value = List.from(widget.selectedItems);
  }

  void _showMultiSelectDialog() async {
    final List<Map<String, dynamic>>? result =
        await showDialog<List<Map<String, dynamic>>>(
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

    if (result != null) {
      selectedItems.value = result;
      widget.onSelected(selectedItems.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showMultiSelectDialog,
      child: ValueListenableBuilder<List<Map<String, dynamic>>>(
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
                          .map((item) => item['key'].toString())
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
  final List<Map<String, dynamic>> items;
  final List<Map<String, dynamic>> selectedItems;

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
  late ValueNotifier<List<Map<String, dynamic>>> tempSelectedItems;

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
        child: ValueListenableBuilder<List<Map<String, dynamic>>>(
          valueListenable: tempSelectedItems,
          builder: (_, value, __) {
            return ListBody(
              children: widget.items.map((Map<String, dynamic> item) {
                return CheckboxListTile(
                  value: value.any((element) => element['key'] == item['key']),
                  title: Text(item['key'].toString()),
                  onChanged: (bool? selected) {
                    if (selected == true) {
                      if (!value
                          .any((element) => element['key'] == item['key'])) {
                        tempSelectedItems.value =
                            List.from(tempSelectedItems.value)..add(item);
                      }
                    } else {
                      tempSelectedItems.value =
                          List.from(tempSelectedItems.value)
                            ..removeWhere(
                                (element) => element['key'] == item['key']);
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
