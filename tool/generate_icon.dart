import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

void main(List<String> arguments) {
  if (arguments.length != 1) {
    stderr.writeln('Usage: dart run tool/generate_icon.dart <output.ppm>');
    exitCode = 64;
    return;
  }

  const size = 1024;
  final bytes = BytesBuilder(copy: false);
  bytes.add('P6\n$size $size\n255\n'.codeUnits);

  for (var y = 0; y < size; y++) {
    for (var x = 0; x < size; x++) {
      final dx = x - size * .5;
      final dy = y - size * .5;
      final distance = math.sqrt(dx * dx + dy * dy);
      final angle = math.atan2(dy, dx);

      final glowDx = x - size * .78;
      final glowDy = y - size * .2;
      final glow = math.max(
        0.0,
        1 - math.sqrt(glowDx * glowDx + glowDy * glowDy) / 620,
      );
      var red = 18 + 38 * glow * glow;
      var green = 16 + 13 * glow * glow;
      var blue = 15 + 8 * glow * glow;

      const ringRadius = 265.0;
      final ringDistance = (distance - ringRadius).abs();
      var ringAlpha = math.max(0.0, 1 - ringDistance / 35);
      final normalizedAngle = (angle + math.pi * 2) % (math.pi * 2);
      if (normalizedAngle > math.pi * 1.63 &&
          normalizedAngle < math.pi * 1.92) {
        ringAlpha = 0;
      }
      if (ringAlpha > 0) {
        final warm = (.5 + .5 * math.sin(normalizedAngle + .7));
        red = red * (1 - ringAlpha) + (255) * ringAlpha;
        green = green * (1 - ringAlpha) + (120 + 60 * warm) * ringAlpha;
        blue = blue * (1 - ringAlpha) + (92 + 45 * warm) * ringAlpha;
      }

      if (distance < 52) {
        final centerAlpha = math.min(1.0, (58 - distance) / 10);
        red = red * (1 - centerAlpha) + 243 * centerAlpha;
        green = green * (1 - centerAlpha) + 235 * centerAlpha;
        blue = blue * (1 - centerAlpha) + 221 * centerAlpha;
      }

      bytes.add([
        red.round().clamp(0, 255),
        green.round().clamp(0, 255),
        blue.round().clamp(0, 255),
      ]);
    }
  }

  File(arguments.single).writeAsBytesSync(bytes.takeBytes());
}
