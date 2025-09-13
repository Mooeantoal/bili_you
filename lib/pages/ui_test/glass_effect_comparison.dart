import 'package:flutter/material.dart';
import 'package:bili_you/common/widget/frosted_glass_card.dart';
import 'package:oc_liquid_glass/oc_liquid_glass.dart';

class GlassEffectComparisonPage extends StatelessWidget {
  const GlassEffectComparisonPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('玻璃效果对比'),
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // 标题
              const Text(
                '玻璃效果对比',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              
              // frosted_glass 效果
              _buildFrostedGlassCard(context),
              
              // oc_liquid_glass 效果
              _buildLiquidGlassCard(context),
              
              // 说明文本
              const Text(
                '上方为 frosted_glass 效果（基于 BackdropFilter）\n下方为 oc_liquid_glass 效果（基于 Shader）',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFrostedGlassCard(BuildContext context) {
    return FrostedGlassCard(
      borderRadius: 20.0,
      backgroundColor: Colors.white.withOpacity(0.2),
      blurSigma: 10.0,
      padding: const EdgeInsets.all(20),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.filter_vintage,
            size: 40,
            color: Colors.white,
          ),
          SizedBox(height: 10),
          Text(
            'Frosted Glass 效果',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 5),
          Text(
            '基于 BackdropFilter 实现',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiquidGlassCard(BuildContext context) {
    return OCLiquidGlassGroup(
      settings: const OCLiquidGlassSettings(
        refractStrength: -0.08,
        blurRadiusPx: 2.0,
        specStrength: 25.0,
      ),
      child: OCLiquidGlass(
        width: double.infinity,
        height: 120,
        borderRadius: 20,
        color: Colors.white.withOpacity(0.25),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.water_drop,
                size: 40,
                color: Colors.white,
              ),
              SizedBox(height: 10),
              Text(
                'Liquid Glass 效果',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 5),
              Text(
                '基于 Shader 实现',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}