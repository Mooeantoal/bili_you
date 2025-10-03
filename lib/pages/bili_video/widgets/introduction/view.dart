import 'package:bili_you/common/utils/bvid_avid_util.dart';
import 'package:bili_you/common/utils/string_format_utils.dart';
import 'package:bili_you/common/values/hero_tag_id.dart';
import 'package:bili_you/common/widget/avatar.dart';
import 'package:bili_you/common/widget/foldable_text.dart';
import 'package:bili_you/common/widget/icon_text_button.dart';
import 'package:bili_you/common/widget/video_tile_item.dart';
import 'package:bili_you/pages/bili_video/view.dart';
import 'package:bili_you/pages/user_space/view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'index.dart';

class IntroductionPage extends StatefulWidget {
  const IntroductionPage(
      {super.key,
      required this.changePartCallback,
      this.refreshReply,
      required this.bvid,
      this.cid,
      this.ssid,
      this.isBangumi = false})
      : tag = "IntroductionPage:$bvid";
  final String bvid;
  final String tag;

  ///普通视频可以不用传入cid, 番剧必须传入
  final int? cid;

  ///番剧专用
  final int? ssid;

  ///是否是番剧
  final bool isBangumi;

  ///番剧必须要的刷新评论区回调
  final Function()? refreshReply;

  final Function(String bvid, int cid) changePartCallback;

  @override
  State<IntroductionPage> createState() => _IntroductionPageState();
}

class _IntroductionPageState extends State<IntroductionPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late IntroductionController controller;

  // 主视图
  Widget _buildView(BuildContext context, IntroductionController controller) {
    return ListView(
      addAutomaticKeepAlives: false,
      addRepaintBoundaries: false,
      controller: controller.scrollController,
      padding: const EdgeInsets.all(12),
      children: [
        //up主条项
        UpperTile(controller: controller),
        //文字信息
        IntroductionText(controller: controller),
        //TODO tags
        //操作按钮
        IntroductionOperationButtons(controller: controller),
        //分P按钮
        if (controller.partButtons.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: PartButtons(controller: controller),
          ),
        Divider(
          color: Theme.of(Get.context!).colorScheme.secondaryContainer,
          thickness: 1,
          height: 20,
        ),
        ListView.builder(
          addAutomaticKeepAlives: false,
          addRepaintBoundaries: false,
          padding: const EdgeInsets.all(0),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controller.relatedVideoInfos.length,
          itemBuilder: (context, index) {
            var i = controller.relatedVideoInfos[index];
            var heroTagId = HeroTagId.id++;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: VideoTileItem.fromVideoTileInfo(i,
                  cacheManager: controller.cacheManager,
                  heroTagId: heroTagId, onTap: (context) {
                HeroTagId.lastId = heroTagId;
                Navigator.of(context).push(GetPageRoute(
                  page: () => BiliVideoPage(
                    key: ValueKey("BiliVideoPage:${i.bvid}"),
                    bvid: i.bvid,
                    cid: i.cid,
                  ),
                ));
              }),
            );
          },
        )
      ],
    );
  }

  @override
  void initState() {
    controller = Get.put(
        IntroductionController(
          changePartCallback: widget.changePartCallback,
          bvid: widget.bvid,
          refreshReply: widget.refreshReply ?? () {},
          cid: widget.cid,
          ssid: widget.ssid,
          isBangumi: widget.isBangumi,
        ),
        tag: widget.tag);
    super.initState();
  }

  @override
  void dispose() {
    try {
      controller.dispose();
    } catch (e) {
      print("释放IntroductionController时出错: $e");
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Obx(() {
      // 检查控制器状态
      if (controller.isLoading.value) {
        // 正在加载
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 10),
              Text("正在加载视频信息..."),
            ],
          ),
        );
      } else if (controller.videoInfo == null && controller.isInitialized.value) {
        // 加载失败
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.grey),
              const SizedBox(height: 10),
              const Text("加载失败，请重试"),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () {
                  controller.isInitialized.value = false;
                  controller.loadVideoInfo();
                },
                icon: const Icon(Icons.refresh),
                label: const Text("重新加载"),
              ),
            ],
          ),
        );
      } else if (controller.videoInfo != null) {
        // 加载成功
        return _buildView(context, controller);
      } else {
        // 默认状态 - 开始加载
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 10),
              Text("正在准备加载..."),
            ],
          ),
        );
      }
    });
  }
}

