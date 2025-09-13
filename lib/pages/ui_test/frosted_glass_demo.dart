import 'package:flutter/material.dart';
import 'package:frosted_glass/frosted_glass.dart';

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
              FrostedGlass(
                width: 300,
                height: 100,
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
              FrostedGlass(
                width: 300,
                height: 100,
                blur: 15.0,
                opacity: 0.15,
                borderRadius: BorderRadius.circular(20),
                padding: const EdgeInsets.all(16),
                overlayColor: Colors.blue,
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
              FrostedGlass(
                width: 300,
                height: 100,
                blur: 10.0,
                opacity: 0.1,
                borderRadius: BorderRadius.circular(15),
                padding: const EdgeInsets.all(16),
                overlayColor: Colors.white,
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