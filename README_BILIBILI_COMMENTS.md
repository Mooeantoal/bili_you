# B站评论展示页面生成说明

## 项目概述
本项目通过调用UAPI平台的B站API接口获取真实的视频评论数据，并生成HTML页面来展示这些评论，实现评论的折叠和展开功能。

## 文件说明
1. `fetch_comments.py` - 用于从UAPI获取B站视频信息和评论数据的Python脚本
2. `generate_comment_page.py` - 用于生成基于真实评论数据的HTML页面的Python脚本
3. `run_script.bat` - Windows批处理文件，用于运行Python脚本
4. `web/bili_comments.html` - B站评论展示页面（已生成）
5. `web/bilibili_comments_realtime.html` - 实时获取B站评论的交互页面
6. `web/bilibili_comments_improved.html` - 改进版的实时获取B站评论页面（增加错误处理和调试信息）
7. `web/bilibili_comments_robust.html` - 健壮版的实时获取B站评论页面（处理各种异常响应格式）
8. `web/bilibili_comments_ultimate.html` - 终极版的实时获取B站评论页面（具有最强的错误处理能力）
9. `web/bilibili_comments_final.html` - 最终版的实时获取B站评论页面（优化处理服务器错误）
10. `web/api_test.html` - API测试页面，用于查看API响应格式

## 使用方法

### 直接查看页面
1. 可以直接在浏览器中打开 `web/bili_comments.html` 文件查看B站评论展示页面。
2. 可以直接在浏览器中打开 `web/bilibili_comments_realtime.html` 文件使用实时获取功能。
3. 可以直接在浏览器中打开 `web/bilibili_comments_improved.html` 文件使用改进版的实时获取功能。
4. 可以直接在浏览器中打开 `web/bilibili_comments_robust.html` 文件使用健壮版的实时获取功能。
5. 可以直接在浏览器中打开 `web/bilibili_comments_ultimate.html` 文件使用终极版的实时获取功能。
6. 可以直接在浏览器中打开 `web/bilibili_comments_final.html` 文件使用最终版的实时获取功能。
7. 可以直接在浏览器中打开 `web/api_test.html` 文件测试API响应格式。

## 功能特点
1. **真实数据**：从B站获取真实的视频评论数据
2. **评论折叠**：当根评论的回复超过3条时，自动折叠第4条及以后的回复
3. **展开功能**：点击"展开剩余X条回复"可以查看所有回复
4. **查看详情**：点击任意回复可以查看该根评论的所有回复
5. **查看所有**：点击"查看所有回复"按钮可以查看根评论的所有回复
6. **实时获取**：通过 `web/bilibili_comments_realtime.html` 可以输入BV号实时获取任何B站视频的评论
7. **错误处理**：改进版页面增加了错误处理和调试信息显示
8. **重试机制**：网络请求失败时会自动重试
9. **健壮性**：健壮版页面能够处理各种异常响应格式
10. **终极兼容**：终极版页面具有最强的错误处理能力和兼容性
11. **服务器错误处理**：最终版页面优化处理服务器500错误和请求频率限制

## 当前问题
由于PowerShell环境中存在一些问题，建议使用CMD或直接双击批处理文件来运行脚本。

## 自定义
如果需要获取其他视频的评论，可以修改 `generate_comment_page.py` 中的BV号：
```python
video_url = "https://uapis.cn/api/v1/social/bilibili/videoinfo?bvid=BV1GJ411x7h7"
```

将 `BV1GJ411x7h7` 替换为你想要获取评论的视频BV号。
