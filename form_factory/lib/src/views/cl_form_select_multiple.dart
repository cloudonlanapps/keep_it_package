import 'dart:async';

import 'package:cl_extensions/cl_extensions.dart' show UtilExtensionOnList;
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

import '../models/cl_form_field_descriptors.dart';
import '../models/cl_form_field_state.dart';

import '../style/cl_form_design.dart';

class CLFormSelectMultiple extends StatelessWidget {
  const CLFormSelectMultiple({
    required this.descriptors,
    required this.state,
    required this.onRefresh,
    this.actionBuilder,
    super.key,
  });
  final CLFormSelectMultipleDescriptors descriptors;

  final CLFormSelectMultipleState state;

  final void Function() onRefresh;
  final Widget Function(BuildContext context)? actionBuilder;

  @override
  Widget build(BuildContext context) {
    return FormField<List<Object>>(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (value) {
        {
          final res = descriptors.onValidate?.call(value);

          if (res != null) return res;

          state.selectedEntities.clear();
          if (value?.isNotEmpty ?? false) {
            for (var item in value!) {
              state.selectedEntities.add(item);
            }
          }
          return null;
        }
      },
      initialValue: List.from(state.selectedEntities),
      builder: (fieldState) {
        return InputDecorator(
          decoration: FormDesign.inputDecoration(
            context,
            label: descriptors.label,
            actionBuilder: fieldState.value!.isEmpty ? null : actionBuilder,
          ),
          child: Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              controller: state.scrollController,
              child: Align(
                alignment: Alignment.topLeft,
                child: Wrap(
                  key: state.wrapKey,
                  spacing: 1,
                  runSpacing: 1,
                  children: [
                    ...fieldState.value!.map(
                      (e) => Theme(
                        data: Theme.of(context).copyWith(
                          chipTheme: const ChipThemeData(side: BorderSide.none),
                          canvasColor: Colors.transparent,
                        ),
                        child: Chip(
                          label: Text(descriptors.labelBuilder(e)),
                          onDeleted: () {
                            fieldState.value!.remove(e);
                            onRefresh();
                          },
                        ),
                      ),
                    ),
                    SearchAnchor(
                      searchController: state.searchController,
                      isFullScreen: false,
                      viewBackgroundColor: Theme.of(
                        context,
                      ).colorScheme.surface,
                      suggestionsBuilder: (context, controller) {
                        return suggestionsBuilder(
                          context,
                          suggestions: descriptors.suggestionsAvailable
                              .excludeByLabel(
                                fieldState.value!,
                                descriptors.labelBuilder,
                              )
                              .toList(),
                          controller: controller,
                          labelBuilder: descriptors.labelBuilder,
                          fieldState: fieldState,
                        );
                      },
                      builder: (context, controller) {
                        return Theme(
                          data: Theme.of(
                            context,
                          ).copyWith(canvasColor: Colors.transparent),
                          child: ActionChip(
                            avatar: clIcons.insertItem.iconFormatted(),
                            label: Text(
                              fieldState.value!.isEmpty ? 'Add' : 'Add',
                            ),
                            onPressed: controller.openView,
                            shape: const ContinuousRectangleBorder(
                              side: BorderSide(),
                              borderRadius: BorderRadius.all(
                                Radius.circular(16),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  FutureOr<Iterable<Widget>> suggestionsBuilder(
    BuildContext context, {
    required SearchController controller,
    required String Function(Object e) labelBuilder,
    String Function(Object e)? descriptionBuilder,
    List<Object>? suggestions,
    required FormFieldState<List<Object>> fieldState,
  }) {
    final List<Object>? filterredSuggestion;
    final controllerText = controller.text.trim();
    if (controllerText.isEmpty) {
      filterredSuggestion = suggestions;
    } else {
      filterredSuggestion = suggestions
          ?.where((element) => labelBuilder(element).contains(controllerText))
          .toList();
    }

    final list =
        filterredSuggestion?.map<Widget>((e) {
          final description = descriptionBuilder?.call(e);
          return ListTile(
            title: Text(labelBuilder(e)),
            subtitle: description == null ? null : Text(description),
            onTap: () {
              controller.closeView(controllerText);
              _onSelect(fieldState, e, onRefresh);
            },
          );
        }).toList() ??
        [];

    if (controllerText.isNotEmpty) {
      final c = suggestions?.getByLabel(controllerText, labelBuilder);

      if (c == null) {
        list.add(
          ListTile(
            title: Text('Create "$controllerText"'),
            onTap: () {
              if (controllerText.isNotEmpty) {
                controller.closeView(controllerText);

                final c = suggestions?.getByLabel(controllerText, labelBuilder);
                if (c == null) {
                  _onCreateByLabel(fieldState, controllerText, onRefresh);
                } else {
                  _onSelect(fieldState, c, onRefresh);
                }
              }
            },
          ),
        );
      }
    }
    return list..add(
      ListTile(
        title: SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
      ),
    );
  }

  Future<void> _onSelect(
    FormFieldState<List<Object>> fieldState,
    Object item,
    void Function() onRefresh,
  ) async {
    final entityUpdated = await descriptors.onSelectSuggestion(item);
    if (entityUpdated == null) return;
    state.searchController.text = '';
    fieldState.didChange([...fieldState.value!, entityUpdated]);
    onRefresh();
    Future.delayed(const Duration(milliseconds: 200), state.scrollToEnd);
  }

  Future<void> _onCreateByLabel(
    FormFieldState<List<Object>> fieldState,
    String label,
    void Function() onRefresh,
  ) async {
    final entityUpdated = await descriptors.onCreateByLabel(label);
    if (entityUpdated == null) return;
    state.searchController.text = '';
    fieldState.didChange([...fieldState.value!, entityUpdated]);
    onRefresh();
    Future.delayed(const Duration(milliseconds: 200), state.scrollToEnd);
  }
}
