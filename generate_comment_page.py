import requests
import json

# 获取B站视频信息
video_url = "https://uapis.cn/api/v1/social/bilibili/videoinfo?bvid=BV1GJ411x7h7"
response = requests.get(video_url)
video_data = response.json()

# 获取视频的aid
aid = video_data['data']['aid']
print(f"视频aid: {aid}")

# 获取评论数据
comments_url = f"https://uapis.cn/api/v1/social/bilibili/replies?oid={aid}&ps=10&pn=1"
response = requests.get(comments_url)
comments_data = response.json()

# 生成HTML文件
html_content = """
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>B站评论展示</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 800px;
            margin: 0 auto;
            padding: 20px;
            background-color: #f5f5f5;
        }
        .comment-container {
            background-color: white;
            border-radius: 8px;
            padding: 16px;
            margin-bottom: 16px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
        }
        .user-info {
            display: flex;
            align-items: center;
            margin-bottom: 8px;
        }
        .avatar {
            width: 32px;
            height: 32px;
            border-radius: 50%;
            background-color: #3498db;
            color: white;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: bold;
            margin-right: 8px;
        }
        .username {
            font-weight: bold;
            font-size: 14px;
        }
        .time {
            font-size: 12px;
            color: #666;
            margin-left: 8px;
        }
        .content {
            font-size: 14px;
            margin: 8px 0;
        }
        .reply-container {
            border-top: 1px solid #eee;
            padding-top: 8px;
            margin-top: 8px;
        }
        .reply-item {
            background-color: #f8f9fa;
            border-radius: 4px;
            padding: 8px;
            margin-bottom: 8px;
            cursor: pointer;
        }
        .reply-item:hover {
            background-color: #e9ecef;
        }
        .reply-item.highlight {
            background-color: #d1ecf1;
            border: 1px solid #bee5eb;
        }
        .stats {
            display: flex;
            gap: 16px;
            font-size: 12px;
            color: #666;
            margin-top: 8px;
        }
        .modal {
            display: none;
            position: fixed;
            z-index: 1000;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0,0,0,0.5);
        }
        .modal-content {
            background-color: white;
            margin: 5% auto;
            padding: 20px;
            border-radius: 8px;
            width: 80%;
            max-width: 600px;
            max-height: 80vh;
            overflow-y: auto;
        }
        .close {
            float: right;
            cursor: pointer;
            font-size: 24px;
        }
        .reply-list {
            max-height: 400px;
            overflow-y: auto;
            margin-top: 15px;
        }
        .view-all-replies {
            background-color: #3498db;
            color: white;
            border: none;
            padding: 8px 12px;
            border-radius: 4px;
            cursor: pointer;
            font-size: 12px;
            margin-top: 8px;
        }
        .view-all-replies:hover {
            background-color: #2980b9;
        }
        .reply-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .reply-count {
            font-size: 12px;
            color: #666;
        }
        .collapsed-replies {
            display: none;
        }
        .view-more-replies {
            color: #3498db;
            cursor: pointer;
            font-size: 12px;
            margin-top: 5px;
            display: inline-block;
        }
    </style>
</head>
<body>
    <h1>B站评论展示</h1>
    <p>此页面展示了从B站获取的真实评论数据。</p>
"""

# 处理评论数据
replies = comments_data.get('data', {}).get('replies', [])

# 按根评论分组
root_comments = {}
for reply in replies:
    root = reply['root']
    if root == 0:  # 根评论
        root_comments[reply['rpid']] = {
            'id': reply['rpid'],
            'username': reply['member']['uname'],
            'content': reply['content']['message'],
            'time': reply['ctime'],
            'likes': reply['like'],
            'replies': []
        }
    else:  # 回复
        if root in root_comments:
            root_comments[root]['replies'].append({
                'id': reply['rpid'],
                'username': reply['member']['uname'],
                'content': reply['content']['message'],
                'time': reply['ctime'],
                'likes': reply['like']
            })

