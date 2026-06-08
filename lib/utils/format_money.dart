String formatMoney(num value) {
  final text = value.toStringAsFixed(0);
  final buffer = StringBuffer();

  for (int i = 0; i < text.length; i++) {
    final reverseIndex = text.length - i;

    buffer.write(text[i]);

    if (reverseIndex > 1 && reverseIndex % 3 == 1) {
      buffer.write('.');
    }
  }

  return '${buffer.toString()}\u0110';
}