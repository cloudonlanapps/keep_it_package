import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

/// Abstract base class for service location configurations.
///
/// A service location represents WHERE services are available (local or remote).
/// This is separate from the actual store implementation (WHAT stores data).
@immutable
abstract class ServiceLocationConfig
    implements Comparable<ServiceLocationConfig> {
  const ServiceLocationConfig({required this.identity, this.label});

  /// Identity for the service location (e.g., 'repo.identifier.cloudonlanapps')
  final String identity;

  /// Optional user-friendly label for the service location
  final String? label;

  /// Whether this service location is local (filesystem) or remote (server)
  bool get isLocal;

  /// Display name computed from identity or label
  String get displayName => label ?? identity.capitalizeFirstLetter();

  /// Serialize to map for storage/transmission
  Map<String, dynamic> toMap();

  @override
  int compareTo(ServiceLocationConfig other) {
    return identity.compareTo(other.identity);
  }
}

/// Registry of available service locations (local and remote).
///
/// Manages the list of available service locations and tracks which one is currently active.
@immutable
class RegisteredServiceLocations {
  factory RegisteredServiceLocations({
    required List<ServiceLocationConfig> availableConfigs,
    required int activeIndex,
  }) {
    if (availableConfigs.isEmpty) {
      throw Exception('At least one service location must be available');
    }
    return RegisteredServiceLocations._(
      availableConfigs: availableConfigs,
      activeIndex: activeIndex < availableConfigs.length ? activeIndex : 0,
    );
  }

  const RegisteredServiceLocations._({
    required this.availableConfigs,
    required this.activeIndex,
  });

  final List<ServiceLocationConfig> availableConfigs;
  final int activeIndex;

  RegisteredServiceLocations copyWith({
    List<ServiceLocationConfig>? availableConfigs,
    int? activeIndex,
  }) {
    return RegisteredServiceLocations._(
      availableConfigs: availableConfigs ?? this.availableConfigs,
      activeIndex: activeIndex ?? this.activeIndex,
    );
  }

  @override
  bool operator ==(covariant RegisteredServiceLocations other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return listEquals(other.availableConfigs, availableConfigs) &&
        other.activeIndex == activeIndex;
  }

  @override
  int get hashCode => availableConfigs.hashCode ^ activeIndex.hashCode;

  @override
  String toString() =>
      'RegisteredServiceLocations(availableConfigs: $availableConfigs, activeIndex: $activeIndex)';

  RegisteredServiceLocations setActiveConfig(ServiceLocationConfig config) {
    if (!availableConfigs.contains(config)) {
      throw Exception('Service location is not registered');
    }
    return copyWith(
      activeIndex: availableConfigs.indexWhere((e) => e == config),
    );
  }

  RegisteredServiceLocations addConfig(ServiceLocationConfig config) {
    if (availableConfigs.contains(config)) {
      throw Exception('Service location already exists');
    }
    final configs = List<ServiceLocationConfig>.from(availableConfigs)
      ..add(config);

    final index = configs.indexWhere((e) => e == config);
    return copyWith(availableConfigs: configs, activeIndex: index);
  }

  RegisteredServiceLocations removeConfig(ServiceLocationConfig config) {
    if (!availableConfigs.contains(config)) {
      throw Exception('Service location is not registered');
    }
    if (isDefaultConfig(config)) {
      throw Exception("Default service location can't be removed");
    }
    final index = (isActiveConfig(config)) ? 0 : activeIndex;

    final configs = List<ServiceLocationConfig>.from(availableConfigs)
      ..remove(config);
    return copyWith(availableConfigs: configs, activeIndex: index);
  }

  bool isDefaultConfig(ServiceLocationConfig config) {
    return config == defaultConfig;
  }

  bool isActiveConfig(ServiceLocationConfig config) {
    return config == availableConfigs[activeIndex];
  }

  ServiceLocationConfig get activeConfig => availableConfigs[activeIndex];
  ServiceLocationConfig get defaultConfig => availableConfigs[0];

  List<ServiceLocationConfig> get remoteConfigs =>
      availableConfigs.where((element) {
        return !element.isLocal;
      }).toList();

  List<ServiceLocationConfig> get localConfigs =>
      availableConfigs.where((element) {
        return element.isLocal;
      }).toList();
}
