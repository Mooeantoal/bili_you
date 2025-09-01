import 'package:bili_you/common/utils/string_format_utils.dart';
import 'package:bili_you/common/values/hero_tag_id.dart';
import 'package:bili_you/common/widget/simple_easy_refresher.dart';
import 'package:bili_you/common/widgets/piliplus_video_card.dart';
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
              TextButton(
                onPressed: controller.onRefresh,
                child: const Text('点击刷新'),
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
            return PiliPlusVideoCard(
              key: ValueKey("${i.bvid}:PiliPlusVideoCard"),
              item: i,
              heroTag: 'recommend_${i.bvid}',
              onTap: () {
                Get.toNamed(
                  '/video?bvid=${i.bvid}&cid=${i.cid}',
                  arguments: {
                    'videoItem': i,
                    'heroTag': 'recommend_${i.bvid}',
                  },
                );
              },
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
