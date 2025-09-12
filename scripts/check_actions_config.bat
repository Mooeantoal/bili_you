@echo off
chcp 65001 >nul
setlocal EnableDelayedExpansion
echo 🔍 验证 GitHub Actions 配置...

REM 检查工作流文件
echo.
echo 📋 检查工作流文件：
if exist ".github\workflows\main.yml" (
    echo ✅ 主构建工作流文件存在
) else (
    echo ❌ 主构建工作流文件不存在
    exit /b 1
)

if exist ".github\workflows\build-test.yml" (
    echo ✅ 测试构建工作流文件存在
) else (
    echo ⚠️  测试构建工作流文件不存在
)

REM 检查Flutter配置
echo.
echo 📋 检查Flutter配置：
if exist "pubspec.yaml" (
    echo ✅ pubspec.yaml 存在
    
    REM 检查版本信息
    for /f "tokens=2" %%a in ('findstr "^version:" pubspec.yaml') do (
        echo 📌 当前版本: %%a
    )
) else (
    echo ❌ pubspec.yaml 不存在
    exit /b 1
)

REM 检查Android配置
echo.
echo 📋 检查Android配置：
if exist "android\app\build.gradle" (
    echo ✅ Android build.gradle 存在
    
    REM 检查签名配置
    findstr /C:"signingConfigs" "android\app\build.gradle" >nul 2>&1
    if !errorlevel! == 0 (
        echo ✅ 签名配置已设置
    ) else (
        echo ⚠️  签名配置未找到
    )
) else (
    echo ❌ Android build.gradle 不存在
    exit /b 1
)

REM 检查签名文件样本
if exist "android\keystore.properties.sample" (
    echo ✅ 签名配置样本文件存在
) else (
    echo ⚠️  签名配置样本文件不存在
)

REM 检查.gitignore
echo.
echo 📋 检查.gitignore配置：
if exist ".gitignore" (
    echo ✅ .gitignore 存在
    
    findstr /C:"keystore.properties" ".gitignore" >nul 2>&1
    if !errorlevel! == 0 (
        echo ✅ 签名文件已加入忽略列表
    ) else (
        echo ⚠️  签名文件未加入忽略列表
    )
) else (
    echo ❌ .gitignore 不存在
)

echo.
echo 🚀 配置验证完成！
echo.
echo 📝 下一步操作：
echo 1. 如需自动发布，请配置GitHub Secrets（见 .github\ACTIONS.md）
echo 2. 创建tag来触发构建：git tag v1.x.x ^&^& git push origin v1.x.x
echo 3. 或手动运行GitHub Actions工作流
echo.
echo 📖 详细说明请查看：.github\ACTIONS.md

pause