class UpperTile extends StatelessWidget {
  const UpperTile({super.key, required this.controller});
  final IntroductionController controller;

  @override
  Widget build(BuildContext context) {
    // 确保视频信息已加载
    if (controller.videoInfo == null) {
      return const SizedBox.shrink();
    }
    
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(GetPageRoute(
          page: () => UserSpacePage(
              key: ValueKey('UserSpacePage:${controller.videoInfo!.ownerMid}'),
              mid: controller.videoInfo!.ownerMid),
        ));
      },
      child: Row(
        children: [
          Padding(
              padding: const EdgeInsets.only(right: 20),
              child: AvatarWidget(
                avatarUrl: controller.videoInfo!.ownerFace,
                radius: 20,
                cacheWidthHeight: 200,
              )),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                controller.videoInfo!.ownerName,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class IntroductionText extends StatelessWidget {
  const IntroductionText({super.key, required this.controller});
  final IntroductionController controller;

  // 构建视频标签组件（参考PiliPlus）
  Widget _buildVideoTags(BuildContext context) {
    // 暂时注释掉标签功能，因为VideoInfo模型中没有tags字段
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    // 确保视频信息已加载
    if (controller.videoInfo == null) {
      return const SizedBox.shrink();
    }
    
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 视频标题区域（添加长按复制功能）
          Padding(
            padding: const EdgeInsets.only(top: 5, bottom: 5),
            child: GestureDetector(
              onLongPress: () {
                // 长按复制视频标题
                Clipboard.setData(ClipboardData(text: controller.title.value));
                Get.snackbar("提示", "已复制视频标题");
              },
              child: Obx(() => Text(
                    controller.title.value,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  )),
            ),
          ),
          // 播放统计信息
          Row(
            children: [
              Icon(
                Icons.slideshow_rounded,
                size: 14,
                color: Theme.of(context).hintColor,
              ),
              Text(
                " ${StringFormatUtils.numFormat(controller.videoInfo!.playNum)}  ",
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).hintColor,
                ),
              ),
              Icon(
                Icons.format_list_bulleted_rounded,
                size: 14,
                color: Theme.of(context).hintColor,
              ),
              Text(
                " ${controller.videoInfo!.danmaukuNum}   ",
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).hintColor,
                ),
              ),
              Text(
                "${StringFormatUtils.timeStampToDate(controller.videoInfo!.pubDate)} ${StringFormatUtils.timeStampToTime(controller.videoInfo!.pubDate)}",
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).hintColor,
                ),
              )
            ],
          ),
          // 视频ID和版权信息
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  // 点击复制BVID
                  Clipboard.setData(ClipboardData(text: controller.videoInfo!.bvid));
                  Get.snackbar("提示", "已复制视频ID: ${controller.videoInfo!.bvid}");
                },
                child: Text(
                  "${controller.videoInfo!.bvid}  AV${BvidAvidUtil.bvid2Av(controller.videoInfo!.bvid)}   ${controller.videoInfo!.copyRight}",
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).hintColor,
                  ),
                ),
              )
            ],
          ),
          // 视频简介（添加展开/收起功能）
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Obx(
              () => FoldableText(
                //简介详细
                controller.describe.value,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).hintColor,
                ),
                maxLines: 6,
                folderTextStyle: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.primary),
              ),
            ),
          ),
          // 视频标签
          _buildVideoTags(context),
        ],
      ),
    );
  }
}

class IntroductionOperationButtons extends StatefulWidget {
  const IntroductionOperationButtons({super.key, required this.controller});
  final IntroductionController controller;

