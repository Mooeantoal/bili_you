import 'package:flutter/material.dart';

class SearchSuggestItemWidget extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final EdgeInsetsGeometry? padding;

  const SearchSuggestItemWidget({
    super.key,
    required this.text,
    required this.onTap,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: padding ?? const EdgeInsets.only(left: 20, top: 9, bottom: 9),
          child: Text(
            text,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}