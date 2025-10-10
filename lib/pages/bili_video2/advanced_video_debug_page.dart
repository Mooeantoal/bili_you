import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'dart:math';

class AdvancedVideoDebugPage extends StatefulWidget {
  const AdvancedVideoDebugPage({super.key});

  @override
  State<AdvancedVideoDebugPage> createState() => _AdvancedVideoDebugPageState();
}

class _AdvancedVideoDebugPageState extends State<AdvancedVideoDebugPage> {
  final TextEditingController _bvidController = TextEditingController();
  final TextEditingController _cidController = TextEditingController();
  bool _isLoading = false;
  String _debugInfo = '';

  @override
  void initState() {
    super.initState();
    _bvidController.text = 'BV1joHwzBEJK';
    _cidController.text = '1326404780';
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

  Future<void> _testAllScenarios() async {
    setState(() {
      _isLoading = true;
      _debugInfo = '';
    });

    final bvid = _bvidController.text.trim();
    final cid = int.tryParse(_cidController.text.trim()) ?? 0;

    if (bvid.isEmpty || cid == 0) {
      _updateDebugInfo('错误: BV号或CID不能为空');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    _updateDebugInfo('开始全面诊断测试');
    _updateDebugInfo('BV号: $bvid, CID: $cid');

    // 测试场景1: 基础请求
    await _testScenario('基础请求', bvid, cid, {
      'bvid': bvid,
      'cid': cid,
      'fnver': 0,
      'fnval': 16,
      'fourk': 1,
    });

    // 测试场景2: 添加force_host
    await _testScenario('添加force_host', bvid, cid, {
      'bvid': bvid,
      'cid': cid,
      'fnver': 0,
      'fnval': 16,
      'fourk': 1,
      'force_host': 2,
    });

    // 测试场景3: 添加try_look
    await _testScenario('添加try_look', bvid, cid, {
      'bvid': bvid,
      'cid': cid,
      'fnver': 0,
      'fnval': 16,
      'fourk': 1,
      'force_host': 2,
      'try_look': 1,
    });

    // 测试场景4: 完整参数
    final random = Random();
    final timestamp = (DateTime.now().millisecondsSinceEpoch / 1000).floor();
    
    await _testScenario('完整参数', bvid, cid, {
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
    });

    setState(() {
      _isLoading = false;
    });
    
    _updateDebugInfo('诊断测试完成');
  }

  Future<void> _testScenario(String scenarioName, String bvid, int cid, Map<String, dynamic> params) async {
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
      };
      
      _updateDebugInfo('请求参数: $params');
      _updateDebugInfo('请求头部: $headers');
      
      final response = await dio.get(
        'https://api.bilibili.com/x/player/playurl',
        queryParameters: params,
        options: Options(headers: headers),
      );
      
      _updateDebugInfo('响应状态码: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = response.data;
        _updateDebugInfo('API代码: ${data['code']}, 消息: ${data['message']}');
        
        if (data['code'] == 0 && data['data'] != null) {
          final playData = data['data'];
          
          // 检查各种流格式
          if (playData['dash'] != null) {
            final dash = playData['dash'];
            final videoCount = (dash['video'] as List?)?.length ?? 0;
            final audioCount = (dash['audio'] as List?)?.length ?? 0;
            _updateDebugInfo('DASH流 - 视频: $videoCount, 音频: $audioCount');
          }
          
          if (playData['durl'] != null) {
            final durlCount = (playData['durl'] as List?)?.length ?? 0;
            _updateDebugInfo('DURL流 - 数量: $durlCount');
          }
          
          if (playData['flv'] != null) {
            final flvCount = (playData['flv'] as List?)?.length ?? 0;
            _updateDebugInfo('FLV流 - 数量: $flvCount');
          }
        } else {
          _updateDebugInfo('API返回错误数据');
        }
      } else {
        _updateDebugInfo('HTTP请求失败');
      }
    } catch (e, stackTrace) {
      _updateDebugInfo('测试失败: $e');
      _updateDebugInfo('堆栈: $stackTrace');
    }
    
    // 添加延迟避免请求过于频繁
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('高级视频调试'),
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
            ElevatedButton(
              onPressed: _isLoading ? null : _testAllScenarios,
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
                  : const Text('开始全面诊断'),
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
                  child: Text(
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