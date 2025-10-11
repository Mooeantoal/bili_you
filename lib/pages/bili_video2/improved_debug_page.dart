import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'dart:math';
import 'package:flutter/services.dart';
import 'dart:convert';

class ImprovedDebugPage extends StatefulWidget {
  const ImprovedDebugPage({super.key});

  @override
  State<ImprovedDebugPage> createState() => _ImprovedDebugPageState();
}

class _ImprovedDebugPageState extends State<ImprovedDebugPage> {
  final TextEditingController _bvidController = TextEditingController();
  final TextEditingController _cidController = TextEditingController();
  final TextEditingController _accessKeyController = TextEditingController();
  bool _isLoading = false;
  String _debugInfo = '';

  @override
  void initState() {
    super.initState();
    _bvidController.text = 'BV1joHwzBEJK';
    _cidController.text = '1326404780';
    _accessKeyController.text = ''; // 在此处填入有效的access_key（如果有的话）
  }

  void _updateDebugInfo(String info) {
    setState(() {
      _debugInfo += '[$currentTime] $info\n';
    });
  }

  String get currentTime {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
  }

  Future<void> _testImprovedScenario() async {
    setState(() {
      _isLoading = true;
      _debugInfo = '';
    });

    final bvid = _bvidController.text.trim();
    final cid = int.tryParse(_cidController.text.trim()) ?? 0;
    final accessKey = _accessKeyController.text.trim();

    if (bvid.isEmpty || cid == 0) {
      _updateDebugInfo('错误: BV号或CID不能为空');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    _updateDebugInfo('开始改进的诊断测试');
    _updateDebugInfo('BV号: $bvid, CID: $cid');
    if (accessKey.isNotEmpty) {
      _updateDebugInfo('Access Key: $accessKey');
    }

    // 测试场景: 改进的完整参数
    final random = Random();
    final timestamp = (DateTime.now().millisecondsSinceEpoch / 1000).floor();
    
    await _testScenario('改进的完整参数', bvid, cid, accessKey, {
      'bvid': bvid,
      'cid': cid,
      'fnver': 0,
      'fnval': 4048,
      'fourk': 1,
      'force_host': 2,
      'try_look': 1,
      'voice_balance': 1,
      'gaia_source': 'pre-load',
      'isGaiaAvoided': true,
      'web_location': 1315873,
      'qn': 120,
      'otype': 'json',
      'platform': 'html5',
      'buvid': 'XY118B45D008F4831277844288FC1F2061F4C',
      'device_type': 1,
      'device_id': 'D3A356A5-CD69-4075-9DA0-584614347DB0',
      'build': 66666,
      'device_name': 'iPhone 14',
      'device_model': 'iPhone 14',
      'device_os': '16.5',
      'device_platform': 'iPhone',
      'device_brand': 'Apple',
      'device_version': '16.5',
      'device_screen': '390x844',
      'abtest': '819588',
      'ts': timestamp,
      'random': random.nextInt(1000000),
      if (accessKey.isNotEmpty) 'access_key': accessKey,
    });

    setState(() {
      _isLoading = false;
    });
    
    _updateDebugInfo('诊断测试完成');
  }

  Future<void> _testScenario(String scenarioName, String bvid, int cid, String accessKey, Map<String, dynamic> params) async {
    _updateDebugInfo('--- 测试场景: $scenarioName ---');
    
    try {
      final dio = Dio();
      dio.interceptors.add(LogInterceptor(responseBody: false, requestBody: true));
      
      final headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36',
        'Referer': 'https://www.bilibili.com/video/$bvid/',
        'Accept': '*/*',
        'Accept-Encoding': 'gzip, deflate, br',
        'Accept-Language': 'en-US,en;q=0.9',
        if (accessKey.isNotEmpty) 'Cookie': 'access_key=$accessKey',
      };
      
      _updateDebugInfo('请求参数: $params');
      _updateDebugInfo('请求头部: $headers');
      
      final response = await dio.get(
        'https://api.bilibili.com/x/player/playurl',
        queryParameters: params,
        options: Options(
          headers: headers,
          responseType: ResponseType.plain, // 使用plain类型以避免格式化错误
        ),
      );
      
      _updateDebugInfo('响应状态码: ${response.statusCode}');
      _updateDebugInfo('响应头部: ${response.headers}');
      
      // 尝试解析响应
      try {
        // 首先尝试直接解析
        final data = response.data;
        _updateDebugInfo('原始响应数据: $data');
        
        // 如果是字符串，尝试解析为JSON
        if (data is String) {
          // 移除可能的非标准字符
          final cleanData = data.replaceAll(RegExp(r'^[^\{]*'), '').replaceAll(RegExp(r'[^\}]*$'), '');
          if (cleanData.isNotEmpty) {
            final jsonResult = json.decode(cleanData);
            _updateDebugInfo('解析后的JSON: $jsonResult');
            
            if (jsonResult is Map && jsonResult['code'] != null) {
              _updateDebugInfo('API代码: ${jsonResult['code']}, 消息: ${jsonResult['message']}');
            }
          } else {
            _updateDebugInfo('无法解析响应数据');
          }
        }
      } catch (parseError) {
        _updateDebugInfo('解析响应失败: $parseError');
        _updateDebugInfo('原始响应长度: ${response.data?.length ?? 0}');
        // 显示响应的前200个字符用于调试
        if (response.data is String && (response.data as String).length > 0) {
          final preview = (response.data as String).substring(0, min(200, (response.data as String).length));
          _updateDebugInfo('响应预览: $preview');
        }
      }
    } catch (e, stackTrace) {
      _updateDebugInfo('测试失败: $e');
      _updateDebugInfo('堆栈: $stackTrace');
    }
  }

  // 添加复制日志到剪贴板的方法
  void _copyLogToClipboard() {
    Clipboard.setData(ClipboardData(text: _debugInfo));
    Get.snackbar('提示', '日志已复制到剪贴板');
  }

  // 添加清空日志的方法
  void _clearLog() {
    setState(() {
      _debugInfo = '';
    });
    Get.snackbar('提示', '日志已清空');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('改进的视频调试'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _bvidController,
              decoration: const InputDecoration(
                labelText: 'BV号',
                hintText: '例如: BV1joHwzBEJK',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _cidController,
              decoration: const InputDecoration(
                labelText: 'CID',
                hintText: '例如: 1326404780',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _accessKeyController,
              decoration: const InputDecoration(
                labelText: 'Access Key (可选)',
                hintText: '如果有的话，请填入access_key',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _testImprovedScenario,
              child: _isLoading
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 10),
                        Text('测试中...'),
                      ],
                    )
                  : const Text('开始改进诊断'),
            ),
            const SizedBox(height: 16),
            // 添加复制日志和清空日志按钮
            Row(
              children: [
                ElevatedButton(
                  onPressed: _debugInfo.isEmpty ? null : _copyLogToClipboard,
                  child: const Text('复制日志'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _clearLog,
                  child: const Text('清空日志'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(8),
                child: SingleChildScrollView(
                  child: SelectableText(
                    _debugInfo,
                    style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}