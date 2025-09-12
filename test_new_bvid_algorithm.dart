// 测试新版BVID算法
void main() {
  // 测试用例来自官方文档
  List<Map<String, dynamic>> testCases = [
    {
      'bvid': 'BV1L9Uoa9EUx',
      'avid': 111298867365120,
      'description': '官方文档示例',
    },
    {
      'bvid': 'BV16hHDzSEzt', 
      'description': '用户问题BVID',
    },
    {
      'bvid': 'BV1BTHezwEnU',
      'description': '用户问题BVID2',
    },
    {
      'bvid': 'BV1xx411c7mD',
      'description': '经典BVID',
    },
  ];
  
  print('=== 新版BVID算法测试 ===\n');
  
  for (var testCase in testCases) {
    String bvid = testCase['bvid'];
    print('测试: ${testCase['description']}');
    print('BVID: $bvid');
    
    try {
      int result = testNewBvid2Av(bvid);
      print('转换结果: av$result');
      
      if (testCase['avid'] != null) {
        int expectedAvid = testCase['avid'];
        if (result == expectedAvid) {
          print('✅ 与官方示例一致');
        } else {
          print('❌ 与官方示例不一致，预期: av$expectedAvid');
        }
      } else {
        if (result > 0 && result <= 999999999) {
          print('✅ 转换成功，结果在合理范围内');
        } else {
          print('❌ 转换结果不在合理范围内');
        }
      }
    } catch (e) {
      print('❌ 转换失败: $e');
    }
    
    print('');
  }
}

// 模拟新版BVID转换算法
int testNewBvid2Av(String bvid) {
  const String table = "FcwAPNKTMug3GV5Lj7EJnHpWsx4tb8haYeviqBz6rkCy12mUSDQX9RdoZf";
  const int xorCode = 23442827791579;
  const int maskCode = 2251799813685247;
  const int base = 58;
  
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