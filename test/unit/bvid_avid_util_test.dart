import 'package:test/test.dart';
import 'package:bili_you/common/utils/bvid_avid_util.dart';

void main() {
  group('BvidAvidUtil Tests', () {
    group('av2Bvid', () {
      test('should convert AV号 to BV号 correctly', () {
        // 已知的AV号和BV号对应关系
        expect(BvidAvidUtil.av2Bvid(170001), equals('BV17x411w7KC'));
        expect(BvidAvidUtil.av2Bvid(455017605), equals('BV1Q541167Qg'));
        expect(BvidAvidUtil.av2Bvid(882584971), equals('BV1mK4y1C7Bz'));
      });

      test('should handle edge cases for av2Bvid', () {
        expect(BvidAvidUtil.av2Bvid(1), isA<String>());
        expect(BvidAvidUtil.av2Bvid(0), isA<String>());
      });
    });

    group('bv2Avid', () {
      test('should convert BV号 to AV号 correctly', () {
        // 反向转换测试
        expect(BvidAvidUtil.bv2Avid('BV17x411w7KC'), equals(170001));
        expect(BvidAvidUtil.bv2Avid('BV1Q541167Qg'), equals(455017605));
        expect(BvidAvidUtil.bv2Avid('BV1mK4y1C7Bz'), equals(882584971));
      });

      test('should handle BV号 with different cases', () {
        expect(BvidAvidUtil.bv2Avid('bv17x411w7KC'), equals(170001));
        expect(BvidAvidUtil.bv2Avid('Bv17x411w7KC'), equals(170001));
      });

      test('should handle invalid BV号', () {
        expect(() => BvidAvidUtil.bv2Avid('invalid'), throwsException);
        expect(() => BvidAvidUtil.bv2Avid(''), throwsException);
        expect(() => BvidAvidUtil.bv2Avid('AV123'), throwsException);
      });
    });

    group('isValidBvid', () {
      test('should validate correct BV号', () {
        expect(BvidAvidUtil.isValidBvid('BV17x411w7KC'), isTrue);
        expect(BvidAvidUtil.isValidBvid('BV1Q541167Qg'), isTrue);
        expect(BvidAvidUtil.isValidBvid('BV1mK4y1C7Bz'), isTrue);
      });

      test('should reject invalid BV号', () {
        expect(BvidAvidUtil.isValidBvid('invalid'), isFalse);
        expect(BvidAvidUtil.isValidBvid(''), isFalse);
        expect(BvidAvidUtil.isValidBvid('AV123'), isFalse);
        expect(BvidAvidUtil.isValidBvid('BV'), isFalse);
        expect(BvidAvidUtil.isValidBvid('BV123'), isFalse);
      });
    });

    group('roundtrip conversion', () {
      test('should maintain consistency in roundtrip conversion', () {
        const testAvids = [170001, 455017605, 882584971, 1, 1000, 999999];
        
        for (final avid in testAvids) {
          final bvid = BvidAvidUtil.av2Bvid(avid);
          final convertedBack = BvidAvidUtil.bv2Avid(bvid);
          expect(convertedBack, equals(avid), 
                 reason: 'Roundtrip conversion failed for AVID: $avid');
        }
      });
    });
  });
}