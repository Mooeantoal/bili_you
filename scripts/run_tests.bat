@echo off
chcp 65001 >nul
echo 🧪 bili_you 项目测试运行器

echo.
echo 📋 可用的测试选项：
echo 1. 运行所有测试
echo 2. 运行单元测试
echo 3. 运行 Widget 测试
echo 4. 运行集成测试
echo 5. 运行覆盖率测试
echo 6. 生成测试报告
echo 0. 退出

set /p choice="请选择要运行的测试类型 (0-6): "

if "%choice%"=="1" goto run_all_tests
if "%choice%"=="2" goto run_unit_tests
if "%choice%"=="3" goto run_widget_tests
if "%choice%"=="4" goto run_integration_tests
if "%choice%"=="5" goto run_coverage_tests
if "%choice%"=="6" goto generate_reports
if "%choice%"=="0" goto exit
goto invalid_choice

:run_all_tests
echo.
echo 🚀 运行所有测试...
flutter test
goto end

:run_unit_tests
echo.
echo 🔧 运行单元测试...
flutter test test/unit/
goto end

:run_widget_tests
echo.
echo 🎨 运行 Widget 测试...
flutter test test/widget/
goto end

:run_integration_tests
echo.
echo 🔗 运行集成测试...
echo 注意：集成测试需要设备或模拟器
flutter test integration_test/
goto end

:run_coverage_tests
echo.
echo 📊 运行覆盖率测试...
flutter test --coverage
echo 生成覆盖率报告...
if exist coverage\lcov.info (
    echo 覆盖率报告已生成: coverage\lcov.info
) else (
    echo 覆盖率报告生成失败
)
goto end

:generate_reports
echo.
echo 📄 生成测试报告...
if not exist test\reports mkdir test\reports
flutter test --reporter json > test\reports\test-results.json
echo 测试报告已生成: test\reports\test-results.json
goto end

:invalid_choice
echo.
echo ❌ 无效选择，请重新运行脚本
goto end

:exit
echo.
echo 👋 退出测试运行器
goto end

:end
echo.
echo ✅ 测试运行完成！
pause