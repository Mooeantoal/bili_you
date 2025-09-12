#!/bin/bash

# GitHub Actions 配置验证脚本
# 用于验证GitHub Actions构建配置是否正确

echo "🔍 验证 GitHub Actions 配置..."

# 检查工作流文件
echo ""
echo "📋 检查工作流文件："
if [ -f ".github/workflows/main.yml" ]; then
    echo "✅ 主构建工作流文件存在"
else
    echo "❌ 主构建工作流文件不存在"
    exit 1
fi

if [ -f ".github/workflows/build-test.yml" ]; then
    echo "✅ 测试构建工作流文件存在"
else
    echo "⚠️  测试构建工作流文件不存在"
fi

# 检查Flutter配置
echo ""
echo "📋 检查Flutter配置："
if [ -f "pubspec.yaml" ]; then
    echo "✅ pubspec.yaml 存在"
    
    # 检查版本信息
    VERSION=$(grep "^version:" pubspec.yaml | cut -d' ' -f2)
    echo "📌 当前版本: $VERSION"
else
    echo "❌ pubspec.yaml 不存在"
    exit 1
fi

# 检查Android配置
echo ""
echo "📋 检查Android配置："
if [ -f "android/app/build.gradle" ]; then
    echo "✅ Android build.gradle 存在"
    
    # 检查签名配置
    if grep -q "signingConfigs" "android/app/build.gradle"; then
        echo "✅ 签名配置已设置"
    else
        echo "⚠️  签名配置未找到"
    fi
else
    echo "❌ Android build.gradle 不存在"
    exit 1
fi

# 检查签名文件样本
if [ -f "android/keystore.properties.sample" ]; then
    echo "✅ 签名配置样本文件存在"
else
    echo "⚠️  签名配置样本文件不存在"
fi

# 检查.gitignore
echo ""
echo "📋 检查.gitignore配置："
if [ -f ".gitignore" ]; then
    echo "✅ .gitignore 存在"
    
    if grep -q "keystore.properties" ".gitignore"; then
        echo "✅ 签名文件已加入忽略列表"
    else
        echo "⚠️  签名文件未加入忽略列表"
    fi
else
    echo "❌ .gitignore 不存在"
fi

echo ""
echo "🚀 配置验证完成！"
echo ""
echo "📝 下一步操作："
echo "1. 如需自动发布，请配置GitHub Secrets（见 .github/ACTIONS.md）"
echo "2. 创建tag来触发构建：git tag v1.x.x && git push origin v1.x.x"
echo "3. 或手动运行GitHub Actions工作流"
echo ""
echo "📖 详细说明请查看：.github/ACTIONS.md"