import 'package:face_it_desktop/cl_browser_panel/models/cl_browser_panal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CLBrowserPanalNotifier extends StateNotifier<CLBrowserPanals> {
  CLBrowserPanalNotifier(super.panels);

  void addPanels(List<CLBrowserPanal> panels) => state = state.copyWith(
    availablePanels: [...state.availablePanels, ...panels],
  );

  void removePanelByLabel(String label) => state = state.copyWith(
    availablePanels: [...state.availablePanels]
      ..removeWhere((e) => e.label == label),
  );

  void onTogglePanelByLabel(String label) => state = state.copyWith(
    activePanelLabel: () => label == state.activePanelLabel ? null : label,
  );

  void clear() => state = const CLBrowserPanals();
}

final clBrowserPanalProvider =
    StateNotifierProvider<CLBrowserPanalNotifier, CLBrowserPanals>((ref) {
      return CLBrowserPanalNotifier(const CLBrowserPanals());
    });
