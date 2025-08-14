import 'package:flutter/material.dart';
import '../models/lesson_question.dart';
import '../utils/responsive.dart';

class PatternGrid extends StatelessWidget {
  final PatternQuestionData data;
  final int? selected;
  final List<int> options; // length 2
  final void Function(int) onSelected;
  const PatternGrid({super.key, required this.data, required this.options, required this.onSelected, this.selected});

  @override
  Widget build(BuildContext context) {
    final double gridFont = scaledFontSize(context, baseOnPhone: 18, maxOnDesktop: 24);
    Widget cell(String text, {bool highlight = false}) => Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: highlight ? Colors.lightBlue.shade50 : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Text(text, style: TextStyle(fontSize: gridFont)),
        );

    final List<Widget> rows = [];
    for (int i = 0; i < 3; i++) {
      rows.add(Row(
        children: [
          Expanded(child: cell(data.isDivision ? '${data.leftOperands[i]} ÷ ${data.rightConst}' : '${data.leftOperands[i]} × ${data.rightConst}')),
          const SizedBox(width: 8),
          Expanded(child: i == 2 ? cell('?', highlight: true) : cell('${data.results[i]}')),
        ],
      ));
      if (i < 2) rows.add(const SizedBox(height: 8));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Column(children: rows),
        ),
        const SizedBox(height: 12),
        for (final v in options)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: ElevatedButton(
              onPressed: () => onSelected(v),
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
              child: Text('$v'),
            ),
          ),
      ],
    );
  }
}

class MultipleChoiceList extends StatelessWidget {
  final List<int> options;
  final void Function(int) onSelected;
  const MultipleChoiceList({super.key, required this.options, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final v in options)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: ElevatedButton(
              onPressed: () => onSelected(v),
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
              child: Text('$v'),
            ),
          ),
      ],
    );
  }
}