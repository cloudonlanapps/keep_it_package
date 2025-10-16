import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:flutter/material.dart' hide ValueGetter;

@immutable
class CLBrowserPanal {
  const CLBrowserPanal({
    required this.label,
    this.panelBuilder,
    this.labelBuilder,
    this.isExpanded = false,
  });

  final Widget Function(BuildContext context)? panelBuilder;
  final Widget Function(BuildContext context)? labelBuilder;
  final String label;
  final bool isExpanded;

  CLBrowserPanal copyWith({
    ValueGetter<Widget Function(BuildContext context)?>? panelBuilder,
    ValueGetter<Widget Function(BuildContext context)?>? labelBuilder,
    String? label,
    bool? isExpanded,
  }) {
    return CLBrowserPanal(
      panelBuilder: panelBuilder != null
          ? panelBuilder.call()
          : this.panelBuilder,
      labelBuilder: labelBuilder != null
          ? labelBuilder.call()
          : this.labelBuilder,
      label: label ?? this.label,
      isExpanded: isExpanded ?? this.isExpanded,
    );
  }

  @override
  bool operator ==(covariant CLBrowserPanal other) {
    if (identical(this, other)) return true;

    return other.panelBuilder == panelBuilder &&
        other.labelBuilder == labelBuilder &&
        other.label == label &&
        other.isExpanded == isExpanded;
  }

  @override
  int get hashCode {
    return panelBuilder.hashCode ^
        labelBuilder.hashCode ^
        label.hashCode ^
        isExpanded.hashCode;
  }
}

@immutable
class CLBrowserPanals {
  const CLBrowserPanals({
    this.availablePanels = const [],
    this.activePanelLabel,
  });
  final List<CLBrowserPanal> availablePanels;
  final String? activePanelLabel;

  List<CLBrowserPanal> get activePanels {
    return availablePanels
        .map(
          (e) => e.label == activePanelLabel ? e.copyWith(isExpanded: true) : e,
        )
        .toList();
  }

  CLBrowserPanals copyWith({
    List<CLBrowserPanal>? availablePanels,
    ValueGetter<String?>? activePanelLabel,
  }) {
    return CLBrowserPanals(
      availablePanels: availablePanels ?? this.availablePanels,
      activePanelLabel: activePanelLabel != null
          ? activePanelLabel.call()
          : this.activePanelLabel,
    );
  }
}
