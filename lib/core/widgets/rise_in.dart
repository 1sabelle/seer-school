import 'dart:async';

import 'package:flutter/material.dart';
import 'night_sky.dart';

/// belle.fyi's hero rise: fades in while moving up 12px, over a second,
/// after [delay]. Stagger the delays to bring a page in line by line.
class RiseIn extends StatefulWidget {
  final Duration delay;
  final Widget child;

  const RiseIn({super.key, this.delay = Duration.zero, required this.child});

  @override
  State<RiseIn> createState() => _RiseInState();
}

class _RiseInState extends State<RiseIn> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
  );
  late final Animation<double> _rise =
      CurvedAnimation(parent: _controller, curve: Curves.ease);
  Timer? _delayTimer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_controller.isDismissed || _delayTimer != null) return;
    if (!motionAllowed(context)) {
      _controller.value = 1;
    } else {
      _delayTimer = Timer(widget.delay, _controller.forward);
    }
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _rise,
      builder: (context, child) => Opacity(
        opacity: _rise.value,
        child: Transform.translate(
          offset: Offset(0, 12 * (1 - _rise.value)),
          child: child,
        ),
      ),
      child: widget.child,
    );
  }
}
