import 'dart:async';
import 'package:flutter/material.dart';

class ContextStripItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback? onTap;

  ContextStripItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    this.onTap,
  });
}

class ContextStrip extends StatefulWidget {
  final List<ContextStripItem> items;

  const ContextStrip({
    super.key,
    required this.items,
  });

  @override
  State<ContextStrip> createState() => _ContextStripState();
}

class _ContextStripState extends State<ContextStrip> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    if (widget.items.length > 1) {
      _timer = Timer.periodic(const Duration(seconds: 7), (_) {
        if (!_pageController.hasClients) return;

        _currentIndex =
            (_currentIndex + 1) % widget.items.length;

        _pageController.animateToPage(
          _currentIndex,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 86,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.items.length,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
            },
            itemBuilder: (context, index) {
              final item = widget.items[index];
              return _ContextCard(item: item);
            },
          ),
        ),

        const SizedBox(height: 10),

        /// Navigation dots (centered, dynamic)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.items.length,
                (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentIndex == index ? 10 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: _currentIndex == index
                    ? Colors.teal
                    : Colors.teal.withOpacity(0.3),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
class _ContextCard extends StatelessWidget {
  final ContextStripItem item;

  const _ContextCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: item.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [
                item.color.withOpacity(0.10),
                item.color.withOpacity(0.04),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          child: Row(
            children: [
              Icon(
                item.icon,
                color: item.color,
                size: 26,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
