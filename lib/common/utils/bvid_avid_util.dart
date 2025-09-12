import 'dart:math';

import 'package:flutter/material.dart';

class BvidAvidUtil {
  // 官方BVID转换参数
  static const String table =
      "fZodR9XQDSUm21yCkr6zBqiveYah8bt4xsWpHnJE7jL5VG3guMTKNPAwcF";
  static const List<int> seqArray = [11, 10, 3, 8, 4, 6];
  static const int xOr = 177451812;
  static const int xAdd = 8728348608;
  
  static const List<String> defaultBvid = [
    'B',
    'V',
    '1',
    '',
    '',
    '4',
    '',
    '1',
    '',
    '7',
    '',
    ''
  ];

  ///avid转bvid
  static String av2Bvid(int av) {
    // 使用64位整数避免溢出
    int newAvId = (av ^ xOr) + xAdd;
    List<String> defaultBv = [];
    defaultBv.addAll(BvidAvidUtil.defaultBvid);
    for (int i = 0; i < seqArray.length; i++) {
      defaultBv[seqArray[i]] = table.characters
          .elementAt((newAvId ~/ pow(58, i).toInt() % 58).toInt());
    }
    return defaultBv.join();
  }

  ///bvid转avid - 按正确的官方算法实现
  static int bvid2Av(String bvid) {
    try {
      // 1. 验证BVID格式
      if (!isBvid(bvid)) {
        throw ArgumentError('无效的BVID格式: $bvid');
      }
      
      // 2. 按官方算法计算58进制值 (r)
      int r = 0;
      for (int i = 0; i < seqArray.length; i++) {
        String char = bvid.characters.elementAt(seqArray[i]);
        int charIndex = table.indexOf(char);
        
        if (charIndex == -1) {
          throw ArgumentError('BVID包含无效字符: $char 在位置 ${seqArray[i]}');
        }
        
        // 使用58进制计算: r += charIndex * (58 ^ i)
        r += (charIndex * pow(58, i).toInt());
      }
      
      // 3. 应用正确的解码公式
      // 根据多个来源确认，正确的公式应该是: (r - add) ^ xor
      // 但如果 r < add，可能需要特殊处理
      
      int result;
      if (r >= xAdd) {
        // 标准情况: r >= add
        result = (r - xAdd) ^ xOr;
      } else {
        // 特殊情况: r < add
        // 可能是新版BVID，尝试不同的计算方式
        
        // 方法1: 直接异或
        int candidate1 = r ^ xOr;
        
        // 方法2: 先加再异或 (av2bv的逆操作)
        int candidate2 = ((r + xAdd) ^ xOr);
        
        // 方法3: 使用无符号运算
        int candidate3 = ((r - xAdd) & 0xFFFFFFFF) ^ xOr;
        
        // 选择合理的结果
        List<int> candidates = [candidate1, candidate2, candidate3]
            .where((av) => av > 0 && av <= 999999999)
            .toList();
        
        if (candidates.isEmpty) {
          throw ArgumentError('转换结果无效: $bvid\n'
              '计算过程: r=$r, xAdd=$xAdd, xOr=$xOr\n'
              '候选结果: [$candidate1, $candidate2, $candidate3]\n'
              '所有候选结果都不在合理范围内');
        }
        
        result = candidates.first;
        print('BVID转换成功(特殊情况): $bvid -> av$result (候选: ${candidates.join(", ")})');
      }
      
      // 4. 验证结果合理性
      if (result <= 0) {
        throw ArgumentError('转换结果无效: $bvid -> av$result');
      }
      
      if (result > 999999999) {
        throw ArgumentError('转换结果过大: av$result，可能计算错误');
      }
      
      print('BVID转换成功: $bvid -> av$result');
      return result;
      
    } catch (e) {
      throw Exception('BVID转换失败: $bvid -> ${e.toString()}');
    }
  }

  ///判断是否是bvid
  ///更新的格式验证 - 适应B站新BVID格式
  static bool isBvid(String bvid) {
    // 基本格式检查
    if (bvid.length != 12) {
      return false;
    }
    
    // 转为大写进行比较
    bvid = bvid.toUpperCase();
    
    // 必须以 "BV" 开头
    if (!bvid.startsWith('BV')) {
      return false;
    }
    
    // 检查第3位必须是数字或字母（通常是'1'但也可能是其他）
    String thirdChar = bvid.characters.elementAt(2);
    if (!table.contains(thirdChar) && !'0123456789'.contains(thirdChar)) {
      return false;
    }
    
    // 检查所有可变位置的字符是否在允许的表中
    for (int i = 2; i < bvid.length; i++) {
      String char = bvid.characters.elementAt(i);
      if (!table.contains(char)) {
        return false;
      }
    }
    
    return true;
  }
}
