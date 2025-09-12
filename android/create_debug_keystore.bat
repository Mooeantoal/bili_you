@echo off
echo 正在创建Android Debug Keystore...

REM 使用Flutter的bundled Java (如果可用)
if exist "%LOCALAPPDATA%\Android\Sdk\cmdline-tools\latest\bin\keytool.bat" (
    "%LOCALAPPDATA%\Android\Sdk\cmdline-tools\latest\bin\keytool.bat" -genkey -v -keystore debug.keystore -alias debug -keyalg RSA -keysize 2048 -validity 10000 -storepass android -keypass android -dname "CN=Debug, OU=Development, O=BiliYou, L=Beijing, S=Beijing, C=CN"
    goto success
)

REM 尝试系统PATH中的keytool
keytool -genkey -v -keystore debug.keystore -alias debug -keyalg RSA -keysize 2048 -validity 10000 -storepass android -keypass android -dname "CN=Debug, OU=Development, O=BiliYou, L=Beijing, S=Beijing, C=CN" 2>nul
if %errorlevel% == 0 goto success

echo 错误: 无法找到keytool工具
echo 请确保已安装Java JDK或Android SDK
echo 或者手动从Android Studio复制debug keystore文件
pause
exit /b 1

:success
echo.
echo ✅ Keystore创建成功: debug.keystore
echo 别名: debug
echo 密码: android
echo.
echo 现在可以进行自动签名构建了！
pause