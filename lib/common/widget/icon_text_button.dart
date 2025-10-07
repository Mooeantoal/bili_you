import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

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
            ? WidgetStateProperty.all(Theme.of(context).colorScheme.onPrimary)
            : null,
        backgroundColor: selected
            ? WidgetStateProperty.all(Theme.of(context).colorScheme.primary)
            : null,
        elevation: WidgetStateProperty.all(0),
        padding: WidgetStateProperty.all(
            const EdgeInsets.only(left: 10, right: 10, bottom: 0, top: 0)),
        minimumSize: WidgetStateProperty.all(const Size(10, 10)),
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