import 'package:flutter/material.dart';

class CardSettingItem extends StatelessWidget {
  const CardSettingItem({
    super.key,
    required this.child,
    this.onTap,
    required this.selected,
  });
  final Widget child;
  final void Function()? onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side:
                selected
                    ? BorderSide(
                      width: 1,
                      color: Colors.grey.withAlpha((0.2 * 255).toInt()),
                    )
                    : BorderSide.none,
          ),
          margin: EdgeInsets.all(5),
          color:
              selected
                  ? Colors.transparent
                  : Colors.grey.withAlpha((0.2 * 255).toInt()),
          child: Padding(padding: EdgeInsets.all(15), child: child),
        ),
      ),
    );
  }
}
