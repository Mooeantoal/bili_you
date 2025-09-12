@echo off
chcp 65001 >nul
echo 🔍 验证测试框架配置

echo.
echo 📋 检查测试目录结构：

if exist "test" (
    echo ✅ test 目录存在
) else (
    echo ❌ test 目录不存在
    exit /b 1
)

if exist "test\unit" (
    echo ✅ test\unit 目录存在
) else (
    echo ❌ test\unit 目录不存在
)

if exist "test\widget" (
    echo ✅ test\widget 目录存在
) else (
    echo ❌ test\widget 目录不存在
)

if exist "test\integration" (
    echo ✅ test\integration 目录存在
) else (
    echo ❌ test\integration 目录不存在
)

echo.
echo 📋 检查测试文件：

set test_files=test\widget_test.dart test\unit\string_format_utils_test.dart test\unit\bvid_avid_util_test.dart test\widget\avatar_widget_test.dart test\test_helper.dart

for %%f in (%test_files%) do (
    if exist "%%f" (
        echo ✅ %%f 存在
    ) else (
        echo ❌ %%f 不存在
    )
)

echo.
echo 📋 检查测试配置：

if exist "test\dart_test.yaml" (
    echo ✅ 测试配置文件存在
) else (
    echo ⚠️  测试配置文件不存在
)

echo.
echo 📋 检查pubspec.yaml测试依赖：

findstr /C:"flutter_test:" pubspec.yaml >nul
if !errorlevel! == 0 (
    echo ✅ flutter_test 依赖已配置
) else (
    echo ❌ flutter_test 依赖未配置
)

findstr /C:"test:" pubspec.yaml >nul
if !errorlevel! == 0 (
    echo ✅ test 依赖已配置
) else (
    echo ❌ test 依赖未配置
)

findstr /C:"mockito:" pubspec.yaml >nul
if !errorlevel! == 0 (
    echo ✅ mockito 依赖已配置
) else (
    echo ⚠️  mockito 依赖未配置
)

echo.
echo 📋 检查测试运行脚本：

if exist "scripts\run_tests.bat" (
    echo ✅ Windows 测试脚本存在
) else (
    echo ❌ Windows 测试脚本不存在
)

if exist "scripts\run_tests.sh" (
    echo ✅ Linux/macOS 测试脚本存在
) else (
    echo ❌ Linux/macOS 测试脚本不存在
)

echo.
echo 🚀 测试框架配置验证完成！

echo.
echo 📝 下一步操作：
echo 1. 运行 flutter pub get 安装测试依赖
echo 2. 运行 flutter test 验证测试
echo 3. 使用 scripts\run_tests.bat 运行特定测试
echo 4. 查看 .github\TESTING_GUIDE.md 了解详细说明

echo.
echo 📖 详细测试指南：.github\TESTING_GUIDE.md

pause