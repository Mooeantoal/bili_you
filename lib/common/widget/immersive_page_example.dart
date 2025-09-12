import 'package:flutter/material.dart';
import '../utils/immersive_utils.dart';

/// 沉浸式页面示例
/// 展示如何在特定页面中使用沉浸式功能
class ImmersivePageExample extends StatefulWidget {
  const ImmersivePageExample({super.key});

  @override
  State<ImmersivePageExample> createState() => _ImmersivePageExampleState();
}

class _ImmersivePageExampleState extends State<ImmersivePageExample> {
  bool _isFullscreen = false;
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    // 页面初始化时确保沉浸式状态正确
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ImmersiveUtils.updateSystemUIOverlay();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 使用SafeArea确保内容不被状态栏和导航栏遮挡
      body: SafeArea(
        child: Column(
          children: [
            AppBar(
              title: const Text('沉浸式体验示例'),
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      '沉浸式功能演示',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // 全屏模式切换
                    Card(
                      child: ListTile(
                        title: const Text('全屏模式'),
                        subtitle: Text(_isFullscreen ? '当前已全屏' : '点击进入全屏'),
                        trailing: Switch(
                          value: _isFullscreen,
                          onChanged: _toggleFullscreen,
                        ),
                        onTap: () => _toggleFullscreen(!_isFullscreen),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // 主题模式切换
                    Card(
                      child: ListTile(
                        title: const Text('深色模式'),
                        subtitle: Text(_isDarkMode ? '当前为深色主题' : '当前为浅色主题'),
                        trailing: Switch(
                          value: _isDarkMode,
                          onChanged: _toggleTheme,
                        ),
                        onTap: () => _toggleTheme(!_isDarkMode),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // 手动控制按钮
                    const Text(
                      '手动控制系统UI',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              ImmersiveUtils.setLightSystemUI();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('已设置为浅色系统UI')),
                              );
                            },
                            child: const Text('浅色UI'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              ImmersiveUtils.setDarkSystemUI();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('已设置为深色系统UI')),
                              );
                            },
                            child: const Text('深色UI'),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    ElevatedButton(
                      onPressed: () {
                        ImmersiveUtils.setAutoSystemUI(ThemeMode.system);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('已恢复自动适配主题')),
                        );
                      },
                      child: const Text('自动适配系统主题'),
                    ),
                    
                    const Spacer(),
                    
                    // 说明文本
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        '本页面展示了沉浸式状态栏和导航栏的各种功能：\n'
                        '• 状态栏和导航栏完全透明\n'
                        '• 智能适配浅色/深色主题\n'
                        '• 支持全屏模式切换\n'
                        '• 实时响应系统主题变化',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleFullscreen(bool value) async {
    setState(() {
      _isFullscreen = value;
    });

    if (value) {
      await ImmersiveUtils.enterFullscreen();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('已进入全屏模式，点击返回键退出')),
        );
      }
    } else {
      await ImmersiveUtils.exitFullscreen();
    }
  }

  void _toggleTheme(bool value) async {
    setState(() {
      _isDarkMode = value;
    });

    if (value) {
      await ImmersiveUtils.setDarkSystemUI();
    } else {
      await ImmersiveUtils.setLightSystemUI();
    }
  }

  @override
  void dispose() {
    // 页面销毁时恢复默认状态
    if (_isFullscreen) {
      ImmersiveUtils.exitFullscreen();
    } else {
      ImmersiveUtils.updateSystemUIOverlay();
    }
    super.dispose();
  }
}