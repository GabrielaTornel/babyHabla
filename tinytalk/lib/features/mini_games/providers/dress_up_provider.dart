import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/dress_up_accessory.dart';

class DressUpState {
  const DressUpState({
    this.equipped = const {},
    this.totalEquips = 0,
    this.showCelebration = false,
    this.lastEquippedSlot,
  });

  /// Slot → accessory id. Absent key = slot is empty.
  final Map<AccessorySlot, String> equipped;
  final int totalEquips;
  final bool showCelebration;
  final AccessorySlot? lastEquippedSlot;

  int get equippedCount => equipped.length;
  bool get isEmpty => equipped.isEmpty;

  DressUpState copyWith({
    Map<AccessorySlot, String>? equipped,
    int? totalEquips,
    bool? showCelebration,
    AccessorySlot? lastEquippedSlot,
    bool clearLastSlot = false,
  }) =>
      DressUpState(
        equipped: equipped ?? this.equipped,
        totalEquips: totalEquips ?? this.totalEquips,
        showCelebration: showCelebration ?? this.showCelebration,
        lastEquippedSlot:
            clearLastSlot ? null : (lastEquippedSlot ?? this.lastEquippedSlot),
      );
}

class DressUpNotifier extends Notifier<DressUpState> {
  @override
  DressUpState build() => const DressUpState();

  void equipAccessory(DressUpAccessory accessory) {
    final newEquipped = Map<AccessorySlot, String>.from(state.equipped)
      ..[accessory.slot] = accessory.id;
    final newTotal = state.totalEquips + 1;
    state = state.copyWith(
      equipped: newEquipped,
      totalEquips: newTotal,
      // Celebrate every 3rd drop action
      showCelebration: newTotal % 3 == 0,
      lastEquippedSlot: accessory.slot,
    );
  }

  void removeSlot(AccessorySlot slot) {
    final newEquipped = Map<AccessorySlot, String>.from(state.equipped)
      ..remove(slot);
    state = state.copyWith(
      equipped: newEquipped,
      showCelebration: false,
      clearLastSlot: true,
    );
  }

  void clearAll() => state = const DressUpState();

  void dismissCelebration() =>
      state = state.copyWith(showCelebration: false, clearLastSlot: true);
}

final dressUpProvider =
    NotifierProvider<DressUpNotifier, DressUpState>(DressUpNotifier.new);
