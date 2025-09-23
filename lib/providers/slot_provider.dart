import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/slot/application/slot_controller.dart';
import '../features/slot/data/history_repository.dart';
import '../features/slot/domain/slot_state.dart';

final historyRepositoryProvider = Provider<HistoryRepository>(
  (ref) => HistoryRepository(),
);

final slotProvider = StateNotifierProvider<SlotStateNotifier, SlotState>((ref) {
  final repo = ref.watch(historyRepositoryProvider);
  return SlotStateNotifier(repo);
});
