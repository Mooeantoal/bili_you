import 'package:bili_you/common/api/video_info_api.dart';
import 'package:bili_you/common/models/local/reply/reply_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'index.dart';

class ReplyPage extends StatefulWidget {
  const ReplyPage({
    Key? key,
    required this.replyId,
    required this.replyType,
  })  : tag = "ReplyPage:$replyId",
        super(key: key);
  final String replyId;
  final ReplyType replyType;
  final String tag;

  @override
  State<ReplyPage> createState() => _ReplyPageState();
}

class _ReplyPageState extends State<ReplyPage>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  _ReplyPageState();

  @override
  bool get wantKeepAlive => true;

  late ReplyController controller;

  @override
  void initState() {
    super.initState();
    
    // 初始化控制器
    controller = Get.put(
      ReplyController(
        bvid: widget.replyId,
        replyType: widget.replyType,
      ),
      tag: widget.tag,
    );
    
    // 加载评论页面
    _loadReplyPage();
  }

  void _loadReplyPage() async {
    String url;
    if (widget.replyType == ReplyType.video) {
      // 对于视频，使用BV号加载评论
      url = 'https://www.bilibili.com/video/${widget.replyId}/#reply';
    } else {
      // 其他类型保持原有逻辑或按需添加
      url = 'https://www.bilibili.com/video/${widget.replyId}/#reply';
    }
    
    // 设置页面加载完成后的回调
    controller.webViewController.setNavigationDelegate(
      NavigationDelegate(
        onPageFinished: (String url) {
          _injectMobileOptimization();
        },
      ),
    );
    
    controller.webViewController.loadRequest(Uri.parse(url));
  }
  
  // 注入移动端优化脚本
  void _injectMobileOptimization() {
    const String script = '''
      (function() {
        // 隐藏所有元素，只显示评论区
        var style = document.createElement('style');
        style.innerHTML = `
          /* 隐藏所有元素 */
          body > * {
            display: none !important;
          }
          
          /* 只显示评论区 */
          #commentapp {
            display: block !important;
            position: fixed !important;
            top: 0 !important;
            left: 0 !important;
            width: 100% !important;
            height: 100vh !important;
            background: #fff !important;
            z-index: 9999 !important;
            overflow-y: auto !important;
          }
          
          /* 移动端优化样式 */
          #commentapp .bili-comment {
            padding: 10px !important;
            font-size: 14px !important;
          }
          
          /* 评论列表优化 */
          #commentapp .comment-list .list-item {
            padding: 12px 10px !important;
            border-bottom: 1px solid #f0f0f0 !important;
          }
          
          /* 用户头像大小优化 */
          #commentapp .bili-avatar {
            width: 36px !important;
            height: 36px !important;
          }
          
          /* 评论内容优化 */
          #commentapp .reply-content {
            font-size: 14px !important;
            line-height: 1.4 !important;
            word-wrap: break-word !important;
          }
          
          /* 操作按钮优化 */
          #commentapp .reply-btn {
            padding: 8px 12px !important;
            font-size: 13px !important;
            min-height: 36px !important;
            touch-action: manipulation !important;
          }
          
          /* 输入框优化 */
          #commentapp .reply-box textarea {
            font-size: 16px !important;
            padding: 12px !important;
            min-height: 80px !important;
          }
          
          /* 防止缩放 */
          #commentapp * {
            -webkit-text-size-adjust: 100% !important;
            -webkit-user-select: text !important;
          }
          
          /* 响应式设计 */
          @media (max-width: 768px) {
            #commentapp .bili-comment {
              padding: 8px !important;
            }
            
            #commentapp .comment-list .list-item {
              padding: 10px 8px !important;
            }
            
            #commentapp .reply-content {
              font-size: 13px !important;
            }
          }
        `;
        document.head.appendChild(style);
        
        // 等待评论区加载
        var checkInterval = setInterval(function() {
          var commentApp = document.getElementById('commentapp');
          if (commentApp) {
            // 确保评论区显示
            commentApp.style.display = 'block';
            commentApp.style.position = 'fixed';
            commentApp.style.top = '0';
            commentApp.style.left = '0';
            commentApp.style.width = '100%';
            commentApp.style.height = '100vh';
            commentApp.style.background = '#fff';
            commentApp.style.zIndex = '9999';
            commentApp.style.overflowY = 'auto';
            
            // 添加页面标题
            var title = document.createElement('div');
            title.innerHTML = '评论区';
            title.style.cssText = `
              position: sticky;
              top: 0;
              background: #fff;
              padding: 12px 16px;
              border-bottom: 1px solid #e1e2e3;
              font-weight: bold;
              font-size: 16px;
              z-index: 10;
            `;
            commentApp.insertBefore(title, commentApp.firstChild);
            
            clearInterval(checkInterval);
          }
        }, 100);
        
        // 5秒后停止检查
        setTimeout(function() {
          clearInterval(checkInterval);
        }, 5000);
      })();
    ''';
    
    controller.webViewController.runJavaScript(script);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: const Row(
            children: [
              Icon(Icons.web, size: 16, color: Colors.grey),
              SizedBox(width: 8),
              Text(
                "网页版评论区",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!, width: 0.5),
            ),
            child: WebViewWidget(
              controller: controller.webViewController,
            ),
          ),
        ),
      ],
    );
  }
}