# 弹幕包替代方案

## 当前问题
由于网络或Git配置问题，无法从GitHub获取 `flutter_ns_danmaku` 包。

## 解决方案

### 方案1：配置Git认证（推荐）
```bash
# 配置Git使用HTTPS而不是SSH
git config --global url."https://github.com/".insteadOf git@github.com:

# 或者设置代理（如果在受限网络环境中）
git config --global http.proxy http://proxy.company.com:8080
git config --global https.proxy https://proxy.company.com:8080
```

### 方案2：手动下载包
1. 访问 https://github.com/lucinhu/flutter_ns_danmaku
2. 下载ZIP文件
3. 解压到本地目录
4. 修改pubspec.yaml使用本地路径：

```yaml
flutter_ns_danmaku:
  path: ./local_packages/flutter_ns_danmaku
```

### 方案3：使用pub.dev上的替代包
```yaml
# 暂时注释掉Git依赖，使用pub.dev上的弹幕包
# flutter_ns_danmaku:
#   git:
#     url: https://github.com/lucinhu/flutter_ns_danmaku.git

# 使用替代的弹幕包
flutter_danmaku: ^1.0.0  # 需要相应修改导入语句
```

### 方案4：临时禁用弹幕功能
```yaml
# 暂时注释掉弹幕依赖
# flutter_ns_danmaku:
#   git:
#     url: https://github.com/lucinhu/flutter_ns_danmaku.git
```

然后在代码中添加条件编译：
```dart
// 在bili_danmaku.dart文件顶部添加
// ignore_for_file: unused_import
import 'package:flutter/material.dart';

// 注释掉弹幕相关的导入
// import 'package:flutter_ns_danmaku/danmaku_controller.dart';
// import 'package:flutter_ns_danmaku/danmaku_view.dart';
// ... 其他弹幕相关导入

class BiliDanmaku extends StatefulWidget {
  // ... 现有代码
  
  @override
  Widget build(BuildContext context) {
    // 临时返回空容器，禁用弹幕功能
    return Container(
      child: Text('弹幕功能暂时不可用'),
    );
  }
}
```

## 建议操作顺序
1. 先尝试方案1（配置Git）
2. 如果仍有问题，尝试方案2（手动下载）
3. 最后考虑方案3或4（使用替代包或临时禁用）