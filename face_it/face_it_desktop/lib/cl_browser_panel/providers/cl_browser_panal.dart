// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:face_it_desktop/cl_browser_panel/models/cl_browser_panal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CLBrowserPanalNotifier extends StateNotifier<CLBrowserPanals> {
  CLBrowserPanalNotifier(super.panels);

  addPanels(List<CLBrowserPanal> panels) => state = state.copyWith(
    availablePanels: [...state.availablePanels, ...panels],
  );

  removePanelByLabel(String label) => state = state.copyWith(
    availablePanels: [...state.availablePanels]
      ..removeWhere((e) => e.label == label),
  );

  onTogglePanelByLabel(String label) => state = state.copyWith(
    activePanelLabel: () => label == state.activePanelLabel ? null : label,
  );

  clear() => state = CLBrowserPanals();
}

final clBrowserPanalProvider =
    StateNotifierProvider<CLBrowserPanalNotifier, CLBrowserPanals>((ref) {
      return CLBrowserPanalNotifier(CLBrowserPanals(availablePanels: []));
    });
