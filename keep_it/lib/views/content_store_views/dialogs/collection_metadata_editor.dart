import 'dart:convert';

import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:cl_extensions/cl_extensions.dart' show UtilExtensionOnString;
import 'package:colan_services/content_store_service/content_store_service.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:store/store.dart';

class CollectionMetadataEditor extends StatefulWidget {
  factory CollectionMetadataEditor({
    required int? id,
    required void Function(StoreEntity collection) onSubmit,
    required void Function() onCancel,
    required CLStore? store,
    required String? suggestedLabel,
    required String? description,
    Key? key,
  }) {
    return CollectionMetadataEditor._(
      id: id,
      onSubmit: onSubmit,
      onCancel: onCancel,
      isDialog: false,
      key: key,
      store: store,
      suggestedLabel: suggestedLabel,
      description: description,
    );
  }
  factory CollectionMetadataEditor.dialog({
    required int? id,
    required void Function(StoreEntity collection) onSubmit,
    required void Function() onCancel,
    required CLStore? store,
    required String? suggestedLabel,
    required String? description,
    Key? key,
  }) {
    return CollectionMetadataEditor._(
      id: id,
      onSubmit: onSubmit,
      onCancel: onCancel,
      isDialog: true,
      key: key,
      store: store,
      suggestedLabel: suggestedLabel,
      description: description,
    );
  }
  const CollectionMetadataEditor._({
    required this.id,
    required this.isDialog,
    required this.onSubmit,
    required this.onCancel,
    required this.store,
    required this.suggestedLabel,
    required this.description,
    super.key,
  });

  final int? id;

  final void Function(StoreEntity collection) onSubmit;
  final void Function() onCancel;
  final bool isDialog;
  final CLStore? store;
  final String? suggestedLabel;
  final String? description;

  @override
  State<CollectionMetadataEditor> createState() =>
      _CollectionMetadataEditorState();

  static Future<StoreEntity?> openSheet(
    BuildContext context, {
    required StoreEntity? collection,
    required CLStore? store,
    required String? suggestedLabel,
    required String? description,
  }) async {
    // Store is ignored if a  collection is provided.
    // Store from collection is used instead
    return showShadSheet<StoreEntity>(
      context: context,
      builder: (context) => CollectionMetadataEditor.dialog(
        id: collection?.id,
        onSubmit: (collection) {
          Navigator.of(context).pop(collection);
        },
        onCancel: () => Navigator.of(context).pop(),
        store: collection?.store ?? store,
        suggestedLabel: suggestedLabel,
        description: description,
      ),
    );
  }
}

class _CollectionMetadataEditorState extends State<CollectionMetadataEditor> {
  final formKey = GlobalKey<ShadFormState>();
  Map<Object, dynamic> formValue = {};
  late final FocusNode focusNode;
  late final FocusNode focusNode2;

  @override
  void initState() {
    focusNode = FocusNode();
    focusNode2 = FocusNode();
    focusNode.addListener(focusNode1Listener);
    focusNode2.addListener(focusNode1Listener);
    super.initState();
  }

  void focusNode1Listener() {
    if (!focusNode.hasFocus && !focusNode2.hasFocus) {
      formKey.currentState?.validate(focusOnInvalid: false);
    } else {
      formKey.currentState?.reset();
    }
  }

  @override
  void dispose() {
    focusNode.dispose();
    focusNode2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: GetEntity(
        id: widget.id,
        errorBuilder: (e, st) => CLErrorView.local(
          message: 'Error loading collection',
          details: e.toString(),
        ),
        loadingBuilder: () => const CLLoadingView.local(
          debugMessage: 'GetCollection',
          message: 'Loading Collection ',
        ),
        builder: (collection) {
          return GetEntities(
            store: widget.store,
            isHidden: null,
            isDeleted: null,
            isCollection: true,
            errorBuilder: (e, st) => CLErrorView.local(
              message: 'Error loading all collections',
              details: e.toString(),
            ),
            loadingBuilder: () => const CLLoadingView.local(
              debugMessage: 'GetAllCollection',
              message: 'Loading Collection ',
            ),
            builder: (allCollections, {onLoadMore}) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: ShadSheet(
                  draggable: true,
                  title: Text(
                    collection == null
                        ? 'Create Collection'
                        : 'Edit Collection "${collection.label!.capitalizeFirstLetter()}"',
                  ),
                  description: const Text(
                    'Change the label and add/update description here',
                  ),
                  actions: [
                    ShadButton(
                      child: const Text('Save changes'),
                      onPressed: () async {
                        if (formKey.currentState!.saveAndValidate()) {
                          formValue = formKey.currentState!.value;
                          final label = formValue['label'] as String;
                          final desc = formValue['description'] as String?;
                          final StoreEntity? updated;
                          if (collection != null) {
                            updated = await collection.updateWith(
                              label: () => label,
                              description: () => desc == null
                                  ? null
                                  : desc.isEmpty
                                  ? null
                                  : desc,
                            );
                          } else {
                            updated = await widget.store?.createCollection(
                              label: label,
                              description: () => desc,
                            );
                          }
                          if (updated == null) {
                            throw Exception('update failed');
                          }

                          widget.onSubmit(updated);
                        }
                      },
                    ),
                  ],
                  child: ShadForm(
                    key: formKey,
                    autovalidateMode: ShadAutovalidateMode.disabled,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 8,
                      children: [
                        ShadInputFormField(
                          id: 'label',
                          // prefix: const Icon(LucideIcons.tag),
                          label: const Text(' Collection Name'),
                          initialValue:
                              widget.suggestedLabel ?? collection?.label,
                          placeholder: const Text('Enter collection name'),
                          validator: (value) => validateName(
                            newLabel: value,
                            existingLabel: collection?.label,
                            collections: allCollections,
                          ),
                          showCursor: true,
                          inputFormatters: [
                            FilteringTextInputFormatter.deny(RegExp(r'\n')),
                          ],
                          focusNode: focusNode,
                        ),
                        ShadInputFormField(
                          id: 'description',
                          // prefix: const Icon(LucideIcons.tag),
                          label: const Text(' About'),
                          initialValue:
                              widget.description ?? collection?.description,
                          placeholder: const Text(
                            'Describe about this collection',
                          ),
                          maxLines: 4,
                          focusNode: focusNode2,
                        ),
                        if (formValue.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 24, left: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('FormValue', style: theme.textTheme.p),
                                const SizedBox(height: 4),
                                SelectableText(
                                  const JsonEncoder.withIndent(
                                    '    ',
                                  ).convert(formValue),
                                  style: theme.textTheme.small,
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String? validateName({
    required String? newLabel,
    required String? existingLabel,
    required ViewerEntities collections,
  }) {
    final newLabel0 = newLabel?.trim();

    if (newLabel0 == null) {
      return "Name can't be empty";
    } else {
      if (newLabel0.isEmpty) {
        return "Name can't be empty";
      }
      if (existingLabel?.trim().toLowerCase() == newLabel0.toLowerCase()) {
        // Nothing changed.
        return null;
      }
      if (collections.entities
          .cast<StoreEntity>()
          .map((e) => e.label!.trim().toLowerCase())
          .contains(newLabel0.toLowerCase())) {
        return '$newLabel0 already exists';
      }
    }
    return null;
  }
}
