import 'lib/common/utils/bvid_avid_util.dart';

/// 测试BVID转换修复 - 基于官方算法
void main() {
  print('🔧 测试BVID转换修复（基于官方算法）...\n');
  
  // 测试各种BVID
  List<Map<String, dynamic>> testCases = [
    {
      'bvid': 'BV16hHDZSEzt',
      'description': '用户报告的问题BVID',
      'expected_valid': true,
    },
    {
      'bvid': 'BV1xx411c7mD',
      'description': '经典测试BVID (av170001)',
      'expected_valid': true,
      'expected_avid': 170001,
    },
    {
      'bvid': 'BV1uv411q7Mv',
      'description': '另一个有效BVID',
      'expected_valid': true,
    },
    {
      'bvid': 'BV1234567890',
      'description': '无效BVID',
      'expected_valid': false,
    },
    {
      'bvid': 'BV16hHDZSEz',
      'description': '长度不够的BVID',
      'expected_valid': false,
    },
  ];
  
  int passedTests = 0;
  int totalTests = testCases.length;
  
  for (var testCase in testCases) {
    String bvid = testCase['bvid'];
    String description = testCase['description'];
    bool expectedValid = testCase['expected_valid'];
    int? expectedAvid = testCase['expected_avid'];
    
    print('📹 测试: $description');
    print('   BVID: $bvid');
    
    try {
      // 格式验证
      bool isValid = BvidAvidUtil.isBvid(bvid);
      print('   格式验证: ${isValid ? "✅ 有效" : "❌ 无效"}');
      
      if (isValid != expectedValid) {
        print('   ⚠️ 格式验证结果与预期不符！预期: $expectedValid, 实际: $isValid');
      }
      
      if (isValid) {
        // 转换测试
        int avid = BvidAvidUtil.bvid2Av(bvid);
        print('   转换结果: av$avid');
        
        // 验证预期结果
        if (expectedAvid != null) {
          if (avid == expectedAvid) {
            print('   ✅ 转换结果与预期一致');
            passedTests++;
          } else {
            print('   ❌ 转换结果不符！预期: av$expectedAvid, 实际: av$avid');
          }
        } else {
          // 验证转换结果的合理性
          if (avid > 0 && avid <= 999999999) {
            print('   ✅ 转换成功且结果在合理范围内');
            passedTests++;
          } else {
            print('   ❌ 转换结果超出合理范围');
          }
        }
        
        // 反向验证
        try {
          String backToBvid = BvidAvidUtil.av2Bvid(avid);
          if (backToBvid == bvid) {
            print('   ✅ 反向转换验证通过');
          } else {
            print('   ⚠️ 反向转换结果不一致: $backToBvid');
          }
        } catch (e) {
          print('   ❌ 反向转换失败: $e');
        }
      } else {
        if (!expectedValid) {
          print('   ✅ 正确识别为无效格式');
          passedTests++;
        }
      }
    } catch (e) {
      if (!expectedValid) {
        print('   ✅ 正确抛出异常（预期行为）');
        passedTests++;
      } else {
        print('   ❌ 意外错误: $e');
      }
    }
    
    print('');
  }
  
  // 总结
  print('📊 测试总结:');
  print('   通过: $passedTests/$totalTests');
  print('   成功率: ${(passedTests / totalTests * 100).toStringAsFixed(1)}%');
  
  if (passedTests == totalTests) {
    print('\n🎉 所有测试通过！BVID转换算法修复成功。');
  } else {
    print('\n⚠️ 部分测试失败，需要进一步检查算法实现。');
  }
  
  print('\n📋 修复说明:');
  print('1. 严格按照官方算法实现');
  print('2. 使用正确的常量值 (XOR: 177451812, ADD: 8728348608)');
  print('3. 改进了数值计算精度');
  print('4. 增强了错误检查和诊断');
  print('5. 添加了反向验证机制');
}