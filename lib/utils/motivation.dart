import 'dart:math';

class Motivation {
  static final _messages = [
    'Tiny steps fly far.',
    'Breathe. Focus. Glide.',
    'Wings up — you got this.',
    'Stay light, stay steady.',
    'One calm minute at a time.',
  ];

  static String randomMessage() {
    final rand = Random();
    return _messages[rand.nextInt(_messages.length)];
  }
}
