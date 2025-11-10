import 'package:flutter/material.dart';

/// 到達回数を表示するカードウィジェット
class ArrivalCounterCard extends StatelessWidget {
  const ArrivalCounterCard({super.key, required this.arrivalCount});

  final ValueNotifier<int> arrivalCount;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: arrivalCount,
      builder: (context, count, child) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(12, 6, 12, 18),
          child: Text(
            '到達: $count',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }
}
