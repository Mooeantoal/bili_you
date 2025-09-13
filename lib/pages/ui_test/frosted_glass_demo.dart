import 'package:flutter/material.dart';
import 'package:bili_you/common/widget/frosted_glass_card.dart'; // 使用自定义的 FrostedGlassCard

class FrostedGlassDemoPage extends StatelessWidget {
  const FrostedGlassDemoPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('液态玻璃效果演示'),
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
              // 默认的毛玻璃效果
              FrostedGlassCard(
                blurSigma: 10.0,
                backgroundColor: Colors.white.withOpacity(0.2),
                child: const Center(
                  child: Text(
                    '默认毛玻璃效果',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              
              // 自定义的毛玻璃效果
              FrostedGlassCard(
                blurSigma: 15.0,
                backgroundColor: Colors.blue.withOpacity(0.15),
                borderRadius: 20,
                padding: const EdgeInsets.all(16),
                child: const Center(
                  child: Text(
                    '自定义毛玻璃效果',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              
              // 低透明度的毛玻璃效果（更接近iOS液态玻璃）
              FrostedGlassCard(
                blurSigma: 10.0,
                backgroundColor: Colors.white.withOpacity(0.1),
                borderRadius: 15,
                padding: const EdgeInsets.all(16),
                child: const Center(
                  child: Text(
                    'iOS风格液态玻璃',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}