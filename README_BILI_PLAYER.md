# B站播放器测试页面说明

## 功能介绍

本项目在测试页面中集成了B站官方播放器，通过WebView嵌入的方式实现。用户可以直接在应用中播放B站视频，无需跳转到浏览器或其他应用。

本实现采用了改进代码0.2版本的方案，使用响应式设计，可以更好地适配不同屏幕尺寸。

## PipePipe播放器实现

参考PipePipe项目的播放器实现方案，我们创建了一个集成了播放器、视频信息和评论功能的综合页面。该页面具有以下特点：

1. 使用WebView嵌入B站官方播放器
2. 集成视频详细信息展示
3. 集成评论系统，支持热门评论和普通评论
4. 支持播放器样式切换（移动端/PC端）
5. 支持视频分P切换
6. 支持评论排序功能
7. 响应式设计，适配不同屏幕尺寸

## 实现原理

1. 使用WebView组件嵌入B站官方播放器
2. 通过B站提供的iframe播放器URL加载视频
3. 采用改进代码0.2版本的响应式容器设计
4. 支持自定义视频ID、CID等参数
5. 提供播放控制选项（自动播放、弹幕开关、静音等）
6. 支持切换播放器样式（移动端/PC端）
7. 支持查看视频评论功能
8. 支持查看视频详细信息功能
9. **整合播放器、视频详细信息和评论到统一界面**

## 改进代码0.2版本方案说明

改进代码0.2版本使用了响应式设计，通过以下方式实现：

```
<div style="position: relative; padding: 30% 45%;">
<iframe style="position: absolute; width: 100%; height: 100%; left: 0; top: 0;" src="//player.bilibili.com/player.html?aid=928861104&bvid=BV1uT4y1P7CX&cid=287639008&page=1" frameborder="no" scrolling="no"></iframe>
</div>
```

在Flutter中，我们通过LayoutBuilder和Container来实现类似的响应式效果，确保播放器在不同设备上都能正确显示。

## 播放器样式切换功能

根据参考文章中的说明，B站提供了两种播放器：
1. **移动端播放器**：URL为 `https://www.bilibili.com/blackboard/html5mobileplayer.html`，界面更清爽
2. **PC端播放器**：URL为 `https://player.bilibili.com/player.html`，功能更丰富但可能较臃肿

本实现支持在两种播放器样式之间切换：
- 在基础版和测试版中，点击 AppBar 左上角的图标（💻/📱）进行切换
- 在高级版中，可以在设置对话框中选择使用PC端播放器

## 视频评论查看功能

