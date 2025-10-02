import 'package:flutter/material.dart';

class IconTextButton extends StatelessWidget {
  const IconTextButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.text,
    this.selected = false,
  });
  final Function()? onPressed;
  final Widget icon;
  final Text? text;

  ///是否被选上
  final bool selected;
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        visualDensity: VisualDensity.comfortable,
        foregroundColor: selected
            ? WidgetStatePropertyAll(Theme.of(context).colorScheme.onPrimary)
            : null,
        backgroundColor: selected
            ? WidgetStatePropertyAll(Theme.of(context).colorScheme.primary)
            : null,
        elevation: const WidgetStatePropertyAll(0),
        padding: const WidgetStatePropertyAll(
            EdgeInsets.only(left: 10, right: 10, bottom: 0, top: 0)),
        minimumSize: const WidgetStatePropertyAll(Size(10, 10)),
      ),
      onPressed: onPressed ?? () {},
      child: FittedBox(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [icon, if (text != null) text!],
        ),
      ),
    );
  }
}
