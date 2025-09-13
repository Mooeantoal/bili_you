import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';

class LiquidGlassDemoPage extends StatelessWidget {
  const LiquidGlassDemoPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('液态玻璃效果演示 (glassmorphism)'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(
              'https://picsum.photos/seed/picsum/600/1000',
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // 默认的液态玻璃效果
              _buildLiquidGlassContainer(
                context,
                '默认液态玻璃效果',
                20.0,
                0.2,
              ),
              
              // 高模糊度的液态玻璃效果
              _buildLiquidGlassContainer(
                context,
                '高模糊度效果',
                30.0,
                0.15,
              ),
              
              // 彩色液态玻璃效果
              _buildColoredLiquidGlassContainer(
                context,
                '彩色液态玻璃',
                Colors.blue,
                0.2, // 添加 opacity 参数
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLiquidGlassContainer(
    BuildContext context,
    String title,
    double blur,
    double opacity, // 使用 opacity 参数
  ) {
    return GlassmorphicContainer(
      width: 300,
      height: 120,
      borderRadius: 20,
      blur: blur,
      border: 2,
      linearGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Theme.of(context).colorScheme.primary.withOpacity(0.1 * (opacity / 0.2)),
          Theme.of(context).colorScheme.primary.withOpacity(0.05 * (opacity / 0.2)),
        ],
        stops: const [0.1, 1],
      ),
      borderGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Theme.of(context).colorScheme.primary.withOpacity(0.5 * (opacity / 0.2)),
          Theme.of(context).colorScheme.primary.withOpacity(0.5 * (opacity / 0.2)),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildColoredLiquidGlassContainer(
    BuildContext context,
    String title,
    Color color,
    double opacity, // 添加 opacity 参数
  ) {
    return GlassmorphicContainer(
      width: 300,
      height: 120,
      borderRadius: 20,
      blur: 20.0,
      border: 2,
      linearGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          color.withOpacity(0.1 * (opacity / 0.2)),
          color.withOpacity(0.05 * (opacity / 0.2)),
        ],
        stops: const [0.1, 1],
      ),
      borderGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          color.withOpacity(0.5 * (opacity / 0.2)),
          color.withOpacity(0.5 * (opacity / 0.2)),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}