# 生成HTML内容
for root_id, root_comment in root_comments.items():
    # 格式化时间
    from datetime import datetime
    time_str = datetime.fromtimestamp(root_comment['time']).strftime('%m-%d %H:%M')
    
    html_content += f"""
    <!-- 根评论 -->
    <div class="comment-container">
        <div class="user-info">
            <div class="avatar">{root_comment['username'][0]}</div>
            <div class="username">{root_comment['username']}</div>
            <div class="time">{time_str}</div>
        </div>
        <div class="content">{root_comment['content']}</div>
        <div class="reply-container">
"""
    
    # 添加回复
    for i, reply in enumerate(root_comment['replies']):
        time_str_reply = datetime.fromtimestamp(reply['time']).strftime('%m-%d %H:%M')
        collapsed_class = "collapsed-replies" if i >= 3 else ""
        html_content += f"""
            <div class="reply-item {collapsed_class}" onclick="showReplyDetail('{reply['id']}', '{root_id}')">
                <div class="user-info">
                    <div class="avatar">{reply['username'][0]}</div>
                    <div class="username">{reply['username']}</div>
                    <div class="time">{time_str_reply}</div>
                </div>
                <div class="content">{reply['content']}</div>
            </div>
"""
    
    # 如果回复超过3条，添加展开链接
    if len(root_comment['replies']) > 3:
        remaining = len(root_comment['replies']) - 3
        html_content += f"""
            <div class="view-more-replies" onclick="toggleReplies('{root_id}')">展开剩余{remaining}条回复</div>
"""
    
    html_content += f"""
        </div>
        <div class="stats">
            <span>👍 {root_comment['likes']} 点赞</span>
            <span>💬 {len(root_comment['replies'])} 回复</span>
            <button class="view-all-replies" onclick="showAllReplies('{root_id}')">查看所有回复</button>
        </div>
    </div>
"""

html_content += """
    <!-- 回复详情模态框 -->
    <div id="replyModal" class="modal">
        <div class="modal-content">
            <span class="close" onclick="closeModal()">&times;</span>
            <div id="modalContent"></div>
        </div>
    </div>

    <script>
        // 评论数据
        const comments = """ + json.dumps(root_comments, ensure_ascii=False) + """;

        // 切换回复显示状态
        function toggleReplies(rootId) {
            const container = event.target.closest('.comment-container');
            const collapsedReplies = container.querySelectorAll('.collapsed-replies');
            const viewMoreLink = event.target;
            
            // 切换折叠回复的显示状态
            collapsedReplies.forEach(reply => {
                reply.style.display = reply.style.display === 'block' ? 'none' : 'block';
            });
            
            // 切换链接文本
            const remaining = collapsedReplies.length;
            viewMoreLink.textContent = viewMoreLink.textContent === `展开剩余${remaining}条回复` ? '收起回复' : `展开剩余${remaining}条回复`;
        }

        // 显示回复详情
        function showReplyDetail(replyId, rootId) {
            const rootComment = comments[rootId];
            if (!rootComment) return;

            // 格式化时间
            const formatDate = (timestamp) => {
                const date = new Date(timestamp * 1000);
                return `${(date.getMonth()+1).toString().padStart(2, '0')}-${date.getDate().toString().padStart(2, '0')} ${date.getHours().toString().padStart(2, '0')}:${date.getMinutes().toString().padStart(2, '0')}`;
            };

            // 构建模态框内容
            let modalContent = `
                <div class="reply-header">
                    <div class="user-info">
                        <div class="avatar">${rootComment.username[0]}</div>
                        <div class="username">${rootComment.username}</div>
                        <div class="time">${formatDate(rootComment.time)}</div>
                    </div>
                    <div class="reply-count">共 ${rootComment.replies.length} 条回复</div>
                </div>
                <div class="content">${rootComment.content}</div>
                <hr>
                <h3>回复列表</h3>
                <div class="reply-list">
            `;

            // 添加所有回复到模态框
            rootComment.replies.forEach(reply => {
                // 如果是被点击的回复，则高亮显示
                const isHighlighted = reply.id == replyId;
                modalContent += `
                    <div class="reply-item ${isHighlighted ? 'highlight' : ''}">
                        <div class="user-info">
                            <div class="avatar">${reply.username[0]}</div>
                            <div class="username">${reply.username}</div>
                            <div class="time">${formatDate(reply.time)}</div>
                        </div>
                        <div class="content">${reply.content}</div>
                        <div class="stats">
                            <span>👍 ${reply.likes} 点赞</span>
                        </div>
                    </div>
                `;
            });

            modalContent += `
                </div>
            `;

            document.getElementById('modalContent').innerHTML = modalContent;
            document.getElementById('replyModal').style.display = 'block';
        }

        // 直接显示所有回复
        function showAllReplies(rootId) {
            showReplyDetail(null, rootId);
        }

        // 关闭模态框
        function closeModal() {
            document.getElementById('replyModal').style.display = 'none';
        }

        // 点击模态框外部关闭
        window.onclick = function(event) {
            const modal = document.getElementById('replyModal');
            if (event.target == modal) {
                modal.style.display = 'none';
            }
        }
    </script>
</body>
</html>
"""

# 写入HTML文件
with open('web/bili_comments.html', 'w', encoding='utf-8') as f:
    f.write(html_content)

print("HTML文件已生成: web/bili_comments.html")