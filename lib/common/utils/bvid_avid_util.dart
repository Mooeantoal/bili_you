import 'dart:math';

import 'package:flutter/material.dart';

class BvidAvidUtil {
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

  ///bvid转avid - 按官方算法实现
  static int bvid2Av(String bvid) {
    try {
      // 1. 验证BVID格式
      if (!isBvid(bvid)) {
        throw ArgumentError('无效的BVID格式: $bvid');
      }
      
      // 2. 按官方算法计算
      int r = 0;
      for (int i = 0; i < seqArray.length; i++) {
        String char = bvid.characters.elementAt(seqArray[i]);
        int charIndex = table.indexOf(char);
        
        if (charIndex == -1) {
          throw ArgumentError('BVID包含无效字符: $char 在位置 ${seqArray[i]}');
        }
        
        // 使用58进制计算，注意使用整数除法
        r += (charIndex * pow(58, i).toInt());
      }
      
      // 3. 应用官方公式: (r - xAdd) ^ xOr
      int av = (r - xAdd) ^ xOr;
      
      // 4. 验证转换结果
      if (av <= 0) {
        throw ArgumentError('转换结果无效: $bvid -> av$av\n'
            '计算过程: r=$r, xAdd=$xAdd, xOr=$xOr\n'
            '公式: ($r - $xAdd) ^ $xOr = $av');
      }
      
      // 5. 检查是否超出合理范围
      if (av > 999999999) {
        throw ArgumentError('转换结果过大: av$av，可能计算错误');
      }
      
      return av;
    } catch (e) {
      // 提供更详细的错误信息
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
