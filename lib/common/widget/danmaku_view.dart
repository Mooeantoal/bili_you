import 'package:flutter/material.dart';
import '../common/api/danmu_api.dart'; // 引用 API

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
  bool _sending = false;
  List<String> _danmakuList = []; // 用于存储弹幕内容

  // 弹幕发送请求
  Future<void> _sendDanmu() async {
    if (_controller.text.isEmpty || widget.cid == null) return;

    setState(() => _sending = true);

    try {
      await DanmakuApi.requestDanmaku(
        cid: int.parse(widget.cid!),
        segmentIndex: 1, // TODO: 根据视频分段获取正确的 segmentIndex
      );

      // 假设成功发送弹幕后，将其添加到本地弹幕列表
      setState(() {
        _danmakuList.add(_controller.text);
      });

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
              child: Stack(
                children: _danmakuList.map((danmu) {
                  return Positioned(
                    left: 0,
                    right: 0,
                    top: (40.0 * _danmakuList.indexOf(danmu)).toDouble(),
                    child: Text(
                      danmu,
                      style: TextStyle(
                        color: Colors.white.withOpacity(widget.opacity),
                        fontSize: widget.fontSize,
                      ),
                    ),
                  );
                }).toList(),
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
