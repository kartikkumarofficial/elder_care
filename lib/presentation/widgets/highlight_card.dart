import 'package:flutter/material.dart';

class HighlightCard extends StatelessWidget {
  final Map<dynamic, dynamic> highlight;

  const HighlightCard({Key? key, required this.highlight}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.orangeAccent.withValues(alpha: 0.8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Engagement Change",
                  style: TextStyle(color: Colors.white70),
                ),
                Text(
                  "${highlight['engagement_change']}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  "Top Day",
                  style: TextStyle(color: Colors.white70),
                ),
                Text(
                  "${highlight['top_day']}: ${highlight['top_value']}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
