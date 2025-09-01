import 'package:bili_you/common/utils/string_format_utils.dart';
import 'package:bili_you/common/values/hero_tag_id.dart';
import 'package:bili_you/common/widget/simple_easy_refresher.dart';
import 'package:bili_you/common/widgets/bili_video_card.dart';
import 'package:bili_you/common/api/home_api.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'index.dart';

class RecommendPage extends StatefulWidget {
  const RecommendPage({Key? key}) : super(key: key);

  @override
  State<RecommendPage> createState() => _RecommendPageState();
}

class _RecommendPageState extends State<RecommendPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  late RecommendController controller;
  @override
  void initState() {
    controller = Get.put(RecommendController());
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  // 主视图
  Widget _buildView(BuildContext context) {
    return Obx(() {
      if (controller.recommendItems.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.video_library, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                '暂无推荐视频',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Column(
                children: [
                  TextButton(
                    onPressed: controller.onRefresh,
                    child: const Text('点击刷新'),
                  ),
                  TextButton(
                    onPressed: () async {
                      try {
                        final testItems = await HomeApi.getRecommendVideoItems(
                          num: 5, 
                          refreshIdx: 0
                        );
                        print('测试加载成功，获取到${testItems.length}条数据');
                        if (testItems.isNotEmpty) {
                          print('第一条数据标题: ${testItems.first.title}');
                        }
                      } catch (e) {
                        print('测试加载失败: $e');
                      }
                    },
                    child: const Text('测试API'),
                  ),
                ],
              ),
            ],
          ),
        );
      }
      
      return SimpleEasyRefresher(
        easyRefreshController: controller.refreshController,
        onLoad: controller.onLoad,
        onRefresh: controller.onRefresh,
        childBuilder: (context, physics) => GridView.builder(
          controller: controller.scrollController,
          physics: physics,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              crossAxisCount: controller.recommendColumnCount,
              mainAxisExtent: (MediaQuery.of(context).size.width /
                          controller.recommendColumnCount) *
                      9 /
                      16 +
                  70 * MediaQuery.of(context).textScaleFactor),
          itemCount: controller.recommendItems.length,
          itemBuilder: (context, index) {
            var i = controller.recommendItems[index];
            return BiliVideoCard(
              key: ValueKey("${i.bvid}:BiliVideoCard"),
              item: i,
              width: (MediaQuery.of(context).size.width - 24) / 2,
            );
          },
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _buildView(context);
  }
}
