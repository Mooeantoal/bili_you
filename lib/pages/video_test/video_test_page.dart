import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bili_you/pages/bili_video2/bili_video_page_new.dart';
import 'package:bili_you/common/api/video_info_api.dart';
import 'package:bili_you/common/utils/bvid_avid_util.dart';

class VideoTestPage extends StatefulWidget {
  const VideoTestPage({Key? key}) : super(key: key);

  @override
  State<VideoTestPage> createState() => _VideoTestPageState();
}

class _VideoTestPageState extends State<VideoTestPage> {
  final TextEditingController _controller = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _navigateToVideo() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      
      String input = _controller.text.trim();
      
      // 解析输入的链接或BV号
      String videoId = _parseVideoId(input);
      
      if (videoId.isNotEmpty) {
        try {
          // 获取视频信息以获取cid
          var videoInfo = await VideoInfoApi.getVideoInfo(bvid: videoId);
          if (videoInfo.cid != 0) {
            // 跳转到新的视频播放页面
            Get.to(() => BiliVideoPageNew(
              bvid: videoId,
              cid: videoInfo.cid,
            ));
          } else {
            Get.snackbar('错误', '无法获取视频信息');
          }
        } catch (e) {
          Get.snackbar('错误', '获取视频信息失败: $e');
        }
      } else {
        Get.snackbar('错误', '无法解析视频链接或BV号');
      }
      
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _parseVideoId(String input) {
    // 处理BV号
    if (input.startsWith('BV') && input.length >= 12) {
      return input;
    }
    
    // 处理AV号
    if (input.startsWith('av') || input.startsWith('AV')) {
      // 对于AV号，转换为BV号
      String avid = input.substring(2);
      if (avid.isNotEmpty) {
        return BvidAvidUtil.av2Bvid(int.parse(avid));
      }
    }
    
    // 处理纯数字（AV号）
    if (RegExp(r'^\d+$').hasMatch(input)) {
      return BvidAvidUtil.av2Bvid(int.parse(input));
    }
    
    // 处理完整链接
    RegExp bvRegExp = RegExp(r'BV[A-Za-z0-9]+');
    RegExp avRegExp = RegExp(r'av(\d+)');
    
    if (bvRegExp.hasMatch(input)) {
      return bvRegExp.firstMatch(input)!.group(0)!;
    }
    
    if (avRegExp.hasMatch(input)) {
      String avid = avRegExp.firstMatch(input)!.group(1)!;
      return BvidAvidUtil.av2Bvid(int.parse(avid));
    }
    
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('视频测试'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                '请输入视频链接或BV号',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _controller,
                decoration: const InputDecoration(
                  labelText: '视频链接或BV号',
                  hintText: '例如：BV1GJ411x7h7 或 https://www.bilibili.com/video/BV1GJ411x7h7',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入视频链接或BV号';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isLoading ? null : _navigateToVideo,
                child: _isLoading 
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('跳转到视频'),
              ),
              const SizedBox(height: 16),
              const Text(
                '示例输入：\n'
                '• BV1GJ411x7h7\n'
                '• https://www.bilibili.com/video/BV1GJ411x7h7\n'
                '• av170001\n'
                '• https://www.bilibili.com/video/av170001',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}