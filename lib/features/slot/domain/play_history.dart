class PlayPoint {
  // スランプ用の1点
  final int gameIndex; // 通しゲーム番号
  final int difference; // その時点の差枚
  final bool isBonus; // そのゲームでボーナスに入ったか
  const PlayPoint({
    required this.gameIndex,
    required this.difference,
    this.isBonus = false,
  });

  Map<String, dynamic> toJson() => {
    'g': gameIndex,
    'd': difference,
    'b': isBonus,
  };
  factory PlayPoint.fromJson(Map<String, dynamic> j) => PlayPoint(
    gameIndex: j['g'] as int,
    difference: j['d'] as int,
    isBonus: (j['b'] as bool?) ?? false,
  );
}
