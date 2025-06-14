import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PriceTableWidget extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> weightRanges;

  const PriceTableWidget({
    Key? key,
    required this.title,
    required this.weightRanges,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: const BorderSide(
          color: Color.fromARGB(255, 253, 109, 37),
          width: 2,
        ),
      ),
      child: ExpansionTile(
        title: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Table(
                  columnWidths: const {
                    0: FlexColumnWidth(1),
                    1: FlexColumnWidth(1),
                    2: FlexColumnWidth(1),
                  },
                  border: TableBorder.all(
                    color: Color.fromARGB(255, 253, 109, 37),
                    width: 1.5,
                  ),
                  children: [
                    TableRow(
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(
                          0.2,
                        ), // Light orange background for header
                      ),
                      children: [
                        _buildTableCell(
                          t.minWeight,
                          isHeader: true,
                          textColor: textColor,
                        ),
                        _buildTableCell(
                          t.maxWeight,
                          isHeader: true,
                          textColor: textColor,
                        ),
                        _buildTableCell(
                          t.price,
                          isHeader: true,
                          textColor: textColor,
                        ),
                      ],
                    ),
                    ...weightRanges.map((range) {
                      return TableRow(
                        children: [
                          _buildTableCell(
                            '${range['min']} kg',
                            textColor: textColor,
                          ),
                          _buildTableCell(
                            '${range['max']} kg',
                            textColor: textColor,
                          ),
                          _buildTableCell(
                            '${range['price']} VND',
                            textColor: textColor,
                          ),
                        ],
                      );
                    }).toList(),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  TableCell _buildTableCell(
    String text, {
    bool isHeader = false,
    required Color textColor,
  }) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
