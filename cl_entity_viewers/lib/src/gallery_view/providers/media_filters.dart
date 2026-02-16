import 'package:cl_basic_types/viewer_types.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/filter/base_filter.dart';
import '../models/filter/ddmmyyyy_filter.dart';
import '../models/filter/enum_filter.dart';
import '../models/filter/string_filter.dart';
import '../models/filter/filters.dart';

class MediaFiltersNotifier extends StateNotifier<SearchFilters<ViewerEntity>> {
  MediaFiltersNotifier()
      : super(
          SearchFilters(
            defaultTextSearchFilter: textSearchFilter,
            filters: List.from(allFilters),
          ),
        );

  void toggleEdit() => state = state.toggleEdit();

  void enableEdit() => state = state.enableEdit();
  void disableEdit() => state = state.disableEdit();

  void updateFilter(
    CLFilter<ViewerEntity> filter,
    String key,
    dynamic value,
  ) =>
      state = state.updateFilter(filter.name, key, value);

  void updateDefautTextSearchFilter(
    String query,
  ) {
    state = state.copyWith(
      defaultTextSearchFilter:
          state.defaultTextSearchFilter.update('query', query),
    );
  }

  /* void addFilter(CLFilter<CLMedia> filter) => state = state.addFilter(filter);

  void removeFilter(CLFilter<CLMedia> filter) =>
      state = state.removeFilter(filter.name); */
  void clearFilters() => state = state.clearFilters();

  List<String> get availableFilters {
    return state.filters?.map((e) => e.name).toList() ?? [];
  }

  Map<String, CLFilter<ViewerEntity>> get unusedFiltersMap => Map.fromEntries(
        allFiltersMap.entries
            .where((entry) => !availableFilters.contains(entry.key)),
      );

  List<CLFilter<ViewerEntity>> get unusedFilters => List.from(
        allFilters.where((e) => !availableFilters.contains(e.name)),
      );
}

final mediaFiltersProvider =
    StateNotifierProvider<MediaFiltersNotifier, SearchFilters<ViewerEntity>>(
        (ref) {
  return MediaFiltersNotifier();
});

final List<CLFilter<ViewerEntity>> allFilters = List.unmodifiable([
  EnumFilter<ViewerEntity, CLMediaType>(
    name: 'Search By MediaType',
    labels: {
      for (var e in [CLMediaType.image, CLMediaType.video]) e: e.name,
    },
    fieldSelector: (media) => media.mediaType,
    isByPassed: (media) => media.isCollection,
    enabled: true,
  ),
  EnumFilter<ViewerEntity, MediaAvailability>(
    name: 'Search By Location',
    labels: {
      for (var e in MediaAvailability.values) e: e.name,
    },
    fieldSelector: (media) {
      return MediaAvailability.local;
    },
    isByPassed: (media) => media.isCollection,
    enabled: true,
  ),
  DDMMYYYYFilter<ViewerEntity>(
    name: 'Search by Date',
    fieldSelector: (media) => media.createDate ?? media.updatedDate,
    isByPassed: (media) => media.isCollection,
    enabled: false,
  ),
]);

Map<String, CLFilter<ViewerEntity>> get allFiltersMap =>
    Map.unmodifiable({for (final e in allFilters) e.name: e});

final StringFilter<ViewerEntity> textSearchFilter = StringFilter(
  name: 'TextSearch',
  fieldSelector: (media) => media.searchableTexts,
  isByPassed: (media) => media.isCollection,
  query: '',
  enabled: true,
);

final filterredMediaProvider =
    StateProvider.family<ViewerEntities, ViewerEntities>((ref, entities) {
  final mediaFilters = ref.watch(mediaFiltersProvider);
  return ViewerEntities(mediaFilters.apply(entities.entities));
});
