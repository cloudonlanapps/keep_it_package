import 'dart:async';

import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../../models/cl_media_candidate.dart';
import '../../store_tasks_service/store_tasks_service.dart';
import '../basic_page_service/widgets/cl_error_view.dart';
import '../basic_page_service/widgets/fullscreen_layout.dart';
import '../basic_page_service/widgets/page_manager.dart';
import 'widgets/step1_analyse.dart';
import 'widgets/step2_duplicates.dart';

class IncomingMediaHandler extends ConsumerStatefulWidget {
  const IncomingMediaHandler({
    required this.incomingMedia,
    required this.onDiscard,
    super.key,
  });

  final CLMediaFileGroup incomingMedia;
  final void Function({required bool result}) onDiscard;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      IncomingMediaHandlerState();
}

class IncomingMediaHandlerState extends ConsumerState<IncomingMediaHandler> {
  ViewerEntities? duplicateCandidates;
  ViewerEntities? newCandidates;

  bool isSaving = false;
  @override
  void didChangeDependencies() {
    duplicateCandidates = null;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final label = widget.incomingMedia.contentOrigin.label;
    return FullscreenLayout(
      child: GetDefaultStore(
        errorBuilder: (e, st) => WizardLayout(
          title: '$label Error',
          onCancel: () => widget.onDiscard(result: false),
          child: CLErrorView(errorMessage: e.toString()),
        ),
        loadingBuilder: () => WizardLayout(
          title: label,
          onCancel: () => widget.onDiscard(result: false),
          child: CLLoader.widget(debugMessage: null),
        ),
        builder: (store) {
          return GetStoreTaskManager(
            contentOrigin: widget.incomingMedia.contentOrigin,
            builder: (taskManager) {
              _infoLogger(
                'build candidate: $duplicateCandidates, isSaving:$isSaving',
              );
              _infoLogger('incoming Media: ${widget.incomingMedia}');
              final Widget widget0;
              try {
                widget0 = isSaving
                    ? const Center(child: CircularProgressIndicator())
                    : (duplicateCandidates == null)
                    ? AnalysePage(
                        store: store,
                        // Hide the Collection from Analysis so that all goes into default
                        incomingMedia: CLMediaFileGroup(
                          entries: widget.incomingMedia.entries,
                          contentOrigin: widget.incomingMedia.contentOrigin,
                        ),
                        onDone:
                            ({
                              required existingEntities,
                              required invalidContent,
                              required newEntities,
                            }) => segretated(
                              storeTaskManager: taskManager,
                              existingEntities: existingEntities,
                              newEntities: newEntities,
                              invalidContent: invalidContent,
                            ),
                        onCancel: () => onDiscard(result: false),
                      )
                    : DuplicatePage(
                        incomingMedia: duplicateCandidates!,
                        parentId: widget.incomingMedia.collection?.id,
                        onDone: ({required mg}) {
                          unawaited(
                            onSave(
                              storeTaskManager: taskManager,
                              mg: ViewerEntities([
                                ...mg?.entities ?? [],
                                ...newCandidates?.entities ?? [],
                              ]),
                            ),
                          );
                        },
                        onCancel: () => onDiscard(result: false),
                      );
              } catch (e) {
                return CLErrorView(errorMessage: e.toString());
              }
              _infoLogger('build IncomingMediaHandler - Done');
              return widget0;
            },
          );
        },
      ),
    );
  }

  bool get isSavingState => isSaving;

  set isSavingState(bool val) {
    isSaving = val;
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> segretated({
    required StoreTaskManager storeTaskManager,
    required ViewerEntities existingEntities,
    required ViewerEntities newEntities,
    required List<CLMediaContent> invalidContent,
  }) async {
    if (existingEntities
        .targetMismatch(widget.incomingMedia.collection?.id)
        .isNotEmpty) {
      duplicateCandidates = existingEntities;
      newCandidates = newEntities;
      setState(() {});
    } else {
      await onSave(
        storeTaskManager: storeTaskManager,
        mg: newEntities,
      );
    }
  }

  Future<void> onSave({
    required StoreTaskManager storeTaskManager,
    required ViewerEntities mg,
  }) async {
    _infoLogger(mg.toString());
    _infoLogger('onSave - Enter');
    isSavingState = true;
    widget.onDiscard(result: mg.isNotEmpty);

    storeTaskManager.add(
      StoreTask(
        items: mg.entities.cast<StoreEntity>(),
        contentOrigin: widget.incomingMedia.contentOrigin,
      ),
    );
    await PageManager.of(
      context,
    ).openWizard(widget.incomingMedia.contentOrigin);

    duplicateCandidates = null;
    newCandidates = null;

    isSavingState = false;
    _infoLogger('onSave - Return');
  }

  void onDiscard({required bool result}) {
    duplicateCandidates = null;
    _infoLogger('discard media');
    widget.onDiscard(result: result);
  }
}

bool _disableInfoLogger = true;
void _infoLogger(String msg) {
  if (!_disableInfoLogger) {
    logger.i('Incoming Media Handler: $msg');
  }
}
