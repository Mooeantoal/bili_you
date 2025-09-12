#!/bin/bash
# 清理Flutter缓存并重新获取依赖

echo "清理Flutter缓存..."
flutter clean

echo "删除依赖锁定文件..."
rm -f pubspec.lock
rm -rf .packages

echo "重新获取依赖..."
flutter pub get

echo "验证依赖..."
flutter pub deps