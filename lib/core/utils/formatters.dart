abstract final class AppFormatters {
  static String rupees(num value) {
    final rounded = value.round().abs();
    final digits = rounded.toString();
    final sign = value < 0 ? '-' : '';
    if (digits.length <= 3) {
      return '$sign\u20B9$digits';
    }
    final lastThree = digits.substring(digits.length - 3);
    var leading = digits.substring(0, digits.length - 3);
    final groups = <String>[];
    while (leading.length > 2) {
      final start = leading.length - 2;
      groups.insert(0, leading.substring(start));
      leading = leading.substring(0, start);
    }
    if (leading.isNotEmpty) {
      groups.insert(0, leading);
    }
    groups.add(lastThree);
    return '$sign\u20B9${groups.join(',')}';
  }

  static String maskedMobile(String mobile) {
    if (mobile.length < 4) {
      return '+91 ******4210';
    }
    return '+91 ******${mobile.substring(mobile.length - 4)}';
  }
}
