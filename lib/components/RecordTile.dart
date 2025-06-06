import 'package:flutter/material.dart';
import 'package:wallet/constants/theme.dart';
import 'package:wallet/models/record.dart';

class RecordTile extends StatelessWidget {
  Record record;
  RecordTile({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: (record.kind == null)
            ? CustomColor.primary.shade900
            : record.kind?.color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            (record.type is Transfer) ? 'Transfer' : record.kind?.name ?? '',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}