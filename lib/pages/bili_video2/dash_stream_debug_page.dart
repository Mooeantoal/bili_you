import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class DashStreamDebugPage extends StatefulWidget {
  const DashStreamDebugPage({super.key});

  @override
  State<DashStreamDebugPage> createState() => _DashStreamDebugPageState();
}

class _DashStreamDebugPageState extends State<DashStreamDebugPage> {
  final TextEditingController _bvidController = TextEditingController();
  final TextEditingController _cidController = TextEditingController();
  bool _isLoading = false;
  String _debugInfo = '';
  Map<String, dynamic>? _apiResponse;

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

  Future<void> _testAllFormats() async {
    setState(() {
      _isLoading = true;
      _debugInfo = '';
      _apiResponse = null;
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

    _updateDebugInfo('开始DASH流诊断测试');
    _updateDebugInfo('BV号: $bvid, CID: $cid');

    // 测试所有格式
    await _testFormat(bvid, cid, '全部格式', 4060);
    
    // 测试DASH格式
    await _testFormat(bvid, cid, 'DASH格式', 16);
    
    // 测试DURL格式
    await _testFormat(bvid, cid, 'DURL格式', 8);
    
    // 测试FLV格式
    await _testFormat(bvid, cid, 'FLV格式', 4);
    
    // 测试MP4格式
    await _testFormat(bvid, cid, 'MP4格式', 1);

    setState(() {
      _isLoading = false;
    });
    
    _updateDebugInfo('DASH流诊断测试完成');
  }

  Future<void> _testFormat(String bvid, int cid, String formatName, int fnval) async {
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
          
          // 保存API响应用于详细分析
          if (formatName == 'DASH格式') {
            setState(() {
              _apiResponse = playData;
            });
          }
          
          // 分析数据结构
          _analyzePlayData(playData, formatName);
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
    
    await Future.delayed(const Duration(milliseconds: 500));
  }

  void _analyzePlayData(Map<String, dynamic> playData, String formatName) {
    _updateDebugInfo('  $formatName 数据结构分析:');
    
    // 显示主要字段
    playData.forEach((key, value) {
      if (value is Map) {
        _updateDebugInfo('    $key: [对象]');
      } else if (value is List) {
        _updateDebugInfo('    $key: [列表, 长度: ${value.length}]');
      } else {
        _updateDebugInfo('    $key: $value');
      }
    });
    
    // 特别检查DASH字段
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
    
    // 特别检查DURL字段
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
  }

  void _showDetailedResponse() {
    if (_apiResponse == null) {
      Get.snackbar('提示', '请先运行测试获取API响应数据');
      return;
    }
    
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '详细API响应',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    JsonEncoder.withIndent('  ').convert(_apiResponse),
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('关闭'),
              ),
            ],
          ),
        );
      },
    );
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
        title: const Text('DASH流诊断'),
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
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _testAllFormats,
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
                        : const Text('开始诊断'),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _apiResponse == null ? null : _showDetailedResponse,
                  child: const Text('查看详细响应'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // 添加复制日志按钮
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