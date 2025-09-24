# 该脚本需要在项目根目录执行
echo 编译linux版AppImage包到build目录...
flutter build linux --release
rm -rf scripts/bili_me.AppDir/opt/
cp -r build/linux/x64/release/bundle/ scripts/bili_me.AppDir/opt/
appimagetool scripts/bili_me.AppDir build/BiliMe-x86_64.AppImage
rm -rf scripts/bili_me.AppDir/opt/
rm scripts/bili_me.AppDir/.DirIcon
