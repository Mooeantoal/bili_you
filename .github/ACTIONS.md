# GitHub Actions 自动构建配置

本项目配置了GitHub Actions自动构建系统，可以自动构建Android APK文件。

## 🔧 工作流配置

### 1. 主构建工作流 (`main.yml`)

**触发条件：**
- 推送tag时自动构建并发布 (如 `v1.1.5`)
- 手动触发构建

**功能特性：**
- ✅ 自动构建多架构APK (arm64-v8a, armeabi-v7a, x86_64)
- ✅ 支持APK签名 (需配置签名密钥)
- ✅ 自动创建GitHub Release
- ✅ 智能文件重命名 (包含版本信息)
- ✅ 代码分析和质量检查 (严格模式，必须通过)
- ✅ 构建产物上传

### 2. 构建测试工作流 (`build-test.yml`)

**触发条件：**
- 推送到主分支 (main/master/develop)
- 创建Pull Request

**功能特性：**
- ✅ 快速构建测试 (debug模式)
- ✅ 代码分析 (严格模式，任何警告或错误都会导致失败)
- ✅ 单元测试执行
- ✅ 构建产物验证

## 🔐 签名配置 (可选)

如果需要发布正式签名的APK，需要在GitHub仓库设置中添加以下Secrets：

### 必需的Secrets：

1. **KEYSTORE** - Base64编码的keystore文件
   ```bash
   base64 -w 0 your-keystore.jks
   ```

2. **KEYSTORE_PASSWORD** - keystore密码

3. **KEY_ALIAS** - 密钥别名

4. **KEY_PASSWORD** - 密钥密码

### 设置Secrets步骤：

1. 进入GitHub仓库
2. 点击 Settings → Secrets and variables → Actions
3. 点击 "New repository secret"
4. 添加上述四个secrets

## 🚀 使用方法

### 自动发布 (推荐)

1. **创建并推送tag：**
   ```bash
   git tag v1.1.6
   git push origin v1.1.6
   ```

2. **GitHub Actions会自动：**
   - 构建多架构APK
   - 创建GitHub Release
   - 上传APK文件到Release

### 手动构建

1. 进入GitHub仓库的Actions页面
2. 选择 "Build and Release APK" 工作流
3. 点击 "Run workflow"
4. 输入版本号 (可选)
5. 点击 "Run workflow" 按钮

## 📦 APK文件说明

构建完成后会生成以下APK文件：

- **bili_you_*_arm64-v8a.apk** - 64位ARM设备 (推荐，支持大部分现代Android设备)
- **bili_you_*_armeabi-v7a.apk** - 32位ARM设备 (兼容老设备)
- **bili_you_*_x86_64.apk** - 64位x86设备 (模拟器或特殊设备)

## 🛠️ 本地构建命令

如果需要在本地构建，可以使用以下命令：

```bash
# 获取依赖
flutter pub get

# 构建release APK (分架构)
flutter build apk --release --split-per-abi

# 构建debug APK
flutter build apk --debug

# 构建单个架构 (更快)
flutter build apk --release --target-platform android-arm64
```

## 📊 构建状态

- [![Build and Release APK](../../actions/workflows/main.yml/badge.svg)](../../actions/workflows/main.yml)
- [![Build Test](../../actions/workflows/build-test.yml/badge.svg)](../../actions/workflows/build-test.yml)

## ⚠️ 注意事项

1. **Flutter版本：** 工作流使用Flutter 3.16.0，确保本地开发环境兼容
2. **签名配置：** 未配置签名密钥时会构建未签名APK
3. **构建时间：** 完整构建大约需要10-15分钟
4. **存储空间：** 构建产物会占用GitHub Actions存储空间

## 🔍 故障排除

### 常见问题：

1. **构建失败：**
   - 检查Flutter版本兼容性
   - 查看Actions日志中的错误信息
   - 确认依赖版本是否正确

2. **签名失败：**
   - 验证所有签名相关Secrets是否正确设置
   - 检查keystore文件是否正确编码

3. **Release创建失败：**
   - 确认tag格式正确 (以v开头，如v1.1.5)
   - 检查GitHub token权限

如有其他问题，请查看Actions运行日志或创建Issue。