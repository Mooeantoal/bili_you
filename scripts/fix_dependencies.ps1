# PowerShell script to fix Flutter dependencies
Write-Host "清理Flutter缓存..." -ForegroundColor Green
flutter clean

Write-Host "删除依赖锁定文件..." -ForegroundColor Green
if (Test-Path "pubspec.lock") { Remove-Item "pubspec.lock" }
if (Test-Path ".packages") { Remove-Item ".packages" -Recurse }

Write-Host "配置Git使用HTTPS..." -ForegroundColor Green
git config --global url."https://github.com/".insteadOf "git@github.com:"

Write-Host "重新获取依赖..." -ForegroundColor Green
flutter pub get

Write-Host "验证依赖..." -ForegroundColor Green
flutter pub deps

Write-Host "完成!" -ForegroundColor Green