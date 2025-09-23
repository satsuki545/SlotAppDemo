import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/slot_provider.dart';
import 'slump_graph.dart';

class SlotScreen extends ConsumerWidget {
  const SlotScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(slotProvider);
    final controller = ref.read(slotProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Slot Game'),
        actions: [
          IconButton(
            onPressed: () => controller.resetSession(clearHistory: false),
            icon: const Icon(Icons.restart_alt),
            tooltip: 'セッションリセット',
          ),
          IconButton(
            onPressed: () => controller.resetSession(clearHistory: true),
            icon: const Icon(Icons.delete_forever),
            tooltip: '履歴クリア',
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 16,
                runSpacing: 8,
                children: [
                  _StatCard(label: 'モード', value: state.gameMode.name),
                  _StatCard(label: 'G数', value: '${state.gameCount}'),
                  _StatCard(label: '差枚', value: '${state.difference}'),
                  _StatCard(label: '投入', value: '${state.inserted}'),
                  _StatCard(label: '払出', value: '${state.payout}'),
                ],
              ),
              const SizedBox(height: 12),
              SlumpGraph(height: 220),
              const SizedBox(height: 12),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 6,
                children: [
                  _StatChip('ベル', state.bellCount),
                  _StatChip('リプレイ', state.replayCount),
                  _StatChip('スイカ', state.suikaCount),
                  _StatChip('チェリー', state.cherryCount),
                  _StatChip('ボーナス', state.bonusCount),
                  _StatChip('AT', state.atCount),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: controller.nextGame,
                icon: const Icon(Icons.sports_esports),
                label: const Text('レバー ON (3枚投入)'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(220, 48),
                ),
              ),
              const SizedBox(height: 8),
              Text('直前役: ${state.lastRole.name}'),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: Theme.of(context).textTheme.labelSmall),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final int count;
  const _StatChip(this.label, this.count);

  @override
  Widget build(BuildContext context) {
    return Chip(label: Text('$label: $count'));
  }
}
