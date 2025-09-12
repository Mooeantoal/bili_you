import 'dart:math';

import 'package:flutter/material.dart';

class BvidAvidUtil {
  // 最新的官方BVID转换参数 (2024版)
  static const String table =
      "FcwAPNKTMug3GV5Lj7EJnHpWsx4tb8haYeviqBz6rkCy12mUSDQX9RdoZf";
  static const int xorCode = 23442827791579;
  static const int maskCode = 2251799813685247;
  static const int maxAid = 2251799813685248; // 2^51
  static const int base = 58;
  
  // 旧版兼容参数 (保留用于向后兼容)
  static const String oldTable =
      "fZodR9XQDSUm21yCkr6zBqiveYah8bt4xsWpHnJE7jL5VG3guMTKNPAwcF";
  static const List<int> seqArray = [11, 10, 3, 8, 4, 6];
  static const int oldXOr = 177451812;
  static const int oldXAdd = 8728348608;
  
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

  ///avid转bvid - 支持新旧算法
  static String av2Bvid(int av) {
    try {
      // 尝试新版算法
      String result = _av2BvidNew(av);
      print('AVID转换成功(新版算法): av$av -> $result');
      return result;
    } catch (e) {
      print('新版算法失败，尝试旧版: $e');
      // 如果新版失败，使用旧版算法
      return _av2BvidOld(av);
    }
  }
  
  /// 新版AVID转BVID算法 (2024版)
  static String _av2BvidNew(int av) {
    List<String> bytes = ['B', 'V', '1', '0', '0', '0', '0', '0', '0', '0', '0', '0'];
    int bvIndex = bytes.length - 1;
    int tmp = (maxAid | av) ^ xorCode;
    
    while (tmp > 0) {
      bytes[bvIndex] = table[tmp % base];
      tmp = tmp ~/ base;
      bvIndex -= 1;
    }
    
    // 交换字符位置
    String temp = bytes[3];
    bytes[3] = bytes[9];
    bytes[9] = temp;
    
    temp = bytes[4];
    bytes[4] = bytes[7];
    bytes[7] = temp;
    
    return bytes.join();
  }
  
  /// 旧版AVID转BVID算法
  static String _av2BvidOld(int av) {
    // 使用64位整数避免溢出
    int newAvId = (av ^ oldXOr) + oldXAdd;
    List<String> defaultBv = [];
    defaultBv.addAll(BvidAvidUtil.defaultBvid);
    for (int i = 0; i < seqArray.length; i++) {
      defaultBv[seqArray[i]] = oldTable[newAvId ~/ pow(58, i).toInt() % 58];
    }
    return defaultBv.join();
  }

  ///bvid转avid - 按最新官方算法实现 (2024版)
  static int bvid2Av(String bvid) {
    try {
      // 1. 验证BVID格式
      if (!isBvid(bvid)) {
        throw ArgumentError('无效的BVID格式: $bvid');
      }
      
      // 2. 尝试新版算法 (2024年最新)
      try {
        int result = _bvid2AvNew(bvid);
        if (result > 0 && result <= 999999999) {
          print('BVID转换成功(新版算法): $bvid -> av$result');
          return result;
        }
      } catch (e) {
        print('新版算法失败: $e');
      }
      
      // 3. 如果新版失败，尝试旧版算法（向后兼容）
      try {
        int result = _bvid2AvOld(bvid);
        if (result > 0 && result <= 999999999) {
          print('BVID转换成功(旧版算法): $bvid -> av$result');
          return result;
        }
      } catch (e) {
        print('旧版算法失败: $e');
      }
      
      throw ArgumentError('所有算法均无法转换BVID: $bvid');
      
    } catch (e) {
      throw Exception('BVID转换失败: $bvid -> ${e.toString()}');
    }
  }
  
  /// 新版BVID转换算法 (2024年最新)
  static int _bvid2AvNew(String bvid) {
    // 1. 检查格式
    if (!bvid.startsWith('BV1') || bvid.length != 12) {
      throw ArgumentError('无效的BVID格式');
    }
    
    // 2. 转换为字符数组
    List<String> bvidArr = bvid.split('');
    
    // 3. 交换字符位置 (按官方算法)
    String temp = bvidArr[3];
    bvidArr[3] = bvidArr[9];
    bvidArr[9] = temp;
    
    temp = bvidArr[4];
    bvidArr[4] = bvidArr[7];
    bvidArr[7] = temp;
    
    // 4. 删除前3个字符 ("BV1")
    List<String> trimmedBvid = bvidArr.sublist(3);
    
    // 5. 58进制解码
    int tmp = 0;
    for (String char in trimmedBvid) {
      int idx = table.indexOf(char);
      if (idx == -1) {
        throw ArgumentError('无效字符: $char');
      }
      tmp = tmp * base + idx;
    }
    
    // 6. 应用逆向转换公式
    int result = (tmp & maskCode) ^ xorCode;
    
    return result;
  }
  
  /// 旧版BVID转换算法 (向后兼容)
  static int _bvid2AvOld(String bvid) {
    // 按旧版算法计算58进制值
    int r = 0;
    for (int i = 0; i < seqArray.length; i++) {
      String char = bvid[seqArray[i]];
      int charIndex = oldTable.indexOf(char);
      
      if (charIndex == -1) {
        throw ArgumentError('BVID包含无效字符: $char 在位置 ${seqArray[i]}');
      }
      
      r += (charIndex * pow(58, i).toInt());
    }
    
    // 应用旧版公式
    int result;
    if (r >= oldXAdd) {
      result = (r - oldXAdd) ^ oldXOr;
    } else {
      // 特殊情况处理
      result = r ^ oldXOr;
    }
    
    return result;
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
