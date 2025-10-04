import 'package:flutter/material.dart';
import 'package:bili_you/common/api/search_api.dart';
import 'package:bili_you/common/models/local/search/hot_word_item.dart';

class HotSearchTestPage extends StatefulWidget {
  const HotSearchTestPage({Key? key}) : super(key: key);

  @override
  State<HotSearchTestPage> createState() => _HotSearchTestPageState();
}

class _HotSearchTestPageState extends State<HotSearchTestPage> {
  List<HotWordItem> hotWords = [];
  bool isLoading = false;
  String errorMessage = '';

  Future<void> loadHotWords() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final words = await SearchApi.getHotWords();
      setState(() {
        hotWords = words;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadHotWords();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('热搜测试'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: loadHotWords,
              child: const Text('刷新热搜'),
            ),
            const SizedBox(height: 16),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (errorMessage.isNotEmpty)
              Text(errorMessage, style: const TextStyle(color: Colors.red))
            else if (hotWords.isEmpty)
              const Text('暂无热搜数据')
            else
              Expanded(
                child: ListView.builder(
                  itemCount: hotWords.length,
                  itemBuilder: (context, index) {
                    final word = hotWords[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        title: Text(word.showWord),
                        subtitle: Text(word.keyWord),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}