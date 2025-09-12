# Android Debug Keystore 创建脚本
Write-Host "正在创建Android Debug Keystore..." -ForegroundColor Green

$keystorePath = "debug.keystore"
$alias = "debug"
$password = "android"

# 检查是否已存在
if (Test-Path $keystorePath) {
    Write-Host "Keystore文件已存在: $keystorePath" -ForegroundColor Yellow
    Write-Host "如需重新创建，请先删除现有文件"
    Read-Host "按回车键继续"
    exit
}

# 定义keytool命令
$keytoolCmd = "keytool -genkey -v -keystore $keystorePath -alias $alias -keyalg RSA -keysize 2048 -validity 10000 -storepass $password -keypass $password -dname `"CN=Debug, OU=Development, O=BiliYou, L=Beijing, S=Beijing, C=CN`""

try {
    # 尝试执行keytool命令
    Invoke-Expression $keytoolCmd
    Write-Host ""
    Write-Host "✅ Keystore创建成功!" -ForegroundColor Green
    Write-Host "文件: $keystorePath" -ForegroundColor Cyan
    Write-Host "别名: $alias" -ForegroundColor Cyan
    Write-Host "密码: $password" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "现在可以进行自动签名构建了！" -ForegroundColor Green
}
catch {
    Write-Host "❌ 创建失败: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "可能的解决方案:" -ForegroundColor Yellow
    Write-Host "1. 安装Java JDK" -ForegroundColor White
    Write-Host "2. 安装Android SDK" -ForegroundColor White
    Write-Host "3. 从Android Studio复制debug keystore" -ForegroundColor White
    Write-Host "   位置通常在: C:\Users\$env:USERNAME\.android\debug.keystore" -ForegroundColor Gray
}

Read-Host "按回车键继续"