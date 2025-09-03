import 'package:bili_you/common/api/danmaku_api.dart';
import 'package:bili_you/common/models/network/proto/danmaku/danmaku.pb.dart';

class SomePage extends StatefulWidget {
  @override
  State<SomePage> createState() => _SomePageState();
}

class _SomePageState extends State<SomePage> {
  DmSegMobileReply? _danmakuData;

  @override
  void initState() {
    super.initState();
    _loadDanmaku();
  }

  void _loadDanmaku() async {
    try {
      final data = await DanmakuApi.requestDanmaku(
        cid: 12345,
        segmentIndex: 0,
      );
      setState(() => _danmakuData = data);
    } catch (e) {
      debugPrint("加载弹幕失败：$e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return _danmakuData == null
        ? const Center(child: CircularProgressIndicator())
        : Text('已加载弹幕，数量：${_danmakuData!.elems.length}');
  }
}
