import "dart:math" as math;

import "package:flutter/material.dart";

/// The Lueur mark: an open ring with a bright point. Decorative, so it is
/// hidden from screen readers; it only turns when animations are allowed.
class LueurLogo extends StatefulWidget {
  const LueurLogo({super.key, this.size = 72});

  final double size;

  @override
  State<LueurLogo> createState() => _LueurLogoState();
}

class _LueurLogoState extends State<LueurLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 8),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ExcludeSemantics(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Transform.rotate(
          angle: _controller.value * math.pi * 2,
          child: child,
        ),
        child: CustomPaint(
          size: Size.square(widget.size),
          painter: _LogoPainter(ring: scheme.primary, dot: scheme.onSurface),
        ),
      ),
    );
  }
}

class _LogoPainter extends CustomPainter {
  const _LogoPainter({required this.ring, required this.dot});

  final Color ring;
  final Color dot;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;
    canvas.drawCircle(
      center,
      radius * .68,
      Paint()
        ..color = ring.withValues(alpha: .2)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, size.width * .18),
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * .68),
      -.7,
      math.pi * 1.75,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * .085
        ..strokeCap = StrokeCap.round
        ..color = ring,
    );
    canvas.drawCircle(center, radius * .14, Paint()..color = dot);
  }

  @override
  bool shouldRepaint(_LogoPainter old) => old.ring != ring || old.dot != dot;
}
