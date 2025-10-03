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
    _medals.insertPerGame();

    final current = state;
    SmallRole role = getRandomRole(current.gameMode);

    // --- AT中は none 以外が必ず揃う ---
    if (current.gameMode == GameMode.at) {
      final forcedRoles = [
        SmallRole.bell,
        SmallRole.suika,
        SmallRole.cherry,
        SmallRole.replay,
      ];
      role = forcedRoles[random.nextInt(forcedRoles.length)];
    }

    // 払い出し処理
    switch (role) {
      case SmallRole.bell:
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
      // 通常時ボーナス抽選
      final chance = {
        SmallRole.bell: 1 / 100,
        SmallRole.replay: 1 / 50,
        SmallRole.suika: 1 / 25,
        SmallRole.cherry: 1 / 10,
      }[role] ?? 0.0;

      if (chance > 0 && random.nextDouble() < chance) {
        newGameCount = 0;
        nextMode = GameMode.bonus;
        bonusCount += 1;
        enteredBonusThisGame = true;
      }
    } else if (current.gameMode == GameMode.bonus) {
        // ボーナス10Gで終了
        if (newGameCount >= 10) {
          newGameCount = 0;
          // --- ボーナス終了後の遷移 ---
          if (current.prevMode == GameMode.at) {
            // ATから入ったボーナスなら AT30G をリセット
            nextMode = GameMode.at;
            atCount += 1;
          } else {
            // 通常から入ったボーナス → 50%でAT、失敗なら通常へ
            final toAT = random.nextBool();
            if (toAT) {
              nextMode = GameMode.at;
              atCount += 1;
            } else {
              nextMode = GameMode.normal;
            }
          }
        }
      } else if (current.gameMode == GameMode.at) {
        // --- ATは30Gで終了 ---
        if (newGameCount >= 30) {
          newGameCount = 0;
          nextMode = GameMode.normal;
        }

        // --- AT中も通常と同じ確率でボーナス抽選 ---
        final chance = {
          SmallRole.bell: 1 / 100,
          SmallRole.replay: 1 / 50,
          SmallRole.suika: 1 / 25,
          SmallRole.cherry: 1 / 10,
        }[role] ?? 0.0;

        if (chance > 0 && random.nextDouble() < chance) {
          newGameCount = 0;
          bonusCount += 1;
          enteredBonusThisGame = true;
        }
      }

    GameMode? prevMode;
    if (current.gameMode != GameMode.bonus && nextMode == GameMode.bonus) {
      // ボーナスに入る直前の状態を保持
      prevMode = current.gameMode;
    }


    final nextState = state.copyWith(
      gameCount: newGameCount,
      lastRole: role,
      gameMode: nextMode,
      prevMode: prevMode,
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

    // スランプポイント更新
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

