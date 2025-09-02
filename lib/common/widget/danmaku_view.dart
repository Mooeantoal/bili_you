import 'package:flutter/material.dart';
import 'package:flutter_barrage/flutter_barrage.dart';

class DanmakuView extends StatelessWidget {
  final String? cid;
  final double fontSize;
  final double opacity;
  final double showArea;

  const DanmakuView({
    super.key,
    this.cid,
    this.fontSize = 16,
    this.opacity = 1.0,
    this.showArea = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: BarrageView(
          cid: cid,
          fontSize: fontSize,
          opacity: opacity,
          showArea: showArea,
        ),
      ),
    );
  }
}
