import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

final targetStoreProvider = StateProvider<CLStore>((ref) {
  throw Exception('Must be overridden');
});