根据 [UAPI提供的API](https://uapis.cn/docs/api-reference/get-social-bilibili-replies)，我们实现了查看视频评论的功能：

### API接口说明
- **接口地址**：`https://uapis.cn/api/v1/social/bilibili/replies`
- **请求方法**：GET
- **必需参数**：
  - `oid`：目标评论区的ID（对于视频，这通常就是它的 aid）
- **可选参数**：
  - `sort`：排序方式（0=按时间，1=按点赞，2=按回复）
  - `ps`：每页获取的评论数量（1-20，默认20）
  - `pn`：要获取的页码（从1开始，默认1）

### 功能特点
1. 支持分页加载评论
2. 支持多种排序方式
3. 显示热门评论和普通评论
4. 显示评论的点赞数和回复数
5. 显示用户头像和评论时间

## 视频详细信息查看功能

根据 [UAPI提供的API](https://uapis.cn/docs/api-reference/get-social-bilibili-videoinfo)，我们实现了查看视频详细信息的功能：

### API接口说明
- **接口地址**：`https://uapis.cn/api/v1/social/bilibili/videoinfo`
- **请求方法**：GET
- **必需参数**：
  - `aid`：视频的AV号（纯数字格式）
  - `bvid`：视频的BV号（例如 BV117411r7R1）
  - aid和bvid任选其一即可

### 功能特点
1. 显示视频标题、封面、时长等基本信息
2. 显示播放量、弹幕数、评论数等统计数据
3. 显示UP主信息（头像、昵称、UID）
4. 显示视频描述和分P列表
5. 支持原创/转载标识

## 整合界面功能

参考普通播放界面布局，我们将播放器、视频详细信息和评论功能整合到一个统一的界面中：

### 界面布局
1. **顶部播放器区域**：嵌入B站官方播放器
2. **Tab导航栏**：包含简介、评论、更多三个Tab
3. **Tab内容区域**：
   - 简介Tab：显示视频详细信息
   - 评论Tab：显示视频评论
   - 更多Tab：显示视频参数和操作说明

### 交互特点
1. 通过Tab导航切换不同内容模块
2. 支持播放器样式切换（移动端/PC端）
3. 支持刷新播放器和页面内容
4. 响应式设计适配不同屏幕尺寸

## 使用方法

### 主页面导航栏入口

现在在主页面的导航栏中已经添加了 PipePipe 播放器的入口：
1. 在桌面端：导航栏中会显示"PipePipe"选项
2. 在移动端：底部导航栏中会显示"PipePipe"选项
3. 点击该选项可以直接进入 PipePipe 播放器页面

### 导航测试页面入口

1. 在应用底部导航栏点击"测试"选项卡
2. 进入整合的B站播放器测试页面
3. 页面会自动加载默认视频
4. 通过顶部的Tab导航切换简介、评论和更多内容
5. 点击左上角图标（💻/📱）可在PC端和移动端播放器样式间切换
6. 点击右上角刷新按钮可重新加载播放器
7. 在播放器选择按钮区域，点击"PipePipe播放器"按钮进入PipePipe风格的播放器页面

### 专门的PipePipe播放器测试入口

为了方便测试PipePipe播放器，我们还提供了一个专门的测试入口文件：
- `lib/main_pipepipe_test_entry.dart`: PipePipe播放器测试入口文件

可以通过以下命令运行：
```
flutter run -t lib/main_pipepipe_test_entry.dart
```

## 技术细节

### 播放器URL格式

```
// 移动端播放器
https://www.bilibili.com/blackboard/html5mobileplayer.html?bvid={视频ID}&cid={CID}&page=1&autoplay=0&danmaku=1&muted=0

// PC端播放器
https://player.bilibili.com/player.html?bvid={视频ID}&cid={CID}&page=1&autoplay=0&danmaku=1&muted=0
```

### 评论API参数说明

- `oid`: 视频的aid（目标评论区的ID）
- `sort`: 排序方式（0=按时间排序, 1=按点赞数排序, 2=按回复数排序）
- `ps`: 每页获取的评论数量，范围是1到20
- `pn`: 要获取的页码，从1开始

### 视频信息API参数说明

- `aid`: 视频的AV号（纯数字格式）
- `bvid`: 视频的BV号（例如 BV117411r7R1）
- aid和bvid任选其一即可

### 文件结构

- `lib/pages/test/bili_integrated_test_page.dart`: 整合的播放器测试页面
- `lib/pages/test/bili_comments_page.dart`: 视频评论页面
- `lib/pages/test/bili_video_info_page.dart`: 视频详细信息页面
- `lib/pages/test/pipepipe_player_page.dart`: PipePipe风格的播放器页面
- `lib/pages/main/controller.dart`: 主页面控制器
- `lib/main_pipepipe_test_entry.dart`: PipePipe播放器测试入口文件

## 自定义视频

要播放其他视频，只需修改以下参数：

```
// B站视频参数
final String videoId = 'BV1GJ411x7h7'; // 视频ID
final String cid = '190597915'; // 视频CID
final String aid = '928861104'; // 视频AID
```

## 响应式设计特点

1. **自适应宽高比**：播放器容器保持16:9的宽高比
2. **居中显示**：在不同屏幕尺寸下都能居中显示
3. **最大尺寸适配**：根据可用空间自动调整播放器尺寸
4. **圆角边框**：美观的圆角设计和阴影效果
5. **跨平台兼容**：在手机、平板和桌面设备上都能良好显示

## 播放器样式对比

### 移动端播放器特点
- 界面清爽简洁
- 无广告干扰
- 适合移动端观看
- 功能相对简化

### PC端播放器特点
- 功能丰富完整
- 可能包含广告
- 适合大屏幕观看
- 提供更多交互选项

## 评论功能特点

### 热门评论
- 仅在第一页显示
- 以特殊标识突出显示
- 包含点赞数和回复数

### 普通评论
- 支持分页浏览
- 显示用户头像和昵称
- 显示评论时间和内容
- 支持多种排序方式

### 分页控制
- 上一页/下一页导航
- 当前页码显示
- 总页数显示

## 视频详细信息功能特点

### 基本信息
- 视频标题、封面、时长
- 发布时间、版权类型
- 视频描述

### 数据统计
- 播放量、弹幕数、评论数
- 点赞数、投币数、收藏数
- 分享数

### UP主信息
- UP主头像、昵称
- UP主UID

### 分P列表
- 显示所有分P标题和时长
- 支持点击跳转到指定分P（待实现）

## 注意事项

1. 需要网络连接才能播放视频和获取数据
2. 部分视频可能因版权限制无法播放
3. 某些功能可能需要登录B站账号
4. 移动端体验更佳
5. PC端播放器在移动设备上可能显示不够优化
6. 评论功能和视频信息功能依赖第三方API服务

## 参考资料

- [B站iframe播放器使用教程](https://www.ymhave.com/archives/bilibiliiframe.html)
- [B站官方播放器文档](https://player.bilibili.com/)
- [UAPI获取Bilibili视频评论接口](https://uapis.cn/docs/api-reference/get-social-bilibili-replies)
- [UAPI获取Bilibili视频详细信息接口](https://uapis.cn/docs/api-reference/get-social-bilibili-videoinfo)