import 'enums.dart';

class SlotState {
  final int gameCount; // 現在のモード内ゲーム数（ボーナスは10G管理）
  final SmallRole lastRole; // 直前の小役
  final GameMode gameMode; // 現在モード

  // 追加：メダル/統計
  final int inserted; // 累計投入
  final int payout; // 累計払い出し
  int get difference => payout - inserted; // 差枚

  final int bonusCount; // 総ボーナス回数
  final int atCount; // 総AT突入回数

  final int bellCount; // 小役回数
  final int replayCount;
  final int suikaCount;
  final int cherryCount;

  const SlotState({
    required this.gameCount,
    required this.lastRole,
    required this.gameMode,
    required this.inserted,
    required this.payout,
    required this.bonusCount,
    required this.atCount,
    required this.bellCount,
    required this.replayCount,
    required this.suikaCount,
    required this.cherryCount,
  });

  static const initial = SlotState(
    gameCount: 0,
    lastRole: SmallRole.none,
    gameMode: GameMode.normal,
    inserted: 0,
    payout: 0,
    bonusCount: 0,
    atCount: 0,
    bellCount: 0,
    replayCount: 0,
    suikaCount: 0,
    cherryCount: 0,
  );

  SlotState copyWith({
    int? gameCount,
    SmallRole? lastRole,
    GameMode? gameMode,
    int? inserted,
    int? payout,
    int? bonusCount,
    int? atCount,
    int? bellCount,
    int? replayCount,
    int? suikaCount,
    int? cherryCount,
  }) {
    return SlotState(
      gameCount: gameCount ?? this.gameCount,
      lastRole: lastRole ?? this.lastRole,
      gameMode: gameMode ?? this.gameMode,
      inserted: inserted ?? this.inserted,
      payout: payout ?? this.payout,
      bonusCount: bonusCount ?? this.bonusCount,
      atCount: atCount ?? this.atCount,
      bellCount: bellCount ?? this.bellCount,
      replayCount: replayCount ?? this.replayCount,
      suikaCount: suikaCount ?? this.suikaCount,
      cherryCount: cherryCount ?? this.cherryCount,
    );
  }
}
