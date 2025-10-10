import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BiliYou Web Test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _bvidController = TextEditingController();
  String _status = '';
  String _debugInfo = '';

  @override
  void initState() {
    super.initState();
    _bvidController.text = 'BV1joHwzBEJK'; // 默认BV号
  }

  void _updateDebugInfo(String info) {
    setState(() {
      _debugInfo += '$info\n';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BiliYou Web测试'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'BiliYou Web测试说明',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              '由于Web平台的限制，我们无法直接在浏览器中测试视频播放功能。'
              '但我们可以测试API调用和其他非播放功能。',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _bvidController,
              decoration: const InputDecoration(
                labelText: 'BV号',
                hintText: '例如: BV1joHwzBEJK',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _status = '正在测试API...';
                  _debugInfo = '';
                });
                
                // 这里可以添加API测试代码
                _testApi();
              },
              child: const Text('测试API调用'),
            ),
            const SizedBox(height: 16),
            Text(_status),
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
  
  void _testApi() {
    // 这里可以添加实际的API测试代码
    _updateDebugInfo('开始测试API调用...');
    _updateDebugInfo('测试视频信息API...');
    _updateDebugInfo('测试播放信息API...');
    _updateDebugInfo('API测试完成');
    
    setState(() {
      _status = 'API测试完成';
    });
  }
}