# 技术债务跟踪

## 待实现功能 (TODO)

### 高优先级
- [ ] **iOS更新功能** (`lib/common/utils/settings.dart:120`)
  - 需要实现iOS平台的应用更新逻辑
  - 可能需要跳转到App Store

### 中优先级  
- [ ] **搜索功能扩展** (`lib/pages/search_tab_view/view.dart:75-76`)
  - [ ] 电影搜索 (SearchType.movie)
  - [ ] 直播间搜索 (SearchType.liveRoom)

- [ ] **视频标签功能** (`lib/pages/bili_video/widgets/introduction/view.dart:54`)
  - 显示视频相关标签

- [ ] **用户动态查看** (`lib/pages/home/widgets/user_menu/view.dart:150`)
  - 实现查看用户发布的动态功能

## 代码质量改进

### 清理任务
- [ ] **移除未使用的代码**
  - `_Fnval` 枚举 (`lib/common/api/video_play_api.dart:147`)
  - 其他未使用的字段和导入

### 弃用警告
- [ ] **更新protobuf依赖**
  - 当前版本: ^3.0.0
  - 建议升级到最新版本以减少弃用警告

## 配置优化

### 已完成 ✅
- [x] **改进代码分析配置** (analysis_options.yaml)
  - 添加了更严格的linter规则
  - 排除了自动生成的文件

### 待优化
- [ ] **Android构建配置**
  - 完善应用ID配置注释 (`android/app/build.gradle:58`)

## 性能优化建议

- [ ] **图片缓存优化**
  - 检查 cached_network_image 配置
  - 优化内存使用

- [ ] **弹幕性能**
  - 优化 ns_danmaku 插件性能
  - 减少弹幕渲染开销

## 安全检查

- [ ] **API安全**
  - 检查所有API调用是否使用HTTPS
  - 验证用户输入过滤

- [ ] **依赖安全**
  - 定期检查依赖版本安全漏洞
  - 使用 `flutter pub deps --style=compact` 检查依赖树

---

> 📝 **更新日期**: 2025-01-12
> 🎯 **目标**: 逐步清理技术债务，提升代码质量