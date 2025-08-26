// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/material.dart';

@immutable
class CLBrowserPanal {
  const CLBrowserPanal({
    this.panelBuilder,
    required this.label,
    this.isExpanded = false,
  });

  final Widget Function(BuildContext context)? panelBuilder;
  final String label;
  final bool isExpanded;

  CLBrowserPanal copyWith({
    Widget Function(BuildContext context)? panelBuilder,
    String? label,
    bool? isExpanded,
  }) {
    return CLBrowserPanal(
      panelBuilder: panelBuilder ?? this.panelBuilder,
      label: label ?? this.label,
      isExpanded: isExpanded ?? this.isExpanded,
    );
  }

  @override
  bool operator ==(covariant CLBrowserPanal other) {
    if (identical(this, other)) return true;

    return other.panelBuilder == panelBuilder &&
        other.label == label &&
        other.isExpanded == isExpanded;
  }

  @override
  int get hashCode =>
      panelBuilder.hashCode ^ label.hashCode ^ isExpanded.hashCode;
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
    if (activePanelLabel != null) {
      return availablePanels
          .map(
            (e) =>
                e.label == activePanelLabel ? e.copyWith(isExpanded: true) : e,
          )
          .toList();
    }
    return availablePanels;
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
