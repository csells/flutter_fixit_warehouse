import 'package:flutter/material.dart';

class GtButton extends StatelessWidget {
  const GtButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.backgroundColor = Colors.green,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) => ElevatedButton(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      disabledBackgroundColor: Colors.grey,
      backgroundColor: backgroundColor,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    ),
    child: child,
  );
}
