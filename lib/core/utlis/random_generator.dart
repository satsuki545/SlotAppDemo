import 'dart:math';

import '../../features/slot/domain/enums.dart';

final random = Random();
SmallRole getRandomRole(GameMode mode) {
  if (mode == GameMode.bonus) return SmallRole.bell;
  final rand = random.nextInt(100);
  if (rand < 10) return SmallRole.cherry;
  if (rand < 20) return SmallRole.suika;
  if (rand < 40) return SmallRole.replay;
  if (rand < 70) return SmallRole.bell;
  return SmallRole.none;
}