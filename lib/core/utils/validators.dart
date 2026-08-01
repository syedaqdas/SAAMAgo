abstract final class Validators {
  static String? mobile(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Enter your mobile number';
    }
    if (!RegExp(r'^\d{10}$').hasMatch(trimmed)) {
      return 'Enter a valid 10-digit number';
    }
    return null;
  }

  static String? requiredText(String? value, String label) {
    if ((value ?? '').trim().isEmpty) {
      return '$label is required';
    }
    return null;
  }

  static String? amount(String? value, String label) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return '$label is required';
    }
    final parsed = num.tryParse(text);
    if (parsed == null || parsed <= 0) {
      return 'Enter a valid amount';
    }
    return null;
  }
}
