import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slot_app/core/utlis/random_generator.dart';
import 'package:slot_app/features/slot/manager/medal_manager.dart';
import '../domain/enums.dart';
import '../domain/slot_state.dart';
import '../domain/play_history.dart';
import '../data/history_repository.dart';

class SlotStateNotifier extends StateNotifier<SlotState> {
  final MedalManager _medals = MedalManager();
  final HistoryRepository _historyRepo;
  final List<PlayPoint> _points = [];
  int _totalGames = 0; // 通しゲーム数（グラフ用）

  SlotStateNotifier(this._historyRepo) : super(SlotState.initial) {
    _init();
  }

  Future<void> _init() async {
    final loaded = await _historyRepo.load();
    _points.addAll(loaded);
  }

  List<PlayPoint> get points => List.unmodifiable(_points);

  // 1ゲーム進行
  void nextGame() {
    // 1ゲームの投入
    _medals.insertPerGame();

    final current = state;
    final role = getRandomRole(current.gameMode);

    // 払い出し（ボーナス中はベルのみ・抽選なし）
    switch (role) {
      case SmallRole.bell:
        // ボーナス中のベルは抽選を行わない仕様
        _medals.payout(7);
        break;
      case SmallRole.suika:
        if (current.gameMode != GameMode.bonus) _medals.payout(4);
        break;
      case SmallRole.cherry:
        if (current.gameMode != GameMode.bonus) _medals.payout(2);
        break;
      case SmallRole.replay:
      case SmallRole.none:
        break;
    }

    // 小役カウント
    final bellC = state.bellCount + (role == SmallRole.bell ? 1 : 0);
    final suikaC = state.suikaCount + (role == SmallRole.suika ? 1 : 0);
    final cherryC = state.cherryCount + (role == SmallRole.cherry ? 1 : 0);
    final replayC = state.replayCount + (role == SmallRole.replay ? 1 : 0);

    int newGameCount = current.gameCount + 1;
    GameMode nextMode = current.gameMode;
    int bonusCount = state.bonusCount;
    int atCount = state.atCount;
    bool enteredBonusThisGame = false;

    if (current.gameMode == GameMode.normal) {
      // 小役に応じた「次ゲームボーナス当選抽選」
      final chance =
          {
            SmallRole.bell: 1 / 100,
            SmallRole.replay: 1 / 50,
            SmallRole.suika: 1 / 25,
            SmallRole.cherry: 1 / 10,
          }[role] ??
          0.0;

      if (chance > 0 && random.nextDouble() < chance) {
        // 次ゲームからボーナスに入る想定 → ここでは即時遷移で表現
        newGameCount = 0;
        nextMode = GameMode.bonus;
        bonusCount += 1;
        enteredBonusThisGame = true;
      }
    } else if (current.gameMode == GameMode.bonus) {
      // ボーナスは10G消化
      if (newGameCount >= 10) {
        newGameCount = 0;
        final toAT = random.nextBool(); // 1/2でAT
        if (toAT) {
          nextMode = GameMode.at;
          atCount += 1;
        } else {
          nextMode = GameMode.normal;
        }
      }
    } else if (current.gameMode == GameMode.at) {
      // AT中の仕様は現状シンプル：通常と同確率で小役決定・抽選は行わない（拡張余地）
      // 必要に応じてAT終了条件を後で追加
    }

    final nextState = state.copyWith(
      gameCount: newGameCount,
      lastRole: role,
      gameMode: nextMode,
      inserted: _medals.inserted,
      payout: _medals.payoutTotal,
      bonusCount: bonusCount,
      atCount: atCount,
      bellCount: bellC,
      replayCount: replayC,
      suikaCount: suikaC,
      cherryCount: cherryC,
    );

    state = nextState;

    // スランプポイント更新 & 保存
    _totalGames += 1;
    _points.add(
      PlayPoint(
        gameIndex: _totalGames,
        difference: nextState.difference,
        isBonus: enteredBonusThisGame,
      ),
    );
    _historyRepo.save(_points);
  }

  Future<void> resetSession({bool clearHistory = false}) async {
    _medals.reset();
    _totalGames = 0;
    state = SlotState.initial;
    if (clearHistory) {
      _points.clear();
      await _historyRepo.clear();
    }
  }
}
