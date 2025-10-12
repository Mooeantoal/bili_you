# B站播放器测试页面说明

## 功能介绍

本项目在测试页面中集成了B站官方播放器，通过WebView嵌入的方式实现。用户可以直接在应用中播放B站视频，无需跳转到浏览器或其他应用。

本实现采用了改进代码0.2版本的方案，使用响应式设计，可以更好地适配不同屏幕尺寸。

## 实现原理

1. 使用WebView组件嵌入B站官方播放器
2. 通过B站提供的iframe播放器URL加载视频
3. 采用改进代码0.2版本的响应式容器设计
4. 支持自定义视频ID、CID等参数
5. 提供播放控制选项（自动播放、弹幕开关、静音等）

## 改进代码0.2版本方案说明

改进代码0.2版本使用了响应式设计，通过以下方式实现：

```html
<div style="position: relative; padding: 30% 45%;">
<iframe style="position: absolute; width: 100%; height: 100%; left: 0; top: 0;" src="//player.bilibili.com/player.html?aid=928861104&bvid=BV1uT4y1P7CX&cid=287639008&page=1" frameborder="no" scrolling="no"></iframe>
</div>
```

在Flutter中，我们通过LayoutBuilder和Container来实现类似的响应式效果，确保播放器在不同设备上都能正确显示。

## 使用方法

1. 在应用底部导航栏点击"测试"选项卡
2. 进入B站播放器页面
3. 页面会自动加载默认视频
4. 点击右上角设置按钮可修改视频参数
5. 点击右上角刷新按钮可重新加载播放器

## 技术细节

### 播放器URL格式

```
https://www.bilibili.com/blackboard/html5mobileplayer.html?bvid={视频ID}&cid={CID}&page=1&autoplay=0&danmaku=1&muted=0
```

### 参数说明

- `bvid`: 视频BV号
- `cid`: 视频CID
- `page`: 视频分P（默认为1）
- `autoplay`: 自动播放（0:关闭，1:开启）
- `danmaku`: 弹幕开关（0:关闭，1:开启）
- `muted`: 静音（0:关闭，1:开启）

### 文件结构

- `lib/pages/test/navigation_test.dart`: 主要的播放器页面（已修改为改进代码0.2版本方案）
- `lib/pages/test/bili_player_advanced.dart`: 高级功能播放器页面（已修改为改进代码0.2版本方案）
- `lib/pages/test/bili_player_test.dart`: 简单播放器测试页面（已修改为改进代码0.2版本方案）

## 自定义视频

要播放其他视频，只需修改以下参数：

```dart
// B站视频参数
String videoId = 'BV1GJ411x7h7'; // 视频ID
String cid = '190597915'; // 视频CID
```

## 响应式设计特点

1. **自适应宽高比**：播放器容器保持16:9的宽高比
2. **居中显示**：在不同屏幕尺寸下都能居中显示
3. **最大尺寸适配**：根据可用空间自动调整播放器尺寸
4. **圆角边框**：美观的圆角设计和阴影效果
5. **跨平台兼容**：在手机、平板和桌面设备上都能良好显示

## 注意事项

1. 需要网络连接才能播放视频
2. 部分视频可能因版权限制无法播放
3. 某些功能可能需要登录B站账号
4. 移动端体验更佳

## 参考资料

- [B站iframe播放器使用教程](https://www.ymhave.com/archives/bilibiliiframe.html)
- [B站官方播放器文档](https://player.bilibili.com/)