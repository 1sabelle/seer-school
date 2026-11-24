import 'package:flutter/material.dart';

/// Holds a page to a comfortable width, centred over the sky, so it doesn't
/// stretch across wide screens. On a phone it changes nothing.
class PageColumn extends StatelessWidget {
  static const maxWidth = 800.0;

  final Widget child;

  const PageColumn({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
