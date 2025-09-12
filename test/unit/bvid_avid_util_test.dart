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

    group('bvid2Av', () {
      test('should convert BV号 to AV号 correctly', () {
        // 反向转换测试
        expect(BvidAvidUtil.bvid2Av('BV17x411w7KC'), equals(170001));
        expect(BvidAvidUtil.bvid2Av('BV1Q541167Qg'), equals(455017605));
        expect(BvidAvidUtil.bvid2Av('BV1mK4y1C7Bz'), equals(882584971));
      });

      test('should handle BV号 with different cases', () {
        expect(BvidAvidUtil.bvid2Av('bv17x411w7KC'), equals(170001));
        expect(BvidAvidUtil.bvid2Av('Bv17x411w7KC'), equals(170001));
      });

      test('should handle invalid BV号', () {
        expect(() => BvidAvidUtil.bvid2Av('invalid'), throwsException);
        expect(() => BvidAvidUtil.bvid2Av(''), throwsException);
        expect(() => BvidAvidUtil.bvid2Av('AV123'), throwsException);
      });
    });

    group('isBvid', () {
      test('should validate correct BV号', () {
        expect(BvidAvidUtil.isBvid('BV17x411w7KC'), isTrue);
        expect(BvidAvidUtil.isBvid('BV1Q541167Qg'), isTrue);
        expect(BvidAvidUtil.isBvid('BV1mK4y1C7Bz'), isTrue);
      });

      test('should reject invalid BV号', () {
        expect(BvidAvidUtil.isBvid('invalid'), isFalse);
        expect(BvidAvidUtil.isBvid(''), isFalse);
        expect(BvidAvidUtil.isBvid('AV123'), isFalse);
        expect(BvidAvidUtil.isBvid('BV'), isFalse);
        expect(BvidAvidUtil.isBvid('BV123'), isFalse);
      });
    });

    group('roundtrip conversion', () {
      test('should maintain consistency in roundtrip conversion', () {
        const testAvids = [170001, 455017605, 882584971, 1, 1000, 999999];
        
        for (final avid in testAvids) {
          final bvid = BvidAvidUtil.av2Bvid(avid);
          final convertedBack = BvidAvidUtil.bvid2Av(bvid);
          expect(convertedBack, equals(avid), 
                 reason: 'Roundtrip conversion failed for AVID: $avid');
        }
      });
    });
  });
}