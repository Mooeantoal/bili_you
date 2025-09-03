import 'package:flutter/material.dart';
import 'package:flutter_barrage/flutter_barrage.dart';

class DanmakuView extends StatefulWidget {
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
  State<DanmakuView> createState() => _DanmakuViewState();
}

class _DanmakuViewState extends State<DanmakuView> {
  late BarrageWallController _barrageWallController;

  @override
  void initState() {
    super.initState();
    _barrageWallController = BarrageWallController();
    // 这里可以先添加几条测试弹幕
    Future.delayed(Duration(seconds: 1), () {
      _barrageWallController.send([
        Bullet(child: _buildText("欢迎进入弹幕区")),
        Bullet(child: _buildText("CID: ${widget.cid ?? "未知"}")),
      ]);
    });
  }

  Text _buildText(String text) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white.withOpacity(widget.opacity),
        fontSize: widget.fontSize,
        shadows: const [
          Shadow(
            blurRadius: 2,
            color: Colors.black,
            offset: Offset(1, 1),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent, // 保持透明覆盖在播放器上
      child: BarrageWall(
        barrageWallController: _barrageWallController,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * widget.showArea,
      ),
    );
  }

  @override
  void dispose() {
    _barrageWallController.dispose();
    super.dispose();
  }
}
