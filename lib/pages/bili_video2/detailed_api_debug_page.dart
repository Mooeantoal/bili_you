import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'dart:convert';

class DetailedApiDebugPage extends StatefulWidget {
  const DetailedApiDebugPage({super.key});

  @override
  State<DetailedApiDebugPage> createState() => _DetailedApiDebugPageState();
}

class _DetailedApiDebugPageState extends State<DetailedApiDebugPage> {
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

  Future<void> _testApiComprehensive() async {
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

    _updateDebugInfo('开始综合API诊断测试');
    _updateDebugInfo('BV号: $bvid, CID: $cid');

    // 测试不同的fnval值
    final fnvalTests = [
      {'name': '全部格式', 'value': 4056}, // all
      {'name': 'DASH格式', 'value': 16},
      {'name': 'MP4格式', 'value': 1},
      {'name': 'DURL格式', 'value': 8},
      {'name': 'FLV格式', 'value': 4},
    ];

    for (var test in fnvalTests) {
      await _testFnval(bvid, cid, test['name'] as String, test['value'] as int);
    }

    setState(() {
      _isLoading = false;
    });
    
    _updateDebugInfo('综合诊断测试完成');
  }

  Future<void> _testFnval(String bvid, int cid, String formatName, int fnval) async {
    _updateDebugInfo('--- 测试格式: $formatName (fnval: $fnval) ---');
    
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
      
      final params = {
        'bvid': bvid,
        'cid': cid,
        'fnver': 0,
        'fnval': fnval,
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
      };
      
      _updateDebugInfo('请求参数: $params');
      
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
          _updateDebugInfo('播放数据结构分析:');
          
          // 分析数据结构
          _analyzeDataStructure(playData);
          
          // 检查各种可能的流格式
          _checkStreamFormats(playData);
        } else {
          _updateDebugInfo('API返回错误数据: ${data['message']}');
        }
      } else {
        _updateDebugInfo('HTTP请求失败: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      _updateDebugInfo('测试失败: $e');
      _updateDebugInfo('堆栈: $stackTrace');
    }
    
    // 添加延迟避免请求过于频繁
    await Future.delayed(const Duration(seconds: 1));
  }

  void _analyzeDataStructure(Map<String, dynamic> data) {
    _updateDebugInfo('  主要字段:');
    data.forEach((key, value) {
      if (value is Map) {
        _updateDebugInfo('    $key: [对象]');
      } else if (value is List) {
        _updateDebugInfo('    $key: [列表, 长度: ${value.length}]');
      } else {
        _updateDebugInfo('    $key: $value');
      }
    });
  }

  void _checkStreamFormats(Map<String, dynamic> playData) {
    // 检查DASH流
    if (playData['dash'] != null) {
      final dash = playData['dash'];
      _updateDebugInfo('  DASH流信息:');
      if (dash is Map) {
        final videoCount = (dash['video'] as List?)?.length ?? 0;
        final audioCount = (dash['audio'] as List?)?.length ?? 0;
        _updateDebugInfo('    视频流数量: $videoCount');
        _updateDebugInfo('    音频流数量: $audioCount');
        
        if (videoCount > 0) {
          _updateDebugInfo('    视频流详情:');
          final videos = dash['video'] as List;
          for (int i = 0; i < videos.length && i < 3; i++) {
            final video = videos[i];
            if (video is Map) {
              _updateDebugInfo('      流 $i: ID=${video['id']}, 编码=${video['codecs']}, 带宽=${video['bandwidth']}');
              _updateDebugInfo('        URL: ${video['baseUrl']}');
            }
          }
        }
      }
    } else {
      _updateDebugInfo('  无DASH流');
    }
    
    // 检查DURL流
    if (playData['durl'] != null) {
      final durlList = playData['durl'];
      _updateDebugInfo('  DURL流信息:');
      if (durlList is List) {
        _updateDebugInfo('    DURL流数量: ${durlList.length}');
        if (durlList.isNotEmpty) {
          final firstDurl = durlList[0];
          if (firstDurl is Map) {
            _updateDebugInfo('    第一个DURL:');
            _updateDebugInfo('      URL: ${firstDurl['url']}');
            _updateDebugInfo('      长度: ${firstDurl['length']}');
            _updateDebugInfo('      大小: ${firstDurl['size']}');
          }
        }
      }
    } else {
      _updateDebugInfo('  无DURL流');
    }
    
    // 检查其他可能的流格式
    if (playData['flv'] != null) {
      _updateDebugInfo('  FLV流信息: ${playData['flv']}');
    } else {
      _updateDebugInfo('  无FLV流');
    }
    
    if (playData['mp4'] != null) {
      _updateDebugInfo('  MP4流信息: ${playData['mp4']}');
    } else {
      _updateDebugInfo('  无MP4流');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('详细API诊断'),
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
              onPressed: _isLoading ? null : _testApiComprehensive,
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
                  : const Text('开始综合诊断'),
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