  @override
  State<IntroductionOperationButtons> createState() =>
      _IntroductionOperationButtonsState();
}

class _IntroductionOperationButtonsState
    extends State<IntroductionOperationButtons> {
  final TextStyle operationButtonTextStyle = const TextStyle(fontSize: 10);
  @override
  Widget build(BuildContext context) {
    // 确保视频信息已加载
    if (widget.controller.videoInfo == null) {
      return const SizedBox.shrink();
    }
    
    var buttonWidth = (MediaQuery.of(context).size.width) / 6;
    var buttonHeight = (MediaQuery.of(context).size.width) / 6 * 0.8;
    widget.controller.refreshOperationButton = () => setState(() {});
    return Row(
      children: [
        const Spacer(),
        SizedBox(
          width: buttonWidth,
          height: buttonHeight,
          child: IconTextButton(
            selected: widget.controller.videoInfo!.hasLike,
            icon: const Icon(Icons.thumb_up_rounded),
            text: Text(
              StringFormatUtils.numFormat(widget.controller.videoInfo!.likeNum),
              style: operationButtonTextStyle,
            ),
            onPressed: widget.controller.onLikePressed,
          ),
        ),
        const Spacer(),
        SizedBox(
            width: buttonWidth,
            height: buttonHeight,
            child: IconTextButton(
                selected: widget.controller.videoInfo!.hasAddCoin,
                icon: const Icon(Icons.circle_rounded),
                text: Text(
                    StringFormatUtils.numFormat(
                        widget.controller.videoInfo!.coinNum),
                    style: operationButtonTextStyle),
                onPressed: widget.controller.onAddCoinPressed)),
        const Spacer(),
        SizedBox(
            width: buttonWidth,
            height: buttonHeight,
            child: IconTextButton(
              selected: widget.controller.videoInfo!.hasFavourite,
              icon: const Icon(Icons.star_rounded),
              text: Text(
                  StringFormatUtils.numFormat(
                      widget.controller.videoInfo!.favariteNum),
                  style: operationButtonTextStyle),
              onPressed: () {},
            )),
        const Spacer(),
        SizedBox(
            width: buttonWidth,
            height: buttonHeight,
            child: IconTextButton(
              icon: const Icon(Icons.share_rounded),
              text: Text(
                  StringFormatUtils.numFormat(
                      widget.controller.videoInfo!.shareNum),
                  style: operationButtonTextStyle),
              onPressed: widget.controller.onAddSharePressed,
            )),
        const Spacer(),
      ],
    );
  }
}

class PartButtons extends StatelessWidget {
  const PartButtons({super.key, required this.controller});
  final IntroductionController controller;

  @override
  Widget build(BuildContext context) {
    return (controller.partButtons.isNotEmpty)
        ? SizedBox(
            height: 50,
            child: Row(
              children: [
                Flexible(
                    child: ListView.builder(
                  addAutomaticKeepAlives: false,
                  addRepaintBoundaries: false,
                  scrollDirection: Axis.horizontal,
                  itemCount: controller.partButtons.length,
                  itemBuilder: (context, index) {
                    return controller.partButtons[index];
                  },
                )),
                SizedBox(
                  width: 50,
                  height: 50,
                  child: InkWell(
                      borderRadius: BorderRadius.circular(25),
                      onTap: () {
                        showModalBottomSheet(
                            context: context,
                            clipBehavior: Clip.antiAlias,
                            builder: (context) => SizedBox(
                                  height: context.height / 2,
                                  child: ListView(
                                    padding: EdgeInsets.only(
                                        top: 10,
                                        left: 10,
                                        right: 10,
                                        bottom:
                                            context.mediaQueryPadding.bottom),
                                    children: [
                                      Wrap(
                                        alignment: WrapAlignment.spaceBetween,
                                        children: controller.partButtons,
                                      )
                                    ],
                                  ),
                                ));
                      },
                      child: const Icon(Icons.more_vert_rounded)),
                ),
              ],
            ))
        : const SizedBox();
  }
}