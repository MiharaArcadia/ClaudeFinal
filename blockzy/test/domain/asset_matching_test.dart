import 'package:blockzy/domain/candy.dart';
import 'package:blockzy/services/asset_loader.dart';
import 'package:flutter_test/flutter_test.dart';

String p(String name) => 'assets/candies/$name';

void main() {
  group('matchCandyFiles', () {
    test('exact candy_<name> files map one-to-one', () {
      final files = CandyType.values.map((t) => p('${t.assetKey}.png'));
      final map = matchCandyFiles(files);
      for (final t in CandyType.values) {
        expect(map[t], p('${t.assetKey}.png'), reason: 'type $t');
      }
    });

    test('colour-keyword filenames map by synonym', () {
      final files = [
        p('red.png'),
        p('yellow.png'),
        p('blue.png'),
        p('green.png'),
        p('purple.png'),
        p('orange.png'),
        p('teal.png'),
      ];
      final map = matchCandyFiles(files);
      expect(map[CandyType.strawberry], p('red.png'));
      expect(map[CandyType.lemon], p('yellow.png'));
      expect(map[CandyType.blueberry], p('blue.png'));
      expect(map[CandyType.lime], p('green.png'));
      expect(map[CandyType.grape], p('purple.png'));
      expect(map[CandyType.orange], p('orange.png'));
      expect(map[CandyType.mint], p('teal.png'));
    });

    test('numbered filenames fall back to sorted order over all 7 types', () {
      final files = [
        p('1.png'),
        p('2.png'),
        p('3.png'),
        p('4.png'),
        p('5.png'),
        p('6.png'),
        p('7.png'),
      ];
      final map = matchCandyFiles(files);
      expect(map.length, CandyType.values.length);
      // Sorted files assigned to enum-ordered leftover types.
      expect(map[CandyType.values.first], p('1.png'));
      expect(map[CandyType.values.last], p('7.png'));
      // Every file used exactly once.
      expect(map.values.toSet().length, 7);
    });

    test('non-image files are ignored', () {
      final files = [p('README.md'), p('candy_lemon.png'), p('notes.txt')];
      final map = matchCandyFiles(files);
      expect(map[CandyType.lemon], p('candy_lemon.png'));
      expect(map.values.every((v) => v.endsWith('.png')), isTrue);
    });

    test('partial sets only map what is present, leaving the rest procedural',
        () {
      final files = [p('candy_grape.png'), p('blue.webp')];
      final map = matchCandyFiles(files);
      expect(map[CandyType.grape], p('candy_grape.png'));
      expect(map[CandyType.blueberry], p('blue.webp'));
      // Others intentionally unmapped (painted procedurally at runtime).
      expect(map.containsKey(CandyType.lemon), isFalse);
    });

    test('mixed case and extensions still match', () {
      final files = [p('Candy_Strawberry.PNG'), p('MINT.WEBP')];
      final map = matchCandyFiles(files);
      expect(map[CandyType.strawberry], p('Candy_Strawberry.PNG'));
      expect(map[CandyType.mint], p('MINT.WEBP'));
    });
  });
}
