#!/bin/bash

# bili_you 项目测试运行器

echo "🧪 bili_you 项目测试运行器"
echo ""
echo "📋 可用的测试选项："
echo "1. 运行所有测试"
echo "2. 运行单元测试"
echo "3. 运行 Widget 测试"
echo "4. 运行集成测试"
echo "5. 运行覆盖率测试"
echo "6. 生成测试报告"
echo "0. 退出"
echo ""

read -p "请选择要运行的测试类型 (0-6): " choice

case $choice in
    1)
        echo ""
        echo "🚀 运行所有测试..."
        flutter test
        ;;
    2)
        echo ""
        echo "🔧 运行单元测试..."
        flutter test test/unit/
        ;;
    3)
        echo ""
        echo "🎨 运行 Widget 测试..."
        flutter test test/widget/
        ;;
    4)
        echo ""
        echo "🔗 运行集成测试..."
        echo "注意：集成测试需要设备或模拟器"
        flutter test integration_test/
        ;;
    5)
        echo ""
        echo "📊 运行覆盖率测试..."
        flutter test --coverage
        echo "生成覆盖率报告..."
        if [ -f "coverage/lcov.info" ]; then
            echo "覆盖率报告已生成: coverage/lcov.info"
        else
            echo "覆盖率报告生成失败"
        fi
        ;;
    6)
        echo ""
        echo "📄 生成测试报告..."
        mkdir -p test/reports
        flutter test --reporter json > test/reports/test-results.json
        echo "测试报告已生成: test/reports/test-results.json"
        ;;
    0)
        echo ""
        echo "👋 退出测试运行器"
        exit 0
        ;;
    *)
        echo ""
        echo "❌ 无效选择，请重新运行脚本"
        exit 1
        ;;
esac

echo ""
echo "✅ 测试运行完成！"