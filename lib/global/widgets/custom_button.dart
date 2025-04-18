import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    this.child,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.textButton = false,
  });

  final Widget? child;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool textButton;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(15),
        shadowColor: Colors.transparent,
        backgroundColor:
            textButton
                ? Colors.transparent
                : backgroundColor ?? Theme.of(context).colorScheme.primary,
        foregroundColor:
            textButton
                ? Theme.of(context).colorScheme.primary
                : foregroundColor ?? Theme.of(context).colorScheme.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide.none,
        ),
      ),
      child: child,
    );
  }
}
