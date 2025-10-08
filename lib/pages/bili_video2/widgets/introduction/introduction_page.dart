import 'package:bili_you/common/api/video_info_api.dart';
import 'package:bili_you/common/api/video_operation_api.dart';
import 'package:bili_you/common/models/local/video/video_info.dart';
import 'package:bili_you/common/utils/num_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IntroductionPage extends StatefulWidget {
  const IntroductionPage(
      {super.key,
      required this.bvid,
      required this.cid,
      this.ssid,
      this.isBangumi = false});

  final String bvid;
  final int cid;
  final int? ssid;
  final bool isBangumi;

  @override
  State<IntroductionPage> createState() => _IntroductionPageState();
}

class _IntroductionPageState extends State<IntroductionPage> {
  VideoInfo? _videoInfo;
  bool _isLoading = true;
  String _errorMessage = '';
  
  // 视频操作状态
  bool _hasLiked = false;
  bool _hasCoin = false;
  bool _hasFavorited = false;

  @override
  void initState() {
    super.initState();
    _loadVideoInfo();
    _loadVideoOperationStatus();
  }

  Future<void> _loadVideoInfo() async {
    try {
      final videoInfo = await VideoInfoApi.getVideoInfo(bvid: widget.bvid);
      setState(() {
        _videoInfo = videoInfo;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = '加载视频信息失败: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadVideoOperationStatus() async {
    try {
      // 加载视频操作状态
      final hasLike = await VideoOperationApi.hasLike(bvid: widget.bvid);
      final hasCoin = await VideoOperationApi.hasAddCoin(bvid: widget.bvid);
      final hasFavorite = await VideoOperationApi.hasFavourite(bvid: widget.bvid);
      
      setState(() {
        _hasLiked = hasLike;
        _hasCoin = hasCoin;
        _hasFavorited = hasFavorite;
      });
    } catch (e) {
      debugPrint('加载视频操作状态失败: $e');
    }
  }

  Future<void> _handleLike() async {
    try {
      final result = await VideoOperationApi.clickLike(
        bvid: widget.bvid,
        likeOrCancelLike: !_hasLiked,
      );
      
      if (result.isSuccess) {
        setState(() {
          _hasLiked = !_hasLiked;
          if (_videoInfo != null) {
            if (_hasLiked) {
              _videoInfo!.likeNum++;
            } else {
              _videoInfo!.likeNum--;
            }
          }
        });
        Get.snackbar(
          _hasLiked ? '点赞成功' : '取消点赞',
          _hasLiked ? '已点赞' : '已取消点赞',
        );
      } else {
        Get.snackbar('操作失败', result.error);
      }
    } catch (e) {
      Get.snackbar('操作失败', '点赞操作失败: $e');
    }
  }

  Future<void> _handleCoin() async {
    try {
      final result = await VideoOperationApi.addCoin(bvid: widget.bvid);
      
      if (result.isSuccess) {
        setState(() {
          _hasCoin = true;
          if (_videoInfo != null) {
            _videoInfo!.coinNum++;
          }
        });
        Get.snackbar('投币成功', '已投币');
      } else {
        Get.snackbar('操作失败', result.error);
      }
    } catch (e) {
      Get.snackbar('操作失败', '投币操作失败: $e');
    }
  }

  Future<void> _handleFavorite() async {
    try {
      // 这里需要实现收藏功能
      setState(() {
        _hasFavorited = !_hasFavorited;
        if (_videoInfo != null) {
          if (_hasFavorited) {
            _videoInfo!.favariteNum++;
          } else {
            _videoInfo!.favariteNum--;
          }
        }
      });
      Get.snackbar(
        _hasFavorited ? '收藏成功' : '取消收藏',
        _hasFavorited ? '已收藏' : '已取消收藏',
      );
    } catch (e) {
      Get.snackbar('操作失败', '收藏操作失败: $e');
    }
  }

  Future<void> _switchToPart(int cid) async {
    // 切换到对应的分P
    // 这里应该通知播放器切换视频
    Get.snackbar('提示', '切换到分P: $cid');
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(child: Text(_errorMessage));
    }

    if (_videoInfo == null) {
      return const Center(child: Text('无法获取视频信息'));
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 视频标题
            Text(
              _videoInfo!.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            // 视频统计信息
            Row(
              children: [
                Icon(Icons.visibility, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(NumUtils.numFormat(_videoInfo!.playNum)),
                const SizedBox(width: 16),
                Icon(Icons.chat_bubble_outline, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(NumUtils.numFormat(_videoInfo!.danmaukuNum)),
                const SizedBox(width: 16),
                Icon(Icons.thumb_up_alt_outlined, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(NumUtils.numFormat(_videoInfo!.likeNum)),
                const SizedBox(width: 16),
                Icon(Icons.monetization_on_outlined, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(NumUtils.numFormat(_videoInfo!.coinNum)),
                const SizedBox(width: 16),
                Icon(Icons.star_border, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(NumUtils.numFormat(_videoInfo!.favariteNum)),
              ],
            ),
            const SizedBox(height: 16),
            
            // 视频操作按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    IconButton(
                      icon: Icon(
                        _hasLiked ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
                        color: _hasLiked ? Colors.pink : null,
                      ),
                      onPressed: _handleLike,
                    ),
                    Text(_hasLiked ? '已点赞' : '点赞'),
                  ],
                ),
                Column(
                  children: [
                    IconButton(
                      icon: Icon(
                        _hasCoin ? Icons.monetization_on : Icons.monetization_on_outlined,
                        color: _hasCoin ? Colors.orange : null,
                      ),
                      onPressed: _handleCoin,
                    ),
                    Text(_hasCoin ? '已投币' : '投币'),
                  ],
                ),
                Column(
                  children: [
                    IconButton(
                      icon: Icon(
                        _hasFavorited ? Icons.star : Icons.star_border,
                        color: _hasFavorited ? Colors.yellow : null,
                      ),
                      onPressed: _handleFavorite,
                    ),
                    Text(_hasFavorited ? '已收藏' : '收藏'),
                  ],
                ),
                Column(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.share),
                      onPressed: () {
                        // 分享功能
                      },
                    ),
                    const Text('分享'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // UP主信息
            Card(
              child: ListTile(
                leading: CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(_videoInfo!.ownerFace),
                ),
                title: Text(_videoInfo!.ownerName),
                subtitle: const Text('UP主'),
                onTap: () {
                  // 跳转到UP主空间
                },
              ),
            ),
            const SizedBox(height: 16),
            
            // 视频描述
            if (_videoInfo!.describe.isNotEmpty) ...[
              const Text(
                '视频描述',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _videoInfo!.describe,
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // 分P信息
            if (_videoInfo!.parts.isNotEmpty) ...[
              const Text(
                '分P列表',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _videoInfo!.parts.length,
                itemBuilder: (context, index) {
                  final part = _videoInfo!.parts[index];
                  return ListTile(
                    title: Text('${index + 1}. ${part.title}'),
                    onTap: () {
                      _switchToPart(part.cid);
                    },
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}