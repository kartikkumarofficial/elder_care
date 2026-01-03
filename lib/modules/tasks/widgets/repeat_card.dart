


import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../events/controllers/events_controller.dart';

class RepeatCard extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const RepeatCard({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? kTeal.withOpacity(0.12) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? kTeal : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.w700,
                color: selected ? kTeal : Colors.black87,
              ),
            ),
            const Spacer(),
            if (selected)
              const Icon(Icons.check_circle, size: 18, color: kTeal),
          ],
        ),
      ),
    );
  }
}
