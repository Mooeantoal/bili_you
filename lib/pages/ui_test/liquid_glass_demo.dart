import 'package:flutter/material.dart';
import 'package:oc_liquid_glass/oc_liquid_glass.dart';

class LiquidGlassDemoPage extends StatelessWidget {
  const LiquidGlassDemoPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('液态玻璃效果演示 (oc_liquid_glass)'),
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
                const OCLiquidGlassSettings(),
              ),
              
              // 自定义的液态玻璃效果
              _buildLiquidGlassContainer(
                context,
                '强折射效果',
                const OCLiquidGlassSettings(
                  refractStrength: -0.15,
                  blurRadiusPx: 3.0,
                  specStrength: 35.0,
                ),
              ),
              
              // 彩色液态玻璃效果
              _buildLiquidGlassContainer(
                context,
                '彩色液态玻璃',
                const OCLiquidGlassSettings(
                  refractStrength: -0.05,
                  blurRadiusPx: 1.5,
                  specStrength: 20.0,
                  lightbandColor: Colors.blue,
                ),
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
    OCLiquidGlassSettings settings,
  ) {
    return OCLiquidGlassGroup(
      settings: settings,
      child: OCLiquidGlass(
        width: 300,
        height: 120,
        borderRadius: 20,
        color: Theme.of(context).colorScheme.primary.withOpacity(0.25),
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
      ),
    );
  }
}