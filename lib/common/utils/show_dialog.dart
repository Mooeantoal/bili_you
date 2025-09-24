import 'package:bili_you/common/utils/cache_util.dart';
import 'package:bili_you/common/widget/frosted_glass_card.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:share_plus/share_plus.dart';

class ShowDialog {
  ///显示图片
  static showImageViewer(
      {required BuildContext context,
      required List<String> urls,
      int initIndex = 0}) {
    var controller = PageController(initialPage: initIndex);
    var currentIndex = initIndex;
    showDialog(
        useSafeArea: false,
        context: context,
        builder: (context) => Container(
              color: Colors.black,
              child: StatefulBuilder(
                builder: (context, setState) {
                  return Stack(
                    children: [
                      PhotoViewGallery.builder(
                          onPageChanged: (index) =>
                              setState(() => currentIndex = index),
                          scrollPhysics: const BouncingScrollPhysics(),
                          itemCount: urls.length,
                          pageController: controller,
                          builder: (context, index) =>
                              PhotoViewGalleryPageOptions(
                                filterQuality: FilterQuality.high,
                                minScale: PhotoViewComputedScale.contained,
                                maxScale: PhotoViewComputedScale.contained * 6.0,
                                initialScale: PhotoViewComputedScale.contained,
                                heroAttributes:
                                    PhotoViewHeroAttributes(tag: urls[index]),
                                imageProvider: CachedNetworkImageProvider(
                                    urls[index],
                                    cacheManager:
                                        CacheUtils.bigImageCacheManager),
                              )),
                      Container(
                        decoration: const BoxDecoration(boxShadow: [
                          BoxShadow(
                              offset: Offset(0, -20),
                              color: Colors.black12,
                              blurRadius: 20,
                              spreadRadius: 20)
                        ]),
                        child: SafeArea(
                          bottom: false,
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                icon: Icon(
                                  Icons.close,
                                  color: Theme.of(context)
                                      .primaryTextTheme
                                      .bodyMedium!
                                      .color,
                                  shadows: const [
                                    Shadow(color: Colors.black54, blurRadius: 2),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              Text(
                                  style: TextStyle(
                                    shadows: const [
                                      Shadow(
                                          color: Colors.black54, blurRadius: 2),
                                    ],
                                    color: Theme.of(context)
                                        .primaryTextTheme
                                        .bodyMedium!
                                        .color,
                                  ),
                                  '${currentIndex + 1}/${urls.length}'),
                              PopupMenuButton(
                                icon: Icon(
                                  Icons.more_vert_rounded,
                                  color: Theme.of(context)
                                      .primaryTextTheme
                                      .bodyMedium!
                                      .color,
                                  shadows: const [
                                    Shadow(
                                        color: Colors.black54, blurRadius: 2),
                                  ],
                                ),
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    child: const Text("保存图片"),
                                    onTap: () async {
                                      await _saveImage(urls[currentIndex]);
                                    },
                                  ),
                                  PopupMenuItem(
                                    child: const Text("分享图片"),
                                    onTap: () async {
                                      await Share.shareXFiles(
                                          [XFile(urls[currentIndex])]);
                                    },
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  );
                },
              ),
            ));
  }

  static Future _saveImage(String url) async {
    try {
      // 确保图片在缓存中
      await CachedNetworkImageProvider(
        url,
        cacheManager: CacheUtils.bigImageCacheManager,
      ).obtainKey(const ImageConfiguration());
      // 从缓存中获取文件
      var file = await CacheUtils.bigImageCacheManager.getFileFromCache(url);
      if (file != null) {
        await ImageGallerySaver.saveFile(file.file.path);
        Get.showSnackbar(const GetSnackBar(
          title: "保存成功",
          message: "图片已保存到相册",
          duration: Duration(seconds: 2),
        ));
      } else {
        Get.showSnackbar(const GetSnackBar(
          title: "保存失败",
          message: "图片缓存不存在",
          duration: Duration(seconds: 2),
        ));
      }
    } catch (e) {
      Get.showSnackbar(GetSnackBar(
        title: "保存失败",
        message: e.toString(),
        duration: const Duration(seconds: 2),
      ));
    }
  }

  /// 显示确认对话框（添加模糊效果）
  static Future<bool?> showConfirmDialog({
    required BuildContext context,
    String title = "提示",
    required String content,
    String confirmText = "确认",
    String cancelText = "取消",
    bool barrierDismissible = true,
  }) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => FrostedGlassCard(
        // 添加模糊效果
        borderRadius: 16.0,
        blurSigma: 8.0,
        backgroundColor:
            Theme.of(context).colorScheme.surface.withOpacity(0.9),
        child: AlertDialog(
          title: Text(title),
          content: Text(content),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(cancelText),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(confirmText),
            ),
          ],
        ),
      ),
    );
  }
}