import 'package:flutter/material.dart';
import '../common/api/danmu_api.dart';

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
  final _controller = TextEditingController();
  final _service = BiliDanmuService();
  bool _sending = false;

  Future<void> _sendDanmu() async {
    if (_controller.text.isEmpty || widget.cid == null) return;

    setState(() => _sending = true);

    try {
      await _service.postDanmu(
        mid: 123456, // TODO: 替换为当前用户ID
        cid: int.parse(widget.cid!),
        playTime: 10.0, // TODO: 替换为当前播放进度
        color: 0xffffff,
        msg: _controller.text,
        fontSize: widget.fontSize.toInt(),
        mode: 1, // 1=滚动
        accessKey: "你的AccessKey", // TODO: 替换为登录token
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("弹幕发送成功")),
      );
      _controller.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("发送失败: $e")),
      );
    } finally {
      setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(
            color: Colors.black,
            child: Center(
              child: Text(
                '弹幕区域 (CID: ${widget.cid})',
                style: TextStyle(
                  color: Colors.white.withOpacity(widget.opacity),
                  fontSize: widget.fontSize,
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: "输入弹幕内容",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _sending ? null : _sendDanmu,
                child: _sending
                    ? const CircularProgressIndicator()
                    : const Text("发送"),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
