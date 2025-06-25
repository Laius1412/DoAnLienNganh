import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';

class FloatingBubblesManager {
  static OverlayEntry? _overlayEntry;
  static Offset _position = Offset(20, 100);

  static void show(BuildContext context) {
    if (_overlayEntry != null) return;

    final size = MediaQuery.of(context).size;
    _position = Offset(
      _position.dx.clamp(0.0, size.width - 56),
      _position.dy.clamp(0.0, size.height - 122),
    );

    _overlayEntry = OverlayEntry(
      builder:
          (context) => Positioned(
            left: _position.dx,
            top: _position.dy,
            child: Draggable(
              feedback: _buildBubbles(),
              child: _buildBubbles(),
              childWhenDragging: SizedBox.shrink(),
              onDragEnd: (details) {
                _position = details.offset;
                hide();
                show(context);
              },
            ),
          ),
    );

    Overlay.of(context, rootOverlay: true).insert(_overlayEntry!);
  }

  static void hide() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  static Widget _buildBubbles() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ShakingWidget(
          child: CircleIconButton(
            color: Colors.deepPurple,
            icon: Icons.support_agent_rounded,
            heroTag: "chat",
            onPressed: () {
              print("Đi tới Chatbot");
            },
          ),
        ),
        SizedBox(height: 10),
        ShakingWidget(
          child: CircleIconButton(
            color: Colors.green,
            icon: Icons.call_end_rounded,
            heroTag: "call",
            onPressed: () async {
              await FlutterPhoneDirectCaller.callNumber("0838541528");
            },
          ),
        ),
      ],
    );
  }
}

class ShakingWidget extends StatefulWidget {
  final Widget child;
  const ShakingWidget({required this.child, Key? key}) : super(key: key);

  @override
  State<ShakingWidget> createState() => _ShakingWidgetState();
}

class _ShakingWidgetState extends State<ShakingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _animation = Tween<double>(
      begin: -2,
      end: 2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticIn));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_animation.value, 0),
          child: widget.child,
        );
      },
    );
  }
}

class CircleIconButton extends StatelessWidget {
  final Color color;
  final IconData icon;
  final VoidCallback onPressed;
  final String heroTag;

  const CircleIconButton({
    required this.color,
    required this.icon,
    required this.onPressed,
    required this.heroTag,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      shape: const CircleBorder(),
      elevation: 6,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: 56,
          height: 56,
          child: Center(child: Icon(icon, color: Colors.white)),
        ),
      ),
    );
  }
}
