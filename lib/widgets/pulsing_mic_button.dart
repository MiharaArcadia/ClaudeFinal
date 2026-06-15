import 'package:flutter/material.dart';
import 'package:nutri_voice/theme/app_theme.dart';

class PulsingMicButton extends StatefulWidget {
  final bool listening;
  final VoidCallback onPressed;

  const PulsingMicButton({
    super.key,
    required this.listening,
    required this.onPressed,
  });

  @override
  State<PulsingMicButton> createState() => _PulsingMicButtonState();
}

class _PulsingMicButtonState extends State<PulsingMicButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _scale = Tween(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(PulsingMicButton old) {
    super.didUpdateWidget(old);
    if (widget.listening && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.listening) {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scale,
      builder: (_, child) {
        return Transform.scale(
          scale: widget.listening ? _scale.value : 1.0,
          child: child,
        );
      },
      child: GestureDetector(
        onTap: widget.onPressed,
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [AppColors.orange, AppColors.pink],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: widget.listening
                ? [
                    BoxShadow(
                      color: AppColors.orange.withOpacity(0.5),
                      blurRadius: 20,
                      spreadRadius: 4,
                    )
                  ]
                : [],
          ),
          child: Icon(
            widget.listening ? Icons.stop : Icons.mic,
            color: Colors.white,
            size: 30,
          ),
        ),
      ),
    );
  }
}
