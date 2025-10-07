import 'package:bili_you/pages/search_test/controller.dart';
import 'package:bili_you/pages/search_test/models.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FullTrendingPage extends StatefulWidget {
  const FullTrendingPage({super.key});

  @override
  State<FullTrendingPage> createState() => _FullTrendingPageState();
}

class _FullTrendingPageState extends State<FullTrendingPage> {
  late final SearchTestController _controller = Get.find();
  SearchTrendingData? _trendingData;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await _controller.getFullTrendingList();
    if (mounted) {
      setState(() {
        _trendingData = data;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('bilibili热搜'),
        centerTitle: false,
      ),
      body: _trendingData == null
          ? const Center(child: CircularProgressIndicator())
          : _buildList(),
    );
  }

  Widget _buildList() {
    final list = _trendingData!.list;
    if (list == null || list.isEmpty) {
      return const Center(child: Text('暂无数据'));
    }

    return ListView.separated(
      itemCount: list.length,
      separatorBuilder: (context, index) => Divider(
        height: 1,
        indent: 56,
        color: Theme.of(context).dividerColor.withOpacity(0.1),
      ),
      itemBuilder: (context, index) {
        final item = list[index];
        return ListTile(
          dense: true,
          onTap: () {
            _controller.onClickKeyword(item.keyword ?? '');
            Navigator.of(context).pop(); // 返回搜索页面
          },
          leading: index < 3
              ? Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: index == 0
                        ? const Color(0xFFd1403e)
                        : index == 1
                            ? const Color(0xFFfdad13)
                            : const Color(0xFF8aace1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
              : Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.outline,
                    fontSize: 17,
                    fontStyle: FontStyle.italic,
                  ),
                ),
          title: Row(
            children: [
              Flexible(
                child: Text(
                  item.keyword ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  strutStyle: const StrutStyle(height: 1, leading: 0),
                  style: const TextStyle(height: 1, fontSize: 15),
                ),
              ),
              if (item.icon?.isNotEmpty == true) ...[
                const SizedBox(width: 4),
                Image.network(
                  item.icon!,
                  height: 16,
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox.shrink();
                  },
                ),
              ] else if (item.showLiveIcon == true) ...[
                const SizedBox(width: 4),
                Image.asset(
                  'assets/images/live/live.gif',
                  width: 51,
                  height: 16,
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}