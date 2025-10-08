class NumUtils {
  static String numFormat(dynamic number) {
    if (number == null) {
      return '0';
    }
    if (number is String) {
      number = int.tryParse(number) ?? number;
      if (number is String) {
        return number;
      }
    }

    String format(first, second) {
      double result = ((number / first) as double);
      // 保留一位小数
      result = double.parse(result.toStringAsFixed(1));
      int intRes = result.toInt();
      if (result == intRes) {
        return '$intRes$second';
      } else {
        return '$result$second';
      }
    }

    if (number >= 100000000) {
      return format(100000000, '亿');
    } else if (number >= 10000) {
      return format(10000, '万');
    } else {
      return number.toString();
    }
  }
}