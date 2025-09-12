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
        console.log('开始注入移动端优化脚本');
        
        // 立即隐藏所有元素
        var style = document.createElement('style');
        style.id = 'bili-mobile-style';
        style.innerHTML = `
          /* 隐藏所有元素 */
          html, body {
            overflow: hidden !important;
            margin: 0 !important;
            padding: 0 !important;
          }
          
          body > *:not(#commentapp) {
            display: none !important;
            visibility: hidden !important;
          }
          
          /* B站头部导航栏 */
          .bili-header,
          .bili-header-m,
          .international-header,
          .fixed-sidenav-storage,
          .left-entry,
          .right-entry,
          .video-toolbar,
          .video-info-container,
          .video-info,
          .up-info,
          .video-desc,
          .video-tag,
          .video-toolbar-container,
          .rec-list,
          .recommend-list-container,
          .playlist-container,
          .danmaku-info,
          .video-data,
          .video-page-game-card-small,
          .video-sponsor,
          .ad-report,
          .footer,
          .mini-header,
          .float-nav,
          .fixed-header {
            display: none !important;
            visibility: hidden !important;
          }
          
          /* 侧边栏 */
          .left-container,
          .right-container {
            display: none !important;
          }
          
          /* 只显示评论区 */
          #commentapp {
            display: block !important;
            visibility: visible !important;
            position: fixed !important;
            top: 0 !important;
            left: 0 !important;
            width: 100vw !important;
            height: 100vh !important;
            background: #fff !important;
            z-index: 99999 !important;
            overflow-y: auto !important;
            overflow-x: hidden !important;
          }
          
          /* 移动端优化样式 */
          #commentapp .bili-comment {
            padding: 10px !important;
            font-size: 14px !important;
            max-width: 100% !important;
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
        console.log('样式表已注入');
        
        // 等待评论区加载
        var attempts = 0;
        var maxAttempts = 100; // 10秒的等待时间
        var checkInterval = setInterval(function() {
          attempts++;
          var commentApp = document.getElementById('commentapp');
          console.log('检查评论区第' + attempts + '次，找到:', !!commentApp);
          
          if (commentApp) {
            console.log('找到评论区，开始优化');
            
            // 确保评论区显示
            commentApp.style.display = 'block';
            commentApp.style.visibility = 'visible';
            commentApp.style.position = 'fixed';
            commentApp.style.top = '0';
            commentApp.style.left = '0';
            commentApp.style.width = '100vw';
            commentApp.style.height = '100vh';
            commentApp.style.background = '#fff';
            commentApp.style.zIndex = '99999';
            commentApp.style.overflowY = 'auto';
            commentApp.style.overflowX = 'hidden';
            
            // 添加页面标题（如果还没有）
            if (!commentApp.querySelector('.mobile-comment-title')) {
              var title = document.createElement('div');
              title.className = 'mobile-comment-title';
              title.innerHTML = '评论区';
              title.style.cssText = `
                position: sticky;
                top: 0;
                background: #fff;
                padding: 12px 16px;
                border-bottom: 1px solid #e1e2e3;
                font-weight: bold;
                font-size: 16px;
                z-index: 100;
                box-shadow: 0 1px 3px rgba(0,0,0,0.1);
              `;
              commentApp.insertBefore(title, commentApp.firstChild);
            }
            
            // 隐藏其他所有元素
            var allElements = document.body.children;
            for (var i = 0; i < allElements.length; i++) {
              if (allElements[i].id !== 'commentapp') {
                allElements[i].style.display = 'none';
                allElements[i].style.visibility = 'hidden';
              }
            }
            
            console.log('评论区优化完成');
            clearInterval(checkInterval);
          } else if (attempts >= maxAttempts) {
            console.log('超时，停止检查');
            clearInterval(checkInterval);
          }
        }, 100); // 每100ms检查一次
        
        // 监听 DOM 变化，确保样式不被覆盖
        var observer = new MutationObserver(function(mutations) {
          var commentApp = document.getElementById('commentapp');
          if (commentApp && commentApp.style.display !== 'block') {
            console.log('检测到评论区被隐藏，重新显示');
            commentApp.style.display = 'block';
            commentApp.style.visibility = 'visible';
            commentApp.style.position = 'fixed';
            commentApp.style.zIndex = '99999';
          }
        });
        
        observer.observe(document.body, {
          childList: true,
          subtree: true,
          attributes: true,
          attributeFilter: ['style', 'class']
        });
        
        console.log('脚本注入完成');
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