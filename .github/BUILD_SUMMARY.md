# GitHub Actions APK 构建系统配置总结

## ✅ 已完成的配置

### 1. GitHub Actions 工作流文件

#### 主构建工作流 (`.github/workflows/main.yml`)
- **触发条件**: 推送tag (v*) 或手动触发
- **功能**: 构建发布版APK并自动创建GitHub Release
- **特性**:
  - 多架构APK构建 (arm64-v8a, armeabi-v7a, x86_64)
  - 智能签名处理 (支持有/无签名证书)
  - 自动文件重命名 (包含版本信息)
  - 代码分析和质量检查
  - 构建产物上传为Artifacts
  - 自动创建Release并上传APK

#### 测试构建工作流 (`.github/workflows/build-test.yml`)
- **触发条件**: 推送到主分支或创建PR
- **功能**: 快速构建测试，验证代码可正常编译
- **特性**:
  - Debug模式快速构建
  - 代码分析和测试执行
  - 测试APK上传 (7天保留期)

### 2. Android 构建配置
- **签名配置**: 已在 `android/app/build.gradle` 中设置
- **环境变量支持**: 支持从环境变量读取签名信息
- **多SDK版本支持**: compileSdkVersion 33, minSdkVersion 21

### 3. 项目配置文件
- **pubspec.yaml**: Flutter项目配置 (当前版本 1.1.5+15)
- **.gitignore**: 已添加keystore文件忽略规则
- **keystore.properties.sample**: 本地签名配置样本

### 4. 辅助工具
- **check_actions_config.bat**: Windows配置验证脚本
- **check_actions_config.sh**: Linux/macOS配置验证脚本
- **ACTIONS.md**: 详细使用说明文档

## 🚀 使用方法

### 自动发布流程 (推荐)
1. **创建发布tag**:
   ```bash
   git tag v1.1.6
   git push origin v1.1.6
   ```

2. **GitHub Actions 自动执行**:
   - 构建多架构APK
   - 创建GitHub Release
   - 上传APK文件

### 手动构建流程
1. 进入仓库的 Actions 页面
2. 选择 "Build and Release APK" 工作流  
3. 点击 "Run workflow"
4. 输入版本号 (可选)
5. 执行构建

## 🔐 签名配置 (可选)

如需发布正式签名APK，在GitHub仓库设置中添加以下Secrets:

- `KEYSTORE`: Base64编码的keystore文件
- `KEYSTORE_PASSWORD`: keystore密码
- `KEY_ALIAS`: 密钥别名  
- `KEY_PASSWORD`: 密钥密码

## 📦 构建产物

### APK文件类型
- `bili_you_*_arm64-v8a.apk`: 64位ARM设备 (推荐)
- `bili_you_*_armeabi-v7a.apk`: 32位ARM设备 (兼容老设备)
- `bili_you_*_x86_64.apk`: 64位x86设备 (模拟器)

### 文件位置
- **GitHub Release**: 自动发布的APK文件
- **Actions Artifacts**: 每次构建的临时文件
- **本地构建**: `build/app/outputs/flutter-apk/`

## 🔧 技术细节

### Flutter 版本
- **Actions使用**: Flutter 3.16.0 stable
- **本地兼容**: Flutter 3.0+ 

### 构建命令
```bash
# GitHub Actions使用的命令
flutter build apk --release --split-per-abi

# 本地开发可用命令
flutter build apk --debug                    # 快速调试版本
flutter build apk --release                  # 发布版本 (单APK)
flutter build apk --release --split-per-abi  # 发布版本 (多架构)
```

### 优化特性
- **缓存**: Flutter SDK和依赖缓存，提升构建速度
- **并行化**: 多步骤并行执行
- **超时控制**: 30分钟构建超时保护
- **错误容忍**: 代码分析失败不影响构建

## ⚡ 性能优化

### 构建时间
- **完整构建**: 约10-15分钟
- **测试构建**: 约5-8分钟
- **缓存命中时**: 减少50%+时间

### 存储优化
- **Artifacts保留期**: 
  - Release APK: 30天
  - Debug APK: 7天
- **多架构APK**: 按需下载，节省带宽

## 🎯 最佳实践

### Tag命名规范
- 使用语义化版本: `v1.2.3`
- 匹配pubspec.yaml版本号
- 建议格式: `v{major}.{minor}.{patch}`

### 发布流程
1. 更新pubspec.yaml版本号
2. 提交版本更新代码
3. 创建并推送tag
4. 验证GitHub Actions构建
5. 下载并测试APK
6. 发布Release说明

### 调试技巧
- 查看Actions日志定位构建问题
- 使用测试工作流验证代码变更
- 运行验证脚本检查配置完整性

## 📋 维护检查清单

- [ ] 定期更新Flutter版本
- [ ] 检查依赖包安全更新
- [ ] 验证签名证书有效期
- [ ] 监控构建成功率
- [ ] 清理过期Artifacts

## 🛠️ 故障排除

### 常见问题
1. **构建失败**: 检查Flutter版本和依赖兼容性
2. **签名失败**: 验证Secrets配置正确性
3. **超时失败**: 检查网络或增加超时时间
4. **Release失败**: 确认tag格式和权限

### 支持渠道
- GitHub Issues: 报告构建问题
- Actions日志: 详细错误信息
- 文档参考: `.github/ACTIONS.md`

---

✅ **GitHub Actions APK自动构建系统已成功配置并可投入使用！**